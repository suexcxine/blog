title: CSAPP
date: 2016-08-14 21:35:00
tags: [cs]
---

深入理解计算机系统, 可以像下面这样:

* 避免由于计算机表示数字的方式引入奇怪的数字错误
* 利用现在处理器和内存的设计优化C代码
* 理解编译器如何实现过程调用,避免缓存溢出带来的安全漏洞
* 写自己的shell,自己的动态存储分配等

# Chapter 1 A Tour of Computer Systems

## 1.1 Information Is Bits + Context

计算机里的一切都是0和1, 代表什么意义都看按什么方式去解释(由Context决定),
如文件的基本的解释方式有文本和二进制两种

## 1.2 Programs Are Translated by Other Programs into Different Forms

源代码(如hello.c)到目标代码的几个步骤:
预处理(Pre Processor), 输出hello.i文件 ->
编译(Compiler), 输出hello.s文件 ->
汇编(Assembler), 输出hello.o文件(relocatable object program) ->
链接(Linker), 输出hello文件

## 1.3 It Pays to Understand How Compilation Systems Work

我们需要知道编译系统如何工作

性能优化:

Is a switch statement always more efficient than a sequence of if-else statements?
How much overhead is incurred by a function call?
Is a while loop more efficient than a for loop?
Are pointer references more efficient than array indexes?
Why does our loop run so much faster if .we sum into a local variable instead of an argument that is passed by reference?
How can a function run faster when we simply rearrange the parentheses in an arithmetic expression?

理解链接错误:

what does it mean when the linker reports that it cannot resolve a reference?
What is the difference between a static variable and a.global variable?
What happens if you define two global variables in different C files with the same name?
What is the difference between a static library and a dynamic library?
Why does it matter what order we list libraries on the command line?
And scariest of all, why do some linker-related errors not appear until runtime?

避免安全漏洞:

## 1.4 Processors. Read and Interpret Instructions Stored-in Memory

PC: 程序计数器, 是CPU中的一个寄存器, 保存一个内存地址, 这个地址指向下一个要执行的指令

执行指令时CPU的几种简单操作:

* Load 从内存读到寄存器
* Store 从寄存器写到内存
* Operate 从两个寄存器取出值, 进行算术运算后覆盖到一个寄存器
* Jump 从指令中取出一个word并覆盖PC的值, 实现跳转

## 1.5 Caches Matter

为了尽可能匹配CPU和内存的速度差, CPU内有多级缓存(L1, L2, L3),
只在缓存未命中时才去访问内存, 减少了访问内存的次数

## 1.6 Storage Devices From a Hierarchy

缓存体系: 寄存器 -> 高速缓存 -> 内存 -> 硬盘 -> 分布式系统中网络上的存储

## 1.7 The Operating System Manages the Hardware

操作系统处于应用程序和硬件之间
1, 保护硬件, 避免应用程序误用导致硬件损坏
2, 提供简单通用的接口供应用程序使用硬件

操作系统的三层抽象: 文件 虚拟内存 进程

进程之间的独立使得应用程序之间没有互相干扰,对一个进程而言,好像整个计算机是他独占一样
多个进程通过上下文切换实现并发,
上下文包括PC, register, 内存
上下文切换: 保存当前上下文, 读取并恢复新进程的上下文

线程之间共享code和global data
线程之间共享数据比进程之间要容易 为什么?
而且线程一般比进程高效 为什么?

虚拟内存的概念使得每个进程感觉好像内存是他独占一样
每个进程看到的内存都是一样的, 这叫做虚拟地址空间
进程虚拟地址空间如下:
Kernel virtual memory, 应用程序不允许读写这个区域, 需要调用内核
User stack(created at run time)
Memory-mapped region for shared libraries
Run-time heap(created by malloc)
Read/write data(全局变量之类的)
Read-only code and data(操作系统的代码和数据, 用户进程的代码和数据)

虚拟内存一般是保存在磁盘上并以内存做为缓存

文件就是一列字节
Unix中一切都是文件统一了不同的IO设备(键盘,鼠标,磁盘,显示器,网络,打印机等)

## 1.8 Systems Communicate with Other Systems Using Networks

网络可以视为另一个IO设备, 也是文件

## 1.9 Important Themes

Amdahl定律

超线程: 一个核能同时跑多个线程, 比如Intel Core i7一个核可以同时跑两个线程
有多个程序计数器和寄存器,但是只有一个ALU等,普通CPU线程切换要20000个时钟周期,
而超线程每个周期都要决定在哪个线程上执行, 这样可以更好地利用计算资源,
当一个线程等待(比如因为内存太慢在等)时这个核就可以去执行另一个线程

指令级并行
现在CPU可以同时执行多个指令.原理是将指令的执行分成多个step,分成组,每组由一个硬件执行

单指令,多数据并行(SIMD)
有些硬件支持一条执行,多数据并行,比如一个浮点加法,八对数据同时做加法
主要用于视频,声音图像的处理

计算机系统中抽象的重要性

文件 + 内存 -> 虚存 + CPU -> 进程 + 操作系统 -> 虚拟机

# Chapter 2 Representing and Manipulating Information

整型要考虑溢出
浮点数不满足结合律, (3.14 + 1e20) - 1e20 = 0.0 而 3.14 + (1e20 - 1e20) = 3.14


