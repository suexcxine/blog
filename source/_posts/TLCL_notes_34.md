title: <<The Linux Command Line>> 第三四章笔记 流程控制：for 循环
date: 2015-09-07 20:00:34
tags: [linux, bash]
---
## for: 传统 shell 格式
原来的 for 命令语法是：
```
for variable [in words]; do
    commands
done
```
如果省略掉 for 命令的可选项 words 部分，for 命令会默认处理位置参数。

## for: C 语言格式
最新版本的 bash 已经添加了第二种格式的 for 命令语法，该语法相似于 C 语言中的 for 语法格式。 
其它许多编程语言也支持这种格式：
```
for (( expression1; expression2; expression3 )); do
    commands
done
```

