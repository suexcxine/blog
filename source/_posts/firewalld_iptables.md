title: firewalld与iptables, 记一次问题的解决
date: 2016-06-21 19:04:00
tags: [linux, firewalld, iptables]
---

关掉firewalld之后有一个docker服务起不来了, 报错如下:
```
# docker-compose up -d shadowsocks
Creating ss_server

ERROR: for shadowsocks  driver failed programming external connectivity on endpoint ss_server (ee95b8b78a095b2838b8e415a9e52d3807cdcec99f3486d7a9ce47101ee794f9): iptables failed: iptables --wait -t nat -A DOCKER -p tcp -d 0/0 --dport 8388 -j DNAT --to-destination 172.23.0.3:8388 ! -i br-d4333300e60a: iptables: No chain/target/match by that name.
 (exit status 1)
 Traceback (most recent call last):
   File "<string>", line 3, in <module>
     File "compose/cli/main.py", line 63, in main
     AttributeError: 'ProjectError' object has no attribute 'msg'
     docker-compose returned -1
```
启动firewalld之后问题解决

个中缘由日后再深入挖掘...

