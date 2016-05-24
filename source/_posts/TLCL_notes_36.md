title: <<The Linux Command Line>> 第三六章笔记 数组
date: 2015-09-07 20:00:36
tags: [linux, bash]
---
Bash 中的数组仅限制为单一维度

数组变量就像其它 bash 变量一样命名，当被访问的时候，它们会被自动地创建。这里是一个例子：
```
[me@linuxbox ~]$ a[1]=foo
[me@linuxbox ~]$ echo ${a[1]}
foo
```
也可以用 declare 命令创建一个数组：
```
[me@linuxbox ~]$ declare -a a
```
数组赋值
有两种方式可以给数组赋值。单个值赋值使用以下语法：
```
name[subscript]=value
```
这里的 name 是数组的名字，subscript 是一个大于或等于零的整数（或算术表达式）。
注意数组第一个元素的下标是0， 而不是1。数组元素的值可以是一个字符串或整数。

多个值赋值使用下面的语法：
```
name=(value1 value2 ...)
```

还可以通过指定下标，把值赋给数组中的特定元素：
```
[me@linuxbox ~]$ days=([0]=Sun [1]=Mon [2]=Tue [3]=Wed [4]=Thu [5]=Fri [6]=Sat)
```

找到数组使用的下标
因为 bash 允许赋值的数组下标包含 “间隔”，有时候确定哪个元素真正存在是很有用的。

