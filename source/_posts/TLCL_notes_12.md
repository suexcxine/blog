title: <<The Linux Command Line>> 第十二章笔记 shell 环境
date: 2015-09-07 20:00:12
tags: [linux, bash]
---
## set & printenv
set 命令可以 显示 shell 和环境变量两者且按字母顺序排列，而 printenv 只是显示环境变量。
printenv | less
printenv USER

## alias
查看所有别名

## 登录 shell 会话的启动文件
* /etc/profile     应用于所有用户的全局配置脚本。
* ~/.bash_profile  用户私人的启动文件。可以用来扩展或重写全局配置脚本中的设置。
* ~/.bash_login    如果文件 ~/.bash_profile 没有找到，bash 会尝试读取这个脚本。
* ~/.profile       如果文件 ~/.bash_profile 或文件 ~/.bash_login 都没有找到，bash 会试图读取这个文件。 这是基于 Debian 发行版的默认设置，比方说 Ubuntu。

## 非登录 shell 会话的启动文件
* /etc/bash.bashrc 应用于所有用户的全局配置文件。
* ~/.bashrc        用户私有的启动文件。可以用来扩展或重写全局配置脚本中的设置。

