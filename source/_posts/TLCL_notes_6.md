title: <<The Linux Command Line>> 第六章笔记
date: 2015-09-07 20:00:06
tags: [linux, bash]
---
## 命令

命令可以是下面四种形式之一：

* 一个可执行程序，就像我们所看到的位于目录/usr/bin中的文件一样。属于这一类的程序，可以是二进制文件，诸如用C和C++语言写成的程序, 也可以是由脚本语言写成的程序，比如说shell，python等等。
* 一个内建于shell自身的命令。bash 支持若干命令，内部叫做shell内部命令 (builtins)。例如，cd 命令，就是一个shell内部命令。
* 一个 shell 函数。这些是小规模的shell脚本，它们混合到环境变量中。在后续的章节里，我们将讨论配置环境变量以及书写shell函数。但是现在，仅仅意识到它们的存在就可以了。
* 一个命令别名。我们可以定义自己的命令，建立在其它命令之上。

type － 显示命令的类型

which － 显示一个可执行程序的位置

help － 得到 shell 内部命令的帮助文档

apropos － 搜索参考手册并显示适当的命令

whatis － 显示非常简洁的命令说明

## 别名
使用alias之前用type检查打算使用的别名名称是否已被占用
```
alias foo='cd /usr; ls; cd -'
```

删除别名，使用 unalias 命令，像这样：
```
unalias foo
```

直接输入alias显示所有别名

