title: wecenter
date: 2016-06-16 12:30:00
tags: [sns, web]
---
试着搭了一个wecenter, 仿知乎的...
<!--more-->

从官网(http://www.wecenter.com/downloads/)下载网站代码, 解压放到/usr/share/nginx/wecenter

nginx配置
```
server {                                                                         
    listen 10000;
    root /usr/share/nginx/wecenter;                                              
    index index.php
    server_name localhost;
    location / {                                                                 
        try_files $uri $uri/ =404;                                               
    } 
    location ~ \.php$ {                                                          
        fastcgi_split_path_info ^(.+\.php)(/.+)$;                                
        fastcgi_pass unix:/var/run/php5-fpm.sock;                                
        fastcgi_index index.php;                                                 
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;        
        include fastcgi_params;                                                  
    }                                                                            
}
```
访问http://localhost:10000, 看到不满足条件的项,一一解决,

. ./system, ./system/config需要写权限
```
sudo chmod a+w wecenter/
sudo chmod a+w wecenter/system
sudo chmod -R a+w wecenter/system/config
```

安装时提示没有CURL支持, 我明明装了curl呀, 查了半天原来是要php5-curl...
```
sudo apt-get install php5-curl
```

提示需要Mcrypt支持, 明明安装了呀, php5-mcrypt也装了还不行, 怎么办... 只能看代码了?
研究片刻发现判断当前是否支持mcrypt的依据是`function_exists('mcrypt_module_open')`
继续google, 发现如下解决方案:
```
sudo apt-get install mcrypt php5-mcrypt
sudo ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available
sudo php5enmod mcrypt
sudo pkill php5-fpm
sudo service nginx restart
```

继续, 配置mysql, 成功~

## docker

下面这个人的dockerfile可用于参考, 虽然我试了一下跑不起来... 
https://hub.docker.com/r/lee2011/wecenter/

## 参考链接
http://stackoverflow.com/questions/22721630/the-mcrypt-extension-is-missing-please-check-your-php-configuration

