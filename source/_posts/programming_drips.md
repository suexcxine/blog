title: 编程点滴
date: 2019-01-29 20:04:00
tags: programming
---
日常引起思考的点点滴滴
<!--more-->

#### 对一个 byte 执行 & 0xff 是干什么? 意义何在?
例:
```
int n = (0xff & byte_a) + (0xff & byte_b);
```
根本原因是 Java 这样的语言里没有 unsigned byte
在处理二进制数据的时候为了得到一个 unsigned byte 的效果, 就只能这么做了
0xff 一个 32 位字面值, 即 00 00 00 ff , 和一个 byte 做与运算后得到一个int
如: -1 会变成 255 , 而 255 正是想要的 unsigned byte 值
反之, 如果直接 `int n = byte_a;` 就会得到 -1

保持二进制补码的一致性 因为byte类型字符是8bit的  而int为32bit 会自动补齐高位1
所以与上0xFF之后可以保持高位一致性 当byte要转化为int的时候，高的24位必然会补1，这样，其二进制补码其实已经不一致了，
& 0xff可以将高的24位置为0，低8位保持原样，这样做的目的就是为了保证二进制数据的一致性。

