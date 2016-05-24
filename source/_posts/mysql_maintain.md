title: mysql维护
date: 2015-12-04
tags: [db]
---

导入导出, 权限管理, 检查表状态, 修复表数据, 日志
<!--more-->
## 导入导出
mysql -u root -p game < mysql.sql
mysqldump -u username -p dbname > backupfile.sql
mysqldump -u username -p dbname tablename > backup.sql

mysqlhotcopy
flush tables; 确保所有数据被写到磁盘,包括索引数据
backup table
select into outfile
restore table

## 权限管理
创建用户
create user ben identified by 'yourpasswd';
或直接insert到user表(不推荐) 
insert into mysql.user(Host,User,Password) values('localhost','user',password('yourpasswd'));
变更用户名
rename user ben to bforta;
删除用户
drop user bforta;
查询用户权限
show grants for bforta;

用户定义为user@host, 如果不定义主机名, 则使用默认的主机名%, 授予用户访问权限而不管主机名

授予和取消用户bforta对crashcourse库的所有表的select权限
grant select, insert on crashcourse.* to bforta;
revoke select, insert on crashcourse.* from bforta;

更新自己的口令
set password = password('n3w p@\$\$wOrd');
更新bforta用户的口令
set password for bforta = password('n3w p@\$\$wOrd');

### 将指定库的所有权限授予指定用户
grant all privileges on databasename.* to user@localhost identified by 'yourpasswd';

flush privileges; 
该命令本质上的作用是将当前user和privilige表中的用户信息/权限设置从mysql库(MySQL数据库的内置库)中提取到内存里。
MySQL用户数据和权限有修改后，希望在"不重启MySQL服务"的情况下直接生效，那么就需要执行这个命令。

## 维护
analyze table xxx; 用来检查表键是否正确
check table xxx; 可以检查表的各方面, help check table查看帮助
repair table xxx; MyISAM引擎可能用到
optimize table xxx; 

mysqld --help --verbose | less 查看配置,选项,变量的相关帮助
mysqladmin -uroot -p variables 查看指定mysql实例当前使用的变量

## 日志
mysqladmin -uroot -p variables | grep log
查日志的路径
log 查询日志
log_error 错误日志
log_bin 二进制日志
log_slow_querys 缓慢查询日志, 有助于找到需要优化的点
一般是: /var/log/mysql

flush logs;语句用于刷新和重新开始所有日志文件

