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

# DTS

1

双向同步配置任务的顺序, 先配置正向, 等正向链路执行到增量同步这个阶段时, 再配置反向, 要不会出问题, 比如说数据没同步上 >_<

DTS的控制台写得超级不好, 比如按钮点击没反应(前端Console报错), 莫名弹窗报错当前请求失败请刷新页面(接口 500), 刷新完当然还是一样, 明明该有数字的地方给你显示的是 0 , 等等 ... >_<

2

本条于 2021.08.29 加入

DTS 同步任务的全量阶段会默认使用 LOAD 模式, 但是如果有非 DTS 写入的话尽量考虑改成 INSERT 模式(用户自己改不了, 要找阿里云改, 郁闷), 因为 LOAD 模式会有表锁的时候(笔者的业务有一次受此影响, 业务耗时 17s 才能写入一行, 于是出现大量 504)

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

# ALB

开启健康检查后, 发现我明明配的 3 秒 1 次的健康检查, 结果我的应用服务器上竟然有高达 21 的 qps, 这个事会超过你的预期, 因为以前用 AWS 时也是这么配, qps 也就 2 左右

钉钉群反馈后给出的解释是他们整个集群在做检查，集群里每个机器都有请求

所以算下来, 大概是 21 / (1/ 3) = 63 台机器在调用健康检查的 api

21 的 qps 倒也不算很高, 这个接口要做得尽可能轻量, 另外要考虑日志污染的问题

# SLB

有一次我们灰度一些流量到阿里云, 结果有一天突然 502, 一个多小时后自己恢复了, 找阿里云没查到问题

第二天又出现了, 再找阿里云找专家多方排查才查到, 说是我们灰度过来流量被判定为恶意流量触发安全规则被临时封了

具体规则不公开

猜测由于流量是从固定的两个 ip 过来, 流量不大不小的, 被误判为攻击了吧

关键是排查过程, 特么的花了两天, 这么个事情不该是一上来就告诉我们是被封了么?

即使没有主动通知邮件之类的, 至少在我们找过去的时候应该可以立即回答上来吧

耽误事





