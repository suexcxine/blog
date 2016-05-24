title: Ubuntu中创建SWAP交换文件
date: 2015-07-22
tags: linux 
---
划分交换文件最佳的方式就是将其放到一个单独的分区当中， 
当然，如果无法单独为其划分的话也可以在已有的分区上创建新的交换文件。
<!--more-->
## 查看当前系统Swap信息

开始在 Ubuntu 14.04 中创建 Swap 分区之前，我们有必要首先看一下当前操作系统是否有可用的交换分区。
默认情况下，Ubuntu 在进行系统安装时就会提醒用户划分 Swap 分区，一般情况下划分好之后也是不太会更改的。

我们可以使用如下命令来进行查看：
```bash
sudo swapon -s
```
当然，我们也可以使用最常用的 free 命令来查看当前系统是否存在 Swap 交换分区：
```bash
free -m
```
## 查看磁盘分区的空闲空间

在创建新的 Swap 交换分区或创建交换文件之前，我们需要通过如下命令了解下当前系统对磁盘空间的使用情况：
```bash
df -h
```
确定好磁盘的空闲空间后，你已经可以根据你自己的实际情况来决定如何划分和创建 Swap 交换分区了。

## 创建swap文件
一般情况下，创建 Swap 分区的大小都为当前系统使用的物理内存大小或内存大小的倍数。

如果同样是要创建 4G 大小的交换文件，命令如下：
```bash
sudo fallocate -l 4G /swapfile
```
## 启用Swap分区文件

我们的 swapfile 交换文件已经创建好了，但 Ubuntu 14.04 还不知道它是被用作交换分区，所以我们还需要将此文件格式化为 Swap 分区交启用它。

首先，我们需要使用如下命令更改下 swapfile 文件的权限，以避免其被无意理性到：
```bash
sudo chmod 600 /swapfile
```
然后，我们需要用如下将 swapfile 初始化为交换文件：
```bash
sudo mkswap /swapfile
```
最后，还需要使用如下命令来启用交换文件：
```bash
sudo swapon /swapfile
```
配置启用时挂载Swap分区文件

Swap 交换文件虽然已经配置好并已经启用了，但 Ubuntu 14.04 在重启后是不会挂载我们刚创建的交换分区文件的，因此我们还需要对 /etc/fstab 文件进行更改，让其在系统启动时就自动挂载我们创建的 /swapfile 文件。

使用 vi 或 nano 在 /etc/fstab 文件底部添加如下内容：
```bash
/swapfile none swap sw 0 0
```
## 附录

还有一个swapoff命令

