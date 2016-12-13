## websocket是为了解决什么问题

很多网站为了实现推送技术，所用的技术都是polling(轮询)。轮询是在特定的的时间间隔（如每1秒），由浏览器对服务器发出HTTP request，然后由服务器返回最新的数据给客户端的浏览器。
![poll](/pics/polling.png)
比较新的技术采用long polling, 在服务器有数据之前hold住连接, 等服务器有数据时返回response, client收到后立即发出一个新的请求, 循环往复, 稍好于普通的polling, 请求数变少.
![long poll](/pics/longpolling.png)

这两种模式都有明显的缺点，即浏览器需要不断的向服务器发出请求，然而HTTP request的header是非常长的，里面包含的数据可能只是一个很小的值，这样会占用很多的带宽和服务器资源。

面对这种状况...

## websocket横空出世

HTML5定义了WebSocket协议，能更好的节省服务器资源和带宽并达到实时通讯。
浏览器和服务器只需要完成一次握手，两者之间就直接可以创建持久性的TCP连接，允许全双工通讯。
允许服务端直接向客户端推送数据而不需要客户端发送请求.
![websocket](/pics/websocket.png)
## 握手(Handshake)

和 HTTP 的唯一关联是使用 HTTP 协议的101状态码进行协议切换
握手用HTTP协议所以web服务器可以使用相同的端口(无需修改firewall规则)处理websocket握手和普通的http请求(80, 443)
一旦websocket连接建立, 通讯即切换为与HTTP无关的双向二进制协议

浏览器请求示例
```
GET /chat HTTP/1.1
Host: example.com:8000
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
Sec-WebSocket-Version: 13
```

服务器回应示例
```
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
```

请求中的“Sec-WebSocket-Key”是随机的，服务器端会用这些数据来构造出一个SHA-1的信息摘要。
服务器端把“Sec-WebSocket-Key”拼上一个固定的字符串“258EAFA5-E914-47DA-95CA-C5AB0DC85B11”。使用SHA-1加密，之后进行BASE-64编码，将结果做为“Sec-WebSocket-Accept”头的值，返回给客户端。

这种做法的目的是
1. 明确判断server是否支持websocket. 避免出现server不支持websocket而按普通http请求处理的情况发生.
2. 避免缓存proxy或者server把之前缓存下来的东西发过来

## 数据帧(Frame)

RFC 6455(2011年)

Frame format:
​​
```
      0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-------+-+-------------+-------------------------------+
     |F|R|R|R| opcode|M| Payload len |    Extended payload length    |
     |I|S|S|S|  (4)  |A|     (7)     |             (16/64)           |
     |N|V|V|V|       |S|             |   (if payload len==126/127)   |
     | |1|2|3|       |K|             |                               |
     +-+-+-+-+-------+-+-------------+ - - - - - - - - - - - - - - - +
     |     Extended payload length continued, if payload len == 127  |
     + - - - - - - - - - - - - - - - +-------------------------------+
     |                               |Masking-key, if MASK set to 1  |
     +-------------------------------+-------------------------------+
     | Masking-key (continued)       |          Payload Data         |
     +-------------------------------- - - - - - - - - - - - - - - - +
     :                     Payload Data continued ...                :
     + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
     |                     Payload Data continued ...                |
     +---------------------------------------------------------------+
```

### opcode

0x0: continuation
0x1: text(UTF-8)
0x2: binary
0x3-0x7: undefined
0x8: close
0x9: ping
0xA: pong
0xB-0xF: undefined

### Message Fragmentation

一条message可以分多个frame发
```
Client: FIN=1, opcode=0x1, msg="hello"
Server: (process complete message immediately) Hi.
Client: FIN=0, opcode=0x1, msg="and a"
Server: (listening, new message containing text started)
Client: FIN=0, opcode=0x0, msg="happy new"
Server: (listening, payload concatenated to previous message)
Client: FIN=1, opcode=0x0, msg="year!"
Server: (process complete message) Happy new year to you too!
```

### Fragmentation是干什么用的?

既然长度都可以用64bit了, Fragmentation还有什么用?

Fragmentation的主要目的是允许发送总长度未知的message.
如果不支持fragmentation, 那么端需要自己buffer, 直到一整条消息都有了, 然后计算出总长度发过去.
有了Fragmentation以后, 端可以定一个合理的size buffer, 当buffer满了就发一个fragment到websocket.

另一种场景是在multiplexing的环境下,
不希望一条太大的message独占带宽, 影响其他人的体验

> The primary purpose of fragmentation is to allow sending a message
> that is of unknown size when the message is started without having to
> buffer that message.  If messages couldn't be fragmented, then an
> endpoint would have to buffer the entire message so its length could
> be counted before the first byte is sent.  With fragmentation, a
> server or intermediary may choose a reasonable size buffer and, when
> the buffer is full, write a fragment to the network.
>
> A secondary use-case for fragmentation is for multiplexing, where it
> is not desirable for a large message on one logical channel to
> monopolize the output channel, so the multiplexing needs to be free
> to split the message into smaller fragments to better share the
> output channel.  (Note that the multiplexing extension is not
> described in this document.)

摘自: https://tools.ietf.org/html/rfc6455#section-5.4

### Decoding Payload Length

读取bit 9-15, 如果小于等于125, 这个就是frame长度.
如果是126, 那么后面16个bit是frame长度.
如果是127, 那么后面64个bit是frame长度.

### Reading and Unmasking the Data

MASK bit 表示 message 是否被 encode 了
如果被encode了, 读取32bit mask key, 使用这个mask key解码, 异或即可, 如下

```
var DECODED = "";
for (var i = 0; i < ENCODED.length; i++) {
    DECODED[i] = ENCODED[i] ^ MASK[i % 4];
}
```

### Mask有什么用?

Key都包含了, 直接异或就行, 有什么用?

RFC6455文档中说明是为了避免缓存投毒

如果攻击者通过client发送一个看起来很像HTTP请求
(比如请求一个特定的资源如计算网站浏览量的一个js文件)
的数据帧到一个攻击者控制下(或者有漏洞)的server,
server再发回一个看起来像是那个HTTP响应的数据帧(这里面是毒, 比如恶意的js代码).
然后这个响应会被天真的proxy缓存住,
于是之后别的用户发一个这样的HTTP请求就会得到被缓存住的有毒的Response

为了解决这个问题, 要求client给server发的Frame做Mask, 而且mask key必须每帧不同且不可预测,
这样攻击者就不知道怎么才能让一个请求在mask后变得很像正经的HTTP请求,
于是即使是天真的proxy也不会把数据帧当成是HTTP请求缓存住, 或者即使缓存住了也不会影响其他用户的正经HTTP请求

那直接就发HTTP请求然后返回恶意代码不就可以了么? 为什么要走websocket?
可能http反而不好搞, 比如全站https了, 这时如果client没有做mask就这条路比较好搞
所以标准说如果client没有做mask, server应当断开连接

参考: https://tools.ietf.org/html/rfc6455#section-10.3

### Pings and Pongs: The Heartbeat of WebSockets

0x9: ping
0xA: pong

收到ping时, 发一个data一样的pong包做为应答.

如果你没有发ping就收到一个pong, 忽略它.
如果你收到ping后在你腾出手来发pong之前你又收到一个ping, 你只需发一次pong.

### 其他字段
RSV1-3是用于扩展的.

### 安全性

可以用wss(Web Socket Secure)协议,
```
ws-URI = "ws:" "//" host [ ":" port ] path [ "?" query ]
wss-URI = "wss:" "//" host [ ":" port ] path [ "?" query ]
```
握手用https, 传输用TLS

> Connection confidentiality and integrity is provided by running the
> WebSocket Protocol over TLS (wss URIs).  WebSocket implementations
> MUST support TLS and SHOULD employ it when communicating with their
> peers.

摘自: https://tools.ietf.org/html/rfc6455#section-10.6

## 浏览器支持情况
IE10及以后才支持, 其他浏览器都支持得比较早

## nginx反向代理websocket

NGINX 1.3 及以后支持 websocket, 可以做为反向代理和负载均衡

```
location /wsapp/ {
    proxy_pass http://wsbackend;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

tcp连接建立后, nginx将从client那里得到的数据包直接转给server
这个阶段不走nginx的负载均衡

## sockjs

sockjs连接成功后服务器会给客户端推一个o
之后每20秒会推一个h, 这是心跳
客户端需要在10秒内回复["h"], 这是应答, 否则连接会被中断

其他详情见:
https://github.com/sockjs/sockjs-protocol/wiki/Heartbeats-and-SockJS
https://github.com/sockjs/sockjs-protocol/wiki/Connecting-to-SockJS-without-the-browser
