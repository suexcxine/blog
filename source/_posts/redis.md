title: redis
date: 2016-11-08 17:14:00
tags: [db]
---

偶尔研究一下 redis

<!--more-->

## 慢查询日志

访问 redis instance
用 slowlog len 先看看长度
然后 slowlog get <count>

# redis 3.2 cluster

## Redis Cluster TCP ports

每个结点两个端口,
如给client用的端口是6379, 则10000(固定) + 6379即16739端口用于结点间通讯

暂不支持 ip 或 port 映射

# Redis Cluster data sharding

集群共有 16384 个 hash slot, 对 key 做 CRC16 并对 16384 取余得到对应的 hash slot, 每个结点负责一部分 hash slot,
这种设计, 摘除和增加结点都比较容易, 把hash slot复制到别的结点即可
hash tags可以让key在同一个slot里, 从而允许类似事务的操作

# Redis Cluster master-slave model

每个master可以有N个slaves,

# Redis Cluster consistency guarantees

保证不了强一致性, 意味着特殊情况下会丢数据(而且是已经给前端确认写入成功的).

原因1: 异步replicate, 所以master自己写完就告诉client ok了, 然后才发到从库, 这时如果master down了, 没有发到从库, 这次写入就丢了. 这里要想解决的话, 就要从库全写成功才告诉client ok, (使用WAIT命令), 但是这个性能代价很高.

原因2: 网络分裂后, 如果客户端和master(B)在一起, 而另一侧的网络里在node timeout 这个时间后B的slave被提升成master, 那么在此期间客户端写到这个B上的数据会丢.
(node timeout后B发现自己与多数master失去联系了也会进入一个error状态, 即只有进入error状态之前的这一段时间内的数据会告诉client成功却丢, 之后就写不了了)

## 参考链接
http://redis.io/topics/cluster-tutorial

