title: erlang ets
date: 2015-09-14
tags: erlang
---
## 进程terminate后ets被销毁的问题

专门启动一个table manager进程,这个进程只负责做ets表的heir
这样就不用担心进程terminate后ets表访问不到了

## compressed选项

可以节约一些内存,缺点是操作会慢一些,尤其是match和select操作会慢很多
目前的实现里key不会压缩
注意: 简单的数据的情况下,压缩可能反而会占更多的内存,看下面的例子

<pre>
1> ets:new(abc, [named_table, compressed]).                             
abc
2> ets:new(def, [named_table]).                                         
def
3> L = lists:zip(lists:seq(1, 1000000), lists:duplicate(1000000, "hello world")).
...
4> ets:insert(abc, L).                                                           
true
5> ets:insert(def, L).                                                           
true
6> ets:info(abc, memory).
10144941
7> ets:info(def, memory).
29144941
8> L2 = lists:zip(lists:seq(1, 1000000), lists:duplicate(1000000, xxx)).
...
9> ets:insert(abc, L2).                                                           
true
10> ets:insert(def, L2).                                                           
true
11> ets:info(abc, memory).
8144942
12> ets:info(def, memory).                                                         
7144942
13> ets:info(abc, compressed).
true
14> ets:info(abc).
[{read_concurrency,false},
 {write_concurrency,false},
 {compressed,true},
 {memory,8144941},
 {owner,<0.34.0>},
 {heir,none},
 {name,abc},
 {size,1000000},
 {node,nonode@nohost},
 {named_table,true},
 {type,set},
 {keypos,1},
 {protection,protected}
]
</pre>

## 源码
首先, 下载erlang源码
https://github.com/erlang/otp 
BIF表
./erts/emulator/beam/bif.tab 
相关c代码
./erts/emulator/beam/erl_db_util.c
./erts/emulator/beam/erl_db.c
./erts/emulator/beam/erl_db_tree.c
./erts/emulator/beam/erl_db_hash.c
相关erl代码
./lib/stdlib/src/ets.erl

## 参考链接
https://github.com/erlang/otp
http://www.erlang.org/doc/man/ets.html
http://mryufeng.iteye.com/blog/113856

