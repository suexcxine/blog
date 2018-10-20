title: locale
date: 2018-10-20
tags: [linux, locale, terminal]
---

今天登录阿里云时发现如下 warning :

```
Welcome to Alibaba Cloud Elastic Compute Service !

-bash: warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory
```
<!--more-->

原因是 ssh 会把 locale 相关的环境变量 forward 到远端,
而本地 mac 没有设置所以 LC_CTYPE 的值为 UTF-8, 而这个值在远端系统没有,
所以有如上警告

解决方案是在 .zshrc 里加入如下
```
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
```

## 参考链接
https://www.jianshu.com/p/2b24861be987
http://www.cnblogs.com/xlmeng1988/archive/2013/01/16/locale.html

