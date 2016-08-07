title: tsocks
date: 2015-07-27
tags: [internet, linux]
---
不仅浏览器,有时其他应用程序也需要代理,比如git clone的时候
tsocks让shell也可以用代理
<!--more-->
## 安装tsocks
sudo apt-get install tsocks

## 编辑配置文件:/etc/tsocks.conf
> local = 192.168.1.0/255.255.255.0
> local = 127.0.0.0/255.0.0.0
> server = 127.0.0.1 
> server_type = 5
> server_port = 1080 

## 测试是否生效
tsocks wget www.google.com
--2015-07-27 14:27:24--  http://www.google.com/
正在解析主机 www.google.com (www.google.com)... 216.58.221.36, 2404:6800:4005:809::2004
正在连接 www.google.com (www.google.com)|216.58.221.36|:80... 已连接。
已发出 HTTP 请求，正在等待回应... 200 OK
长度： 未指定 [text/html]
正在保存至: “index.html”
...
    2015-07-27 14:27:25 (73.9 KB/s) - “index.html” 已保存 [20410]

## 其他使用方法
. tsocks -on
. tsocks -off

## 查看当前LD_PRELOAD的值
tsocks -sh

## 其他参考
man 1 tsocks
man 8 tsocks

