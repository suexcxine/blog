title: 阿里云 polardb 体验有感
date: 2021-07-29

tags: [mysql, db]
---

记录一下目前为止的感受, 写一些官方文档里没有说的话

<!--more-->

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

