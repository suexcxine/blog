title: erlang ets性能优化
date: 2021-05-04
tags: [erlang, ets]
---

假如 ets 里存的数据格式如下
```
{{user_id, type}, pid}
```
ordered_set, keypos = 1

要用上 ordered_set 的前缀匹配高性能, match specification 需要像下面这样写
```elixir
[{{{user_id, :_}, :"$1"}, [], [:"$1"]}]
```
这样才能跳过其他 user_id, 只遍历这一个 user_id 对应的记录
而悲催的是, 如果使用 :ets.fun2ms 函数来做的话, 生成的是这样的 match specification
```elixir
iex> :ets.fun2ms(fn {{user_id, _}, pid} when user_id == 1 -> pid end)
[{{{:"$1", :_}, :"$2"}, [{:==, :"$1", 1}], [:"$2"]}]
```
这种写法将不会用到 ordered_set 的前缀匹配, 而是全表扫描, 是全表扫描!

两者性能差异视表的规模而定, 这也是坑点之一,

因为表小的时候看不出来, 等表大了以后又很难想到是这里的问题, 莫名奇妙 CPU 占用率就飙上去了

笔者的某服务经此一步优化, CPU 占用率从 80% 降到了 20% !

