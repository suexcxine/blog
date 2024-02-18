title: 探索 js-cookie
date: 2024-02-18

tags: [js, cookie, web]
---

有了这个，前端处理 cookie 方便多了

<!--more-->

js-cookie 的工作机制基于浏览器的 cookie 管理功能，提供了一个简化的接口来创建、读取、修改和删除 cookies。它封装了原生 JavaScript 操作 cookies 的复杂性，使得在客户端与 cookies 交互变得更加直观和简单。下面，我们将详细探讨 js-cookie 的工作原理及其在浏览器中如何操作 cookies。

### 创建和设置 Cookies

当使用 js-cookie 的 `set` 函数创建或更新一个 cookie 时，库内部构建了一个符合 HTTP Cookie 标准的字符串，并通过 `document.cookie` 属性将其保存到浏览器中。这个字符串包括了 cookie 的名称、值，以及可选的属性如 `expires`、`path`、`domain`、`secure` 和 `SameSite`。例如：

```javascript
Cookies.set('name', 'value', { expires: 7, path: '/' });
```

此操作会创建一个名为 "name"、值为 "value" 的 cookie，它将在 7 天后过期，并且对整个站点可用。

### 读取 Cookies

当使用 `get` 函数读取一个 cookie 时，js-cookie 会解析 `document.cookie` 字符串，查找指定名称的 cookie，然后返回其值。如果指定的 cookie 不存在，则返回 `undefined`。`document.cookie` 属性包含了一个由分号分隔的 cookie 列表字符串，js-cookie 通过分析这个字符串来提取所需的 cookie 信息。

**注意**：在尝试读取一个特定的 cookie 时，无法通过传递一个 cookie 属性（比如 `domain`）来指定或过滤要读取的 cookie。

当你使用 `Cookies.get('foo')` 来读取一个名为 `foo` 的 cookie 时，你只能获取当前页面域中可见的 `foo` cookie。即使这个 cookie 在创建时指定了特定的 `domain` 或 `path` 属性，你也不能在 `Cookies.get` 方法中通过这些属性来影响或限定读取操作。换句话说，`domain`、`path` 等属性在写入 cookie 时起作用，用以限定 cookie 的发送范围，但在读取时，这些属性不会对 `Cookies.get` 方法的行为产生影响。

这个限制的原因在于浏览器的安全策略。浏览器出于安全考虑，限制了 JavaScript 脚本读取 cookie 的能力。一个脚本只能读取那些与当前页面相同域或子域下的 cookies，且不能跨域访问。因此，即使在设置 cookie 时可以指定 `domain` 和 `path` 来控制 cookie 的作用范围，读取操作的时候，这些属性是不起作用的，只有当前页面可见的 cookies 才能被读取。

这意味着，如果你想要从 JavaScript 中访问一个特定的 cookie，你需要确保你的代码在该 cookie 的作用域内执行。这也是为什么在使用 `Cookies.get` 方法时，不能通过属性如 `domain` 来过滤或指定想要读取的 cookie。

### 删除 Cookies

删除一个 cookie 实际上是通过设置该 cookie 的过期时间为过去的某个时间来实现的。js-cookie 的 `remove` 函数封装了这一操作：

```javascript
Cookies.remove('name');
```

这会将名为 "name" 的 cookie 的过期时间设置为过去的时间，从而导致浏览器在接下来的请求中自动移除它。

**注意**：这里必须与 `set` 时用完全相同的属性才删得掉，如
```
Cookies.set('name', 'value', { expires: 7, path: '/' });
Cookies.remove('name', { expires: 7, path: '/' });
```

### 编码和解码

js-cookie 自动处理 cookie 值的编码和解码，使用 `encodeURIComponent` 和 `decodeURIComponent` 函数。这意味着即使值中包含特殊字符（如分号、逗号或空白符），也能正确保存和读取 cookie。这样做的目的是为了确保 cookie 的名称和值在传输过程中不会破坏 HTTP 请求和响应的结构。

### 安全性

通过设置 `secure` 标志和 `SameSite` 属性，js-cookie 增强了 cookie 的安全性。`secure` 标志确保 cookie 仅通过 HTTPS 协议传输，防止通过监听 HTTP 流量来盗取 cookie。`SameSite` 属性可以设置为 `Strict`、`Lax` 或 `None`，以控制跨站点请求时 cookie 的发送行为，这有助于防止跨站点请求伪造 (CSRF) 攻击。

### 兼容性

js-cookie 旨在提供跨浏览器的兼容性，它透明地处理不同浏览器对 cookie 操作的细微差异，确保开发者的代码在不同环境中都能一致运行。
