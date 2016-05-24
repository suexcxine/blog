title: erlang useful functions
date: 2015-09-06
tags: erlang
---
## erlang:integer_to_list
## erlang:list_to_integer
字符串与整型的相互转换,可以指定进制

## erlang:function_exported
判断指定的函数是否已导出,要求模块已加载,另外,BIF一律返回false
#### 另有一种做法
```erlang
is_exported({M, F, A}) ->
    lists:member({F, A}, M:module_info(exports)).
```
区别是
* 这种做法会自动加载模块(调用module_info的时候),而erlang:function_exported不会
* BIF也会返回true
* 性能(我机器上平均一次26.1微秒)比erlang:function_exported(0.86微秒)差30倍左右, 能不能大量用呢?

## binary:replace
## binary:split
可以使用正则表达式,还是很有用的

## erlang:decode_packet
要记得用呀, 很好用

## net_kernel:longnames
判断当前是不是longname 

## net_kernel:monitor_nodes
## erlang:monitor_node的区别
net_kernel:monitor_nodes是全监听,erlang:monitor_node只监听一个结点
net_kernel:monitor_nodes不会尝试连接,erlang:monitor_node会尝试连接
net_kernel:monitor_nodes有nodeup和nodedown消息,erlang:monitor_node只有nodedown消息
erlang:monitor_node在对应的结点down掉之后即失效,还想监听需要重新调用erlang:monitor_node

## erl_scan:tokens
## erl_scan:string
## erl_parse:parse_exprs
## erl_parse:parse_form
## compile:forms
## code:load_binary
## erl_syntax
## erl_eval
编译相关的一些api

## c:i
shell的i(x,y,z)接口，可以方便替代process_info()

## application:get_application
可以传入pid或module取所属的application

