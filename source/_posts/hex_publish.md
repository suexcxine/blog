title: 如何 publish 自己的项目到 hex package manager
date: 2021-06-20

tags: [erlang, elixir, mix, rebar, hex]
---

背景: 由于在中国众所周知的原因, 下载依赖一直是一个麻烦事 

而发布到 hex , 就可以通过又拍云(点赞!)提供的 mirror 在国内比较方便快速地拉取到依赖

另一个选项是: [自己 host 一个 hex server](https://hex.pm/docs/self_hosting)

<!--more-->

### 使用 mix 的情况

按照[hex官方文档](https://hex.pm/docs/publish) 的要求, 把 mix.exs 里的必要信息填上

然后如下操作即可

```elixir
mix hex.publish package
# 需要文档的话 mix hex.publish
# 如果发现搞错了要撤回, 可以 revert
mix hex.publish --revert 1.3.0
# 然后再重发
```

> 注意: 有时我们需要改变 package 的 name, 原因是 upstream 没人维护了, 
>
> 那么我们需要把 mix.exs 里的 app 名和 package.name 都改成新的名称才可以, 
>
> 如果只改了 package.name, app 名没改, 那么包下载下来编译过不了
>

包上传好了, 现在在 mix.exs 用上, 然后用上又拍云的 mirror, 如下:

`HEX_MIRROR=https://hexpm.upyun.com mix deps.get`

Enjoy!



### 使用 rebar3 的情况

参见[hex官方文档reber3的情况]https://hex.pm/docs/mirrors

To Be Continued



### 如何 self-host

https://hex.pm/docs/self_hosting











