title: erlang interoperability
date: 2015-09-07
tags: erlang
---
erlang跨语言调用
<!--more-->
## ports
erlang的port方式做跨语言调用会启动一个外部的操作系统进程, 
就像后端和前端交互一样与这个进程交互

## erl_interface 
官方自带的例子有点问题,得加上-lpthread才能编译通过,如下
```bash
gcc -o extprg -I/usr/local/lib/erlang/lib/erl_interface-3.7.6/include/ -L/usr/local/lib/erlang/lib/erl_interface-3.7.6/lib/ \
complex.c erl_comm.c ei.c -lerl_interface -lei -lpthread
```

测试
```erlang
> complex2:start("extprg").
这里根据搜索路径可能需要改成complex2:start("./extprg").
```

## port driver
erlang的port driver官方自带的例子有问题
```bash
官方: gcc -o exampledrv -fpic -shared complex.c port_driver.c
正确的应该是: gcc -o example_drv.so -fpic -shared complex.c port_driver.c -I /usr/local/lib/erlang/usr/include/
```

## c_node
c node结点名的规则
If short node names are used, the plain name of the node will be cN where N is an integer. 
If long node names are used, there is no such restriction. 
An example of a C node name using short node names is thus c1@idril, an example using long node names is cnode@idril.ericsson.se.

遇到的问题
```
cnode_s.c: In function ‘my_listen’:
cnode_s.c:87:5: warning: incompatible implicit declaration of built-in function ‘memset’ [enabled by default]
     memset((void*) &addr, 0, (size_t) sizeof(addr));
     ^
/usr/bin/ld: cannot find -lsocket
```
解决过程:
去掉了-lsocket

编译短名称的cserver
```
gcc -o cserver -I /usr/local/lib/erlang/lib/erl_interface-3.7.6/include/ -L /usr/local/lib/erlang/lib/erl_interface-3.7.6/lib/ complex.c cnode_s.c -l erl_interface -l ei -l nsl -l pthread
```

编译长名称的cserver2
```
gcc -o cserver2 -I /usr/local/lib/erlang/lib/erl_interface-3.7.6/include/ -L /usr/local/lib/erlang/lib/erl_interface-3.7.6/lib/ complex.c cnode_s2.c -l erl_interface -l ei -l nsl -l pthread
```

编译cclient
```
gcc -o cclient -I /usr/local/lib/erlang/lib/erl_interface-3.7.6/include/ -L /usr/local/lib/erlang/lib/erl_interface-3.7.6/lib/ complex.c cnode_c.c -l erl_interface -l ei -l nsl -l pthread
```

使用短名称的示例:
```
$ ./cserver 3459
Connected to e1@chenduo-desktop

$ erl -sname e1 -setcookie secretcookie
Erlang R15B (erts-5.9) [source] [smp:4:4] [async-threads:0] [hipe] [kernel-poll:false]

Eshell V5.9  (abort with ^G)
(e1@chenduo-desktop)1>
(e1@chenduo-desktop)1> complex3:foo(3).
4
(e1@chenduo-desktop)2> complex3:bar(3).
6
```

使用长名称的示例:
```
$ ./cserver2 3459
Connected to e1@192.168.1.113

$ erl -name e1@192.168.1.113 -setcookie secretcookie
Erlang R15B (erts-5.9) [source] [smp:4:4] [async-threads:0] [hipe] [kernel-poll:false]

Eshell V5.9  (abort with ^G)
(e1@192.168.1.113)1> complex4:bar(2).
4
(e1@192.168.1.113)2> complex4:bar(2).
4
(e1@192.168.1.113)3> complex4:foo(3).
4
(e1@192.168.1.113)4> complex4:foo(30).
31
```

使用cclient的示例
```
$ ./cclient
Connected to ei@chenduo-desktop

$ erl -sname e1 -setcookie secretcookie
Erlang R15B (erts-5.9) [source] [smp:4:4] [async-threads:0] [hipe] [kernel-poll:false]

Eshell V5.9  (abort with ^G)
(e1@chenduo-desktop)1> complex3:foo(3).
4
(e1@chenduo-desktop)2> complex3:foo(4).
5
(e1@chenduo-desktop)3> complex3:bar(4).
8
```

## NIF
NIFs are most suitable for synchronous functions like foo and bar in the example, 
that does some relatively short calculations without side effects and return the result
适用于相对简单且无副作用的同步函数调用

a crash in a NIF will bring the emulator down

We use the directive on_load to get function init to be automatically called when the module is loaded. 
If init returns anything other than ok, such when the loading of the NIF library fails in this example, 
the module will be unloaded and calls to functions within it will fail.

Loading the NIF library will override the stub implementations and cause calls to foo and bar to be dispatched to the NIF implementations instead.

编译
```
$ gcc -o complex6_nif.so -fpic -shared complex.c complex6_nif.c -I /usr/local/lib/erlang/usr/include/
```

测试
```
$ erl
Erlang R15B (erts-5.9) [source] [smp:4:4] [async-threads:0] [hipe] [kernel-poll:false]

Eshell V5.9  (abort with ^G)
1> c(complex6).
{ok,complex6}
2> complex6:foo(100).
101
3> complex6:foo(1000000000000).
** exception error: bad argument
     in function  complex6:foo/1
        called as complex6:foo(1000000000000)
4> complex6:bar(3000).         
6000
```

## 源码下载
[interoperability](/attachments/interoperability.tar.gz)

## 参考链接
http://www.erlang.org/doc/tutorial/introduction.html

