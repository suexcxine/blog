title: 论我与专业 Devops 的差距
date: 2018-09-28
tags: [devops, linux, centos]
---
今天线上操作出了点小问题, 服务(a)崩了, 但不是马上崩, 而是十几分钟以后.

<!--more-->

更新一个服务(a)的代码的时候,
先把新的release包发到a_bak目录下, 停掉原服务进程, 在a_bak目录下启动了新进程,
本来这就结束了.

但是过了一小会自己觉得在一个叫bak的目录下放真实的release目录貌似不太好,
就mv a a_bak2 && mv a_bak a && rm -rf a_bak2了, 然后测了一下服务, 一切正常.
就走开了.

没想到十几分钟后崩掉了.
发现后赶紧重新启动服务.

还是 journalctl 给了我线索, 发现如下一段红字
```
Sep 28 18:19:00 gs001 run_erl[28661]: errno=2 'No such file or directory'
                                      Can't open log file '/data/apps/a_bak/var/log/erlang.log.2'.
```
原来是 log rotate 时出的问题.

以后不敢胡乱 mv 胡乱 rm 了

