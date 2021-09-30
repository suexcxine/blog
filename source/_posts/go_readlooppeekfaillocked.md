title: readlooppeekfaillocked问题
date: 2021-09-30

tags: [go, http]
---

一位同事花了半个月查出来的问题, 与 net/http 模块相关

<!--more-->

一句话, 是因为有的 204 的返回 body 里有东西(开发者误写的, 不符合标准), 对于这些东西, go 的 http 模块当时没有去读(因为觉得 204 不需要去读 body), 而且复用了连接的情况下, 等到下一个请求时, 发现请求还没发怎么 body 已经来了? 就报错了...

然而 nginx 没有这种问题, 换言之 net/http 模块要求 http server 严格遵守协议

## 参考链接

https://caddy.community/t/got-502-with-an-error-message-readlooppeekfaillocked-nil/13616/7
https://github.com/golang/go/issues/31259#issuecomment-925708748

cowboy 2.8.0 增加了 check

https://github.com/ninenines/cowboy/commit/39b2816255503910dc23e2fdf703ee63bbc8953e

