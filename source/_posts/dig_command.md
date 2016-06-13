title: dig命令
date: 2016-06-13 11:31:00
tags: [internet, dns]
---

据说比nslookup命令好用
<!--more-->

### 指定公共dns服务器如8.8.8.8
```
dig @8.8.8.8 suexcxine.cc

; <<>> DiG 9.9.5-3ubuntu0.3-Ubuntu <<>> @8.8.8.8 suexcxine.cc
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 51934
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 512
;; QUESTION SECTION:
;suexcxine.cc.          IN  A

;; ANSWER SECTION:
suexcxine.cc.       599 IN  A   118.193.216.246

;; Query time: 370 msec
;; SERVER: 8.8.8.8#53(8.8.8.8)
;; WHEN: Mon Jun 13 16:00:55 CST 2016
;; MSG SIZE  rcvd: 57

```

### 跟踪dig全过程
```
$ dig +trace suexcxine.cc

; <<>> DiG 9.9.5-3ubuntu0.3-Ubuntu <<>> +trace suexcxine.cc
;; global options: +cmd
.           513159  IN  NS  e.root-servers.net.
.           513159  IN  NS  h.root-servers.net.
.           513159  IN  NS  l.root-servers.net.
.           513159  IN  NS  i.root-servers.net.
.           513159  IN  NS  a.root-servers.net.
.           513159  IN  NS  d.root-servers.net.
.           513159  IN  NS  c.root-servers.net.
.           513159  IN  NS  b.root-servers.net.
.           513159  IN  NS  j.root-servers.net.
.           513159  IN  NS  k.root-servers.net.
.           513159  IN  NS  g.root-servers.net.
.           513159  IN  NS  m.root-servers.net.
.           513159  IN  NS  f.root-servers.net.
;; Received 239 bytes from 127.0.1.1#53(127.0.1.1) in 744 ms

cc.         172800  IN  NS  ac1.nstld.com.
cc.         172800  IN  NS  ac2.nstld.com.
cc.         172800  IN  NS  ac3.nstld.com.
cc.         172800  IN  NS  ac4.nstld.com.
cc.         86400   IN  DS  519 8 1 7285EF05E1B4E679D4F072EEA9B00953E01F3AE2
cc.         86400   IN  DS  519 8 2 E1EC6495ABD34562E6F433DEE201E6C6A52CB10AF69C04D675DA692D 2D566897
cc.         86400   IN  RRSIG   DS 8 1 86400 20160623050000 20160613040000 60615 . kmlYZSZOtDbV2J/J23O4AYUFLZ6N+oD4eICLj+ZN/y1ki4UoUlMyqcJW scXz/ux+DmbQJXhwUwn/ode3uh4EHvBjhbVDvhVET1I0xbyloOqkYhiy WtL400eUF23Bd5rxvmb2i/+LPcmoMkaWZh+6GWA6hH3J8VFOjldnSxVx TBo=
;; Received 541 bytes from 192.203.230.10#53(e.root-servers.net) in 823 ms

suexcxine.cc.       172800  IN  NS  f1g1ns2.dnspod.net.
suexcxine.cc.       172800  IN  NS  f1g1ns1.dnspod.net.
RQGAP5UF6Q1NGVCKFNO8RANVDN5ILRIN.cc. 86400 IN NSEC3 1 1 0 - RV11BJCVDH79RSELE61AK8640MB8689H NS SOA RRSIG DNSKEY NSEC3PARAM
RQGAP5UF6Q1NGVCKFNO8RANVDN5ILRIN.cc. 86400 IN RRSIG NSEC3 8 2 86400 20160619190704 20160612190704 4430 cc. k0e66YorcywAW7+cUSVJrqzHPRJY4YBEhi+j6JjgyONWjxBmaZ1pdB+P QJvs8Dt3HeMrlmSfSe7eOgQ0J0CkuQnNCEoAES18GB0Nv2vICmccx8kq qcjdL2JObtMAN4eerRyYEF4n+3GfK9UMSFbAWsJhgs8YO2WWlWpktot5 rt0=
JSOFD7DUT1KLQP4ATN919VJUMSMPPKR3.cc. 86400 IN NSEC3 1 1 0 - KBR2RRU7FVEIU4PPG8128HD76RDD86J5 NS DS RRSIG
JSOFD7DUT1KLQP4ATN919VJUMSMPPKR3.cc. 86400 IN RRSIG NSEC3 8 2 86400 20160620061457 20160613061457 4430 cc. o5Q3Td1Lmxu0H/ESPYIHBJ5lr0zIMOpylFdvvDKsN3mv7TFtzupL3uiD 7oFBjDRl6NxY+lX1rH2pM9+t20AV1R1gE0CclL9UB3zeUbaBRDOeEkDi gs4o3wx0IJyvSry+I3BHxHc/Dt4gcfKEDqIJJSFenu+d0GpcRU/jheUC knU=
;; Received 578 bytes from 192.42.173.30#53(ac1.nstld.com) in 672 ms

suexcxine.cc.       600 IN  A   118.193.216.246
suexcxine.cc.       86400   IN  NS  f1g1ns2.dnspod.net.
suexcxine.cc.       86400   IN  NS  f1g1ns1.dnspod.net.
;; Received 121 bytes from 125.39.208.193#53(f1g1ns1.dnspod.net) in 5 ms
```

### 默认追加域
```
$ dig +domain=baidu.com blog

; <<>> DiG 9.9.5-3ubuntu0.3-Ubuntu <<>> +domain=baidu.com blog
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 19480
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1280
;; QUESTION SECTION:
;blog.baidu.com.            IN  A

;; ANSWER SECTION:
blog.baidu.com.     7168    IN  CNAME   blog.n.shifen.com.
blog.n.shifen.com.  268 IN  A   180.149.132.208

;; Query time: 50 msec
;; SERVER: 127.0.1.1#53(127.0.1.1)
;; WHEN: Mon Jun 13 16:28:38 CST 2016
;; MSG SIZE  rcvd: 90
```

### 查询权威dns server
```
$ dig +nssearch youtube.com
SOA ns4.google.com. dns-admin.google.com. 124701907 900 900 1800 60 from server 216.239.32.10 in 78 ms.
SOA ns3.google.com. dns-admin.google.com. 124701907 900 900 1800 60 from server 216.239.38.10 in 365 ms.
;; connection timed out; no servers could be reached
```

### 查看反向解析
```
$ dig -x 180.149.132.47
```

### 从文件中读取查询内容实现批量查询
```
$ cat querylist //文件内容，共有两个域名需要查询
www.baidu.com
www.sohu.com
$ dig -f querylist -c IN -t A //设置-f参数开始批量查询
```

### 不要版本信息, 不要注释, 不要统计信息
```
$ dig +nocmd +nocomment +nostat youtube.com
;youtube.com.           IN  A
youtube.com.        200 IN  A   216.58.199.110
```

### 最简输出
```
$ dig +short youtube.com
216.58.199.110
```

## 参考链接
http://roclinux.cn/?p=2449

