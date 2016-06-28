title: erlang 19.0发布啦
date: 2016-06-28 11:27:00
tags: erlang
---

光阴似箭, 迎来了19.0

<!--more-->

看看有哪些新特性吧

### compiler, stdlib
新的预处理器宏, ?FUNCTION_NAME, ?FUNCTION_ARITY 
新的预处理器指令, -error(Term)和-warning(Term), 用于产生编译错误和警告

### gen_statem
新的状态机behavior, 取代gen_fsm

### mnesia_ext
用于接入外部存储的mnesia插件, mnesia可以用上mysql, redis了?

### crypto
性能更好且支持硬件加速(HW acceleration)

### ssh
使用gen_statem提升了性能

### ssl
改善错误日志

### dialyzer
对map的支持大幅扩展, 包括type specification语法和type analysis

### erts
erlang:open_port(spawn, ...), 快3-5倍
tracing, 大幅改进(可伸缩性,性能,send/receive上的match specification,支持lttng,...)
dirty调试器改进
单进程级的message_queue配置
多module的快速加载
增加一个process flag: max_heap_size

### erts/kernel
Unix Domain Socket的试验性支持, 如
```
gen_udp:open(0, [{ifaddr,{local,"/tmp/socket"}}])
```

## 参考链接
http://www.erlang.org/download/otp_src_19.0.readme

