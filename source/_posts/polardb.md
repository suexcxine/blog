title: 阿里云 polardb 体验有感
date: 2021-07-29

tags: [mysql, db]
---

记录一下目前为止的感受, 写一些官方文档里没有说的话

<!--more-->

### TDE加密

开启TDE时, 8.0版本下可以选择新建的表都自动加密

否则的话, 对每个表都需要手动开启加密模式

```mysql
# 对于老表 
ALTER TABLE <tablename> ENCRYPTION = 'Y';
# 对于新表
CREATE TABLE t1 (id int PRIMARY KEY,c1 varchar(10)) ENCRYPTION= 'Y'; 
```

这里的ALTER TABLE需要挺长时间, 阿里云给出的估算时间是 100MB/s

实测达不到这个速度, 可能与机器配置有关吧, 我算的是大约 50MB/s, 8C32G的配置

对于大表来说还是很慢, 难以接受, 更难受的一点是过程中会占用元数据锁(MDL), 于是DML都会卡住

所以最好是一开始就加密, 要不就建议用DTS工具同步到一张新表再改名的方法来做

阿里云DTS工具还是比较好用

