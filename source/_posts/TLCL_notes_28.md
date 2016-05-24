title: <<The Linux Command Line>> 第二八章笔记 流程控制：if 分支结构
date: 2015-09-07 20:00:28
tags: [linux, bash]
---
## if语法
```
x=5
if [ $x = 5 ]; then
    echo "x equals 5."
elif [ $x = 3 ]; then
    echo "x equals 3."
else
    echo "x does not equal 5."
fi
```

## 退出状态 & true & false

当命令执行完毕后，命令（包括我们编写的脚本和 shell 函数）会给系统发送一个值，叫做退出状态。 
这个值是一个 0 到 255 之间的整数，说明命令执行成功或是失败。
按照惯例，一个零值说明成功，其它所有值说明失败。 Shell 提供了一个参数，我们可以用echo $?检查退出状态。
shell 提供了两个极其简单的内部命令，它们不做任何事情，除了以一个零或1退出状态来终止执行。 
true 命令总是执行成功，而 false 命令总是执行失败：
如果 if 之后跟随一系列命令，则将计算列表中的最后一个命令：

## 测试

到目前为止，经常与 if 一块使用的命令是 test。
这个 test 命令执行各种各样的检查与比较。 它有两种等价模式：
test expression
比较流行的格式是：
[ expression ]
例:
```
#!/bin/bash
# test-file: Evaluate the status of a file
FILE=~/.bashrc
if [ -e "$FILE" ]; then
    if [ -f "$FILE" ]; then
        echo "$FILE is a regular file."
    fi
    if [ -d "$FILE" ]; then
        echo "$FILE is a directory."
    fi
    if [ -r "$FILE" ]; then
        echo "$FILE is readable."
    fi
    if [ -w "$FILE" ]; then
        echo "$FILE is writable."
    fi
    if [ -x "$FILE" ]; then
        echo "$FILE is executable/searchable."
    fi
else
    echo "$FILE does not exist"
    exit 1
fi
exit
```
引号并不是必需的，但这是为了防范空参数。如果$FILE的参数展开 是一个空值，就会导致一个错误（操作符将会被解释为非空的字符串而不是操作符）。用引号把参数引起来就 确保了操作符之后总是跟随着一个字符串，即使字符串为空。
exit 命令接受一个单独的，可选的参数，其成为脚本的退出状态。当不传递参数时，退出状态默认为零。

## 更现代的测试版本
目前的 bash 版本包括一个复合命令，作为加强的 test 命令替代物。它使用以下语法：
[[ expression ]]

这个[[ ]]命令非常 相似于 test 命令（它支持所有的表达式），但是增加了一个重要的新的字符串表达式：

string1 =~ regex
如果 string1匹配扩展的正则表达式 regex,其返回值为真

[[ ]]添加的另一个功能是==操作符支持类型匹配，正如路径名展开所做的那样。

## (( )) - 为整数设计

## 结合表达式
操作符     测试     [[ ]] and (( ))
* AND        -a     &&
* OR         -o     ||
* NOT         !     !

一个像这样的命令：
```
[me@linuxbox ~]$ [ -d temp ] || mkdir temp
```
会测试目录 temp 是否存在，并且只有测试失败之后，才会创建这个目录。

