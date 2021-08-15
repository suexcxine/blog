title: time zone
date: 2021-07-15

tags: [linux]
---

ubuntu 下这样修改时区

<!--more-->

查看时当前时区

$ cat /etc/timezone
Etc/UTC

修改时区

$ timedatectl set-timezone Asia/Shanghai

