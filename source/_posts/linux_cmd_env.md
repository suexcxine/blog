title: netcat
date: 2016-06-04 17:17:00
tags: linux
---

env命令, 以前只知道可以看环境变量, 没想到还能设置或移除
<!--more-->

## 查看环境变量
```
$ env
```

## 设置环境变量(允许多个), 并执行指定的命令
```
$ env TERM=a COLORTERM=b bash
$ env | grep TERM
TERM=a
COLORTERM=b
```

## 移除环境变量(允许多个), 并执行指定的命令
参数-u
```
$ env -u TERM -u HOME -u COLORTERM bash
$ env | grep TERM
$ env | grep HOME
```

