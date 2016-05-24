title: 关于erlang作用域
date: 2015-12-29
tags: [erlang]
---

以下三种情况定义一个作用域:
* 函数分句
* fun
* list comprehension
<!--more-->

## fun和list comprehension

Erlang一开始只有函数分句会定义作用域
Erlang里仅有的嵌套作用域只有后来的fun和list comprehension

list comprehension里引入的变量在执行期间可能被绑定0次(即未绑定)或多次
所以加了独立作用域, 如果不加独立作用域的话, 里面的变量在外面也没法用(因为可能未绑定)
外面也不能重新定义这个变量名(因为可能已经绑定了), 所以还是加个独立作用域的好

fun也是相同的道理, 定义了一个fun之后这个fun可能没有被调用, 也可能被调用多次

## list comprehension

在javascript, ruby, python这样的语言中, list comprehension更像一个做过性能优化的for循环,
例如Python:
<pre>\>>> [x for x in [1,2,3]]
 [1, 2, 3]
\>>> x
 3
\>>> [x for x in []]
[]
\>>> x
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'x' is not defined</pre>
这里说明python的list comprehension没有定义作用域

erlang与这些语言的重要区别是, 它们都有Fortran式的可变变量, 而erlang是变量单次赋值

## case是否是一个scope? 
case从来也不是一个scope, 在erlang里不是, 在c里(包括if, switch, while, do, for)也不是, c里只有花括号会引入scope

下面这段编译不过(会报variable 'Value' unsafe in 'case'), 
```erlang
foo(Dict) ->
    Value = case orddict:find(foo, Dict) of
        {ok, Value} -> Value;
        error -> calculate_very_expensive_default_value()
    end,
    ...
```
在任何一个变量被使用的地方, 
所以能到达该处的路径上该变量必须绑定一次且只能绑定一次(bind once and only once原则)
否则会被认为'unsafe'
这也是因为case不是一个scope, 所以里面的Value还是取一个别的名吧

## 关于warn_export_vars警告

先看这段代码:
```erlang
foo() ->
    ...
    V1 = case bar() of
        {ok, Bar} ->
            Bar;
        {error, Reason} ->
            lager:error("SOS ~p", [Reason]),
            BarDefault
    end,
    V2 = case baz() of
        {ok, Baz} ->
            Baz;
        {error, Reason} ->
            lager:error("SOS ~p", [Reason]),
            BazDefault
    end,
    ...
```
这里两个Reason就匹配上了, 有时就会报badmatch崩掉
erlang里变量名相同的地方会自动match, 这点太容易出bug
其实宁愿用when语句明确指定match, Haskell就没有这个问题, 都是明确比较的, 而不像erlang名字相同就会自动match,
确实经常出bug(有用的情形基本上只有binary pattern, 因为长度信息经常有用)

再看这段代码:
```erlang
-module(test).
-export([test/1]).
test(Mode) ->
    case Mode of
        r -> {ok, FP} = file:open("warn.erl", [read]);
        w -> {ok, FP} = file:open("warn.erl", [write])
    end,
    file:close(FP).
```
会报如下警告:
<pre>compile:file("test.erl", [report, warn_export_vars]).
test.erl:8: Warning: variable 'FP' exported from 'case' (line 4)</pre>
由于case没有独立的作用域(可能有人以为有), 
所以为了提示潜在的风险, 比如后续代码中相同变量名的匹配, 有了这个warning

另外, 不要为了消除警告而把这种:
```erlang
case foo(...) of 
    {bar,X,Y} -> ...; 
    {ugh,Y,X} -> ...
end,
use(X, Y)
```
改成这种:
```erlang
{X,Y} = 
case foo(...) of 
    {bar,X1,Y1} -> ..., {X1,Y1}; 
    {ugh,Y2,X2} -> ..., {X2,Y2}
end,
use(X, Y)
```
命名更恶心,也更容易出问题

另外, 虽然第一段较好, 但是后面再用X,Y的话也会有匹配问题, 所以还是把这段抽成一个函数吧
```erlang
foo({bar,X,Y}) -> bar_related_thing({X,Y});
foo({ugh,X,Y}) -> ugh_related_thing({X,Y}).
```
当一个函数分句中出现多次case且其分支内变量命名都类似的时候, 意味着你应当把这些case抽象成独立的函数
可读性好, 可复用性好, 还可以加type声明做type检查等, 比较符合erlang的哲学

## 参考链接
http://www.erlang.org/doc/man/compile.html
http://erlang.org/pipermail/erlang-questions/2015-October/086252.html
http://erlang.org/pipermail/erlang-questions/2014-March/078017.html

