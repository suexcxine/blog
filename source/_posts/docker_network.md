title: docker network
date: 2016-06-02
tags: [docker, network]
---

今天在使用docker-compose搭建游戏服务器时遇到了问题,
发现将docker-compose.yml改成version 2之后links没有注入环境变量,
导致服务器连接数据库失败
<!--more-->

## link功能的变化

在docker-compose version 2中, 由links生成环境变量这一功能已经过时, 
如果需要兼容性, 可以在docker-compose.yml中增加环境变量设置, 设为service名即可 
Docker 1.10 不再使用/etc/hosts, 而是使用embedded DNS server 

在同一network中的service会被默认连接在一起, 可以使用service名访问其他service
在如下示例中, 在my-app中可以ping my-redis, 在my-redis中可以ping my-app
```
version: '2'

services:
  my-app:
    image: tomcat:8.0
    container_name: my-app1
    links:
      - my-redis
  my-redis:
    image: redis
    container_name: my-redis1
```

仅当使用旧式的version 1 Compose文件格式时, links才会生成形如DB_PORT_3306_ADDR这样的环境变量

## 参考链接
http://stackoverflow.com/questions/35297093/links-between-containers-not-working-with-docker-compose-version-2
http://stackoverflow.com/questions/36087173/containers-are-not-linked-with-docker-compose-version-2

compose networking的详细讲解,非常清晰易懂
https://github.com/docker/compose/blob/master/docs/networking.md

