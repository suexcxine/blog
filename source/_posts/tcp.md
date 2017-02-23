title: tcp
date: 2016-06-13 15:49:00
tags: [internet, tcp]
---

继续回顾计算机网络的内容

<!--more-->

## 握手和挥手

建立tcp连接需要三次握手: SYN, SYN+ACK, ACK
断开tcp连接需要四次挥手: FIN, ACK, FIN, ACK

![tcp](/pics/tcp/tcp.gif)

![建立tcp连接](/pics/tcp/tcp_establish.gif)

![断开tcp连接](/pics/tcp/tcp_close.gif)

【注意】 在TIME_WAIT状态中，如果TCP client端最后一次发送的ACK丢失了，它将重新发送。
TIME_WAIT状态中所需要的时间是依赖于实现方法的。典型的值为30秒、1分钟和2分钟。
等待之后连接正式关闭，并且所有的资源(包括端口号)都被释放。

### 为什么连接的时候是三次握手，关闭的时候却是四次握手？
答：因为当Server端收到Client端的SYN连接请求报文后，可以直接发送SYN+ACK报文。
其中ACK报文是用来应答的，SYN报文是用来同步的。但是关闭连接时，当Server端收到FIN报文时，
很可能并不会立即关闭SOCKET，所以只能先回复一个ACK报文，告诉Client端，"你发的FIN报文我收到了"。
只有等到我Server端所有的报文都发送完了，我才能发送FIN报文，因此不能一起发送。故需要四步握手。

### 为什么TIME_WAIT状态需要经过2MSL(最大报文段生存时间)才能返回到CLOSE状态？
答：虽然按道理，四个报文都发送完毕，我们可以直接进入CLOSE状态了，但是我们必须假象网络是不可靠的，有可以最后一个ACK丢失。
所以TIME_WAIT状态就是用来重发可能丢失的ACK报文。

## keep alive

* tcp_keepalive_time 最后一次数据交换到发送第一个keepalive探测包的间隔,默认值为7200s（2h）。
* tcp_keepalive_probes 在tcp_keepalive_time之后,没有接收到对方确认,继续发送keepalive探测包次数，默认值为9（次）。
* tcp_keepalive_intvl 在tcp_keepalive_time之后,没有接收到对方确认,继续发送keepalive探测包的时间间隔，默认值为75s。

tcp_keepalive_intvl乘以tcp_keepalive_probes，就得到了从开始探测到放弃探测确定连接断开所需的时间

例子: 修改/etc/sysctl.conf文件,
```
net.ipv4.tcp_keepalive_time=90
net.ipv4.tcp_keepalive_intvl=15
net.ipv4.tcp_keepalive_probes=2
```
执行sysctl -p生效, sysctl -a | grep keepalive可查看

## tcp_retries

* tcp_syn_retries 对于一个新建连接,内核要发送多少个 SYN 连接请求才决定放弃。默认值是5。
* tcp_retries1 放弃回应一个TCP连接请求前,需要进行多少次重试。默认值3。
* tcp_retries2 在丢弃激活(已建立通讯状况)的TCP连接之前,需要进行多少次重试。默认值为15。

## 参考链接
http://blog.csdn.net/whuslei/article/details/6667471

