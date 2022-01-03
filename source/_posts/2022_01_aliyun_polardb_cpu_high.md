title:  记录一次 polardb CPU 高的问题
date: 2022-01-03

tags: [mysql, db, cloud]
---

前几天遇到的，目前也没有完全水落石出，不过还是记录一下

大概的过程是：将一个有 1 亿多行表改成了分区表，然后发现只读结点的CPU从长期稳定的 20%以下升到了 50% 多， 并一直持续在这个水平。我以为是改分区表导致的，于是第二天我又执行DDL要改回非分区表。结果执行了半小时（过程中的监控图表很像是一直在干活的那种，就是 iops 等各种高）后提示 ERROR 8007 (HY000): Fail to get MDL on replica during DDL synchronize，执行 show full processlist 发现只读结点上有几个 select 持续了一天还没结束，显然它们阻塞了 MDL 锁的获取。于是 kill 掉，然后 CPU 就下来了。

<!--more-->

疑点：上述那几个 select 现在再执行的话， 都是 0.1 秒以下。为什么持续了一天都还没结点？
kill 掉那几个查询后 CPU 立即直线下降， 说明那几个 select 确实是一直在处理中。分区表DDL成功后 CPU 就直线上升说明是分区表DDL成功后的瞬间的 select 出了问题， 怀疑是某种竞态条件。

请教阿里云服务群后得到的解释是：

> 从ro慢日志看，在cpu高的时间内，类似select扫描的行记录基本上都翻了十倍了，似乎是执行计划走错了。我猜测是由于之前加partition的ddl，导致统计信息重新维护了，执行计划才走错的。单独把子查询拿出来验证一下。一种直接执行，一种加force index(idx_created_on_ent_id)，大概就能看出来差异了。  
> 从我们内部的perf数据看，出问题的时间段主要cpu消耗在IndexScanIterator，正常的时候是IndexRangeScanIterator。异常的时候子查询大概率走了idx_created_on_ent_id而不是primary。这个KEY `idx_created_on_ent_id` (`created_on`,`ent_id`)，上面created_on在前，ent_id在后，也符合这个逻辑，是全量扫索引的。如果用primary，就是用ent_id+agent_id定range，然后拿created_on过滤，是范围扫。
> 影响索引的那种DDL，有些场景走到非最优索引也挺常见的，比如好几个执行计划cost差不多那种。所以一般情况下，DDL这种变更，对业务持续观察很必要。

这个说法一句话就是说分区表的DDL完成后统计信息重新维护了，于是执行计划走错了，没有走到最优的执行计划。但是，一亿多行的数据也花不了一天吧，。。顶多几分钟也足够了。。

不过，还是学到了一点，遇到问题的时候，show full processlist 可能会让你发现一些问题，找到突破口。

另外，下面有一段来自[淘宝数据库内核月报2018/10](http://mysql.taobao.org/monthly/2018/10/01/)的摘抄与本次事件有关，

## DDL与大事务和大查询的问题

如果有一个大事务或者长事务长时间未提交，由于其长期持有MDL读锁，这个会带来很多问题。在RDS MySQL上，如果后续对这张表又有DDL操作，那么这个操作会被这个大事务给堵住。在POLARDB上，这个问题更加严重，简单的说，如果只读实例上有一个大事务或者长期未提交的事务，会影响主实例上的DDL，导致其超时失败。纠其本质的原因，是因为POLARDB基于共享存储的架构，因此在对表结构变更前，必须保证所有的读操作(包括主实例上的读和只读实例上的读)结束。

具体解释一下POLARDB上DDL的过程。在DDL的不同阶段，当需要对表进行结构变更前，主实例自己获取MDL锁后，会写一条redolog日志，只读实例解析到这个日志后，会尝试获取同一个表上的MDL锁，如果失败，会反馈给主实例。**主实例会等待所有只读实例同步到最新的复制位点，即所有实例都解析到这条加锁日志，主实例同时判断是否有实例加锁失败，如果没有，DDL就成功，否则失败回滚。**

这里涉及到两个时间，一个是主实例等待所有只读实例同步的超时时间，这个由参数`loose_innodb_primary_abort_ddl_wait_replica_timeout`控制，默认是一个小时。另外一个是只读实例尝试加MDL锁的超时时间，由参数`loose_replica_lock_wait_timeout`控制，默认是50秒。可以调整这两个参数来提前结束回滚DDL，通过返回的错误信息，来判断是否有事务没结束。 `loose_innodb_primary_abort_ddl_wait_replica_timeout`建议比`loose_replica_lock_wait_timeout`大。

举个实际例子方便理解： 用户可以通过命令`show processlist`中的State列观察，如果发现`Wait for syncing with replicas`字样，那么表示这条DDL目前处在等待只读节点同步的阶段。如果超过`loose_innodb_primary_abort_ddl_wait_replica_timeout`设置的时间，那么主节点会返回错误：

```
ERROR HY000: Rollback the statement as connected replica(s) delay too far away. You can kick out the slowest replica or increase variable 'innodb_abort_ddl_wait_replica_timeout'
```

如果没有超时，那么主节点会检查是否所有只读节点都成功获取MDL锁了，如果失败，那么主节点依然会返回错误：

```
ERROR HY000: Fail to get MDL on replica during DDL synchronize
```

如果主实例返回第二个错误，那么建议用户检查一下主实例以及所有只读实例上是否有未结束的大查询或者长时间未提交的事务。

这里顺便介绍一下大事务长事务的防范手段。参数`loose_max_statement_time`可以控制大查询的最大执行时间，超过这个时间后，会把查询kill掉。参数`loose_rds_strict_trx_idle_timeout`可以控制空闲事务的最长存活时间，当一个事务空闲状态超过这个值时候，会主动把这个连接断掉，从而结束事务，注意，这个参数应该比`wait_timeout/interactive_timeout`小，否则无效。

 ## 参考链接
 
https://help.aliyun.com/document_detail/154987.html


