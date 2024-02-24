title: Rails 的 config.hosts 配置深入解析
date: 2024-02-24

tags: [rails]
---

在 Rails 应用程序中，`config.hosts` 是一个安全特性，用于防范针对网站的 Host 头攻击。这种攻击是通过修改 HTTP 请求的 Host 头来尝试欺骗服务器，使之认为请求来自不同的源。通过恰当配置 `config.hosts`，开发者可以明确指定哪些主机名是被允许的，从而增强应用的安全性。

<!--more-->

## 为什么需要 config.hosts？

在互联网上，DNS 重绑定攻击和其他基于 Host 头的攻击手段可以使攻击者绕过某些安全措施，如同源策略（SOP）。为了缓解这些风险，Rails 引入了 `config.hosts` 配置。当启用时，Rails 会校验进来的请求的 Host 头，如果不匹配配置中指定的任何一个主机名，Rails 会拒绝该请求。

## 如何配置 config.hosts？

在 Rails 应用中配置 `config.hosts` 通常在 `config/environments` 文件夹下的环境配置文件中进行，如 `development.rb`、`production.rb` 等。

### 示例

假设你有一个在 `example.com` 域名下运行的 Rails 应用，你可以如下配置 `config.hosts`：

```ruby
# config/environments/production.rb
Rails.application.config.hosts << "example.com"
```

这会使得只有 `example.com` 域名下的请求被允许。

### 允许多个主机名

你可以通过添加多个条目来允许多个主机名：

```ruby
Rails.application.config.hosts += ["example.com", "www.example.com", "api.example.com"]
```

### 使用正则表达式

如果你需要允许一组主机名，可以使用正则表达式：

```ruby
Rails.application.config.hosts << /.*\.example\.com/
```

这样，任何以 `.example.com` 结尾的域名都将被允许。

### 允许所有主机名

在某些场景下，如开发环境，你可能希望允许所有主机名。这可以通过清空 `config.hosts` 数组来实现：

```ruby
Rails.application.config.hosts.clear
```

或者使用通配符：

```ruby
Rails.application.config.hosts << nil
```
