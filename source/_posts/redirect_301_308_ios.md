title: 301 重定向踩坑：POST 变 GET、Authorization 头丢失与 WebSocket 失联
date: 2026-04-20
tags: [http, ios, redirect, websocket, networking]
---

用 Cloudflare 规则把国内流量从主域名重定向到镜像节点，是一种常见的分流方案。我们最近就遇到了这种配置下的三个连锁 bug，现象是国内用户登录失败、登录后立刻掉线、WebSocket 静默断连。本文把整个排查和修复过程记录下来。

<!--more-->

## 背景

我们有一个移动端 App，海外用户访问主域名，国内用户需要走镜像节点以改善网络质量。Cloudflare 配了一条规则：匹配国内 IP 时，将请求从主域名 301 重定向到镜像域名。

上线之后，国内用户反映登录失败。

---

## 问题一：301 让 POST 变成了 GET

### 现象

App 向 `/api/v1/signin` POST 登录凭据，服务端收到的是一个 GET 请求，路由器找不到对应的 GET handler，返回 `404 page not found`。

### 原因

HTTP 规范对 301/302 的规定存在一个历史遗留问题：**规范允许客户端在跟随 301/302 重定向时，将 POST 降级为 GET**。这原本是为了兼容早期浏览器表单提交的行为，但导致的结果是重定向后请求方法变了、请求体也丢了。

iOS 的 `URLSession` 严格遵循这一行为：遇到 301，POST 请求会被改写为 GET，body 被丢弃。

```
[iOS App]
  POST /api/v1/signin  →  主域名
  ← 301 Location: 镜像域名/api/v1/signin
  GET /api/v1/signin   →  镜像域名     ← body 丢了
  ← 404 page not found
```

### 修复：301 → 308

HTTP/1.1 引入了 **308 Permanent Redirect**，语义与 301 完全相同（永久重定向，客户端应更新书签），但明确规定**重定向时必须保持原始请求方法和请求体**。将 Cloudflare 规则改为 308 后，POST 请求就能完整地到达镜像节点的真实 handler。

```
[iOS App]
  POST /api/v1/signin  →  主域名
  ← 308 Location: 镜像域名/api/v1/signin
  POST /api/v1/signin  →  镜像域名     ← body 保留
  ← 200 OK
```

几个重定向状态码的方法保持行为对比：

| 状态码 | 类型 | 方法保持 | 适用场景 |
|---|---|---|---|
| 301 | 永久 | 不保证（实践中 POST→GET） | 浏览器 GET 跳转 |
| 302 | 临时 | 不保证（实践中 POST→GET） | 浏览器 GET 跳转 |
| 307 | 临时 | 保证 | API 临时重定向 |
| 308 | 永久 | 保证 | API 永久重定向 |

---

## 问题二：跨域重定向导致 Authorization 头被丢弃

### 现象

改成 308 后，登录本身成功了，但随后的业务请求（如 `GET /api/v1/agent`）返回 401，App 判断 session 失效，自动跳回登录页——用户刚登上就被踢了出去。

### 原因

iOS 的 `URLSession` 有一条安全策略：**跟随重定向时，如果目标 URL 的 origin 与原始请求不同，则自动去掉 `Authorization` 头**。

我们的主域名和镜像域名是两个不同的域，属于跨 origin 跳转。于是每一个带 `Authorization: Bearer <token>` 的请求，在跟随 308 到达镜像节点时，都已经没有了认证头，收到的全是 401。

```
[iOS App]
  GET /api/v1/agent
  Authorization: Bearer <token>
  →  主域名
  ← 308 Location: 镜像域名/api/v1/agent

  GET /api/v1/agent
  (Authorization 头被 iOS 丢弃)
  →  镜像域名
  ← 401 Unauthorized
```

这是 iOS 的安全机制，防止认证凭据泄露到意料之外的服务器，本身是合理的设计。

### 修复：客户端 Origin Pinning（源地址固定）

既然跨 origin 跳转会丢头，那就让请求不再跨 origin——在第一次成功完成重定向后，客户端记住镜像节点的 origin，后续请求直接发到这个地址，不再经过 Cloudflare 的重定向。

实现逻辑：

1. 正常发出请求到主域名
2. 如果响应经过了重定向，记录最终落地的 origin（即镜像节点地址）
3. 将这个 origin 持久化到本地（随 session 保留）
4. 后续所有请求直接发往固定的 origin，完全绕开重定向链路

```
首次请求：
  POST /api/v1/signin → 主域名
  ← 308 → 镜像域名
  POST 直达镜像域名（308 body 保留）
  ← 200，记录 origin = 镜像域名

后续请求：
  GET /api/v1/agent
  Authorization: Bearer <token>
  → 镜像域名（直连，无跳转）
  ← 200
```

另外加了自愈逻辑：如果直连镜像节点发生网络错误（连接超时、DNS 失败等），则清除缓存的 origin，下次请求重新走 Cloudflare 探测。这样在镜像节点发生故障时，App 能自动重新发现可用节点，而不是一直打到一个已下线的地址。

---

## 附带修复：WebSocket 本就无法跟随重定向

修了 origin pinning 之后，国内用户的 WebSocket 连接问题也顺带解决了。

WebSocket 的建立过程是先发一个 HTTP Upgrade 请求，期望服务器返回 `101 Switching Protocols`。如果服务器返回的是 301 或 308，客户端不知道如何处理——`101` 是它唯一能接受的成功响应，重定向响应会导致握手失败，连接静默建立不了。

原本国内用户的 WS 连接一直是静默失败的，只是没有被明显的报错暴露出来。有了 origin pinning 之后，WS 也直连到了镜像节点，不再经过那条会返回 308 的 Cloudflare 规则，握手自然就成功了。

---

## 小结

这次的问题是三个 bug 叠加在一起，但根源都来自同一条配置——用 301 做 API 流量重定向：

| 问题 | 根因 | 修复 |
|---|---|---|
| POST 登录 404 | 301 允许 POST→GET 降级 | 改为 308（方法保持型重定向） |
| 登录后立刻 401 | iOS 跨 origin 跳转丢 Authorization 头 | 客户端 origin pinning，直连镜像节点 |
| WebSocket 静默断连 | WS 握手不支持跟随重定向 | origin pinning 使 WS 直连，无需跳转 |

对于面向 API 客户端（而非浏览器）的重定向，需要注意：
- 用 307/308 代替 301/302，避免方法被改写
- 跨域重定向会触发 iOS 等客户端的安全策略，认证头会被剥离
- WebSocket 的 Upgrade 握手不支持跟随任何形式的重定向

---

## 参考

- [RFC 7238 - 308 Permanent Redirect](https://datatracker.ietf.org/doc/html/rfc7238)
- [RFC 9110 - HTTP Semantics: Redirects](https://datatracker.ietf.org/doc/html/rfc9110#section-15.4)
- [WebSocket RFC 6455 - Opening Handshake](https://datatracker.ietf.org/doc/html/rfc6455#section-4)
