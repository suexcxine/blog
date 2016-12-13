title: erlang实现websocket简单示例
date: 2015-09-07
tags: [erlang, internet]
---
WebSocket protocol 是HTML5一种新的协议。它实现了浏览器与服务器全双工通信(full-duplex)。
<!--more-->
![运行效果](/pics/websocket_demo.png)

本示例仅支持文本消息
基于websocket版本13

由于joe armstrong的例子:
http://armstrongonsoftware.blogspot.com/2009/12/comet-is-dead-long-live-websockets.html
已经过时,不符合现在的websocket标准,于是改写了一下

前端使用js发送websocket请求

## 测试
在erlang shell里执行local_server:start()即可启动服务端,
此时打开index.html即可看到文首的截图效果

## 源码下载
[websocket](/attachments/websocket_demo.tar.gz)

## 参考链接
[cowboy](https://github.com/extend/cowboy)
[websocket标准](http://blog.csdn.net/fenglibing/article/details/6852497)

