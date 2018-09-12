title: linux系统如何添加sudoer
date: 2018-09-12
tags: [linux, root]
---

```
$ usermod -aG wheel [username]
$ vim /etc/sudoers, 在root下面加一条一样的，改一下username即可
```

## 参考链接
https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-centos-quickstart

