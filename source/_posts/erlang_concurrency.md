title: erlang concurrency
date: 2016-02-24
tags: [erlang]
---

## gen_server:call的Req参数可以这样子
{a, {b, {c, Req}}}
每次剥一层处理一层,
就像网络协议一样, 每层都有自己的头部


