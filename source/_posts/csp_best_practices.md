title: Content Security Policy 最佳实践：从 allowlist 到 Strict CSP
date: 2026-05-22
tags: [security, csp, xss, javascript, http]
---

CSP（Content Security Policy）是防御 XSS 的最后一道浏览器级防线，但大多数项目的 CSP 配置形同虚设——allowlist 方式的 `script-src` 可以被多种手段绕过，保护的是一个不存在的威胁模型。本文从"为什么 allowlist 不管用"讲起，给出现在真正有效的配置方案。

<!--more-->

## 为什么 allowlist 方式的 CSP 是有缺陷的

常见的 CSP 配置长这样：

```
Content-Security-Policy: script-src 'self' https://cdn.jsdelivr.net https://www.googletagmanager.com;
```

看起来只允许自己的域和几个可信 CDN，实际上攻击面很大：

**CDN JSONP 端点**。很多 CDN 或第三方服务提供 JSONP 接口，格式类似 `https://cdn.example.com/api?callback=alert`。如果 `cdn.example.com` 在白名单里，攻击者可以直接注入 `<script src="https://cdn.example.com/api?callback=攻击代码">`，绕过 CSP。

**Script gadgets**。Angular、React、Vue 等框架的 CDN 版本存在已知的"gadget"——框架本身的模板语法或 API 可以被攻击者利用来执行任意代码，只需要能注入一段 HTML 属性。能注入 `ng-init="..."` 就能在允许加载 AngularJS（1.x）CDN 的页面上执行代码。

**子域名接管**。白名单里的 `*.example.com` 中，一旦任何子域名发生 DNS 接管或被攻陷，整条 CSP 就失效了。

Google 的 CSP Evaluator 检测过大量真实站点的 CSP 配置，结论是：**大多数基于 allowlist 的 script-src 都存在已知绕过**。

---

## Strict CSP：基于 nonce 的方案

现在推荐的做法叫 **Strict CSP**，核心是用 nonce 代替域名白名单：

```
Content-Security-Policy:
  script-src 'nonce-{RANDOM_BASE64}' 'strict-dynamic';
  object-src 'none';
  base-uri 'none';
```

### Nonce

每次 HTTP 响应，服务端生成一个随机值（至少 128 位，base64 编码），同时注入到响应头和所有合法的 `<script>` 标签：

```html
<!-- 服务端渲染时注入 nonce -->
<script nonce="r4nd0mV4lu3A==">
  // 这段脚本被允许执行
</script>

<script>
  // 没有匹配 nonce，被阻止
</script>
```

攻击者注入的 `<script>` 没有 nonce，浏览器拒绝执行。即使攻击者能读取页面 HTML，nonce 每次请求都不同，无法复用。

**生成示例（各语言）：**

```python
# Python
import secrets, base64
nonce = base64.b64encode(secrets.token_bytes(16)).decode()
```

```go
// Go
b := make([]byte, 16)
rand.Read(b)
nonce := base64.StdEncoding.EncodeToString(b)
```

```ruby
# Ruby
nonce = SecureRandom.base64(16)
```

### strict-dynamic

`'strict-dynamic'` 解决了一个实际问题：现代前端应用经常在运行时动态加载脚本（`document.createElement('script')`、`import()`），这些动态加载的脚本不带 nonce。

`'strict-dynamic'` 的语义是：**持有合法 nonce 或 hash 的脚本，可以加载任意其他脚本，这些脚本同样被信任**。

```
script-src 'nonce-ABC' 'strict-dynamic'
```

- 带 `nonce="ABC"` 的 `<script>` 被允许执行。
- 该脚本动态创建的 `<script>` 同样被允许。
- 攻击者直接注入的 `<script src="evil.js">` 没有 nonce，被阻止——`strict-dynamic` 不信任 HTML 里直接出现的脚本，只信任"被受信任脚本创建的脚本"。

有了 `strict-dynamic`，白名单域名就不再需要了——`'strict-dynamic'` 存在时，浏览器会忽略 `script-src` 里的域名和 `'unsafe-inline'`（除非配合 nonce/hash）。

### 完整的 Strict CSP 模板

```
Content-Security-Policy:
  script-src 'nonce-{RANDOM}' 'strict-dynamic' 'unsafe-inline' https:;
  object-src 'none';
  base-uri 'none';
```

`'unsafe-inline'` 和 `https:` 是为了兼容不支持 nonce 的旧浏览器（IE、旧版 Safari）——当 nonce 存在时，现代浏览器会忽略 `'unsafe-inline'`，所以加上它不影响安全性，只是保持旧浏览器的兼容。

---

## Hash-based CSP：静态场景的替代方案

如果没有服务端渲染（纯静态站、CDN 托管），无法每次请求生成新 nonce，可以用 hash：

```
Content-Security-Policy:
  script-src 'sha256-{HASH_OF_INLINE_SCRIPT}' 'strict-dynamic';
  object-src 'none';
  base-uri 'none';
```

Hash 是对 `<script>` 标签内容（不含标签本身）计算的 SHA-256/384/512 摘要，base64 编码后写入 CSP 头。

```bash
# 计算内联脚本的 sha256
echo -n 'console.log("hello")' | openssl dgst -sha256 -binary | base64
```

每次脚本内容变更，hash 就要更新。适合内联脚本很少且不频繁变化的场景。

外部脚本（`<script src="...">`）在 CSP Level 2 里不能用 hash 保护，CSP Level 3 引入了对外部脚本的 hash 支持，但浏览器支持度仍有限。实践上，外部脚本要么用 nonce，要么配合 SRI（Subresource Integrity）。

---

## 其他关键 directive

### `object-src 'none'`

禁止 Flash、Java Applet 等插件。这些插件可以绕过 `script-src` 的限制执行代码，必须显式禁掉。

### `base-uri 'none'`

防止 `<base href="https://attacker.example/">` 注入。一旦 `<base>` 被改，页面上所有相对 URL（包括 `<script src="...">` 的相对路径）都会指向攻击者的域，即使 `script-src` 只允许 `'self'`。

### `frame-ancestors`

控制谁可以把当前页面嵌入 iframe，替代旧的 `X-Frame-Options` 头：

```
Content-Security-Policy: frame-ancestors 'none';
Content-Security-Policy: frame-ancestors 'self';
Content-Security-Policy: frame-ancestors https://parent.example.com;
```

`frame-ancestors` 和 `X-Frame-Options` 同时设置时，现代浏览器优先遵从 CSP。

### `form-action`

限制表单可以提交到哪些 URL，防止攻击者注入 `<form action="https://attacker.example">` 窃取用户输入：

```
Content-Security-Policy: form-action 'self';
```

注意：`default-src` 不覆盖 `form-action`，必须单独设置。

### `connect-src`

限制 `fetch`、`XMLHttpRequest`、WebSocket 可以连接的目标：

```
Content-Security-Policy: connect-src 'self' wss://your-ws-host.example.com;
```

这是阻断 XSS 到 C2 连接的关键——即使攻击者的脚本成功执行，`connect-src` 能阻止它建立 WebSocket 或 fetch 到外部服务器。

---

## Trusted Types：进阶防御

Trusted Types 是 CSP Level 3 引入的新 API，目标是在 DOM 操作层面阻断 XSS，而不只是控制脚本来源。

```
Content-Security-Policy: require-trusted-types-for 'script';
```

开启后，以下危险 sink 不再接受普通字符串，包括 `innerHTML`、`outerHTML`、动态脚本加载等 API，必须传入对应的 `TrustedHTML`、`TrustedScript`、`TrustedScriptURL` 对象。这些对象只能通过显式注册的 policy 创建：

```js
const policy = trustedTypes.createPolicy('myPolicy', {
    createHTML: input => DOMPurify.sanitize(input),
});

element.innerHTML = policy.createHTML(userInput);   // OK，经过 sanitizer
element.innerHTML = userInput;                       // TypeError，直接拒绝
```

效果是把"HTML sanitization 必须执行"从开发约定变成了运行时强制——哪里忘了用 policy，运行时立刻报错，不会静默通过。这从根本上消灭了"某个地方漏掉了 sanitization"这类问题。

**浏览器支持**：Chrome/Edge 完整支持，Firefox 实验性支持（`dom.security.trusted_types.enabled`）。生产环境建议先用 `report-only` 观察违规。

---

## 部署策略：先 Report-Only，再 Enforce

直接上 enforce 模式很容易打断合法功能。正确做法是分两阶段：

**第一阶段：观察**

```
Content-Security-Policy-Report-Only:
  script-src 'nonce-{RANDOM}' 'strict-dynamic';
  object-src 'none';
  base-uri 'none';
  report-to csp-endpoint;
```

`Report-Only` 模式只记录违规，不阻止任何请求。

**配置 Reporting Endpoint：**

```http
Reporting-Endpoints: csp-endpoint="https://your-app.example.com/csp-report"
```

违规报告是 JSON POST，包含 `blockedURL`、`effectiveDirective`、`originalPolicy` 等字段，可以接到日志系统里分析。旧的 `report-uri` 已废弃，改用 `Reporting-Endpoints` + `report-to`。

**第二阶段：修复违规，切换为 Enforce**

把 `Content-Security-Policy-Report-Only` 改为 `Content-Security-Policy`，同时保留 `report-to`，持续监控生产环境的违规情况。

---

## 常见错误

| 错误 | 后果 |
|---|---|
| `script-src 'unsafe-inline'` 不配合 nonce | 允许所有内联脚本，CSP 对 XSS 完全无效 |
| `script-src 'unsafe-eval'` | 允许动态代码执行，大量 XSS 攻击可复用 |
| `script-src *` 或只写 `https:` | 允许加载任意 HTTPS 域的脚本，等于没有限制 |
| 有 `default-src` 但忘了 `object-src` | Flash/插件不受限 |
| 忘了 `base-uri` | `<base>` 注入可改变所有相对 URL 的指向 |
| 白名单里有 JSONP 端点 | 攻击者用 `?callback=` 参数执行任意代码 |
| 只用废弃的 `report-uri` | 新版浏览器逐步停止支持，应改用 `report-to` |

---

## 小结

| 方案 | 适用场景 | 核心配置 |
|---|---|---|
| Nonce-based Strict CSP | 有服务端渲染 | `'nonce-{RANDOM}' 'strict-dynamic'` |
| Hash-based Strict CSP | 静态站、纯前端 | `'sha256-{HASH}' 'strict-dynamic'` |
| Trusted Types | 进阶，消除 DOM XSS sink | `require-trusted-types-for 'script'` |

不管用哪种，`object-src 'none'` 和 `base-uri 'none'` 都是必配项，`connect-src`、`frame-ancestors`、`form-action` 视业务情况补充。

CSP 不是银弹——它防的是"脚本加载"，`connect-src` 才防"数据外泄"。但在 sanitization 失效的情况下，它是能阻断 XSS 到 C2 这整条链的最后防线。上一篇分析的那个 Stored XSS 案例里，一条 `script-src 'self'` 就能让整个攻击链失效。

---

## 参考

- [Mitigate cross-site scripting with a strict Content Security Policy — web.dev](https://web.dev/articles/strict-csp)
- [CSP Evaluator — Google](https://csp-evaluator.withgoogle.com/)
- [Content Security Policy Level 3 — W3C Working Draft](https://www.w3.org/TR/CSP3/)
- [Trusted Types — web.dev](https://web.dev/articles/trusted-types)
- [Reporting API — MDN](https://developer.mozilla.org/en-US/docs/Web/API/Reporting_API)
- [DOMPurify](https://github.com/cure53/DOMPurify)
