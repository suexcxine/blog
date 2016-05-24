title: linux tips
date: 2015-09-06
tags: linux
---
零碎的linux知识
<!--more-->
## 查看显卡所支持的OpenGL版本
sudo apt-get install mesa-utils
glxinfo | grep OpenGL

## ulimit -c 999999999
用于产生core文件,否则产生不了

## linux上的office解决方案
在线的Google Docs和Office Web Apps可以在一定程序上替代本地Office套件
这样本地不用装那么臃肿的Office
https://www.google.com/docs/about/
https://office.live.com/start/default.aspx

使用金山WPS
可以从源里安装, 官网上的beta版本不稳定

## 把当前目录放到PATH中有安全风险
因为当前目录中可能有与/bin等目录里的文件重名的恶意脚本等情况

## 内核空间 用户空间
每个进程有4GB的进程地址空间(虚拟内存空间),
多数情况下内核占用其中的1GB,用户空间获得剩余的3GB,64位系统这些数字可能不同

