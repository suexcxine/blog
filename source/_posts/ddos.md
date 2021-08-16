title: DDoS
date: 2021-07-16

tags: [ddos]
---

记录一些被攻击的知识和经验, >_<

<!--more-->

## UDP Flood

胡乱弄一个包, 包体可以很大(比如超过8KB), 里面全是垃圾, 发到对面之后, 对面发现没有应用在监听指定的端口, 就会给 src 返一个 Destination Unreachable 的 ICMP 包, udp 包的 ip 地址可以伪造, 借以避免返回的大量 ICMP 包把自己搞死, 同时隐藏身份

有现成的软件可以实施 UDP Flood, 比如 UDP Unicorn

#### DNS amplification

攻击者不是直接攻击目标服务IP，而是通过伪造源 IP 地址，将请求包发送给 DNS 服务器。理论上，ISP的DNS服务器只响应来自其自身客户端IP的DNS查询响应，但实际上，互联网上大量DNS服务的默认配置丢失，导致响应所有IP的DNS查询请求。同时，大多数DNS使用没有握手过程(即无法对源 IP 进行身份验证)的UDP协议来验证请求的源IP。由于DNS查询的返回包通常比请求包很多倍，黑客发出的 1M 流量的请求, 到受害者那里就是数M到数十M，起到一个放大效果。



## NTP Flood

NTP反射攻击

NTP是网络时间协议的缩写，是用于同步计算机时间的网络协议。ntp包含一个monlist函数，也称为mon-getlist，主要用于监视ntp服务器。当ntp服务器响应monlist时，它们返回与ntp服务器同步的最后600个客户机的IP。响应包分为六个IP包，最多100个响应包。我们可以通过ntpdc命令向ntp服务器发送monlist，并结合抓包查看实际效果。

***ntpdc-n-c monlist x.x.x_wc-l***

***602\***

在上面的命令行中，我们可以看到一个包含monlist的请求收到了602行数据，除了前两行是无效数据之外，它碰巧是600个客户机IP列表。这个放大效果不错。







