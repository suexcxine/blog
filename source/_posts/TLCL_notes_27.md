title: <<The Linux Command Line>> 第二七章笔记 自顶向下设计
date: 2015-09-07 20:00:27
tags: [linux, bash]
---
## 函数
Shell 函数有两种语法形式：
```
function name {
    commands
    return
}
```
和
```
name () {
    commands
    return
}
```

注意为了使函数调用被识别出是 shell 函数，而不是被解释为外部程序的名字，所以在脚本中 shell 函数定义必须出现在函数调用之前。

## 局部变量
```
foo=0 # global variable foo
funct_1 () {
    local foo  # variable foo local to funct_1
    foo=1
    echo "funct_1: foo = $foo"
}
```

## .bashrc 文件中的 shell 函数
Shell 函数是更为完美的别名替代物，实际上是创建较小的个人所用命令的首选方法。
别名 非常局限于命令的种类和它们支持的 shell 功能，然而 shell 函数允许任何可以编写脚本的东西。

