title: <<The Linux Command Line>> 第二一章笔记 文本处理
date: 2015-09-07 20:00:21
tags: [linux, bash]
---

## cat -A 
显示非打印字符

## dos2unix & unix2dos
在windows和linux的文本格式之间转换

## sort 
程序能接受命令行中的多个文件作为参数，所以有可能把多个文件合并成一个有序的文件。
例如， 如果我们有三个文本文件，想要把它们合并为一个有序的文件，我们可以这样做：
```
sort file1.txt file2.txt file3.txt > final_sorted_list.txt
```

## uniq 
会删除任意重复行
sort 程序支持一个 -u 选项，其可以从排好序的输出结果中删除重复行。

## cut
```
cut -f 3 distros.txt | cut -c 7-10
```

## expand & unexpand
它既可以接受一个或多个文件参数，也可以接受标准输入，并且把 修改过的文本送到标准输出。
Coreutils 软件包也提供了 unexpand 程序，用 tab 来代替空格。

## paste
与cut相反
```
paste distros-dates.txt distros-versions.txt
```

## join 
操作通常与关系型数据库有关联，在关系型数据库中来自多个享有共同关键域的表格的 数据结合起来，得到一个期望的结果。

## comm
comm -12 file1.txt file2.txt

## diff

## patch

## tr
translate

## sed
stream editor

## aspell

