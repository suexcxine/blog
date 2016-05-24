title: svn
date: 2015-08-07
tags: linux
---
SVN是Subversion的简称
<!--more-->
## 安装
```bash
sudo apt-get install subversion
```

## 将默认编辑器设置为vim
编辑配置文件~/.subversion/config
editor-cmd = vim
或
```bash
sudo update-alternatives --config editor
```

## Ubuntu14.04下搭建SVN服务器

### 建版本仓库, 取名suexbag
```bash
cd /srv
sudo mkdir svn
cd /srv/svn
sudo mkdir suexbag
sudo svnadmin create /srv/svn/suexbag
```

### 配置
进入suex/conf目录
编辑配置文件svnserve.conf
[general]
anon-access = none
auth-access = write
password-db = passwd
authz-db = authz

编辑配置文件authz 
组名取为admin,可以用逗号分割允许多个用户在同一个组内
[groups]
admin = suex

[/]
@admin = rw
*=r

编辑passwd文件 
设定用户密码, 此处是明文
[users]
suex = www

### 启动svn服务器
```bash
sudo svnserve -d -r /srv/svn/
```

### 客户端checkout代码
```bash
svn co svn://172.16.205.129/suexbag --username=suex
```

## svn cleanup
清除写锁(svn st时发现状态为L),取消未完成的状态

## svn ignore
```bash
svn propset svn:ignore "*.beam" .
svn propget svn:ignore
```



