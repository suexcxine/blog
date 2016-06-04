title: erlang remsh
date: 2016-06-04
tags: [erlang]
---

连接erlang remote shell的几种方式方法

<!--more-->

### 启动a shell

```
$ erl -name a@127.0.0.1 -setcookie abc
Erlang R15B03 (erts-5.9.3.1) [source] [64-bit] [smp:4:4] [async-threads:0] [hipe] [kernel-poll:false]

Eshell V5.9.3.1  (abort with ^G)
(a@127.0.0.1)1> 
```

### 启动b shell后通过JCM(Job Control Mode)远程连接a shell

```
$ erl -name b@127.0.0.1 -setcookie abc
Erlang R15B03 (erts-5.9.3.1) [source] [64-bit] [smp:4:4] [async-threads:0] [hipe] [kernel-poll:false]

Eshell V5.9.3.1  (abort with ^G)
(b@127.0.0.1)1> 
User switch command
--> h
c [nn]            - connect to job
i [nn]            - interrupt job
k [nn]            - kill job
j                 - list all jobs
s [shell]         - start local shell
r [node [shell]]  - start remote shell
q        - quit erlang
? | h             - this message
--> r 'a@127.0.0.1'
--> j
1  {shell,start,[init]}
2* {'a@127.0.0.1',shell,start,[]}
--> c 
Eshell V5.9.3.1  (abort with ^G)
(a@127.0.0.1)1> nodes().
['b@127.0.0.1']
```

### 通过命令行参数remsh直接连接a shell
```
$ erl -name b@127.0.0.1 -setcookie abc -remsh a@127.0.0.1
Erlang R15B03 (erts-5.9.3.1) [source] [64-bit] [smp:4:4] [async-threads:0] [hipe] [kernel-poll:false]

Eshell V5.9.3.1  (abort with ^G)
(a@127.0.0.1)1> 
User switch command
--> j
1* {'a@127.0.0.1',shell,start,[]}
```

### 增加-hidden命令行参数避免出现在nodes()函数的返回值里, 同时避免自动连接到整个集群上
如:
```
$ erl -name b@127.0.0.1 -setcookie abc -remsh a@127.0.0.1 -hidden
Erlang R15B03 (erts-5.9.3.1) [source] [64-bit] [smp:4:4] [async-threads:0] [hipe] [kernel-poll:false]

Eshell V5.9.3.1  (abort with ^G)
(a@127.0.0.1)1> nodes().
[]
```

