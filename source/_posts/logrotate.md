title: logrotate
date: 2016-09-06 21:09:00
tags: [linux, log]
---

linux自带的日志滚动工具, 依赖crond定时调用

<!--more-->

## 相关文件

/etc/cron.daily/logrotate # 告诉crontab每天调用logrotate
/usr/sbin/logrotate # logrotate的可执行文件
/etc/logrotate.conf 和 /etc/logrotate.d # logrotate自己的配置文件

## 与supervisor结合使用

禁用supervisor的log backup而使用logrotate
```
stdout_logfile_maxbytes=0
stderr_logfile_maxbytes=0

stdout_logfile_backups=0
stderr_logfile_backups=0
```

每天rotate, 保存60份, 压缩
```
/var/log/supervisor/my_app_*.log {
 daily
 rotate 60
 copytruncate
 compress
 missingok
 notifempty
}
```

copytruncate
有些程序你无法让他关闭原日志文件，于是只能这样，即通过先copy再truncate原日志文件来实现滚动，
copy和truncate之间有一小段时间差，这时的日志会丢失

missingok
如果找不到日志文件，跳过，不报错

notifempty
如果日志文件是空的，不要滚动

## 参考链接
https://www.rounds.com/blog/easy-logging-with-logrotate-and-supervisord/
http://www.thegeekstuff.com/2010/07/logrotate-examples/

