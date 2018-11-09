title: erlang macro
date: 2018-11-09
tags: [erlang, macro]
---

宏参数字符串化(Stringifying Macro Arguments)
这个功能有时候还真挺有用的, 比如测试用例和打日志的时候.
语法是: `??Arg`

```
-define(TESTCALL(Call), io:format("Call ~s: ~w~n", [??Call, Call])).

?TESTCALL(myfunction(1,2)),
?TESTCALL(you:function(2,1)).
```

```
io:format("Call ~s: ~w~n",["myfunction ( 1 , 2 )",myfunction(1,2)]),
io:format("Call ~s: ~w~n",["you : function ( 2 , 1 )",you:function(2,1)]).
```

<!--more-->

## 参考链接
http://erlang.org/doc/reference_manual/macros.html#stringifying-macro-arguments

