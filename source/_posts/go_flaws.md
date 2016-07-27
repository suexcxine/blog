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
可读性不好, 本身就已经颠覆了一般性的顺序执行思维, 多条defer在一起还是LIFO顺序
还是像其他语言那样try finally比较好
