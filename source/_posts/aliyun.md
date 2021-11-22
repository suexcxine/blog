title: 阿里云使用记录
date: 2021-08-29

tags: [mysql, db, cloud]
---

记录一下目前为止的感受, 写一些官方文档里没有说的话..

(持续更新 ing )

<!--more-->

# polardb

### TDE加密

开启TDE时, 8.0版本下可以选择新建的表都自动加密, 否则的话, 对每个表都需要手动开启加密模式

```mysql
# 对于老表 
ALTER TABLE <tablename> ENCRYPTION = 'Y';
# 对于新表
CREATE TABLE t1 (id int PRIMARY KEY,c1 varchar(10)) ENCRYPTION= 'Y'; 
```

这里的ALTER TABLE需要挺长时间, 阿里云给出的估算时间是 100MB/s, 实测达不到这个速度, 可能与机器配置有关吧, 我算的是大约 50MB/s, 8C32G的配置

对于大表来说还是很慢, 难以接受, 更难受的一点是过程中会占用元数据锁(MDL), 于是DML都会卡住, 所以最好是一开始就加密, 要不就建议用DTS工具同步到一张新表再改名的方法来做

阿里云DTS工具还是比较好用

### 秒加字段

线上一个 40亿行的大表

mysql> alter table message add column test_field int NOT NULL;
Query OK, 0 rows affected (0.47 sec)
Records: 0  Duplicates: 0  Warnings: 0

这个真的很开心

不过 drop column 就和以前一样很慢了, 大概还是 COPY 的方式吧

或者用 DMS 的无锁变更或者 pt_online_schema_change 等等东西去搞也是非常慢

所以不要 drop column, 如果你有洁癖看不得废字段的话,

先把应用里用到这个column的地方都改掉, 然后

`ALTER TABLE message RENAME COLUMN test_field TO xxx_deprecated;`

这样搞吧, 感觉比较舒服些

如果这个字段里面还没有值, 比如全是0或空串或null的话, 那就

`ALTER TABLE message RENAME COLUMN test_field TO reserved1;`

*注意: 秒加字段的功能只能将新字段加到最后, 不能用 after, 如果用了 after 就秒不了了, 像以前一样慢*

### 表回收站

注意事项里有一条"如果回收站数据库（**__recycle_bin__**）和待回收的表跨了文件系统，执行`DROP TABLE`语句将会搬迁表空间文件，耗时较长。"

这里的意思是drop table之后，这个表在库里删除了，但是会放到回收站（另外一个存储），如果是同文件系统，迁移表空间文件的时候就会快一些，如果跨了文件系统，迁移文件就会慢。主要看后端存储用的什么文件系统。这个确定不了。

这个注意事项就是解释下，有些情况执行的很快，drop table后很快就能在 recycle_bin 库中找到对应的表，有些情况比较慢。 可能就是跨文件系统的影响，导致drop table后 一段时间才能在 recycle_bin 库中找到对应的表。

另外表比较大的话会比较慢，不会将实例打hang，不过对性能还是有些影响，因为会占用部分io资源。

# DTS

1

双向同步配置任务的顺序, 先配置正向, 等正向链路执行到增量同步这个阶段时, 再配置反向, 要不会出问题, 比如说数据没同步上 >_<

DTS的控制台写得超级不好, 比如按钮点击没反应(前端Console报错), 莫名弹窗报错当前请求失败请刷新页面(接口 500), 刷新完当然还是一样, 明明该有数字的地方给你显示的是 0 , 等等 ... >_<

2

本条于 2021.08.29 加入

DTS 同步任务的全量阶段会默认使用 LOAD 模式, 但是如果有非 DTS 写入的话尽量考虑改成 INSERT 模式(用户自己改不了, 要找阿里云改, 郁闷), 因为 LOAD 模式会有表锁的时候(笔者的业务有一次受此影响, 业务耗时 17s 才能写入一行, 于是出现大量 504)

3

本条于 2021.10.04 加入

两边完全同步之后, 有可能会看到速度是 1 Row/s , 这个问过阿里云, 答复由于 DTS 也会写心跳表，出现1 Row/s的情况也是正常的, 只要确信已经完全同步, 就可以停止同步并删除 DTS 实例了

# DMS

有一次有个大表(40多亿行), 通过无锁变更加索引, 执行了 5 天, 进度约 43% 的时候, 报错了

报的是下面这个错:

```
DMS-OnlineDDL msg:Could not access HTTP invoker remote service; nested exception is org.apache.http.NoHttpResponseException: Did not receive successful HTTP response: status code = 302, status message = [Found]
```

钉钉群反馈后给出的解释是他们内部A系统调用B系统登录状态过期302到登录页面了, 一个连接调用保持不了5天的链接

后来给我们公司专门设置了 token 的超时时间为不超时, >_<, 厉害

续:

于是我又执行了 5 天, 又失败了 >_<

```
DMS-OnlineDDL msg:Could not access HTTP invoker remote service; nested exception is javax.net.ssl.SSLHandshakeException: Remote host closed connection during handshake
```

于是我又怒气冲冲地找上去, 大佬告诉我没办法, 中间有一次发版, 所以中断了, 需要我再重试一下

我... MMP

再问你们下次什么时候发版呢? 告知我每周三晚上有一次, ...  那我是不是要等周四再重试?

告诉我本周三发不发版还要找另一个大佬确认一下

然后另一个大佬表示想确认一下失败的原因, 结果, 告诉我说, 任务没有失败, 后台还在跑, 震惊

于是等了一天之后, 真的成功了

真是个欢喜的故事



2021-09-18 关于数据追踪

有人 update 没写 where 把整表都覆盖了, 需要找回数据

尝试用数据追踪, 结果报错, 询问阿里云的人, 答曰:

"从日志看是Binlog过滤中连不上导致, binlog日志太多, 遇到读取异常了, 这边的 show binary logs 有多少的binlog?"

查到有 1966 行, 答曰:

"这个量比较大, 数据追踪解析超过100个, server上的binlog可能就已经差不多极限了, 看日志是解析到某个binlog的时候 网络异常被迫close掉了, 这边看下是否用其他的方式可以恢复, 数据追踪可能无法支持您这个恢复的场景。"

# ALB

开启健康检查后, 发现我明明配的 3 秒 1 次的健康检查, 结果我的应用服务器上竟然有高达 21 的 qps, 这个事会超过你的预期, 因为以前用 AWS 时也是这么配, qps 也就 2 左右

钉钉群反馈后给出的解释是他们整个集群在做检查，集群里每个机器都有请求

所以算下来, 大概是 21 / (1/ 3) = 63 台机器在调用健康检查的 api

21 的 qps 倒也不算很高, 这个接口要做得尽可能轻量, 另外要考虑日志污染的问题



##### 循环抓包

出问题时， 一般阿里云的支持会建议在 client 机器上循环抓包， 例如下面这样：
最大抓取50个包，每个包20M，共占用1G的空间，这个抓包命令需要根据实际的情况修改。 
tcpdump -i eth0 tcp and port 80 -C 20 -W 50 -w /tmp/cap.pcap



# SLB

有一次我们灰度一些流量到阿里云, 结果有一天突然 502, 一个多小时后自己恢复了, 找阿里云没查到问题

第二天又出现了, 再找阿里云找专家多方排查才查到, 说是我们灰度过来流量被判定为恶意流量触发安全规则被临时封了

具体规则不公开

猜测由于流量是从固定的两个 ip 过来, 流量不大不小的, 被误判为攻击了吧

关键是排查过程, 特么的花了两天, 这么个事情不该是一上来就告诉我们是被封了么?

即使没有主动通知邮件之类的, 至少在我们找过去的时候应该可以立即回答上来吧

耽误事



# ElasticSearch

有一次ES的一个数据节点， 据称 hippo slave进程异常，管控平台发现节点异常，自动做了自愈操作， 触发节点迁移重启。

执行如下请求，看下集群未分配分片的情况

```
GET /_cluster/allocation/explain 
```

建议我们检查下节点的shard个数是不是过多了，单节点shard过多会消耗大量节点资源，监控读写请求增加，负载增加，索引加载异常等

unassigned 现象，会导致分配分片的5次（默认）重试机会用完 ，所以不会再自动分配， 需要手动 retry

建议依次执行以下ES_API尝试恢复（可以尝试多执行几次）。

```
POST visitor-2019-11/_flush
POST _cluster/reroute?retry_failed
```



# DDoS高防国际版

海外访问anycast是就近走，国内访问国际高防根据运营商不同，线路是固定的
移动——香港
联通——新加坡
电信——美国



偶尔会出现客户连不上高防或者延迟很高（200-300ms）的情况

阿里云是用听云APM来监测他们各个结点（比如阿联酋）， 另外他们建议客户把DNS设成 8.8.8.8







