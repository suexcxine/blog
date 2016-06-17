title: gogs
date: 2016-06-17 15:09:00
tags: versioncontrol
---

自己搭一个git server
gogs与github有点不一样的地方, 坑了我...
不过总体上gogs还是方便好用的
<!--more-->

## docker-compose
```
gogs:
  image: gogs/gogs
  container_name: gogs
  ports:
    - "10022:22"
    - "10080:3000"
  volumes:
    - /root/gogs:/data
```

## 遇到的问题

如下这样, 从https改到ssh,
```
git remote set-url origin git@suexcxine.cc:10022/suexcxine/gogogo.git
```
测试ssh连接:
```
$ ssh -T -p 10022 git@suexcxine.cc
Hi there, You've successfully authenticated, but Gogs does not provide shell access.
If this is unexpected, please log in with password and setup Gogs under another user.
```
github这样是可以的, 但是git push时gogs却提示我输入git@suexcxine.cc的密码:
```
git@suexcxine.cc's password: 
```
无语, 查了许久, 原来要加上ssh://, 但是github确实是不需要的
```
git remote set-url origin ssh://git@suexcxine.cc:10022/suexcxine/gogogo.git
```
clone也需要:
```
git clone ssh://git@suexcxine.cc:10022/suexcxine/gogogo.git
```

