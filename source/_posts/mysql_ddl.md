title: mysql DDL
date: 2015-12-04
tags: [db]
---

设计和创建表

<!--more-->
## 引擎
memory引擎功能上等同于MyISAM但是数据存储在内存中所以速度快
InnoDB支持事务, MyISAM不支持

## 数据类型
不用于运算的值一般不应存储在数值字段,如邮编可能以0开头,存储在数值字段会导致前导0消失

## 本地化
#### 字符集
显示可用的字符集
show character set;

查看当前数据库使用的变量中包含character的配置
show variables like 'character%';

#### 校对
用于排序, 也译为排序规则
显示可用的校对
show collation;

_cs表示区分大小写(case sensitive),
_ci表示不区分大小写(case insensitive)

查看当前数据库使用的变量中包含collation的配置
show variables like 'collation%';

建表时指定表级的字符集和校对
```
create ...
(
  ...
) DEFAULT CHARACTER SET utf8
  COLLATE utf8_general_ci
```

在select时也可以指定校对
select * from customers order by lastname, firstname collate latin1_general_cs;

#### 遇到过的乱码问题
有一次写到DB里的中文都变成问号了
show variables 发现 character_set_database 是 latin1
查了很久, 最后执行下面的语句
```
ALTER DATABASE databasename CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
```
而且还重启了 mysql 才好..

可见当初 create database 的时候真的要小心,
要这样:
```
CREATE DATABASE new_db CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;
```


