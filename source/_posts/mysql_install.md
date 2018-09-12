title: mysql 安装
date: 2018-09-12
tags: [db, mysql, install]
---

mysql 安装

<!--more-->

## 步骤
```
# 下载rpm文件
wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
# 安装
sudo yum localinstall mysql57-community-release-el7-11.noarch.rpm
sudo yum repolist enabled | grep mysql
sudo yum install mysql-community-{server,client,common,libs}-*
# 查询安装了哪些mysql相关的包
rpm -qa | grep mysql
sudo yum list installed | grep mysql
# 启动
sudo systemctl start mysqld
# 设为开机启动
sudo systemctl enable mysqld
# 找到root初始密码
sudo grep 'temporary password' /var/log/mysqld.log
# 使用root连接上之后修改密码
mysql -uroot -p
mysql> set password for 'root'@'localhost'=password('MyNewPass4!');
```

## 默认配置文件路径
配置文件：/etc/my.cnf
日志文件：/var/log/mysqld.log
服务启动脚本：/usr/lib/systemd/system/mysqld.service
socket文件：/var/run/mysqld/mysqld.pid

## 参考链接:
```
https://dev.mysql.com/downloads/mysql/
https://dev.mysql.com/doc/refman/5.7/en/linux-installation-rpm.html
https://www.jianshu.com/p/1dab9a4d0d5f
https://www.cnblogs.com/ivictor/p/5142809.html
```

