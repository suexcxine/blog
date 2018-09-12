title: aws ec2时区设定
date: 2018-09-12
tags: [aws, ec2, timezone]
---

有时候服务器时区不想用UTC, 需要修改
<!--more-->

## 时区设定

修改这个文件里的ZONE
```
sudo vi /etc/sysconfig/clock
```
可选项可以看这里
```
ls /usr/share/zoneinfo
```
如下例:
```
ZONE="America/Los_Angeles"
```

修改软链
```
sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
```
重启
```
sudo reboot
```

## 参考链接
http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/set-time.html#change_time_zone

