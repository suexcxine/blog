title: /etc/hosts配置文件
date: 2015-07-23
tags: linux
---

Hosts - The static table lookup for host name（主机名查询静态表）
<!--more-->
hosts文件的每行由三部份组成
* IP地址
* 主机名或域名
* 主机名别名

### 主机名(hostname)和域名(Domain）的区别
主机名通常在局域网内使用，通过hosts文件，主机名就被解析到对应ip；
域名通常在internet上使用，但如果不想使用internet上的域名解析，就可以更改hosts文件，加入自己的域名解析。

### hostname命令
hostname - show or set the system’s host name

$ hostname            查看主机名
chenduo-desktop

$ hostname test100    修改主机名,需要root权限
test100

$ hostname -i         查看ip
192.168.1.100

$ hostname -f         查看FQDN
chenduo-desktop.localdomain

通过hostname命令设置主机名是临时的，重启系统后此主机名不会存在

