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

### 当docker遇到terminal

docker run时如果没有加-t,则container的环境变量里不会有TERM=xterm,                
```
docker exec -it $container bash
```
如上进入后环境变量里仍然没有TERM=xterm, 反直觉, 这里的-t参数无效
docker team给出的理由是exec并不会新建一个container,而是在原来的container里执行, 所以原来没-t现在加-t也没用, 
那exec的-t参数是干什么用的? 结果是exec时不设-t也不行, 也不能正常工作             
最后只能这样
```
docker exec -it $container /bin/bash -c "export TERM=xterm; command" 
```
或者在docker run时加上-t  

## 参考链接
http://unix.stackexchange.com/questions/43945/whats-the-difference-between-various-term-variables
http://stackoverflow.com/questions/30913579/ctrlg-in-erl-doesnt-work
https://andykdocs.de/development/Docker/Fixing+the+Docker+TERM+variable+issue

