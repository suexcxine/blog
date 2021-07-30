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
curl -O https://raw.githubusercontent.com/kerl/kerl/master/kerl
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

## 解除激活，查看当前激活版本, 查看当前状态
```
$ kerl_deactivate
$ kerl active
$ kerl status
```

## centos 7.0 环境下安装
yum install gcc openssl-devel ncurses-devel autoconf
之后用kerl安装过程相同
https://docs.basho.com/riak/1.3.1/tutorials/installation/Installing-Erlang/


## 曾经遇到的问题
<pre>
KERL_CONFIGURE_OPTIONS=--enable-hipe kerl build R15B r15b
Verifying archive checksum...
Checksum verified (dd6c2a4807551b4a8a536067bde31d73)
Building Erlang/OTP R15B (r15b), please wait...
Build failed.
 class WXDLLIMPEXP_CORE wxMDIClientWindow : public wxMDIClientWindowBase
                         ^
                         /usr/include/wx-3.0/wx/gtk/mdi.h:138:24: note:   candidate expects 1 argument, 2 provided
                         make[3]: *** [x86_64-unknown-linux-gnu/wxePrintout.o] Error 1
                         make[3]: Leaving directory `/home/chenduo/.kerl/builds/r15b/otp_src_R15B/lib/wx/c_src'
                         make[2]: *** [opt] Error 2
                         make[2]: Leaving directory `/home/chenduo/.kerl/builds/r15b/otp_src_R15B/lib/wx'
                         make[1]: *** [opt] Error 2
                         make[1]: Leaving directory `/home/chenduo/.kerl/builds/r15b/otp_src_R15B/lib'
                         make: *** [libs] Error 2
</pre>
这是因为R15B是匹配wxWidgets2.8的, 而我机器上装的是3.0
卸载3.0即可

## mac下提示没有 fop 的问题, 用于生成文档
```
brew install fop
```

## 21.2 开始要求使用 openssl 1.1.1
macos下如下安装依赖
```
brew upgrade openssl@1.1
```



### 非完整安装的情形

有时只装了 erlang-base 和一些要用的 package

遇到过这样的报错, 装 exoffice 过程中遇到的, 因为没有parsetools, 然后又没有 hrl 头文件

```shell
Could not compile "src/link_text_parser.yrl" because the application "parsetools" could not be found. This may happen if your package manager broke Erlang into multiple packages and may be fixed by installing the missing "erlang-dev" and "erlang-parsetools" packages

/usr/lib/erlang/lib/parsetools-2.2/include/yeccpre.hrl: no such file or directory
```

apt install erlang-parsetools erlang-dev 就可以了, 视情况可能需要指定版本

# 参考链接:

[otp安装wiki][1]
[ubuntu下erlang源代码的编译与安装][2]
[kerl的github][3]

[1]: https://github.com/erlang/otp/wiki/Installation
[2]: http://cryolite.iteye.com/blog/356419
[3]: https://github.com/yrashk/kerl

