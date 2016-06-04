title: netcat
date: 2016-06-04 17:17:00
tags: linux
---

telnet的替代品?更多功能?
<!--more-->

## 例子

### 启动一个一次性的web server在8080端口, 提供一个文件
```
{ echo -ne "HTTP/1.0 200 OK\r\nContent-Length: $(wc -c <some.file)\r\n\r\n"; cat some.file; } | nc -l -p 8080
```
参数-l: listen
参数-p: source port

### 检测hostname/ip的port是否open且listening
```
nc -vz suexcxine.cc 8888
```
参数-v: 详细信息
参数-z: 只扫描listening的程序, 并不发数据

### 简单的UDP服务器和客户端
服务端监听8388端口
nc -ul 8388
客户端连接
nc -u suexcxine.cc 8388
双方可以输入字符通信

参数-u: udp

### 代理
```
$ nc -vl 12345 | nc www.google.com 80
Listening on [0.0.0.0] (family 0, port 12345)
Connection from [127.0.0.1] port 12345 [tcp/*] accepted (family 2, sport 40841)
```
由于管道是单向的, 流量被转发到google.com但是响应不会转给客户

