title: 关于排序稳定性
date: 2015-10-10
tags: [erlang, algorithm]
---
稳定排序会保持输入数据的相对顺序,而不稳定排序则不一定保持.
<!--more-->
## erlang
官方文档中lists:keysort说明是稳定的,然而lists:sort没有说是否稳定,那到底如何呢?
```
> lists:sort(fun({_, T1}, {_, T2}) -> T1 < T2 end, [{"UK", "London"}, {"US", "New York"}, {"US", "Birmingham"}, {"UK", "Birmingham"}]).
[{"UK","Birmingham"},
 {"US","Birmingham"},
 {"UK","London"},
 {"US","New York"}]
> lists:keysort(2, [{"UK", "London"}, {"US", "New York"}, {"US", "Birmingham"}, {"UK", "Birmingham"}]).
[{"US","Birmingham"},
 {"UK","Birmingham"},
 {"UK","London"},
 {"US","New York"}]
```
可见lists:sort不稳定,没有保持输入顺序

## 参考链接
http://www.erlang.org/doc/man/lists.html
