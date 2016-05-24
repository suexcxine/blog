title: <<The Linux Command Line>> 第三五章笔记 字符串和数字
date: 2015-09-07 20:00:35
tags: [linux, bash]
---
## \${parameter:-word}
若 parameter 没有设置（例如，不存在）或者为空，展开结果是 word 的值。
若 parameter 不为空，则展开结果是 parameter 的值。
```
$ echo ${foo:-"substitute value if unset"}
```
substitute value if unset

## \${parameter:=word}
若 parameter 没有设置或为空，展开结果是 word 的值。另外，word 的值会赋值给 parameter。 
若 parameter 不为空，展开结果是 parameter 的值。
注意： 位置参数或其它的特殊参数不能以这种方式赋值。

## \${parameter:?word}
若 parameter 没有设置或为空，这种展开导致脚本带有错误退出，并且 word 的内容会发送到标准错误。
若 parameter 不为空， 展开结果是 parameter 的值。
```
$ echo ${foo:?"parameter is empty"}
```
bash: foo: parameter is empty

## \${parameter:+word}
若 parameter 没有设置或为空，展开结果为空。
若 parameter 不为空， 展开结果是 word 的值会替换掉 parameter 的值；然而，parameter 的值不会改变。
返回变量名的参数展开
shell 具有返回变量名的能力。这会用在一些相当独特的情况下。

## \${!prefix*}
## \${!prefix@}
这种展开会返回以 prefix 开头的已有变量名。根据 bash 文档，这两种展开形式的执行结果相同。 
这里，我们列出了所有以 BASH 开头的环境变量名：
```
[me@linuxbox ~]$ echo ${!BASH*}
BASH BASH_ARGC BASH_ARGV BASH_COMMAND BASH_COMPLETION
BASH_COMPLETION_DIR BASH_LINENO BASH_SOURCE BASH_SUBSHELL
BASH_VERSINFO BASH_VERSION
```

## \${&#35;parameter}
展开成由 parameter 所包含的字符串的长度。

## \${parameter:offset}
## \${parameter:offset:length}

这些展开用来从 parameter 所包含的字符串中提取一部分字符。
若 offset 的值为负数，则认为 offset 值是从字符串的末尾开始算起，而不是从开头。
注意负数前面必须有一个空格， 为防止与 \${parameter:-word} 展开形式混淆。length，若出现，则必须不能小于零。

## \${parameter#pattern}
## \${parameter##pattern}
这些展开会从 paramter 所包含的字符串中清除开头一部分文本，这些字符要匹配定义的 patten。p
attern 是 通配符模式，就如那些用在路径名展开中的模式。这两种形式的差异之处是该 \# 形式清除最短的匹配结果， 而该 \## 模式清除最长的匹配结果。

```
[me@linuxbox ~]$ foo=file.txt.zip
[me@linuxbox ~]$ echo ${foo#*.}
txt.zip
[me@linuxbox ~]$ echo ${foo##*.}
zip
```

## \${parameter%pattern}
## \${parameter%%pattern}

这些展开和上面的 \# 和 \## 展开一样，除了它们清除的文本从 parameter 所包含字符串的末尾开始，而不是开头。
```
[me@linuxbox ~]$ foo=file.txt.zip
[me@linuxbox ~]$ echo ${foo%.*}
file.txt
[me@linuxbox ~]$ echo ${foo%%.*}
file
```

## time
使用 time 命令来比较这两个脚本版本的效率
time可以测试脚本的执行时间

## declare 命令可以用来把字符串规范成大写或小写字符
使用 declare 命令，我们能强制一个 变量总是包含所需的格式，无论如何赋值给它。
declare -u upper
declare -l lower

## 大小写转换参数展开
* ${parameter,,}    把 parameter 的值全部展开成小写字母。
* ${parameter,}     仅仅把 parameter 的第一个字符展开成小写字母。
* ${parameter^^}    把 parameter 的值全部转换成大写字母。
* ${parameter^}     仅仅把 parameter 的第一个字符转换成大写字母（首字母大写）。

## 在算术表达式中，shell 支持任意进制的整形常量。
* number      默认情况下，没有任何表示法的数字被看做是十进制数（以10为底）。
* 0number     在算术表达式中，以零开头的数字被认为是八进制数。
* 0xnumber    十六进制表示法
* base#number number 以 base 为底

## bc - 一种高精度计算器语言

