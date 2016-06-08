title: dnsmasq
date: 2016-06-08 16:18:00
tags: [internet, dns]
---

尝试在自己的vps上搭一个dns服务
<!--more-->

在/root/dnsmasq_conf/dnsmasq.hosts文件里填写自己想要解析的域名
```
# cat /root/dnsmasq_conf/dnsmasq.hosts 
118.193.216.246 suexcxine.me
```
启动dnsmasq服务
```
# docker run --name dns -d -p 53:53/tcp -p 53:53/udp -v /root/dnsmasq_conf:/etc/dnsmasq --cap-add=NET_ADMIN andyshinn/dnsmasq:2.75 --addn-hosts=/etc/dnsmasq/dnsmasq.hosts
```
在网络连接里将自己机器的dns设为vps的ip, 并测试
```
ping suexcxine.me
```
解析成功

今后修改dnsmasq.hosts文件后, 可以如下reload
```
docker exec -it dns kill -SIGHUP 1 
```
这样有一个做动态解析的可能

