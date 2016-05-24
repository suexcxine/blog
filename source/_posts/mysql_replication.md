title: mysql replication
date: 2015-12-30
tags: [mysql]
---

MySQL replication通过将数据从主库自动copy到从库的方式, 提供了一个维护数据多份拷贝的方便途径

<!--more-->

## 主库/etc/mysql/my.cnf配置

bind-address            = 192.168.1.114

server-id在replication组中必须**唯一**
server-id               = 1

replication的真实细节被记录在下面的log文件中, slave会从这里读取变化内容
log_bin                 = /var/log/mysql/mysql-bin.log

下面这行可以写多行以同步多个库
binlog_do_db            = databasename

重启数据库以使配置生效
sudo service mysql restart

### 进入mysql命令行

授予slave replication权限
mysql> GRANT REPLICATION SLAVE ON *.* TO 'slave_user'@'%' IDENTIFIED BY 'password';
mysql> FLUSH PRIVILEGES;

进入想要同步的库并**加锁**以保证数据暂时不发生变化
mysql> USE databasename;
mysql> FLUSH TABLES WITH READ LOCK;

获取Position值, 我们将让从库从这个位置开始replicate
mysql> SHOW MASTER STATUS;

此时如果再做其他操作数据库会自动解锁, 所以我们开一个新的terminal继续下面的操作, 导出数据库内容
mysqldump -u root -p databasename > databasename.sql

回到之前的terminal, 解锁并退出mysql命令行
UNLOCK TABLES;
QUIT;

## 将导出的数据库内容导入从库
进入从库mysql命令行
mysql> CREATE DATABASE databasename;
mysql> QUIT;
导入刚刚导出的主库数据库sql文件, 
mysql -u root -p databasename < /path/to/databasename.sql

## 从库/etc/mysql/my.cnf配置

记住server-id不能与replication组内其他mysql实例相同
server-id               = 2

下面这行需要加入, 没在被注释掉的行里
relay-log               = /var/log/mysql/mysql-relay-bin.log

log_bin                 = /var/log/mysql/mysql-bin.log
binlog_do_db            = databasename

重启数据库以使配置生效
sudo service mysql restart

## 再次进入从库mysql命令行
指定当前mysql实例为我们主库的从库, 
指定从库所使用的主库用户, 
指定开始replicate的位置(即前面的Position值)
mysql> CHANGE MASTER TO MASTER_HOST='192.168.1.114', MASTER_USER='slave_user', 
    -> MASTER_PASSWORD='password', MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=  332;
mysql> START SLAVE;
mysql> SHOW SLAVE STATUS\G
检查状态, 看是否有报错信息

## 验收
在主库insert, update, delete并在从库select检查结果

## 参考链接
https://www.digitalocean.com/community/tutorials/how-to-set-up-master-slave-replication-in-mysql
