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

