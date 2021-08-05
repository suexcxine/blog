title: clickhouse nested object 经验
date: 2021-08-05 12:00:00

tags: [clickhouse, olap]
---

总结一下使用 clickhouse nested object 过程中的经验

<!--more-->

说在前面, 我使用的是阿里云托管版 clickhouse, 20.3.10.75 

用这个东西当然是为了 denormalization , 也就是为了性能, 因为 join 太重了

Nested object 给业务端的感觉是这是一个表中表, 然而存储上其实它的每个字段都是一个 array, 而且强制要求各字段array的长度必须相等(否则就乱套了)

## 问题和解决过程 

我遇到了什么问题呢? 就是之前我给 clickhouse 的大宽表加字段都是无脑轻松加, 先给本地表 alter table add column, 然后给分布式表[^1] alter table add column , 然后 drop materialized view 和 kafka engine table , 最后重建 kafka engine table 和 materialzied view , 事情就成了

然而现在, 因为加的是 nested object 的字段, 就出了问题

本地表和分布式表都加得很顺利, 检查历史数据的新字段的值, 都是类似 [0, 0, 0] 这样的值, 长度与现有的其他 nested object 字段相同, 说明 clickhouse 的本地表还是挺贴心的

当重建 kafka 引擎表时, 由于应用端打的点(json格式的)里还没有加上新字段[^2], kafka引擎表在消费这些数据时就报错[^3]了, 而且, 一报错(DB::Exception: Elements 'objectname.old_field' and 'objectname.new_field' of Nested data structure 'objectname' (Array columns) have different array sizes.)就卡住不消费了, 后面有正常消息也不会消费

看到 kafka 的 topic 积压的消息数字越来越大, 心里有点慌

试了几个方案, 比如我本来以为是 mv -> clickhouse 本地表这一步出的问题, 想着在 mv 定义的 select 里给上默认值, 比如 objectname.new_field as objectname.old_field , 结果发现 as 后面的名称里不能带 dot(.) >_<

最终发现 kafka引擎表看到不认识的字段也不会报错而是会忽略, 于是果断先更新应用, 问题最终解决

## 重点

* nested object 的各个 array 字段的长度必须相同, clickhouse 本地表在 insert 时如果缺字段会自动给默认值, 即如果 nested object 有三个字段, insert 时只指定了两个字段, 那么剩下的那个字段会有默认值, 长度自动适配其他字段
* kafka 引擎表的 kafka_skip_broken_messages = N 这个配置, 表示处理一个 block 时会忽略 N 条 broken 消息, 啥叫 broken 呢, 比如非法 json, 呃, nested object 字段缺或者长度不一致也算..
* select 语句中, as 后面的别名里不允许带 dot(.) 



## 注

[^1]:  分布式表晚加是因为 check on use , 如果先加的话加的动作本身会成功但是用的时候发现本地表没这个字段就会报错
[^2]: 想着是数据库先兼容, 因为我担心先更新应用的话, 数据库看到不认识的字段会报错
[^3]: 这里不得不吐槽一下阿里云托管版 clickhouse, 连日志也不给看, 需要提工单找阿里云的人帮忙看日志

