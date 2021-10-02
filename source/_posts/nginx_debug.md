title: nginx/openresty 排障经验
date: 2021-10-02

tags: [nginx, openresty, debug]
---

这里记录一些 nginx/openresty 排障经验备查
<!--more-->

## request_time 远大于 upstream_response_time

虽然有一些是因为 client 的网速太慢, 但是如果大多数请求都是这样那就不会是 client 网速问题了..

有可能是在 proxy_pass 之前 nginx 自己内部有一些处理

笔者遇到过一个情况是在转发给 upstream 之前, openresty 有一些 lua 代码要执行, 就是 authentication , 因为对应的 redis 挂了, 这里的 redis connect 要等 60s 才超时, 于是看到的现象就是 request_time 基本都是 60s, 而 upstream_response_time 则很小, 几毫秒到几十毫秒而已





