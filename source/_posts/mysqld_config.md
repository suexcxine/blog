title: mysql配置
date: 2018-09-18
tags: [db, mysql, config]
---

缓存大小, 最大连接数, 等待超时时间等
<!--more-->

```
innodb_buffer_pool_size = 1G # (adjust value here, 50%-70% of total RAM)

innodb_log_file_size = 256M

innodb_flush_log_at_trx_commit = 2 # 设成2能提高不少性能, 代价是有极小概率会丢数据

innodb_flush_method = O_DIRECT

max_connections = 1000 # (这个值根据mysql pool的max_overflow等值来计算一下吧, 一般一个游戏服预留100-200个连接, 一般用不到这么多, 只为特殊情况需要)

wait_timeout = 86400

interactive_timeout = 86400

```

