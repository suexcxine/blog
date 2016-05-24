title: erlang relx
date: 2015-09-14
tags: erlang
---
## 如何在release不包含src代码
relx.config里加上配置即可不包含源代码
> {include_src, false}.

## 怎么不让wx, observer等app一开始就启动但是又包含在release里
在relx.config里加上就可以了, 如下
> {release, {suex_1, "1"}, [suex, wx, observer]}.