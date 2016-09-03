title: 坎坷之路 Hasee和linux的内核
date: 2016-09-03 14:01:00
tags: linux
---

今天弹出一个升级框，天真地点了下去。悲剧发生了。电脑启动不了了。
本来都打算换电脑了。试了一下grub里显示的ubuntu的其他选项。
里面有各种内核版本的普通mode和safe mode。
于是选了旧的3.19版本，
启动成功！喜悦！

<!--more-->

这次是升级到了ubuntu 14.04.5, 看来换4.4内核(linux-headers-4.4.0-36-generic)了
之前装16.04装不了也是相同的症状, 看来就是我手里这台Hasee的硬件问题了。
另外为了避免以后每次启动都要从其他选项里进ubuntu，下面记录怎么删不要的内核版本。

```
uname -r # 查看当前使用的内核版本, 这个版本不要删哦
dpkg --list | grep linux-image # 查看已经安装的内核版本
sudo apt-get purge linux-image-x.x.x.x-generic # 不要的都删
sudo update-grub2 # 更新grub2
```

## 参考链接
http://askubuntu.com/questions/2793/how-do-i-remove-old-kernel-versions-to-clean-up-the-boot-menu

