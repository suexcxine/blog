title: nmap
date: 2016-06-06 19:09:00
tags: [internet, test]
---

端口扫描工具
<!--more-->

```
# 扫描单个主机
nmap scanme.nmap.org
# 扫描整个子网
nmap 192.168.1.1/24
# 扫描多个目标
nmap 192.168.1.2 192.168.1.5
# 扫描范围目标
nmap 192.168.1.1-100
# 如果你有一个ip地址列表，将这个保存为一个txt文件，和namp在同一目录下,扫描这个txt内的所有主机
nmap -iL target.txt
参数 -iL: input from list
# 显示扫描目标列表
nmap -sL 192.168.1.1/24
参数 -sL: List Scan - simply list targets to scan
# 扫描除过某些ip外的所有子网主机
nmap 192.168.1.1/24 -exclude 192.168.1.1-100
# 指定端口
nmap -p80,21,23 192.168.1.1
```

## Nmap的扫描技术
```
Tcp SYN Scan (sS)
nmap -sS 192.168.1.1
Tcp connect() scan(sT)
nmap -sT 192.168.1.1
Udp scan(sU)
nmap -sU 192.168.1.1
FIN scan (sF)
nmap -sF 192.168.1.8
PING Scan (sP)
nmap -sP 192.168.1.1
版本检测(sV)
nmap -sV 192.168.1.1
Idle scan (sL)
nmap -sL 192.168.1.6 192.168.1.1
```

## Nmap的OS检测（O）, 只是猜, 不准
nmap -O -PN 192.168.1.1/24
nmap -O --osscan-guess 192.168.1.1

## 其他
#### sun-answerbook是什么鬼?
出现在nmap的service列中
调查发现: 
sun-answerbook是sun的过时的文档http服务,该服务正好也用8888端口,
于是nmap看到8888端口就以为是sun answerbook, 其实不是, 所以nmap的这个不准
用netstat -ontlp看看8888端口的进程名还能明白点

## 参考链接
http://www.2cto.com/Article/201207/142903.html

