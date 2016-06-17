title: pgrep & pkill
date: 2016-06-16 15:19:00
tags: [linux]
---

pkill可以使用名称给进程发信号,
使用pkill之前,可以用pgrep命令确认一下
```
$ pgrep -a php5-fpm
26677 php-fpm: master process (/etc/php5/fpm/php-fpm.conf)
26680 php-fpm: pool www
26681 php-fpm: pool www
$ sudo pkill -HUP php5-fpm
```
