title: elixir异常
date: 2021-09-22

tags: [elixir, exception]
---

elixir 的异常融合了 ruby 的东西, 很多人容易搞错, 这里总结一下

<!--more-->

基础知识: erlang 异常类型有三种, throw, error 和 exit

# raise + rescue

raise 字符串就是 RuntimeError 类型

```elixir
> try do
>   raise("haha")
> rescue
>   err ->
>     err
> end
%RuntimeError{message: "haha"}
```

raise 原子被认为是模块名会报错

```elixir
> try do
>   raise(:haha)
> rescue
>   err ->
>     err
> end
%UndefinedFunctionError{
  arity: 1,
  function: :exception,
  message: nil,
  module: :haha,
  reason: nil
}
```

rescue 可以拦截到 erlang error 类型

```elixir
> try do
>   :erlang.error("haha")
> rescue
>   err ->
>     err
> end
%ErlangError{original: "haha"}

> try do
>   :erlang.error(:badarith)
> rescue
>   err ->
>     err
> end
%ArithmeticError{message: "bad argument in arithmetic expression"}

> try do
>   :foo + 1
> rescue
>   err ->
>     err
> end
%ArithmeticError{message: "bad argument in arithmetic expression"}

> try do
>   1 / 0
> rescue
>   err ->
>     err
> end
%ArithmeticError{message: "bad argument in arithmetic expression"}

```

raise rescue 这两关键字是从 ruby 里来的, 还允许自定义 Error 类型以及扩展字段

```elixir
> try do
>   File.read!("unknown")
> rescue
>   err ->
>     err
> end
%File.Error{action: "read file", path: "unknown", reason: :enoent}
```

rescue 拦截不到 throw 类型的异常

```elixir
> try do
>   throw("haha")
> rescue
>   err ->
>     err
> end
** (throw) "haha"
```

rescue 也拦截不住 exit 类型的异常

```elixir
> try do
>   :erlang.exit(:haha)
> rescue
>   err ->
>     err
> end
** (exit) :haha
```

即 rescue **只能拦截 error 类型的异常**

# catch

catch 一个参数的形式**只能拦截 throw 类型的异常**, error 和 exit 都拦截不住

官方建议 throw 仅用于流控, 也就是在一个内部函数里抛一个值出来, 相当于命令式语言里的 return

```elixir
> try do
>   throw("haha")
> catch
>   err ->
>     err
> end
"haha"

> try do
>   exit("haha")
> catch
>   err ->
>     err
> end
** (exit) "haha"

> try do
>   1 / 0
> catch
>   err ->
>     err
> end
** (ArithmeticError) bad argument in arithmetic expression: 1 / 0
    :erlang./(1, 0)
```

catch 两个参数的形式可以拦截 throw, error 和 exit 类型的异常, **全能**

```elixir

> try do
>   throw("haha")
> catch
>   _, err ->
>     err
> end
"haha"

> try do
>   :foo + 1
> catch
>   _, err ->
>     err
> end
:badarith

> try do
>   :erlang.exit(:haha)
> catch
>   _, err ->
>    err
> end
:haha
```

Enjoy!

