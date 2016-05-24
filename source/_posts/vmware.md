title: vmware
date: 2015-07-30
tags: linux
---
## 安装vmware
官网下载workstation
sudo chmod +x ./VMware-Workstation-Full-11.1.2-2780323.x86_64.bundle 
sudo ./VMware-Workstation-Full-11.1.2-2780323.x86_64.bundle
Key: ZC79R-F3Z15-H8E5Z-TXMEE-PUU8F
<!--more-->
## 安装ubuntu虚拟机
使用ubuntu的iso镜像安装

## 安装vmware tools
首先虚拟机的右键菜单里选择安装vmware tools,虚拟机会加载一个光盘,打开shell
虚拟机里需要先安装编译用的东西 
```bash
sudo apt-get install build-essential
sudo apt-get install linux-headers-`uname -r`
cp /cdrom/*.gz /tmp/ # 此处cdrom可能会对应于/media/xxxxx/xxx
cd /tmp
tar xvzf VM*.gz
cd vmware*
sudo ./vmware-install.pl
```
出现提示时一律使用默认

## 共享文件夹
要求已安装vmware tools
虚拟机右键菜单Settings->Options->Always Enabled->添加文件夹
重启虚拟机
/mnt/hgfs/share即是共享文件夹
如下命令可用于检查是否已经加载成功
```bash
lsmod | grep vmhgfs
```
如果没有结果,尝试下面的命令
```bash
modprobe vmhgfs
```
如果报错,可能是因为没有安装vmware tools

## 焦点移出
vmware使用ctrl + alt将光标移出虚拟机


