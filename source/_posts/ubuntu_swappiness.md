title: Ubuntu swappiness
date: 2015-07-16
tags: linux
---
swappiness=0表示最大限度使用物理内存
swappiness=100表示积极的使用swap分区，并且把内存上的数据及时的搬运到swap
ubuntu的默认值为60，可以修改为10：
1.查看当前swappiness
```bash
$ cat /proc/sys/vm/swappiness
```
2.修改swappiness值为10
```bash
$ sudo sysctl vm.swappiness=10
```
但这只是临时有效的修改，重启系统后会恢复默认的60，所以，还要做一步：
```bash
$ vim /etc/sysctl.conf
```
在这个文档的最后加上这样一行:
```bash
vm.swappiness=10
```
