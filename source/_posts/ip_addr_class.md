title: ip地址分类
date: 2016-06-07 12:11:00
tags: [internet]
---

大学计算机网络课学的东西全忘光了...

<!--more-->

## 分类
A类
由1字节的网络地址和3字节主机地址组成，网络地址的最高位必须是“0”,
地址范围1.0.0.1-126.255.255.254

B类
由2个字节的网络地址和2个字节的主机地址组成，网络地址的最高位必须是“10”,
地址范围128.1.0.1-191.255.255.254

C类
由3字节的网络地址和1字节的主机地址组成，网络地址的最高位必须是“110”,
地址范围192.0.1.1-223.255.255.254

D类地址用于多点广播（Multicast）。

D类IP地址第一个字节以“1110”开始，它是一个专门保留的地址。
它并不指向特定的网络，目前这一类地址被用在多点广播（Multicast）中。
多点广播地址用来一次寻址一组计算机，它标识共享同一协议的一组计算机。
D类没有子网掩码。
地址范围224.0.0.0-239.255.255.255

E类 
以“11110”开始，E类地址保留，仅作实验和开发用。
E类没有子网掩码。
地址范围240.0.0.0-255.255.255.254

全零（0.0.0.0）地址指当前主机。全“1”的IP地址（255.255.255.255）是当前子网的广播地址。

## 私有地址(RFC 1918)
在IP地址3种主要类型里，各保留了1个区域作为私有地址，如下：

A类地址：10.0.0.0～10.255.255.255
B类地址：172.16.0.0～172.31.255.255
C类地址：192.168.0.0～192.168.255.255

这些地址在网络上不被路由, 即无法连接公网

## 特殊地址
A,B,C类地址的最低和最高的网段,
如0.0.0.0/8, 127.0.0.0/8, 128.0.0.0/16, 191.255.0.0/16, 192.0.0.0/24, 223.255.255.0/24,
根据RFC 3330, 都是IANA保留的, 其中,
0.0.0.0/8段的说明如下:

> 0.0.0.0/8 - Addresses in this block refer to source hosts on "this"
>   network.  Address 0.0.0.0/32 may be used as a source address for this
>   host on this network; other addresses within 0.0.0.0/8 may be used to
>   refer to specified hosts on this network [RFC1700, page 4].

127.0.0.0/8都是环回地址(loopback)

128.0.0.0/16, 191.255.0.0/16, 192.0.0.0/24, 223.255.255.0/24貌似现在已经可以使用

> was initially and is still reserved by
> the IANA.  Given the present classless nature of the IP address
> space, the basis for the reservation no longer applies and addresses
> in this block are subject to future allocation to a Regional Internet
> Registry for assignment in the normal manner.

RFC 3330还有其他特殊地址, 参见
http://www.rfc-base.org/txt/rfc-3330.txt

