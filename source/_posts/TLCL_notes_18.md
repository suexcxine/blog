title: <<The Linux Command Line>> 第十八章笔记 查找文件
date: 2015-09-07 20:00:18
tags: [linux, bash]
---
## locate & updatedb 
数据库由另一个叫做 updatedb 的程序创建

## find
添加测试条件-type d 限制了只搜索目录。-type f 限制只搜索文件, -size 指定大小
```
find ~ -type f -name "\*.JPG" -size +1M | wc -l
```
find命令的预定义操作例如-delete,一定要放到末尾,否则可能会有灾难性后果,因为可能测试(如-type, -name)还没做就删除了
-ok参数可以在执行前询问用户是否确认
```
find ~ -type f -name 'foo*' -exec ls -l '{}' +
```
### 处理古怪的文件名
类 Unix 的系统允许在文件名中嵌入空格（甚至换行符）。
这就给一些程序，如为其它 程序构建参数列表的 xargs 程序，造成了问题。
一个嵌入的空格会被看作是一个界定符，生成的 命令会把每个空格分离的单词解释为单独的参数。
为了解决这个问题，find 命令和 xarg 程序 允许可选择的使用一个 null 字符作为参数分隔符。
一个 null 字符被定义在 ASCII 码中，由数字 零来表示（相反的，例如，空格字符在 ASCII 码中由数字32表示）。
find 命令提供的 -print0 行为， 则会产生由 null 字符分离的输出，并且 xargs 命令有一个 –null 选项，这个选项会接受由 null 字符 分离的输入。
这里有一个例子：
```
find ~ -iname ‘*.jpg’ -print0 | xargs –null ls -l
```
使用这项技术，我们可以保证所有文件，甚至那些文件名中包含空格的文件，都能被正确地处理。
                
## stat命令
显示文件详细信息

