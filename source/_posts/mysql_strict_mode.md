title: mysql STRICT_MODE
date: 2016-07-31 20:36:00
tags: [mysql, db]
---

有时想让mysql多做一点检查, 有时想让mysql少做一点检查...
<!--more-->

## 问题起源
以前的csv里int字段没有值,例如`INSERT INTO `test` VALUES ('1', '', '', '')`这样也能导入数据库,
现在却不行了,即使字段设为允许NULL也不行,允许NULL且默认值为0也不行,而我们只是换了MySQL的版本

## 真相大白
MySQL的5.6版本以后将sql-mode的STRICT_TRANS_TABLES设为默认
导致一切不合法值不再被隐式转换成最接近的值,而是直接报错

#1366 - Incorrect integer value: '' for column 'gold' at row 1 

## 如何检查是否是STRICT模式?
查看下列SQL语句的返回中是否包含STRICT_TRANS_TABLES
```
SELECT @@GLOBAL.sql_mode;
```

## 如何改回以前那样?
如果我执行`SELECT @@GLOBAL.sql_mode;`后返回如下结果,

STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION
那么执行如下命令可以将上面的Strict关掉,即只保留NO_ENGINE_SUBSTITUTION,

SET @@global.sql_mode= 'NO_ENGINE_SUBSTITUTION';
从my.cnf配置中去掉STRICT_TRANS_TABLES以免下次mysql启动时再变成strict mode

# Recommended in standard MySQL setup
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

## 参考链接
http://dev.mysql.com/doc/refman/5.7/en/sql-mode.html#sql-mode-strict
http://www.tocker.ca/2014/01/14/making-strict-sql_mode-the-default.html
http://stackoverflow.com/questions/24347906/incorrect-integer-value-for-a-mysql-column-thats-integer-and-allow-null
http://stackoverflow.com/questions/8874647/general-error-1366-incorrect-integer-value-with-doctrine-2-1-and-zend-form-upda/8882396#8882396

