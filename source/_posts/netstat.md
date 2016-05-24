title: netstat
date: 2016-01-04
tags: [internet, linux]
---

Print network connections, routing tables, interface statistics, masquerade connections, and multicast memberships

<!--more-->

## 常用选项
-a 显示全部socket(包括监听中的和非监听中的)
-l 显示监听中(默认不显示)的socket

-t 显示TCP协议的
-u 显示UDP协议的

-n 以网络IP地址而不是名称显示
-p 显示建立相关连接的程序名和PID
-o 包含timer相关信息
-e 显示更多信息

-c 每秒刷新

-s 显示各类协议的统计信息

## 其他用途
netstat -ie 同ifconfig
netstat -r 同route -e





