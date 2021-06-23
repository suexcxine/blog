title: 关于 http 协议里 querystring 里 array 的写法
date: 2021-06-23

tags: [http, erlang, elixir, plug, cowboy]
---

传说中有如下三种:

```
agent_id=1,2

agent_id=1&agent_id=2 

agent_id[]=1&agent_id[]=2
```

这几种在 erlang, elixir 里的支持程度怎么样呢?

<!--more-->

```elixir
> URI.decode_query("a=1,2")
%{"a" => "1,2"}
> URI.decode_query("a=1&a=2")
%{"a" => "2"}
> URI.decode_query("a[]=1&a[]=2")
%{"a[]" => "2"}
```

可见 URI.decode_query 三种都不支持

```erlang
> :cow_qs.parse_qs("a=1,2")
[{"a", "1,2"}]
> :cow_qs.parse_qs("a=1&a=2")
[{"a", "1"}, {"a", "2"}]
> :cow_qs.parse_qs("a[]=1&a[]=2")
[{"a[]", "1"}, {"a[]", "2"}]
```

呃, cowboy 里这种算勉强支持第三种写法? 至少数据没有丢, 可以自行处理 

```elixir
> Plug.Conn.Query.decode("a=1,2")
%{"a" => "1,2"}
> Plug.Conn.Query.decode("a=1&a=2")
%{"a" => "2"}
> Plug.Conn.Query.decode("a[]=1&a[]=2")
%{"a" => ["1", "2"]}
```

Plug.Conn.Query 里的支持可谓完美

赞一个!

