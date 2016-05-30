title: ulimit
date: 2016-05-30
tags: [linux, socket, pam]
---
The pam_limits.so module applies ulimit limits, nice priority and number of simultaneous login sessions limit to user login sessions.
曾经有个工程需要用root权限,只为了设一个ulimit值...
<!--more-->

### ulimit命令后不设置新limit即可查看当前值
如, 文件描述符数量限制:
```
$ ulimit -n
1024
```
想改值只能改小不能改大

### ulimit里的那些限制对每个shell分别生效
所以在执行程序之前要设置

### 查看全部
```
$ ulimit -a
core file size          (blocks, -c) 999999999
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 31647
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 31647
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
```

### 修改默认值
sudo vim /etc/security/limits.conf
```
*   -       nofile       60000 
```
需要重启或重登录
这样就不需要为ulimit给程序root权限了

## 参考链接
man bash 搜索ulimit

