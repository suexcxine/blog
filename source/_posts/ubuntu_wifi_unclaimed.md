title: 解决ubuntu 14.04下wifi功能突然丢失的问题
date: 2016-07-17 11:17:00
tags: [ubuntu, linux, wifi]
---

今天笔记本电脑电池电量耗尽后，再重启时发现wifi功能没有了，任务栏上的网络图标点开之后选项少了许多。
<!--more-->

```
sudo lshw -C network
```
发现Wireless interface那标记着"UNCLAIMED"
我的无线网卡型号是
<pre>
product: RT3290 Wireless 802.11n 1T/1R PCIe
vendor: Ralink corp.
</pre>

```
sudo modprobe ath9k
```
重启， 再查看lshw -C network, 如果状态变为disabled了，
尝试Fn+F2, 笔记本电脑一般都有这个功能键可以禁用和启用wifi  

