title: mysql 事务
date: 2016-08-10
tags: [db, mysql]
---

InnoDB提供四种事务隔离级别,从低到高分别为READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, 和 SERIALIZABLE, 默认是REPEATABLE READ
InnoDB使用不同的锁策略来支持不同的事务隔离级别.

所有行为都在事务内, 默认是autocommit模式, 每条SQL语句形成一个独立的transaction.

COMMIT意味着变更确定持久化, ROLLBACK意味着放弃尚未持久化的变更, 两个操作都会释放锁.

transaction里select和update两句话之间有可能执行其他transaction的update语句么? || 有可能
在update之前, 这个select的行会被其他transaction读到吗? || 会, 连SERILIZABLE都靠不住

## READ UNCOMMITED 与 READ COMMITED

READ UNCOMMITED可以读到未COMMIT的内容, 这叫脏读
READ COMMITED满足一个事物开始时，只能“看见”已经提交的事物做的修改。

client1上start transaction;后insert一条,
client2使用READ UNCOMMITED可以看到
<pre>
mysql> set session transaction isolation level READ UNCOMMITTED;
Query OK, 0 rows affected (0.01 sec)

mysql> select * from tag_perm;
+-----+--------+---------+---------------------+---------------------+
| id  | tag_id | perm_id | create_ts           | update_ts           |
+-----+--------+---------+---------------------+---------------------+
|  70 |      1 |       3 | 2016-08-10 13:50:45 | 2016-08-10 13:50:45 |
|  71 |      2 |       3 | 2016-08-10 13:50:45 | 2016-08-10 13:50:45 |
|  72 |      3 |       3 | 2016-08-10 13:50:45 | 2016-08-10 13:50:45 |
+-----+--------+---------+---------------------+---------------------+
</pre>
改为READ COMMITED后就看不到了
<pre>
mysql> set session transaction isolation level READ COMMITTED;
Query OK, 0 rows affected (0.00 sec)

mysql> select * from tag_perm;
+-----+--------+---------+---------------------+---------------------+
| id  | tag_id | perm_id | create_ts           | update_ts           |
+-----+--------+---------+---------------------+---------------------+
|  70 |      1 |       3 | 2016-08-10 13:50:45 | 2016-08-10 13:50:45 |
|  71 |      2 |       3 | 2016-08-10 13:50:45 | 2016-08-10 13:50:45 |
+-----+--------+---------+---------------------+---------------------+
</pre>
client1上commit,
client2上READ COMMITED可以看到了


## READ COMMITED 与 REPEATABLE READ


client2开始transaction, select数据
<pre>
mysql> set session transaction isolation level READ COMMITTED;
Query OK, 0 rows affected (0.00 sec)

mysql> start transaction;
Query OK, 0 rows affected (0.00 sec)

mysql> select * from tag_perm;
+-----+--------+---------+---------------------+---------------------+
| id  | tag_id | perm_id | create_ts           | update_ts           |
+-----+--------+---------+---------------------+---------------------+
|  70 |      1 |       3 | 2016-08-10 13:50:45 | 2016-08-10 13:50:45 |
+-----+--------+---------+---------------------+---------------------+
</pre>

client1上commit之后

<pre>
mysql> select * from tag_perm;
+-----+--------+---------+---------------------+---------------------+
| id  | tag_id | perm_id | create_ts           | update_ts           |
+-----+--------+---------+---------------------+---------------------+
|  70 |      1 |       3 | 2016-08-10 13:50:45 | 2016-08-10 13:50:45 |
|  71 |      2 |       3 | 2016-08-10 13:50:45 | 2016-08-10 13:50:45 |
+-----+--------+---------+---------------------+---------------------+
</pre>

而REPEATABLE READ的情况则是client1上commit之后select也看不到外部的变更, 即仍是一行
仍然只能看到本事务的变更, 即事务最开始的select时生成了一个snapshot(快照或副本)
之后一直在snapshot的基础上操作

READ COMMITTED还是有读的问题,虽然未提交的不会读出来,但是自己的事务进行过程中会读到其他事务已经commit的内容,
这是一个问题,比如事务开始后第一个select读到一个数,程序用了之后,第二次select时数变了,可能引发bug

## REPEATABLE READ 与 SERILIZABLE

SERIALIZABLE这个级别接近于串行执行,普通的SELECT会被自动转化成SELECT ... LOCK IN SHARE MODE,即SELECT加共享锁,能读不能写

If you use FOR UPDATE, rows examined by the query are write-locked until the end of the current transaction.
Using LOCK IN SHARE MODE sets a shared lock that permits other transactions to read the examined rows but not to update or delete them.

## SERILIZABLE的风险

select cnt from tablename;
程序里c2 = cnt + 1
update tablename set cnt = c2;
如果两个transaction都在select处取到0,
update时都update tablename set cnt = 1; 就错了

这种事SERILIZABLE也救不了你, 因为只是select加了个共享锁, 其他事务还是可以读,
于是只能改为select cnt from tablename for update,
或者,更推荐的是删掉select, 直接用update tablename set cnt = cnt + 1
这两者其实都是select时加了写锁,于是其他事务读不了了,只能等写锁释放

不过这里主要想说的是即使是SERILIZABLE也不是能完全放心的,
还是要小心啊, 真实业务不会像这里的例子这样单纯

