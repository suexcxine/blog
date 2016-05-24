title: 使用ppa源
date: 2015-07-28
tags: linux
---
## 使用ppa源安装官方源里没有的软件
sudo add-apt-repository ppa:ubuntu-wine/ppa
sudo apt-get update
sudo apt-get install wine
## 删除
cd /etc/apt/sources.list.d/
可以看到关于源的文件,删除即可
或者GUI的方式: 系统设置->软件和更新->其他软件,删除不想要的源

