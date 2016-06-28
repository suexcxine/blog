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

### default_server

## location

```
location optional_modifier location_match {
    . . .
}
```
modifier如下:
(none)  prefix匹配
= 精确匹配
~ 大小写敏感的正则表达式匹配
~* 大小写不敏感的正则表达式匹配
^~ prefix匹配,且阻止后续的正则表达式匹配

匹配算法如下:
优先选择完全匹配的(即=型的),然后选择prefix(即none型的),选最长的,如果有^~,就定了,
没有的话,先存着再往下看正则表达式型的,把与刚才存的匹配的正则表达式提到最上,然后顺序尝试匹配,
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


