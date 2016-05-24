title: <<The Linux Command Line>> 第三二章笔记 流程控制：case 分支
date: 2015-09-07 20:00:32
tags: [linux, bash]
---
## case
Bash 的多选复合命令称为 case。它的语法规则如下所示：
```
case word in
    [pattern [| pattern]...) commands ;;]...
esac
```

### 模式
* a)     若单词为 “a”，则匹配
* [[:alpha:]])     若单词是一个字母字符，则匹配
* ???)     若单词只有3个字符，则匹配
* *.txt)     若单词以 “.txt” 字符结尾，则匹配
* *)     匹配任意单词。把这个模式做为 case 命令的最后一个模式，是一个很好的做法， 可以捕捉到任意一个与先前模式不匹配的数值；也就是说，捕捉到任何可能的无效值。
还可以使用竖线字符作为分隔符，把多个模式结合起来。这就创建了一个 “或” 条件模式。

### 执行多个动作
现在的 bash 版本，添加 “;;&” 表达式来终允许 case 语句继续执行下一条测试，而不是简单地终止运行。
```
#!/bin/bash
# case4-2: test a character
read -n 1 -p "Type a character > "
echo
case $REPLY in
    [[:upper:]])    echo "'$REPLY' is upper case." ;;&
    [[:lower:]])    echo "'$REPLY' is lower case." ;;&
    [[:alpha:]])    echo "'$REPLY' is alphabetic." ;;&
    [[:digit:]])    echo "'$REPLY' is a digit." ;;&
    [[:graph:]])    echo "'$REPLY' is a visible character." ;;&
    [[:punct:]])    echo "'$REPLY' is a punctuation symbol." ;;&
    [[:space:]])    echo "'$REPLY' is a whitespace character." ;;&
    [[:xdigit:]])   echo "'$REPLY' is a hexadecimal digit." ;;&
esac
```
当我们运行这个脚本的时候，我们得到这些：
```
[me@linuxbox ~]$ case4-2
Type a character > a
'a' is lower case.
'a' is alphabetic.
'a' is a visible character.
'a' is a hexadecimal digit.
```

