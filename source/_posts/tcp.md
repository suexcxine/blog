title: tcp
date: 2016-06-13 15:49:00
tags: [internet, tcp]
---

继续回顾计算机网络的内容

<!--more-->

## 握手和挥手

建立tcp连接需要三次握手: SYN, SYN+ACK, ACK
断开tcp连接需要四次挥手: FIN, ACK, FIN, ACK

![建立tcp连接](/pics/tcp/tcp_establish.gif)

![断开tcp连接](/pics/tcp/tcp_close.gif)

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

* tcp_retries1 放弃回应一个TCP连接请求前﹐需要进行多少次重试。默认值3。
* tcp_retries2 在丢弃激活(已建立通讯状况)的TCP连接之前﹐需要进行多少次重试。默认值为15。

## 参考链接
http://blog.csdn.net/whuslei/article/details/6667471


