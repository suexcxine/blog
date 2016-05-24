title: erlang tips
date: 2015-09-06
tags: erlang
---
零碎的erlang知识
<!--more-->
## 关于erlang guard里的,号和;号的注意点
guard分三级,
第一级guard sequence, 由;号分隔,第一段guard sequence崩了还会执行第二段guard sequence,成功的话也算匹配成功
第二级guard, 由,号分隔,是且的关系
第三级guard expression, 内部可以有各种运算符包括andalso,orelse等,这里的orelse里如果崩了的话,orelse的后半段不会执行了

## 用Fun写递归函数
```erlang
Fn = fun(F)->
    receive
        {echo, Msg} ->
            io:format("~p received.~n",[Msg]), 
            F(F);
        stop -> stop 
    end
end.
```
调用时: Fn(Fn).

另一个例子:
```erlang
Fn = fun(F, X, Y) when Y < 10000 -> F(F, Y, X+Y); (F,X,Y)-> done end.
```
调用时: Fn(Fn, 1, 1).

erlang 17.0以后有了命名fun之后就不必这么麻烦地把自己做为参数传给自己了

## 几种函数调用方式之间的性能差异
fun包含或者间接包含了实现了该方法的指针调用不涉及hash-table的查询,
apply/3必须要在HashTable中查找funtion对应的Code实现，所以通常比直接调用或者fun调用速度要慢.
另外, 在参数个数确定的时候, apply/3的调用会在编译时被优化为m:f(a)形式的external function call.
例如:

```erlang
a() ->
    M=erlang,
    F=now,
    apply(M,F,[]).

b(M,F,A) ->
    apply(M,F,A).

c(M,F) ->
    apply(M,F,[a,b,c]).

d(M)->
    apply(M,do_something,[]).
```

添加to_core参数,看一下编译出来的Core Erlang代码:
```
'a'/0 =
    fun () ->
        call 'erlang':'now'()
'b'/3 =
    fun (_cor2,_cor1,_cor0) ->
        call 'erlang':'apply'(_cor2, _cor1, _cor0)
'c'/2 =
    fun (_cor1,_cor0) ->
        call _cor1:_cor0('a', 'b', 'c')
'd'/1 =
    fun (_cor0) ->
        call _cor0:'do_something'()
```

## 根据ets表名获取ets表id,可用但是繁琐一点
```erlang
fun(Name) -> [ID || ID <- ets:all(), Name == ets:info(ID,name)] end.
```

## erlang io重定向 
如想要把shell里通过io:format输出的内容(比如m()命令返回的已加载模块列表)重定向到文件时,
用group_leader/2函数重定向到file:open返回的port上

## 传入一段代码,可以得到AST,可用于分析erlang
```erlang
> E = fun(Code)-> {_,Tokens,_}=erl_scan:string(Code),rp(erl_parse:parse_exprs(Tokens)) end.
> E("[Item || Item<- [1,2,3,4],Item>2 ].").
{ok,[{lc,1,
    {var,1,'Item'},
    [{generate,1,
        {var,1,'Item'},
        {cons,1,
            {integer,1,1},
            {cons,1,
                {integer,1,2},
                {cons,1,{integer,1,3},{cons,1,{integer,1,4},{nil,1}}}}}},
    {op,1,'>',{var,1,'Item'},{integer,1,2}}]}]}
    ok
```

## 手动产生crashdump文件的方法
如下：
1. erlang:halt(“abort”).
2. 在erlang shell下输入CTRL C + “大写的A”

## supervior里permanent和transient的区别
normal退出的时候permanent会重启而transient不重启？

## erlang bootscript
erl -boot start_clean(默认)
erl -boot start_sasl

## 配置sasl的日志
erl -boot start_sasl -config elog

elog.config
%% rotating log and errors
[{sasl, [
    %% minimise shell error logging
    {sasl_error_logger, false},
        %% only report errors
        {errlog_type, error},
        %% define the parameters of the rotating log
        %% the log file directory
        {error_logger_mf_dir,"/Users/joe/error_logs"},
        %% # bytes per logfile
        {error_logger_mf_maxbytes,10485760}, % 10 MB
    %% maximum number of
    {error_logger_mf_maxfiles, 10}
    ]}].

## 查erlang安装信息
erl -version

## 使用user_default加载record定义
user_default必须要带debug_info编译

## 根据Pid查注册名
process_info(Pid, registered_name)

## erlang 18 里日志文件可以设为append, 15B不行
```bash
erl -sasl sasl_error_logger \{file,\"haha\",[append]\}
```

## format_error函数
许多模块都有format_error函数,可以传入其他函数返回的error代码得到详细信息

