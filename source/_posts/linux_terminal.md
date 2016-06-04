title: linux terminal
date: 2016-06-04
tags: linux
---

terminal还是有挺多内容的...

<!--more-->
## Ubuntu终端Terminal常用快捷键
F11全屏

### 各种term type的区别
如xterm支持颜色,而vt220不支持颜色, 在shell里执行top, 按z键可以看到颜色, 而 TERM=vt220 top再按z键就没有颜色
使用命令infocmp, 如: `infocmp xterm vt220`, 可以查看具体区别

### 查看所有的terminfo
```
toe -a
或
toe /usr/share/terminfo
```

### 查看当前terminfo的信息
```
infocmp
```

### 常见terminfo

* xterm: X Window System上的标准虚拟终端
* linux: Ctrl+Alt+F1这种情况时
* screen: 在GNU screen中 
* dumb: 字符终端, 只有最基本的输入输出功能, 不能执行删行,清屏,控制光标位置等特殊换码顺序操作

## 参考链接
http://unix.stackexchange.com/questions/43945/whats-the-difference-between-various-term-variables

