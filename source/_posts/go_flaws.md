title: go语言槽点
date: 2016-07-19 21:27:00
tags: go
---

想起一条写一条

## 定义类型的地方允许`x, y, z int`这种写法表示x, y, z均为int型
可读性不好

## 没有重载, 许多package里看到大片的XXXInt, XXXInt64, XXXUint64, ...
视觉污染, 写代码麻烦, 改代码也麻烦

## defer
* 可读性不好, 本身就已经颠覆了一般性的顺序执行思维, 多条defer在一起还是LIFO顺序
还是像其他语言那样try finally比较好
* 容易引发bug, 因为defer可以修改return语句的值, 使得return语句处具有不确定性,
使得程序员容易搞错

## var, :=, =
太容易出错了, 何必整这么多种, 像python或erlang那样都是=对大家都好 
平白增加程序员需要处理的细节, 与go宣传的简单化背道而驰

