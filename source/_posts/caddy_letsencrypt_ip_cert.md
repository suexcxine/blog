title: Caddy + Let's Encrypt：为 IP 地址自动签发并续期证书
date: 2026-05-01
tags: [caddy, letsencrypt, acme, tls, ssl, https]
---

Let's Encrypt 在 2026 年 1 月正式开放了 **IP 地址证书** 的公开签发能力，配合 Caddy 的 ACME 集成，可以做到给一个裸 IP 自动签发并自动续期 TLS 证书——无需第三方付费 CA，也无需手动操作。本文记录一下踩过的坑和最终能用的配置。

<!--more-->

## 背景：为什么 IP 证书一直是个麻烦

在 HTTPS 普及多年后，"为一个 IP 直接签 TLS 证书" 这件事一直是个相对小众的需求：

- 公开 CA（Let's Encrypt、Sectigo 等）长期以来不签发 IP 证书，理由是 IP 归属变化频繁、滥用风险高。
- 历史上能签 IP 证书的只有少数商业 CA，而且通常要求 **公网 IP + 域名 SOA 验证**，价格不便宜。
- ZeroSSL 是少数曾经支持 IP 证书的免费方案，但它的 ACME 集成体验一般，且对 IP 证书的支持时常变动。

但确实有合法场景必须用 IP 证书：比如内网服务通过裸 IP 暴露给客户端、CDN 回源使用 IP、客户端做 SNI 不便的场景。

## 变化：Let's Encrypt 在 2026 年开放 IP 证书

2026 年 1 月，Let's Encrypt 正式向所有用户开放了 **IP 地址 + 短期证书（short-lived certificates）** 的公开签发能力，目前的关键参数是：

- **有效期 6 天**（不是常规的 90 天）
- 必须使用 `shortlived` profile
- IP 证书 **不支持 TLS-ALPN-01 challenge**，必须用 HTTP-01

6 天有效期看起来很短，但只要 ACME 客户端可靠地自动续期，这反而比 90 天版本更"安全"——证书一旦泄漏，最长暴露窗口就 6 天。换句话说，**只要自动化续期靠谱，证书有效期就不再是用户该关心的事**。

Caddy 从 v2 开始就内建了完整的 ACME 客户端，对 issuer profile 和 challenge 类型的控制都暴露在 JSON 配置里，所以现在可以直接通过 Caddy 拿 IP 证书。

---

## 配置一：纯 IP 证书

最小可用的 Caddy JSON 配置，给一个裸 IP（这里用文档保留段 `1.2.3.4` 作为示例）签证书并反向代理到一个上游域名：

```json
{
  "apps": {
    "http": {
      "servers": {
        "srv0": {
          "listen": [":80", ":443", ":1024-1500"],
          "protocols": ["h1", "h2"],
          "routes": [{
            "match": [{"host": ["1.2.3.4"]}],
            "handle": [{
              "handler": "reverse_proxy",
              "headers": {
                "request": {
                  "set": {
                    "Host": ["yourhost.example.com"]
                  }
                }
              },
              "transport": {
                "protocol": "http",
                "tls": {}
              },
              "upstreams": [{"dial": "yourhost.example.com:443"}]
            }],
            "terminal": true
          }]
        }
      }
    },
    "tls": {
      "automation": {
        "policies": [{
          "subjects": ["1.2.3.4"],
          "issuers": [{
            "module": "acme",
            "profile": "shortlived",
            "challenges": {
              "tls-alpn": {"disabled": true}
            }
          }]
        }]
      }
    }
  }
}
```

几个关键点：

- `tls.automation.policies[].subjects` 显式列出 IP，告诉 Caddy "这个 IP 的证书走这条策略"。
- `issuers[].profile = "shortlived"` 指定使用 Let's Encrypt 的 6 天短证书 profile。**不指定的话默认走 90 天 profile，但 90 天 profile 目前不接受 IP 作为 subject，会签发失败。**
- `tls-alpn.disabled = true` 必须显式关闭 TLS-ALPN-01 挑战。Let's Encrypt 对 IP 证书目前只接受 HTTP-01，留着 TLS-ALPN-01 会让 Caddy 优先尝试该挑战然后失败。
- `transport.tls = {}` 让 Caddy 以 HTTPS 方式回源（上游是 `:443`）。同时通过 `Host` 头改写让上游基于域名做虚拟主机识别——这是反向代理 IP 入口的常见需求。

### 端口范围（port range）

注意 `listen` 字段里的 `":1024-1500"`：Caddy 的 JSON 配置 [支持端口范围语法](https://caddyserver.com/docs/json/apps/http/servers/)，省去手写 `":1024", ":1025", ..., ":1500"` 四百多个端口的麻烦。

这个特性在两种场景下特别实用：

1. 给一组业务端口统一加 TLS（比如游戏服务、TCP 多端口的私有协议）。
2. 反向代理一台后端机器上多个端口的 HTTP 服务，对外用同一个 IP 入口暴露。

需要注意的是，**端口范围会让 Caddy 在每个端口上都监听**——如果范围设得太大，会占用大量文件描述符。生产环境记得先 `ulimit -n` 检查一下进程的 fd 上限。

---

## 配置二：同时支持 IP 证书和域名证书（多租户/多种入口）

实际生产中经常需要 "同一台 Caddy 既给固定 IP 签证书，又按需给托管的客户域名签证书"。可以用两条策略配合 `on_demand` 实现：

```json
"tls": {
  "automation": {
    "on_demand": {
      "permission": {
        "endpoint": "https://your-permission-server.example.com/api/v1/caddy/ask?secret=YOUR_SECRET",
        "module": "http"
      }
    },
    "policies": [
      {
        "issuers": [
          {
            "challenges": {
              "tls-alpn": {
                "disabled": true
              }
            },
            "module": "acme",
            "profile": "shortlived"
          }
        ],
        "on_demand": false,
        "subjects": ["1.2.3.4"]
      },
      {
        "key_type": "p256",
        "on_demand": true
      }
    ]
  }
}
```

要点：

- **第一条策略** 显式锁定到固定 IP：`subjects = ["1.2.3.4"]`，`on_demand = false`，启动时就把这个 IP 的证书拿到，并定期续期。
- **第二条策略** 不写 `subjects`，开 `on_demand = true`，作为兜底——客户的任意域名第一次访问时，Caddy 才会触发 ACME 流程去拿证书。
- `on_demand.permission.endpoint` 是 **强烈建议** 配置的：这是一个由你自己实现的 HTTP 接口，Caddy 在签发任何 on-demand 证书前会先调用它确认 "这个域名是否允许签证书"。**不加这个保护的话，任何人把域名解析过来就能让你的 Caddy 触发签发**，很容易被滥用直到打到 Let's Encrypt 的 rate limit。
- 策略匹配是 **先匹配 subjects 显式列表，再 fallback 到通配策略**。

### permission endpoint 的最小实现

permission endpoint 收到 GET 请求带 `?domain=xxx`，根据情况返回 HTTP 200（允许）或非 200（拒绝）即可。最小实现就是查一下你的客户/租户表，确认这个域名在已注册列表里：

```
GET /api/v1/caddy/ask?domain=client123.example.com&secret=YOUR_SECRET
→ 200 OK   # 允许签发
→ 403 Forbidden  # 拒绝
```

记得校验 `secret` 参数，避免别人直接命中你的允许接口测域名是否被托管（虽然信息泄漏不严重，但能防就防）。

---

## 续期与运维

- Caddy 默认在证书有效期剩余 1/3 时触发续期，对应 6 天证书就是大约还剩 48 小时时续期。
- 续期失败会按指数退避重试，日志里会有 `renewing` / `obtained certificate` 的事件，运维上可以直接 grep `acme` 关键字。
- 6 天证书的续期频率高，如果有大量 IP/域名（百级以上），建议关注 Let's Encrypt 的 [rate limits](https://letsencrypt.org/docs/rate-limits/)，特别是 **每账号每小时新订单数**。
- IP 证书目前不支持通配符（这是规范层面的事，IP 地址本身没有"通配"概念）。

## 常见坑

1. **`profile` 没设或设错**：默认 profile 不接受 IP，签发会拿到类似 `unauthorized: IP not allowed for this profile` 的错误。改成 `shortlived` 即可。
2. **TLS-ALPN-01 没关**：Caddy 会优先尝试 ALPN 挑战，对 IP 证书会失败几次后才回退到 HTTP-01。显式 `disabled: true` 直接跳过这步，启动更快、日志更干净。
3. **80 端口被占**：HTTP-01 挑战需要 80 端口可达，如果机器上还有别的服务占着 80，Caddy 拿不到证书。可以让 Caddy 接管 80 然后把其他服务通过反向代理路由。
4. **IP 必须公网可达**：HTTP-01 的本质是 Let's Encrypt 服务器从公网访问目标 IP 的 80 端口验证 token，内网/防火墙后的 IP 拿不到 Let's Encrypt 公开 CA 的 IP 证书（这种场景应该用内部 CA）。
5. **反向 DNS 不影响**：和邮件服务器不同，IP 证书签发不要求 PTR 记录，只要 80 端口能访问就行。

---

## 小结

| 维度 | 旧方案（ZeroSSL / 商业 CA） | 新方案（Let's Encrypt + Caddy） |
|---|---|---|
| 是否免费 | 视 CA 而定 | 免费 |
| 证书有效期 | 通常 90 天 / 1 年 | 6 天 |
| 自动续期 | 需自行集成 ACME | Caddy 内建，零配置 |
| 配置复杂度 | 中到高 | 一段 JSON |
| 适用范围 | IP / 域名 | IP + 域名（同一份配置） |

**结论**：从 2026 年开始，单独为了 IP 证书去对接第三方付费CA已经没必要了。Caddy + Let's Encrypt + `shortlived` profile，是目前同时签发 IP 证书和域名证书最省心的方案，6 天有效期在自动续期面前不构成实际负担。

---

## 参考

- [Let's Encrypt: 6-Day and IP Address Certificates Now Available](https://letsencrypt.org/2026/01/15/6day-and-ip-general-availability)
- [Caddy JSON Config: HTTP Servers (port range)](https://caddyserver.com/docs/json/apps/http/servers/)
- [Caddy JSON Config: TLS Automation](https://caddyserver.com/docs/json/apps/tls/automation/)
- [Caddy On-Demand TLS](https://caddyserver.com/docs/automatic-https#on-demand-tls)
- [Let's Encrypt Rate Limits](https://letsencrypt.org/docs/rate-limits/)
