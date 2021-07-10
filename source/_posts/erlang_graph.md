title: erlang graph
date: 2021-07-10

tags: [erlang, elixir, graph]
---

不常用却很有用的数据结构, erlang 有内建的支持, 即 digraph, 和 digraph_util 这两个模块

<!--more-->

digraph 模块里只有一些基本函数, new, add_vertex, add_edge, delete 之类的

算法相关的都在 digraph_util 里, 比如求拓扑排序的 :digraph_utils.topsort



### 需要注意的点

这是我在 erlang 遇到的唯一一个不 pure 的数据结构, 

```elixir
> d = :digraph.new()
{:digraph, #Reference<0.2230174936.1150418949.31867>,
 #Reference<0.2230174936.1150418949.31868>,
 #Reference<0.2230174936.1150418949.31869>, true}
```

可以看到用了三个 ets 来存实际的数据

下面我们来看下里面是什么内容, 先放一些数据进去

```elixir
> :digraph.add_vertex(d)
[:"$v" | 0]
> :digraph.add_vertex(d)
[:"$v" | 1]
> :digraph.add_vertex(d)
[:"$v" | 2]
> :digraph.add_vertex(d)
[:"$v" | 3]
> :digraph.add_vertex(d, :nimei, [1,2,3])
:nimei
> :digraph.add_edge(d, :nimei, [:"$v" | 1])
[:"$e" | 1]

> :digraph_utils.topsort(d)
[[:"$v" | 3], [:"$v" | 2], [:"$v" | 0], :nimei, [:"$v" | 1]]

```

下面可以看出来, 一个是顶点数据, 一个是边的数据, 

最后一个是元数据(默认顶点名和边名的 counter, 以及为了性能考虑的入度和出度的数据)

```elixir
> {_, a, b, c, _} = d
{:digraph, #Reference<0.2230174936.1150418949.31867>,
 #Reference<0.2230174936.1150418949.31868>,
 #Reference<0.2230174936.1150418949.31869>, true}
> :ets.tab2list(a)
[
  {:nimei, [1, 2, 3]},
  {[:"$v" | 1], []},
  {[:"$v" | 0], []},
  {[:"$v" | 2], []},
  {[:"$v" | 3], []}
]
> :ets.tab2list(b)
[{[:"$e" | 1], :nimei, [:"$v" | 1], []}]
> :ets.tab2list(c)
[
  {:"$eid", 2},
  {:"$vid", 4},
  {{:out, :nimei}, [:"$e" | 1]},
  {{:in, [:"$v" | 1]}, [:"$e" | 1]}
]
```



### 应用场景

To Be Continued