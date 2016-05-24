title: windows和ubuntu中看到的时间不一样的问题
date: 2015-08-05
tags: [windows, linux]
---
正好差时区的值
<!--more-->
## 原因: Windows与Mac/Linux缺省看待系统硬件时间的方式不一样
Windows把系统硬件时间当作本地时间(local time)，即操作系统中显示的时间跟BIOS中显示的时间是一样的。
Linux/Unix/Mac把硬件时间当作UTC，操作系统中显示的时间是硬件时间按时区计算得来的，比如说北京时间是硬件时间+8小时。

## 让Windows把硬件时间当作UTC
开始->运行->CMD
Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_DWORD /d 1

## 或修改Mac和Ubuntu不使用UTC的时间
sudo gedit /etc/default/rcS
将UTC=yes改为UTC=no

