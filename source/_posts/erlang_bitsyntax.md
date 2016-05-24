title: erlang bit syntax
date: 2015-09-07
tags: [erlang]
---
erlang二进制语法点滴
<!--more-->
## 整型默认长度8位及一个疑点
```erlang
Erlang/OTP 17 [erts-6.0] [source] [smp:2:2] [async-threads:10] [kernel-poll:false]

Eshell V6.0  (abort with ^G)
1> <<100,200,300,400>>.
<<100,200,44,144>>
2> <<100,200,300:16,400:16>>.
<<100,200,1,44,1,144>>
```
说明了一个segment默认是8位,高于8位的部分被截断

同理
```erlang
1> A = <<15768105>>.
<<")">>
2> $).
41
3> io:format("~.16B", [15768105]).
F09A29ok
```

16进制29是10进制的41,由此可以看出<<15768105>>其实等于<<41>>

但是
```erlang
1> <<41>> = <<15768105>>.
<<")">>
2> <<15768105>> = <<41>>.
** exception error: no match of right hand side value <<")">>
3>  <<1:1>> = <<3:1>>.
<<1:1>>
4> <<3:1>> = <<1:1>>.
** exception error: no match of right hand side value <<1:1>>
5> <<5:2>> = <<13:2>>.
** exception error: no match of right hand side value <<1:2>>
6> A = <<15768105>>.
<<")">>
7> B = <<41>>.
<<")">>
8> A = B.
<<")">>
```
这些该如何解释呢?

## 基本形式
```erlang
Value:Size/TypeSpecifierList
TypeSpecifierList包括
Type(integer, float, binary, bitstring),
Signedness(signed, unsigned),
Endianness(big, little, native),
Unit(1-256)
e.g.
X:4/little-signed-integer-unit:8
<<X:4/big-signed-float-unit:16>> = <<100.5/float>>.
```

## 默认值
类型默认为integer
Size的默认项:
integer默认8位,float默认64位
binary或bitstring处于尾部时默认匹配全部
Unit的默认项:
integer和float和bitstring为1, binary为8
Signedness默认为unsigned
Endianness默认为big

## 词法注意
```erlang
B=<<1>>需要写成B = <<1>>, 否则编译器会理解为小于等于
<<X+1:8>>需要写成<<(X+1):8>>, 否则编译器会理解为(1:8)
匹配时Value和Size必须是常量或已绑定的变量
下面的形式会报N is unbound错,
foo(N, <<X:N,T/binary>>) ->
   {X,T}.
正确的写法:
foo(N, Bin) ->
   <<X:N,T/binary>> = Bin,
   {X,T}.
```

## Unit
最好不要改binary和bitstring的Unit

## 语法糖
```erlang
<<"hello">>是<<$h,$e,$l,$l,$o>>的语法糖
```

## 常用写法
取尾部的写法:
```erlang
foo(<<A:8,Rest/binary>>) ->
foo(<<A:8,Rest/bitstring>>) ->
```

高效拼binary的写法:
```erlang
triples_to_bin(T) ->
    triples_to_bin(T, <<>>).

triples_to_bin([{X,Y,Z} | T], Acc) ->
    triples_to_bin(T, <<Acc/binary,X:32,Y:32,Z:32>>);   % inefficient before R12B
triples_to_bin([], Acc) ->
    Acc.
```

## 参考链接
[官方文档](http://www.erlang.org/doc/programming_examples/bit_syntax.html)

