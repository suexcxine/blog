title: elixir struct
date: 2021-06-25

tags: [elixir]
---

看下面的示例, 原来还可以这样 pattern match , 现在才知道

```elixir
> %m{} = %Example.AgentInfo{}
%Example.AgentInfo{
  agent_id: 0
}
> m
Example.AgentInfo
```





