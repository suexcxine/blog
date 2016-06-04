title: docker problems
date: 2016-06-04
tags: docker
---

学习和尝试docker的这段时间里, 陆续遇到了不少问题
<!--more-->

### volume ro(只读)

原以为只是container对这个volume只读, 把一个nginx的volume设成ro了
没想到宿主机这边修改了内容后, nginx的container里没有跟着改,
这就不方便更新网页内容了, 果断从docker-compose.yml里去掉ro后解决

### 当docker遇到terminal

docker run时如果没有加-t,则container的环境变量里不会有TERM=xterm,                
```
docker exec -it $container bash
```
这样进入后环境变量里仍然没有TERM=xterm, 反直觉, 这里的-t参数无效
docker team给出的理由是exec并不会新建一个container, 而是在原来的container里执行, 所以原来没-t现在加-t也没用, 
那exec的-t参数是干什么用的? 结果是exec时不设-t也不行, 也不能正常工作             
最后只能这样:
```
docker exec -it $container /bin/bash -c "export TERM=xterm; command" 
```
或者在docker run时加上-t

参考链接:
http://stackoverflow.com/questions/30913579/ctrlg-in-erl-doesnt-work
https://andykdocs.de/development/Docker/Fixing+the+Docker+TERM+variable+issue

