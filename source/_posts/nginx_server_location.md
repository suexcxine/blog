title: nginx, 理解server和location配置
date: 2016-06-28 20:38
tags: [web, linux]
---

server和location的配置还是有点小复杂的..

<!--more-->

## listen

可以是以下几种:

* ip:port
* ip(port默认80)
* port(ip默认0.0.0.0)
* unix socket的路径

nginx检查http请求的Host头信息

## server_name

可以使用通配符和正则, 就像下面这样
```
server_name www.example.*;
server_name ~^(www|host1).*\.example\.com$;
```
允许多个
```
server_name example.com www.example.com;
server_name example.com linode.com icann.org;
```
允许不合法的域名, 反正nginx只是用来与request里的Host信息比较
局域网等情况下有用
```
server_name localhost linode galloway;
```
空的server name表示无域名, 直接使用ip访问的请求
```
server_name "";
```

### default_server
这个选项表示默认, 即如果其他virtual host不匹配时, 使用这个
```
listen 80 default_server;
listen [::]:80 default_server ipv6only=on;
```
允许多个listen语句,同时监听多个ip和端口
```
listen     12.34.56.77:80;
listen     12.34.56.78:80;
listen     12.34.56.79:80; 
```

## location

```
location optional_modifier location_match {
    . . .
}
```
modifier如下:
(none)  prefix匹配
= 精确匹配, 性能略高, 如果有些请求确实很热就适用
~ 大小写敏感的正则表达式匹配
~* 大小写不敏感的正则表达式匹配
^~ prefix匹配,且阻止后续的正则表达式匹配

匹配规则如下:
优先选择完全匹配的(即=型的), 然后选择prefix(即none型和^~的),选最长的,如果有^~,就定了,
没有的话,先存着这个最长的,再往下看正则表达式型的,
找到一个匹配的正则表达式就定了(意味着顺序有影响),否则用之前存着的

即默认是正则表达式优先于prefix型,然而=或^~允许用户改变这种倾向

例子:
```
location /site
location = /page1
location ~ \.(jpe?g|png|gif|ico)$
location ~* \.(jpe?g|png|gif|ico)$
location ^~ /costumes
```

### index
当请求是目录而不是具体文件时使用的文件

### try_files

```
root /var/www/main;

location / {
    try_files $uri $uri.html $uri/ /fallback/index.html;
}

location /fallback {
    root /var/www/another;
}
```

### rewrite

```
root /var/www/main;

location / {
    rewrite ^/rewriteme/(.*)$ /$1 last;
    try_files $uri $uri.html $uri/ /fallback/index.html;
}

location /fallback {
    root /var/www/another;
}
```

### return

会导致外部可见的跳转

### error_page

内部跳转

```
root /var/www/main;

location / {
    error_page 404 /another/whoops.html;
}

location /another {
    root /var/www;
}
```

## 参考链接
https://www.digitalocean.com/community/tutorials/understanding-nginx-server-and-location-block-selection-algorithms
https://www.linode.com/docs/websites/nginx/how-to-configure-nginx

