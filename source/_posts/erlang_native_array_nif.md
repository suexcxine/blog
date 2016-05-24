title: erlang native array nif
date: 2015-12-25
tags: [erlang]
---

erlang nif实现的一个数组

<!--more-->

<pre>
Erlang R15B03 (erts-5.9.3.1) [source] [64-bit] [smp:4:4] [async-threads:0] [hipe] [kernel-poll:false]

Eshell V5.9.3.1  (abort with ^G)
1> native_array:new(13, 10000).
ok
2> native_array:put(13, 345, 103).
ok
3> native_array:get(13, 345).
103
4> native_array:put(13, 6645, 255).
ok
5> native_array:get(13, 6645).     
255
</pre>

### 内存分配在system里, 调用delete后立即释放
<pre>
> native_array:new(1, 100000000).
ok
> memory().
[{total,116695824},
 {processes,5250144},
 {processes_used,5249120},
 {system,111445680},
 {atom,256313},
 {atom_used,223947},
 {binary,100879232},
 {code,5342662},
 {ets,305112}]
> native_array:delete(1).
ok
> memory().              
[{total,16782792},
 {processes,5251440},
 {processes_used,5250264},
 {system,11531352},
 {atom,256313},
 {atom_used,223947},
 {binary,964896},
 {code,5342662},
 {ets,305112}]
</pre>

## 源码下载
https://github.com/suexcxine/native_array

## 参考链接
https://github.com/chitika/cberl
https://github.com/davisp/nif-examples

