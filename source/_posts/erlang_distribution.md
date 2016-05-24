title: erlang distribution
date: 2015-09-06
tags: erlang
---

## 连不上时怎么办??
cookie对吗? erlang:get_cookie()看一下两边是否一样
结点名不是nonode@nohost吧, erlang:is_alive()返回true才行
两边的端口开了吗?epmd的默认端口是4369, 
不光默认端口, 还得开一批别的端口用于结点间socket通信, 
可以查看自己机器上各结点的端口
如:
> $ epmd -names
> epmd: up and running on port 4369 with data:
> name aries_game at port 44554

可以设置epmd使用的端口范围, 以便在防火墙中开放这些端口
> erl -sname abc -kernel inet_dist_listen_min 4370 inet_dist_listen_max 4375

代码中如下设置
> application:set_env(kernel, inet_dist_listen_min, 4370).
> application:set_env(kernel, inet_dist_listen_max, 4375).

## -kernel dist_auto_connect never
该情况下,该结点不会主动连接其他结点,
使用net_kernel:connect_node可以连上其他结点, 
并且还会跟其他结点的已知结点(没有设dist_auto_connect never的结点)都连上
因为对面连过来了, 即双方只要有一方没设dist_auto_connect never, 那么你不自动连接它, 它会自动连接你

## erlang Can&apos;t set long node name的问题
报错信息如下:
```erlang
$ erl -name aaa -setcookie abc
{error_logger,{{2015,7,23},{17,25,1}},"Can't set long node name!\nPlease check your configuration\n",[]}
...
```
解决办法:
在/etc/hosts中增加一行,如自己的ip是192.168.1.108
192.168.1.108   chenduo-desktop.localdomain chenduo-desktop

问题解决:
$ erl -name aaa -setcookie abc
Erlang R15B (erts-5.9) [source] [64-bit] [smp:4:4] [async-threads:0] [hipe] [kernel-poll:false]

Eshell V5.9  (abort with ^G)
(aaa@chenduo-desktop.localdomain)1>

## 如何判断本结点与某结点是否已连接?
1, lists:member(xxx, nodes()), 但是这个不能保障后续通信成功
2, erlang:monitor_node, 断开时得到通知
3, call目标进程, 得到执行结果或得到错误如nodedown的话就没连接

