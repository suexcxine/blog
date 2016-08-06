title: git
date: 2015-09-15
tags: versioncontrol
---

Git是分布式版本管理, 每个开发者都有代码库的完整copy,包括完整的历史记录

<!--more-->

## 概述

每个Git代码库包含四个部分:
* The working directory
* The staging area
* Committed history
* Development branches
staging area在项目历史和工作目录之间,Git允许在提交修改之前将修改分组
大多数开发者在专门的分支下工作,主干分支留给public release

git的每一个commit都保存完整的文件,而不是diff,
这样读很快,因为具体的文件内容不需要从一开始慢慢按diff上溯

## Stage and Commit
staging的意义在于将编码工作与版本控制分离,
组织代码的变更为一个个有意义的commit, 而不是一个commit里有许多不相关的代码变更
<pre>
下面的命令会将删除操作加入stage并停止track该文件,但是不会删除工作区文件
git rm --cached <file>
只显示已经stage的diff
git diff --cached
提交代码时还是不要用-m
git commit 
这样会出一个编辑器,在里面多写几行注释
</pre>

## log

git log <since>..<until>
git log --stat
git log --oneline

## tags

Tag是到commit的指针, 或者说别名
<pre>
新建tag
git tag -a v1.0 -m "Stable release"
显示tag列表
git tag 
</pre>

## 撤销变更

最近一次提交叫做HEAD
<pre>
unstage单个文件
git reset HEAD <file>
unstage全部代码
git reset HEAD
将工作目录的代码恢复到HEAD, 本地的变更都会丢弃
git reset --hard HEAD
强制删除没有纳入git管理的文件
git clean -f
恢复单个文件到过去的某commit, 默认是HEAD
git checkout <commit> <file>
退到HEAD之前一个版本
git reset HEAD~1 
删除commit在多人协作时可能会产生严重后果,其他人需要从被删除的commit之前开始将他们的commit一一合并过来,过程中很可能有许多冲突,所以不要reset公共commit(私人的无所谓)而是用一个新的commit盖掉不想要的commits
git revert <commit-id>
修改最近一次commit
git commit --amend
如果已经push到远程,可以考虑如下覆盖远程,可能会导致远程的commit变成垃圾,需要用git gc回收
git push origin +dev:dev
</pre>

## 分支

git的branch只是到commit的一个指针,不像svn会把整个目录拷贝一份
<pre>
查看本地分支列表及当前分支
git branch
新建分支
git branch <name>
删除分支
git branch -d <name>
强行删除分支
git branch -D <name>
切换分支
git checkout <branch>
在detached HEAD state时(旧commit或远程分支)使用如下命令开辟实验分支
git checkout -b <new-branch-name> 
</pre>

## 合并

fast-forward 和 3-way merge
<pre>
切换分支并合并some-feature分支的内容
git checkout master
git merge some-feature
由于merge会让history变乱,采用rebase是一个好主意,
把当前分支的变更在现在master的基础上重做一遍
git checkout some-feature
git rebase maste
交互式rebase, Interactive Rebasing
git rebase –i master
pick 58dec2a First commit for new feature
squash 6ac8a9f Second commit for new feature
可以把多个commit squash(挤压)成一个commit
</pre>
由于rebase会把当前分支的这些commits都毁掉,把目标(比如master)的commits同步过来,然后再把刚刚毁掉的commits加上,所以commit的id变了,所以如果已经push到公共版本库,就不要再rebase了,以免影响到别人,就像reset命令一样.

## 远程代码库(Remote Repositories)

<pre>
remote相当于书签,就是个网络地址,是为了让你少敲点键盘起的别名而已
git remote
git remote add <name> <path-to-repo>
git remote rm <remote-name>
省略branch名表示所有分支全下载
git fetch <remote> <branch>
显示远程分支列表
git branch -r
可以checkout远程分支,不过是只读的
git checkout <remote>/<branch>
这样看origin/master领先于master的log
git log master..origin/master
将origin master的内容合并到当前分支
git merge origin/master
但是这样会产生一条无意义的merge commit, 所以
git rebase origin/master
pull是fetch和merge的快捷方式
git pull origin/master 
也可以用--rebase选项表示rebase
git pull origin/master --rebase
更新到远程代码库
git push <remote> <branch>
初始化一个用于当公共代码库的git仓库
git init --bare some-repo.git
这样没有.git目录,.git目录里的内容直接就在some-repo.git目录下
</pre>

## 中心化流程和分布式流程
中心化流程下大家都直接在中心库上工作,不fork自己的repository
这样的主要缺陷是每个人都需要有对中心库的写权限
而大型开源项目不可能给每个人写权限,所以就走pull request那条路了

## git config
手动修改.gitconfig文件也行
`--global`选项使得参数被存储在~/.gitconfig,即全局位置

config示例

User Info
<pre>
git config --global user.name "John Smith"
git config --global user.email john@example.com
</pre>
Editor
<pre>
git config --global core.editor vim
</pre>
Aliases(命令别名)
<pre>
git config --global alias.st status
git config --global alias.ci commit
git config --global alias.co checkout
git config --global alias.br branch
</pre>

git config --global push.default simple
 
## 初始化
> git init <path>

Git代码库和普通目录之间的区别仅仅是有无.git目录

## Cloning Repositories
> git clone ssh://<user>@<host>/path/to/repo.git

### 从https改为使用ssh

这样就不用输密码了
<pre>
git remote set-url origin git@github.com:USERNAME/REPOSITORY.git
</pre>

### 同步主干分支
<pre>
git remote -v
git remote add upstream git@github.com:username/repository.git
git fetch upstream
git checkout master
git merge upstream/master
git push
</pre>

### 编译安装git
https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

## 遇到的问题

### docker container需要用到git功能时, ssh key是个问题吧, 不想把自己的私钥放vps上
github可以绑定多个ssh key, 区分开来用, 可以给hexo专门弄一个, 每个版本库也可以单独绑定key
叫做deploy key
https://www.zybuluo.com/yangfch3/note/172120

### 子模组(subproject)好坑, git add命令没有效果
被坑了两次了,想着为什么git add命令无效呢?

### git clone时报错如下:
<pre>
Failed to receive SOCKS4 connect request ack
</pre>
在用代理且代理挂了? git的代理在哪里设的?
如下解决
<pre>
$ git config --global http.proxy 'socks5://127.0.0.1:1080'
$ git config --global https.proxy 'socks5://127.0.0.1:1080'
</pre>

### git push时报错如下:
<pre>
error: src refspec master does not match any.
</pre>
应该是没有commit就push了, 如下解决 
<pre>
git add .
git commit -m 'Initial Commit'
git push -u origin master
</pre>

参考链接
http://stackoverflow.com/questions/4181861/src-refspec-master-does-not-match-any-when-pushing-commits-in-git

