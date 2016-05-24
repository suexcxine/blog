title: socket
date: 2015-11-25
tags: [internet]
---
网络进程间通讯需要唯一标识一个进程,使用ip地址和端口可以做到
<!--more-->
## socket
一个网络套接字(Socket)至少由以下信息表示:
本地socket地址: 本地ip和端口号
协议类型: TCP, UDP, raw IP等, 于是TCP端口53与UDP端口53可以区分开来
一个已经连接上的socket,即ESTABLISHED状态的socket,还有远端socket地址

一个tcp server可以同时为很多client提供服务,服务端为每个client创建一个socket,
从tcp server的角度来看,这些socket的本地socket地址都相同, 远端socket地址不同(即client的ip和端口)

## Socket pairs
每个连接(socket pair)由一个唯一的四元组{本地ip,本地端口,远程ip,远程端口}表示,
TCP下,每个socket pair对应一个整数,即socket descriptor
UDP下,由于UDP是无连接的,所以每个本地socket地址对应一个整数,即socket descriptor

## Socket文件
socket起源于UNIX，在Unix一切皆文件哲学的思想下，socket是一种"打开—读/写—关闭"模式的实现，服务器和客户端各自维护一个"文件"，在建立连接打开后，可以向自己文件写入内容供对方读取或者读取对方内容，通讯结束时关闭文件。

## 心跳
为了及时检测到无效连接,由应用程序发送心跳包来检测连接是否还有效(还活着)
大致的方法:
客户端定时向服务端发一个很小的数据包(小是为了不浪费流量,空包也可以),意思是告诉服务端我还活着(故称心跳包)
服务端定时检查上次检查到现在这段时间内有没有收到客户端发来的数据包
如果没有(或连续几次没有)则认为客户端连接断开,在这个时机(timing)可以做一些逻辑处理,如一些清理操作
反之,如果客户端在一定时间内没有收到服务端对心跳包的响应,则认为连接不可用

## 参考链接
https://en.wikipedia.org/wiki/Network_socket
