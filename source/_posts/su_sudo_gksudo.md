title: su sudo gksudo
date: 2015-08-12 
tags: linux
---
这几个命令的相同点和不同点...
<!--more-->
## login shell & non-login shell
login shell: 登录shell, 会执行.bash_profile和.bashrc, 需要用户名和密码, Ctrl+Alt+F1登录后就是一个登录shell
non-login shell: 非登录shell, 执行.bashrc, 不执行.bash_profile, 需要已经登录, 在gnome里开启的图形terminal是非登录shell

## interactive shell & non-interactive shell
interactive shell: 交互式shell, 例如gnome的图形terminal
non-interactive shell: 非交互式shell, 可能由一个进程启动, 用户看不到输入或输出

## su
su -c apt-get install vlc
-c 执行命令

su -
登录shell

## sudo
用户必须在sudoers文件里或在一个group里(这个group在sudoers文件里)

sudo su
非登录shell, HOME环境变量变成root

sudo -i
登录shell 
近似于sudo su -
启动由目标用户的password数据库项指定的shell

sudo -s
非登录shell, HOME环境变量还是当前用户
启动由SHELL环境变量指定的shell
如果没有SHELL环境变量则启动由当前用户的password数据库项指定的shell

sudo su = sudo + su + shell 
sudo -i = sudo + shell

## 检测是否处于登录shell中(仅限bash)
```bash
shopt -q login_shell && echo 'Login shell' || echo 'No login shell'
```

## sudo和gksudo
sudo和gksudo都是使用root权限来执行应用
sudo执行程序时使用的是当前用户的home及其配置，而gksudo使用的是root用户的home和配置

一般情况下看不出什么区别，但是对于那些针对不同用户有不同的配置文件和表现形式的应用程序来说，这两种方式的结果区别就很明显了。
比如使用sudo firefox出现权限问题，gksudo firefox就没有这个问题。

在不通过终端运行程序时，sudo没有办法提供一个界面来输入管理员密码，比如在快捷方式中。
还有些GUI程序只能用gksudo

## Ubuntu设置root密码
在普通用户shell里
sudo passwd
但是最好不要使用root密码,通过sudo机制处理root权限比较好

