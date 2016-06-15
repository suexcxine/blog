title: nginx
date: 2015-11-07
tags: [web, linux]
---
开源,BSD许可
跨平台
模块间松耦合,可以分开用,也可以组合用
内存消耗低,10000个非活跃Keep-Alive连接仅消耗2.5MB内存
单机支持10万以上的并发连接, 更多数量取决于内存
master和worker机制支持热更新
<!--more-->

## 编译环境要求
Linux内核2.6以上
gcc
PCRE 支持正则表达式
zlib
OpenSSL

## 目录 
源代码存放目录
编译中间文件存放目录, 默认为源代码目录下的objs目录
部署目录 
日志文件存放目录

## Linux内核参数优化
/etc/sysctl.conf
> fs.file-max = 999999	进程,如worker进程可以同时打开的最大文件句柄数
> net.ipv4.tcp_tw_reuse = 1	允许将TIME-WAIT状态的socket重新用于新的TCP连接
> net.ipv4.tcp_keepalive_time = 600	控制 TCP/IP 尝试验证空闲连接是否完好的频率。如果需要更快地发现丢失了接收方，请考虑减小这个值,默认是2小时检测一次,改短一些有助于快速清理无效连接
> net.ipv4.tcp_fin_timeout = 30	当服务器主动关闭连接时,socket保持在FIN-WAIT-2状态的最大时间
> net.ipv4.tcp_max_tw_buckets = 5000	允许TIME_WAIT socket数量上限
> net.ipv4.cp_max_syn.backlog = 1024	TCP三次握手建立阶段接收SYN请求队列的最大长度
> net.ipv4.ip_local_port_range = 1024	61000	UDP和TCP连接中本地端口的取值范围
> net.ipv4.tcp_rmem = 4096 32768 262142	TCP接收缓存(滑动窗口用)的最小值,默认值和最大值
> net.ipv4.tcp_wmem = 4096 32768 262142	TCP发送缓存(滑动窗口用)的最小值,默认值和最大值
> net.core.netdev_max_backlog = 8096	当网卡接收数据包的速度大于内核处理的速度时,缓存这些数据包的队列上限
> net.core.rmem_default = 262144		内核套接字接收缓存的默认值
> net.core.wmem_default = 262144		内核套接字发送缓存的默认值
> net.core.rmem_max = 2097152		内核套接字接收缓存的最大值
> net.core.wmem_max = 2097152		内核套接字发送缓存的最大值
> net.ipv4.tcp_syncookies = 1		用于解决TCP的SYN攻击

执行sysctl -p命令使修改生效

## 获取Nginx源码
http://nginx.org/en/download.html

## 编译
进入源码目录
> ./configure --help
> 
> --prefix=PATH	安装目录,会做为其他参数的相对目录,默认为/usr/local/nginx
> --sbin-path=PATH	可执行文件路径
> --conf-path=PATH	配置文件路径
> --error-log-path=PATH	错误日志文件路径
> --pid-path=PATH		pid文件存放路径,文件形式存储进程Id
> --lock-path=PATH	

## ubuntu下安装nginx
> sudo aptitude install nginx

### 查看版本和编译参数
> $ nginx -V
> nginx version: nginx/1.4.6 (Ubuntu)
> built by gcc 4.8.4 (Ubuntu 4.8.4-2ubuntu1~14.04) 
> TLS SNI support enabled
> configure arguments: --with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-debug --with-pcre-jit --with-ipv6 --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_addition_module --with-http_dav_module --with-http_geoip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_spdy_module --with-http_sub_module --with-http_xslt_module --with-mail --with-mail_ssl_module
>

### 帮助
> $ nginx -h
> nginx version: nginx/1.4.6 (Ubuntu)
> Usage: nginx [-?hvVtq] [-s signal] [-c filename] [-p prefix] [-g directives]
> 
> Options:
>   -?,-h         : this help
>   -v            : show version and exit
>   -V            : show version and configure options then exit
>   -t            : test configuration and exit
>   -q            : suppress non-error messages during configuration testing
>   -s signal     : send signal to a master process: stop, quit, reopen, reload
>   -p prefix     : set prefix path (default: /usr/share/nginx/)
>   -c filename   : set configuration file (default: /etc/nginx/nginx.conf)
>   -g directives : set global directives out of configuration file

### 相关路径
> $ whereis nginx
> nginx: /usr/sbin/nginx /etc/nginx /usr/share/nginx /usr/share/man/man1/nginx.1.gz

所有的配置文件都在/etc/nginx下，
并且每个虚拟主机已经安排在了/etc/nginx/sites-available下
日志放在了/var/log/nginx中，分别是access.log和error.log
默认的虚拟主机的目录设置在了/usr/share/nginx/html
并已经在/etc/init.d/下创建了启动脚本nginx

> 先停掉apache, 放开80端口
> sudo /etc/init.d/apache2 stop
> 启动nginx
> $ sudo /etc/init.d/nginx start

## php支持
所谓FastCGI就是对CGI的改进。
它一般采用C/S结构，一般脚本处理器会启动一个或者多个daemon进程，
每次web服务器遇到脚本的时候，直接交付给FastCGI的进程来执行，然后将得到的结果(通常为html)返回给浏览器。

$ sudo apt-get install php5-fpm
查看是否已启动
```
$ ps aux | grep php-fpm
root     30397  0.0  0.2 264876 21104 ?        Ss   21:44   0:00 php-fpm: master process (/etc/php5/fpm/php-fpm.conf)
www-data 30401  0.0  0.0 264876  6980 ?        S    21:44   0:00 php-fpm: pool www
www-data 30402  0.0  0.0 264876  6980 ?        S    21:44   0:00 php-fpm: pool www
chenduo  30447  0.0  0.0  15960  2168 pts/35   R+   21:45   0:00 grep --color=auto php-fpm
```

/etc/nginx/nginx.conf里有如下一行:
include /etc/nginx/sites-enabled/*; 
找到对应的文件
/etc/nginx/sites-enabled/default
```
location ~ \.php$ {                                                          
    fastcgi_split_path_info ^(.+\.php)(/.+)$;                                
    fastcgi_pass unix:/var/run/php5-fpm.sock;                                
    fastcgi_index index.php;                                                 
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;        
    include fastcgi_params;                                                  
} 
```

$ sudo /etc/init.d/nginx restart

/etc/php5/fpm/php.ini
cgi.fix_pathinfo=0
据说这里不设成0的话会有安全问题,详见
<http://cnedelcu.blogspot.com/2010/05/nginx-php-via-fastcgi-important.html>

/etc/php5/fpm/php-fpm.conf里有如下一行:
include=/etc/php5/fpm/pool.d/*.conf
即会包含pool.d下的配置文件

用户是www-data

### 反向代理
将收到的流量转发到其它url, 如下
```
location / { 
    proxy_pass http://redmine.suexcxine.cc:3000;
}
```

### php-fpm端口引发的502 BAD GATEWAY的问题
/etc/php5/fpm/pool.d/www.conf里有listen = /var/run/php5-fpm.sock
nginx.conf里的配置应为: fastcgi_pass unix:/var/run/php5-fpm.sock;
或者也可以将两处都改为127.0.0.1:9000这样的配置

结论:两边的配置需要一致才能通信,即nginx能找到php-fpm

### fastcgi_param引发的空白页问题
当时的配置:
fastcgi_param  SCRIPT_FILENAME  /usr/local/nginx/html/phpmyadmin$fastcgi_script_name;

结果nginx出空白页
后来改为:
fastcgi_param  SCRIPT_FILENAME  /usr/local/nginx/html$fastcgi_script_name;
就好了

后来又试了下:
fastcgi_param  SCRIPT_FILENAME  \$document_root$fastcgi_script_name;
也没问题

结论:路径配错了
