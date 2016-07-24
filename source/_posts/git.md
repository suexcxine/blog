title: git
date: 2015-09-15
tags: versioncontrol
---
## 概述
Git的每个开发者都有代码库的完整copy,包括完整的历史记录

每个Git代码库包含四个部分:
* The working directory
* The staging area
* Committed history
* Development branches
staging area在项目历史和工作目录之间,Git允许在提交修改之前将修改分组
大多数开发者在专门的分支下工作,主干分支留给public release

## git config
手动修改.gitconfig文件也行
`--global`选项使得参数被存储在~/.gitconfig,即全局位置

获取帮助
> git help config

### config示例
User Info
```
git config --global user.name "John Smith"
git config --global user.email john@example.com
```
Editor
```
git config --global core.editor vim
```
Aliases(命令别名)
```
git config --global alias.st status
git config --global alias.ci commit
git config --global alias.co checkout
git config --global alias.br branch
```

git config --global push.default simple
 
## 初始化
> git init <path>

Git代码库和普通目录之间的区别仅仅是有无.git目录

## Cloning Repositories
> git clone ssh://<user>@<host>/path/to/repo.git

### 从https改为使用ssh
这样就不用输密码了
```
git remote set-url origin git@github.com:USERNAME/REPOSITORY.git
```

### 同步主干分支
```
git remote -v
git remote add upstream git@github.com:username/repository.git
git fetch upstream
git checkout master
git merge upstream/master
git push
```

## 遇到的问题

### git clone时报错如下:
```
Failed to receive SOCKS4 connect request ack
```
在用代理且代理挂了? git的代理在哪里设的?
如下解决
```
$ git config --global http.proxy 'socks5://127.0.0.1:1080'
$ git config --global https.proxy 'socks5://127.0.0.1:1080'
```

### git push时报错如下:
```
error: src refspec master does not match any.
```
应该是没有commit就push了, 如下解决 
```
git add .
git commit -m 'Initial Commit'
git push -u origin master
```

参考链接
http://stackoverflow.com/questions/4181861/src-refspec-master-does-not-match-any-when-pushing-commits-in-git

