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
[mysqld]
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

## NO_ZERO_DATE
As of MySQL 5.7.4, NO_ZERO_DATE is deprecated. 
In MySQL 5.7.4 through 5.7.7, NO_ZERO_DATE does nothing when named explicitly. 
Instead, its effect is included in the effects of strict SQL mode. 
In MySQL 5.7.8 and later, NO_ZERO_DATE does have an effect when named explicitly and is not part of strict mode, as before MySQL 5.7.4. 
However, it should be used in conjunction with strict mode and is enabled by default. 
A warning occurs if NO_ZERO_DATE is enabled without also enabling strict mode or vice versa.

使用NO_ZERO_DATE之后insert时会报如下错误:
```
ERROR 1292 (22007): Incorrect datetime value: '0000-00-00 00:00:00' for column 'updated' at row 1
```

## TIMESTAMP类型字段的默认值
0可以, 
CURRENT_TIMESTAMP可以
'0000-00-00 00:00:00'不行, 
'1970-01-01 00:00:00'不行, 
'1970-01-01 00:00:01'不行, 
'1970-01-02 00:00:00'可以, 
原因可能与mysql版本及sql_mode有关,暂不深究

## 参考链接
http://dev.mysql.com/doc/refman/5.7/en/sql-mode.html#sql-mode-strict
http://www.tocker.ca/2014/01/14/making-strict-sql_mode-the-default.html
http://stackoverflow.com/questions/24347906/incorrect-integer-value-for-a-mysql-column-thats-integer-and-allow-null
http://stackoverflow.com/questions/8874647/general-error-1366-incorrect-integer-value-with-doctrine-2-1-and-zend-form-upda/8882396#8882396

