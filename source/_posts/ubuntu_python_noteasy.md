title: 坎坷之路 Ubuntu python
date: 2016-07-24 21:34:00
tags: [linux, python]
---

由于Ubuntu 14.04的python版本是2.7.6, 觉得不够用了, 上上周自己编译了一个2.7.12版,
默认装在/usr/local/lib下, 结果出了不少问题

因为Ubuntu内部多处用到了python, 不能影响到系统用的python

which python返回的是2.7.12版的python, 但是进去之后pip安装的库访问不到...
汗
有一次要用passlib.hash.bcrypt, 用pip装了passlib,又装了bcrypt
结果有时能用有时用不了, 有时cd一下之后就用不了了, 
总报错说找不到bcrypt

终于耐心耗尽,想把自己编译的python干掉, google找了几种方法, 结果都不干净
为了让which python返回系统的2.7.6的python, 把/usr/local/bin下的python软链删除了
hash -r后发现which python指向/usr/bin下2.7.6的python, 还以为问题解决了

结果后来任务栏上出现一个奇怪的图标,说Dependency count如何如何,
google之后发现此时打开software center会有提示,照做即可

傻傻地照做了... 走了一个进度条..

发现重启后进不了图形界面了...
一定是被software center删了不少东西..., 以依赖不满足为名..

这个世界好复杂

