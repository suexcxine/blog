title: erlang 浮点数的坑点
date: 2018-10-08
tags: [erlang, float]
---

字符串 100,100 会被解析为浮点数 100.1

```erlang
Eshell V8.3  (abort with ^G)
1> list_to_float("100,100").
100.1
```

