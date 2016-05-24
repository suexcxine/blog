title: erlang gc 
date: 2015-09-09
tags: [erlang]
---
每个Erlang进程创建之后都会有自己的PCB，栈，私有堆。
<!--more-->
erlang不知道他创建的进程会用到哪种场合下，所以一开始分配的内存比较小。
如果分配的空间不够了，erlang gc会动态调整堆大小以满足需求，如果分配的空间大了，就会收缩堆，回收内存。

## erlang进程堆的gc是分代gc
分代gc的想法基于统计学：大部分数据的生存周期都比较短，最新的数据更容易不再被使用。
这里erlang使 用young heap 和old heap来区分数据，
young heap放新数据，oldheap放旧数据，也就是gc后存活的数据。
erlang进程堆gc有两个主要过程：浅扫描和深扫描

## 浅扫描（minor collection）
![浅扫描](/pics/erlang_gc_shallow.png)

浅扫描是当young heap空间不足时，erlang会对young heap做一次扫描，
把有用的数据复制到新申请的young heap空间，发现已经扫描过1次以上的数据放入old heap，然后删掉原来的young heap
在young heap中，erlang使用了高水位线来区分标记一次以上的数据和未标记的数据，
那么young heap移入old heap的就是超过高水位线的数据

## 深扫描（major collection）
![深扫描](/pics/erlang_gc_deep.png)

深扫描是一般当old heap空间不足时触发，erlang会对young heap和old heap做扫描，
把有用的数据放入新申请的young heap，删掉原来的heap
深扫描的触发条件还有手动执行gc，和gc次数超过fullsweep_after的参数限定

## 控制垃圾回收
以游戏网关进程为例，网关进程通常有大量消息，而大部分消息都只是在网关这里做转发，生命周期很短，所以网关进程可以设定较大的初始内存，较快的内存回收。

spawn_opt(Fun, [{min_heap_size, 5000},{min_bin_vheap_size, 100000},{fullsweep_after, 500}])
先看下参数默认值：
> 1> erlang:system_info(min_heap_size).
> {min_heap_size,233}
> 2> erlang:system_info(min_bin_vheap_size).
> {min_bin_vheap_size,46368}
> 3> erlang:system_info(fullsweep_after).
> {fullsweep_after,65535}

min_heap_size是进程最小堆大小

这个参数两个地方会用到，第一处是erlang初始化进程堆大小，第二处是gc后堆收缩后维持的最小值，min_bin_vheap_size是进 程最小虚拟二进制堆大小，这两个参数都是以word为单位。初始化足够大的初始内存，可以减少轻度gc的次数，减少反复申请和回收内存的开销

fullsweep_after是控制深扫描的频率

这个参数确定多少次gc后执行一次深度gc，默认值为65536，有点大了
所以，上面3个参数配合起来的意义就是，进程初始化分配足够大的内存，减少反复申请内存的开销，
当申请的内存不够用，gc会重新申请内存，累计达到500次就做一次gc

## 手动执行垃圾回收
上面提到了利用fullsweep_after来控制gc的情况，下面再介绍手动gc的情况：
在rabbitMQ看到这段代码，可以在项目中定期执行这个函数：
```erlang
gc() ->
    [erlang:garbage_collect(P) || P <- erlang:processes(), 
        {status, waiting} =:= erlang:process_info(P, status)],
    erlang:garbage_collect(),
    ok.
```
当然，你还可以加入一些判断，比如指定占内存过50M的进程执行gc

## erlang进程占用多少内存
用下面这个方法检查erlang进程占用的内存，你可以换别的参数再试试
Fun = fun()-> receive after infinity -> ok end end.
erlang:process_info(erlang:spawn(Fun), memory).

## erlang垃圾回收的副作用
前面讲到erlang进程堆的gc是分代gc的，这个只是全局层面的，在底层erlang还是标记清除。
标记清除这种gc方式是定期执行的，首先gc不够及时，其次，在gc执行期间开销比较大，会引起中断。
不过每个erlang进程的堆区域是独立的，gc可以独立进行，
加上它内存区域比较小，还有erlang的变量是单次赋值，无需多次追踪，因此，erlang进程gc的延迟不会引起全局的中断

## .erl +h选项
可以调整全局的min_heap_size

## 垃圾回收器的本质
实际上是改变存活数据结构构成图的连通性.
堆对象在图中的存活性是由指针的可到达性定义的.
程序可以操作三种位置的数据:寄存器, 程序栈(局部变量, 临时变量), 全局变量.
这些位置的变量有一部分保存了指向堆数据的引用,他们构成了应用程序的根(Root).
对于用户程序动态分配的内存只能通过Root或者根发出的指针链访问,程序不应该访问其地址空间的随机位置.

## 垃圾回收的经典算法
[1]引用计数方法是和程序执行同时进行,内存管理的开销比较均匀,这样进行没有长时间的挂起内存管理的时间比较稳定,可以获得比较平滑的响应时间;
[2]标记清除 内存单元不会被立即回收,而是处于不可到达状态,直到所有的内存都被耗尽,进行全局级别的遍历来确定哪些单元可以回收.显然这种全局级别的中断在实时性要求较高的系统并不实用,甚至视频游戏都不可能接受在GC时有这么长的停顿.如果实时性方面要求不高,标记清除可以获得比引用计数更好的性能.标记清除的代价还是较高,标记是全局级别的,算法复杂度与整个堆大小成正比;标记清除使得内存空间倾向于碎片化.在物理存储器中碎片化的影响不大,但虚拟存储中会导致辅助存储器和主存之间频繁的交换页面,系统出现颠簸.
[3]节点复制将堆分成两个半区,一个包含现有数据,另一个包含已经被废弃的数据,运行时两个半区的角色不断交换;这样做的优势在于内存分配的开销很小,只需要比较指针,不存在内存碎片的问题.但是内存浪费较大;
[4]标记-整理缩并 标记所有的存活对象 通过重新调整存活对象位置来缩并对象图；更新指向被移动了位置的对象的指针
[5]分代回收 是基于统计学原理的:多数内存块的生存周期都比较短,垃圾收集器应当把更多的精力放在检查和清理新分配的内存块上 

## 参考链接
http://blog.csdn.net/mycwq/article/details/26613275
http://www.cnblogs.com/me-sa/archive/2011/11/13/erlang0014.html

