title: 坎坷之路 Ubuntu 16.04
date: 2016-07-24 21:34:00
tags: linux
---

至今仍然没能成功

<!--more-->

上周下载了16.04的镜像, 做好U盘后, 重启电脑, 设为从U盘启动

结果出现error: 一行一行地持续出,

google后有人说按tab键, 可以看到几个可选的命令，输入live回车即可，
可是我输入live后就卡死，两分钟后，出现如下报错:
task swapper/0:1 blocked for more than 120 seconds.
还有几个swapper以外的名字, 不过都是被阻塞了超过120秒
一遍一遍不停地出, 只能强制关机

不放弃, 再次google, 可是这次什么有用的信息也没有查到

不放弃, 换Ubuntu-kylin 16.04试试, 结果一样

不放弃, 昨天出了16.04.1, 估计官方把这些bug都改好了吧?
又下载了16.04.1的镜像,还是一样... 失望

不放弃, 从14.04升级到16.04吧,
```
sudo update-manage -d
```
两个多小时后, 一切顺利! 安装过程中桌面背景刷新了, 好漂亮, 好激动! 最后一步重启,

重启.. 粉屏, 卡住了..

两分钟后, 再次出现task xxx blocked for more than 120 seconds.

好吧, 可能我这笔记本的硬件或者BIOS什么的不兼容吧..
不放弃, 等我以后换了电脑再装

最后还得重新装14.04, 重装环境...

## 或许可以16.04和3.19的linux内核搭配着用

因为发现14.04升级内核到4.4也出现了同样的问题
http://askubuntu.com/questions/758452/ubuntu-16-04-lts-with-3-kernel

