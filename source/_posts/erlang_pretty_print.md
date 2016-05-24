title: 如何在shell里好好(pretty)地显示erlang的record
date: 2015-12-07
tags: [erlang]
---
调试的时候
是否经常觉得record显示成tuple那样很难把值和字段名对上?
是否经常觉得record如果能好好显示就好了?
显示成什么样算是好好显示了呢,就像下面这样:
```
#person{id = undefined,age = undefined,name = <<>>,
        gold = undefined,career = undefined}
```
<!--more-->
## 使用erlang未公开的io\_lib\_pretty模块好好显示record
```
pretty_print(Val) ->                                                             
    io_lib_pretty:print(Val, fun rec_def_fun/2).                                 
                                                                                 
rec_def_fun(Tag, N) ->                                                           
    Ret = recordfields:get(Tag),                                                 
    case Ret =/= [] andalso length(Ret) =:= N of                                 
        true -> Ret;                                                             
        false -> no                                                              
    end. 
```

recordfields模块代码(考虑用工具自动生成)
```    
-module(recordfields).                                                              
-export([get/1]).  
-include("xxx.hrl").                                                              
-include("yyy.hrl").                                           

get(recordname1) ->                                                                   
    record_info(fields, recordname1);
get(recordname2) ->                                                                   
    record_info(fields, recordname2);  
get(recordname3) ->                                                                   
    record_info(fields, recordname3);  
get(_) ->
    [].
```

这样一来使用上面定义的pretty_print函数打印出来的格式就是~好好的~

## 使用user_default模块
user\_default(必须以debug\_info编译选项编译)里include的头文件里的record会在结点启动时自动加载,
于是在shell里可以用,即不需要使用shell的rr命令
效果:如下
```
> #person{}.
#person{id = undefined,age = undefined,name = <<>>,
        gold = undefined,career = undefined}
```
