title: mysqld_multi
date: 2015-12-30
tags: [mysql]
---

如何启动多个mysql实例?

<!--more-->

## /etc/mysql/my.cnf
加入如下配置, 其中mysqld2里的2是group number(GNR)
<pre>
[mysqld_multi]                                                                   
mysqld = /usr/bin/mysqld_safe                                                    
mysqladmin = /usr/bin/mysqladmin                                                 
user = multi_admin                                                               
password = multipass

[mysqld2]                                                                        
user        = mysql                                                              
pid-file    = /var/run/mysqld/mysqld2.pid                                        
socket      = /var/run/mysqld/mysqld2.sock                                       
port        = 3307                                                               
datadir     = /var/lib/mysql2 
</pre>

## 新建datadir和log目录
sudo mkdir /var/lib/mysql2
sudo chown -RL mysql:mysql /var/lib/mysql2
sudo mkdir /var/log/mysql2
sudo chown -RL mysql:mysql /var/log/mysql2

## 为mysql_install_db扫除障碍, 否则apparmor会报错
sudo apt-get install apparmor-utils
sudo vim /etc/apparmor.d/usr.sbin.mysqld
将文件中关于mysql的路径改成类似下面这样(方针是给新数据库实例的datadir与/var/lib/mysql相同的授权)
<pre>
  /etc/mysql/*.pem r,                                                            
  /etc/mysql/conf.d/ r,                                                          
  /etc/mysql/conf.d/* r,                                                         
  /etc/mysql/*.cnf r,                                                            
  /usr/lib/mysql/plugin/ r,                                                      
  /usr/lib/mysql/plugin/*.so* mr,                                                
  /usr/sbin/mysqld mr,                                                           
  /usr/share/mysql/** r,                                                         
  /var/log/mysql*.log rw,                                                        
  /var/log/mysql*.err rw,                                                        
  /var/lib/mysql/ r,                                                             
  /var/lib/mysql/** rwk,                                                         
  /var/log/mysql/ r,                                                             
  /var/log/mysql/* rw,                                                           
  /var/run/mysqld/mysqld*.pid rw,                                                
  /var/run/mysqld/mysqld*.sock w,                                                
  /run/mysqld/mysqld*.pid rw,                                                    
  /run/mysqld/mysqld*.sock w,
  /usr/share/mysql2/** r,                                                        
  /var/lib/mysql2/ r,                                                            
  /var/lib/mysql2/** rwk,                                                        
  /var/log/mysql2/ r,                                                            
  /var/log/mysql2/* rw,                                                          
</pre>

sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.mysqld

## 使用mysql_install_db(deprecated in MySQL 5.7.6)初始化datadir

sudo mysql_install_db --user=mysql --datadir=/var/lib/mysql2

## 启动指定group number(GNR)的mysql实例

sudo mysqld_multi start 2

## 检验成果

<pre>
$ sudo mysqld_multi report 2
Reporting MySQL servers
MySQL server from group: mysqld2 is running
</pre>

<pre>
$ ps aux | grep mysql
mysql     1211  0.0  0.4 2400952 34464 ?       Ssl  12月19   8:56 /usr/sbin/mysqld
mysql    18811  1.2  0.5 483128 46264 pts/33   Sl   18:51   0:00 /usr/sbin/mysqld --user=mysql --pid-file=/var/run/mysqld/mysqld2.pid --socket=/var/run/mysqld/mysqld2.sock --port=3307 --datadir=/var/lib/mysql2
</pre>

<pre>
$ netstat -nlotp
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name Timer
tcp        0      0 127.0.0.1:3306          0.0.0.0:*               LISTEN      -                关闭 (0.00/0/0)
tcp        0      0 127.0.0.1:3307          0.0.0.0:*               LISTEN      -                关闭 (0.00/0/0)
...
</pre>

设置新数据库实例的初始root密码
mysqladmin -S /var/run/mysqld/mysqld2.sock -u root password
连接新的数据库实例
mysql -S /var/run/mysqld/mysqld2.sock -u root -p

## 授予shutdown权限, 否则stop不了
mysqld_multi stop关闭每个mysql实例时使用相同的用户名和密码,
所以最好在每个mysql实例都专门建一个账号并授予shutdown权限
<pre>
mysql> CREATE USER 'multi_admin'@'localhost' IDENTIFIED BY 'multipass';
mysql> GRANT SHUTDOWN ON *.* TO 'multi_admin'@'localhost';
</pre>

停止指定的数据库实例
<pre>
$ sudo mysqld_multi stop 2
$ sudo mysqld_multi report 2
Reporting MySQL servers
MySQL server from group: mysqld2 is not running
</pre>

## 参考链接
http://dev.mysql.com/doc/refman/5.7/en/mysqld-multi.html
http://ubuntuforums.org/showthread.php?t=782224


