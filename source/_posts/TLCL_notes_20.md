title: <<The Linux Command Line>> 第二十章笔记 正则表达式
date: 2015-09-07 20:00:20
tags: [linux, bash]
---
## grep, global regular expression print
* -c     打印匹配的数量（或者是不匹配的数目，若指定了-v 选项），而不是文本行本身。 也可用`--count`选项来指定。
* -l     打印包含匹配项的文件名，而不是文本行本身，也可用--files-with-matches 选项来指定。
* -L     相似于-l 选项，但是只是打印不包含匹配项的文件名。也可用--files-without-match 来指定。

## /usr/share/dict下有英文字典
你知道你的 Linux 系统中带有一本英文字典吗？千真万确。
看一下 /usr/share/dict 目录，你就能找到一本， 或几本。

## locale
使用 locale 命令，来查看 locale 的设置。
把这个 LANG 变量设置为 POSIX，来更改 locale，使其使用传统的 Unix 行为。
```
[me@linuxbox ~]$ export LANG=POSIX
```
注意这个改动使系统为它的字符集使用 U.S.英语（更准确地说，ASCII），所以要确认一下这 是否是你真正想要的效果。
通过把这条语句添加到你的.bashrc 文件中，你可以使这个更改永久有效。

## Alternation
例: 
```
echo "AAA" | grep -E 'AAA|BBB|CCC'
```
为了把 alternation 和其它正则表达式元素结合起来，我们可以使用()来分离 alternation。
```
[me@linuxbox ~]$ grep -Eh '^(bz|gz|zip)' dirlist*.txt
```

## 限定符
扩展的正则表达式支持几种方法，来指定一个元素被匹配的次数。
```
^\(?[0-9]{3}\)?  [0-9]{3}-[0-9]{4}$
```
这样一种扫描会发现包含空格和其它潜在不规范字符的路径名：
```
[me@linuxbox ~]$ find . -regex '.*[^-\_./0-9a-zA-Z].*'
```

## zgrep 程序
grep 的前端，允许 grep 来读取压缩文件。

