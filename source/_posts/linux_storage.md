title: linux storage
date: 2015-09-06
tags: linux
---
## 关于磁盘第一个分割区前面预留的1MiB空间
1. 以前的硬盘分割MBR常常说MBR是512bytes,这是早期的规格,就是指第1個分割区前面的空白是512 bytes = 1 sector
现在Ubuntu预设,第1個分割区前面的空白是1048576 bytes = 1 MiB = 2048 sectors = 0 ~ 2047 sector
所以gparted第一個分割区前面预留1 MiB空白空间
fdisk 指令
parted 指令
gdisk 指令
....
第一个分区都是从第2048个sector开始

2. 这1 MiB的用途
除了前面512 bytes还是存放MBR信息以外 (0~445放开机引导信息446~511放分区信息)
后面还有2047个512 sectors留给其它程序使用,例如RAID LVM等等

## 检查某分区的block size
sudo blockdev --getbsz /dev/sda1


