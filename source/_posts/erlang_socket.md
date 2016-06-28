title: erlang socket
date: 2016-06-28 16:35:00
tags: erlang
---

### controlling process死了以后, port会回收吗? 不回收的话会有内存泄漏吗?
根据下面链接的话
https://mitnk.com/wiki/2012/05/programming_with_sockets_in_erlang/

> If the controlling process dies, then the socket will be automatically closed.

有空可以看看代码

