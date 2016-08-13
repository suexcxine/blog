title: iostat
date: 2016-08-13 17:20:00
tags: [linux, monitoring]
---

## iostat

sudo apt-get install sysstat
yum install sysstat

<pre>
iostat
Linux 3.19.0-66-generic (chenduo)   2016年08月13日  _x86_64_    (8 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
          28.30    0.06   11.32    1.43    0.00   58.88

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
sda               3.44        21.71        99.34    6225040   28490308
</pre>

user: 用户级时间比例
nice: nice优先级时间比例
system: 系统级时间比例
iowait: 等待io的时间比例,相当于top里的wa
steal: 虚拟环境下等待物理CPU周期的时间比例
idle: 空闲时间比例, 相当于top里的id

tps: transfer per second, 一次transfer就是一次io

### steal

如果你使用Amazon EC2等虚拟环境,就要考虑这个steal值了,因为虚拟机之间并不是均等分配CPU,
比如一台物理机器上有四个虚拟机,并不是说每个虚拟机平均占用25%的CPU周期

这个值持续20分钟以上超过10%就有问题

如何判断原因是否host超卖? 如果自己的每台VM都高,则是自己的软件占用CPU过高,如果只是一部分VM的steal高,可能是物理主机host超卖

Xen和KVM支持这个值,貌似vmware和virtualbox都不支持

## 参考链接
http://blog.scoutapp.com/articles/2013/07/25/understanding-cpu-steal-time-when-should-you-be-worried
http://linuxcommand.org/man_pages/iostat1.html

