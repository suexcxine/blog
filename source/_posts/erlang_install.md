title: erlang安装指引
date: 2015-07-16 12:00:00
tags: erlang
---
## 安装erlang所依赖的库
```bash
sudo apt-get build-dep erlang
```
<!--more-->
## 安装基础开发工具
```bash
sudo apt-get install build-essential
sudo apt-get install libncurses5-dev
```

## crypto依赖
```bash
sudo apt-get install libssl-dev 
```
## wxWidgets依赖
```bash
sudo apt-get install freeglut3-dev libwxgtk2.8-dev libgl1-mesa-dev libglu1-mesa-dev libpng3
```
## jinterface依赖
```bash
sudo apt-get install default-jdk
```
## C++支持
```bash
sudo apt-get install g++
```
## 旧图形工具(appmon, pman等)依赖 
```bash
sudo apt-get install tk8.5   
```

# 使用kerl安装更方便, 且能支持多个版本
## 安装R15B版本
```bash
curl -O https://raw.githubusercontent.com/spawngrid/kerl/master/kerl
chmod a+x kerl
sudo mv kerl /usr/local/bin/
kerl update releases
KERL_CONFIGURE_OPTIONS=--enable-hipe kerl build R15B r15b
kerl install r15b ~/erls/R15B
```
## 再安装18.0版本
```bash
KERL_CONFIGURE_OPTIONS=--enable-hipe kerl build 18.0 18.0
kerl install 18.0 ~/erls/18.0
```
## 将以下代码加入.bashrc以便切换版本
```bash
. ~/erls/R15B/activate
alias erl15='source /home/chenduo/erls/R15B/activate'  
alias erl18='source /home/chenduo/erls/18.0/activate'    
```

## centos 7.0 环境下安装
yum install gcc openssl-devel ncurses-devel autoconf
之后用kerl安装过程相同
https://docs.basho.com/riak/1.3.1/tutorials/installation/Installing-Erlang/

# 参考链接:
[otp安装wiki][1]
[ubuntu下erlang源代码的编译与安装][2]
[kerl的github][3]

  [1]: https://github.com/erlang/otp/wiki/Installation
  [2]: http://cryolite.iteye.com/blog/356419
  [3]: https://github.com/yrashk/kerl

