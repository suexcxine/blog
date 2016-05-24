title: rsync
date: 2015-09-06
tags: [linux]
---
rsync是类unix系统下的数据镜像备份工具——remote sync。
<!--more-->
## 创建/etc/rsyncd.conf配置文件
> uid = root
> gid = root
> use chroot = yes
> max connections = 10
> transfer logging = no
> list = yes
> secrets file = /etc/rsyncd/rsyncd.secrets
> log file = /var/log/rsyncd.log
> pid file = /var/run/rsyncd.pid
> lock file = /var/run/rsyncd.lock
> charset = UTF-8
> read only = yes
> dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2
> hosts allow = *
> [my_share]
> path = /data/share
> auth users = rsy_user
> read only = true
> transfer logging = no
> ignore errors

## 创建/etc/rsyncd/rsyncd.secrets密码文件
> rsy_user:youareaFOOL

修改权限
```bash
sudo chmod 600 rsyncd.secrets
```

## 启动rsync
```
rsync --daemon
```

## 客户端同步数据
```
rsync -azvp rsync://rsy_user@172.16.205.129/my_share ~/tmp
```
