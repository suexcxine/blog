title: ip地址分类
date: 2016-06-07 12:11:00
tags: [internet]
---

大学计算机网络课学的东西全忘光了...

分类网络（Classful network）或称“分级式定址”，
是在1981(RFC 791)-1993(CIDR出现, RFC 1518, RFC 1519)间使用的network addressing architecture。

<!--more-->

## 分类之前
一开始，32位的IPv4地址只由8位的网络地址和“剩下的”主机位组成。
这种格式用在局域网出现之前。在那时，只有一些很少很大的的网络，例如ARPANET。
这使独立的网络的数量不能太多（最多254个），这在局域网出现的早期，就已经显得不足够了。

## 分类
* A类, 最高位0, 地址范围0.0.0.0/8 - 127.0.0.0/8
* B类, 最高位10, 地址范围128.0.0.0/16 - 191.255.0.0/16
* C类, 最高位110, 地址范围192.0.0.0/24 - 223.255.255.0/24
* D类, 最高位1110, 地址范围224.0.0.0/4
* E类, 最高位1111, 地址范围240.0.0.0/4

D类地址用于多点广播（Multicast）。

E类地址保留，仅作实验和开发用。

全零（0.0.0.0）地址指当前主机。全“1”的IP地址（255.255.255.255）是当前子网的广播地址。

## 无类别域间路由(Classless Inter-Domain Routing、CIDR)
在之前的分类网络中，IP地址的分配把IP地址的32位按每8位为一段分开。这使得前缀必须为8，16或者24位。
遵从CIDR规则的地址有一个后缀说明前缀的位数，例如：208.130.28.0/22。这使得对日益缺乏的IPv4地址的使用更加有效。

## 关于子网的第一个和最后一个地址
一般来说, 子网的第一个地址表示子网本身, 最后一个是广播地址
即这两个地址不用于表示主机, 其它地址可以分配给各个主机
注意, 子网的第一个和最后一个地址不一定是0和255, 这取决于子网掩码
如10.6.43.0/22不是第一个地址, 这个子网的第一个地址是10.6.40.0

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

