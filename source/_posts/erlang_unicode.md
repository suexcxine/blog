title: erlang unicode
date: 2015-09-08
tags: erlang
---
## LANG & LC_CTYPE环境变量和encoding
影响Erlang Shell,告诉终端程序是否要处理unicode
> \$ echo $LC_CTYPE
> 
> \$ echo $LANG
> zh_CN.UTF-8

如,下例中encoding是unicode:
> Erlang R15B (erts-5.9) [source] [smp:4:4] [async-threads:0] [hipe] [kernel-poll:false]
> 
> Eshell V5.9  (abort with ^G)
> 1> io:getopts().
> [{expand_fun,#Fun<group.0.33302583>},
>  {echo,true},
>  {binary,false},
>  {encoding,unicode}]

改成latin1看看,显示都成乱码了:
> LC_CTYPE=en_US.ISO-8859-1 /usr/local/bin/erl
> Erlang R15B (erts-5.9) [source] [smp:4:4] [async-threads:0] [hipe] [kernel-poll:false]
> 
> Eshell V5.9  (abort with ^G)
> 1> io:getopts().
> [{expand_fun,#Fun<group.0.33302583>},
>  {echo,true},
>  {binary,false},
>  {encoding,latin1}]
> 2> "\346\210\221\344\273\254".
> [230,136,145,228,187,172]
> 3> io:format("~ts",[lists:seq(20204,20220)]).
> \x{4EEC}\x{4EED}\x{4EEE}\x{4EEF}\x{4EF0}\x{4EF1}\x{4EF2}\x{4EF3}\x{4EF4}\x{4EF5}\x{4EF6}\x{4EF7}\x{4EF8}\x{4EF9}\x{4EFA}\x{4EFB}\x{4EFC}ok
> 4> io:setopts([{encoding,unicode}]).
> ok
> 5> "我们".
> [25105,20204]

输入"我们"变成了"\346\210\221\344\273\254"

## erl的参数: +pc 
选择Shell可打印字符的范围,可以是erl +pc latin1 或者  erl +pc unicode, 默认情况下,erl启动参数是latin1 
io:printable_range/0返回可打印的字符集
io_lib:printable_list/1判断一个List是否可打印
> $ erl
> Erlang/OTP 17 [erts-6.2] [source] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]
> 
> Eshell V6.2  (abort with ^G)
> 1> io:printable_range().
> latin1
> 2> io_lib:printable_list([25105]).
> false
> 3> unicode:characters_to_binary("我").
> <<230,136,145>>
> 4> file:write_file("test", [unicode:characters_to_binary("我")]).
> ok
> 5> file:read_file("test").
> {ok,<<230,136,145>>}
> 6> file:write_file("test", [io_lib:format("~w.~n", [unicode:characters_to_binary("我")])]).
> ok
> 7> file:consult("test").
> {ok,[<<230,136,145>>]}

> 17.0 +pc unicode情况下,unicode字符串可以正常显示如下
> $ erl +pc unicode
> Erlang/OTP 17 [erts-6.2] [source] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]
> 
> Eshell V6.2  (abort with ^G)
> 1> io:printable_range().
> unicode
> 2> io_lib:printable_list([25105]).
> true
> 3> <<230,136,145,228,187,172,229,173,166,228,185,160,69,114,108,97,110,103>>.
> <<"我们学习Erlang"/utf8>>
> 4> unicode:characters_to_binary("我").
> <<"我"/utf8>>
> 5> file:write_file("test", [unicode:characters_to_binary("我")]).
> ok
> 6> file:read_file("test").
> {ok,<<"我"/utf8>>}
> 7> file:write_file("test", [io_lib:format("~w.~n", [unicode:characters_to_binary("我")])]).
> ok
> 8> file:consult("test").
> {ok,[<<"我"/utf8>>]}

## epp:default_encoding/0
返回的是当前OTP版本使用的默认编码方式.R16B是latin1, 17.0是utf8.
> $ erl
> Erlang/OTP 17 [erts-6.2] [source] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]
> 
> Eshell V6.2  (abort with ^G)
> 1> epp:default_encoding().
> utf8

文件注释头可以指定编译器使用某种编码来解析,如
```
%% -*- coding: utf-8 -*-
%% -*- coding: latin-1 -*-
```
例如:
```
%% -*- coding: utf-8 -*-
-module(test).
-export([test/0]).
test() ->
        ["我", <<"我"/utf8>>].     
```
> $ erl
> Erlang/OTP 17 [erts-6.2] [source] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]
> 
> Eshell V6.2  (abort with ^G)
> 1> test:test().
> [[25105],<<230,136,145>>]
 
## 文件编码带来的差异
R15B, erlang一律以latin-1编译代码,遇到中文都编译成这种,
如test模块的函数:
```
data() -> "中国人".
data2() -> <<"中国人">>.
```
运行时:
> 1> test:data().
> [228,184,173,229,155,189,228,186,186]
> 2> test:data2().
> <<228,184,173,229,155,189,228,186,186>>

而erlang 17中,erlang一律默认以unicode编译代码(也可以在文件头指定),遇到中文都编译成这种,
如test模块的函数:
```
data() -> "中国人".
data2() -> <<"中国人"/utf8>>.  (注意这里需要加utf8类型)
```
运行时:
> 1> test:data().
> [20013,22269,20154]
> 2> test:data2().
> <<228,184,173,229,155,189,228,186,186>>

而这里如果data2()没加utf8类型说明,即写成了这样
```
data2() -> <<"中国人">>.
```
则会有问题:
> 1> test:data2().
> <<"-ýº">>
> 2> io:format("~w", [test:data2()]).
> <<45,253,186>>ok

或者写成了这样
```
%% -*- coding: latin-1 -*-
data2() -> <<"中国人"/utf8>>.
```
即utf8类型说明与latin-1文件编码说明冲突,则也会有问题:
> 1> test:data2().
> <<195,164,194,184,194,173,195,165,194,155,194,189,195,164,
>   194,186,194,186>>
> 2> io:format("~ts", [v(2)]).
> ä¸­å½äººok
> 3> io:format("~s", [v(2)]).
> Ã¤Â¸Â­Ã¥ÂÂ½Ã¤ÂºÂºok

所以以下这段问题代码
```
-module(t).
-export([test/0]).
test() ->
    ["我", <<"我">>].
```
R17编译后的运行结果为：
> 1> t:test().
> [[25105],<<17>>]

字符串是字符串,binary是binary,
字符串是这样的[25105, 25105, 97]
binary是这样的, <<230,136,145,230,136,145,97>>, 二进制这里面一个数字肯定是1个字节的, 要不不叫binary了

<<"我">>相当于<<25105>>,而二进制一个数字需要是1个字节,所以截断变成<<17>>
而加上utf8描述符后就不会被截断
> <<"我"/utf8>>.
<<230,136,145>>

所以这里把代码改为
```
-module(t).
-export([test/0]).
test() ->
    ["我", <<"我"/utf8>>].
```
即可

## 文件名解析
erl启动的时候添加不同的flag可以控制解析文件名的方式: 
* +fnl 按照latin去解析文件名 
* +fnu 按照unicode解析文件名 
* +fna 是根据环境变量(LC_CTYPE)自动选择,这也是目前的系统默认值.

可以使用file:native_name_encoding检查此参数.
> $ erl
> Erlang/OTP 17 [erts-6.2] [source] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]
> 
> Eshell V6.2  (abort with ^G)
> 1> file:native_name_encoding().
> utf8
> 2> file:read_file("test我.erl").
> {ok,<<45,109,111,100,117,108,101,40,39,116,101,115,116,230,136,145,39,41,46,32,10,45,101,120,112,111,114,...>>}

+fnl后
> $ erl +fnl
> Erlang/OTP 17 [erts-6.2] [source] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]
> 
> Eshell V6.2  (abort with ^G)
> 1> file:native_name_encoding().
> latin1
> 2> file:read_file("test我.erl").
> {error,badarg}

## 参考链接
[Erlang User Conference 2013上patrik分享的BRING UNICODE TO ERLANG!视频](http://www.youtube.com/watch?v=M6hPLCA0F-Y)
[PDF在这里](http://www.erlang-factory.com/upload/presentations/847/PatrikEUC2013.pdf)
[官方文档](http://www.erlang.org/doc/apps/stdlib/unicode_usage.html)

