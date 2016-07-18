title: python
date: 2016-07-18 16:52:00
tags: linux
---

## virtualenv
沙箱机制
ubuntu 14.04用的是python 2.7.6, 有些旧了
自己上python官网下载了2.7.12的源码并编译安装，
创建virtualenv使用如下命令, 在新环境里使用2.7.12
```
virtualenv --python=/usr/local/bin/python venv
```

## 解决问题: 自己编译的python,方向键不能用

原来是编译时缺一些dev, 没有编译readline
```
sudo apt-get install libreadline6 libreadline6-dev
sudo apt-get install libgdbm-dev
sudo apt-get install libsqlite3-dev
sudo apt-get install libbz2-dev
```
有第一个就可以解决方向键的问题，剩下的是其他依赖，
不需要的话就可以不管
做完这些之后再重新编译一遍python就好

```
sudo apt-get install python-dev
sudo easy_install gnureadline
```

