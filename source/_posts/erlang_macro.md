title: erlang macro
date: 2021-06-24

tags: [erlang, macro]
---

宏参数字符串化(Stringifying Macro Arguments)
这个功能有时候还真挺有用的(虽然 elixir 不需要~), 比如测试用例和打日志的时候.
语法是: `??Arg`

<!--more-->

例如:

```erlang
-define(TESTCALL(Call), io:format("Call ~s: ~w~n", [??Call, Call])).

?TESTCALL(myfunction(1,2)),
?TESTCALL(you:function(2,1)).
```

上面的 `?TESTCALL` 那两行展开后会变成下面这样:

```erlang
io:format("Call ~s: ~w~n",["myfunction(1,2)", myfunction(1,2)]),
io:format("Call ~s: ~w~n",["you:function(2,1)", you:function(2,1)]).
```

## 参考链接
http://erlang.org/doc/reference_manual/macros.html#stringifying-macro-arguments

