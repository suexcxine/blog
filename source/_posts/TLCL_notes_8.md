title: <<The Linux Command Line>> 第八章笔记 从shell眼中看世界
date: 2015-09-07 20:00:08
tags: [linux, bash]
---
bash在执行你的命令之前做的预处理
## 展开 
* 通配符
* 波浪线~
* 算术表达式展开
* 花括号 
* 参数展开
* 历史记录展开
* 命令替换
* 引用
* 双引号
* 单引号
* 转义字符
* 转义序列

展开不会包括隐藏文件,除非以.*这样的方式展开

## 算术表达式展开
$((expression)) 只支持整数四则运算,取余和幂

## 花括号展开
```
mkdir {2007..2009}-0{1..9} {2007..2009}-{10..12}
```

## 历史记录展开
!!      重复最后一次执行的命令。可能按下上箭头按键和 enter 键更容易些。
!number 重复历史列表中第 number 行的命令。

## 命令替换 
```
ls -l $(which cp) 等同于 ls -l `which cp`
```

## 双引号 
除了 $，\ (反斜杠），和 `（反引号）之外， 当作普通字符来看待

## 单引号
禁止所有的展开

## 转义字符
反斜杠

## 转义序列
```
\a \b \t等等 
可以这样解释: $'\n' 或 echo -e 解释转义字符,否则不解释 
```

