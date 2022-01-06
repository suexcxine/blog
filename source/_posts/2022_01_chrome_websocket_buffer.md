title:  记一次 chrome websocket receive buffer 与心跳超时的问题
date: 2022-01-05

tags: [websocket, chrome]
---

我们的一个项目是后端定时发心跳包给前端，前端必须在 4 秒内回复， 不回复就断开连接。
然而有一次前端被断开了连接， 说没有收到心跳包就被断了。查了很久。

<!--more-->

chrome 开发者工具的 Network/WS/Messages 这个 tab 页里的 Time 并不是客户端机器的 tcp 协议栈收到消息的时间戳。而是从 websocket receive buffer 里拿出来的时间戳。
如果前端的处理代码太慢或后端发消息太快，这个时间会和实际的时间差很远。

我们遇到的这个情况的真相是，前端说没收到心跳包，其实是发了的，但是这个心跳包很晚才从 chrome websocket receive buffer 里取出来，甚至还没取出来心跳就已经超时了。

猜想 chrome 是回调前端代码，每处理完一条就再从 buffer 里取一条。

[stackoverflow上的类似问题](https://stackoverflow.com/questions/44447081/websocket-receive-buffer-in-chrome/44454960)

