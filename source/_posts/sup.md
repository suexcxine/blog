title: sup
date: 2022-08-09
tags: [operation]
---

一定程度上可以当 ansible 用, 比较简单
https://github.com/pressly/sup
<!--more-->

```
networks:
  my_vps:
    hosts:
      - root@192.168.64.4

  local:
    hosts:
      - localhost

env:
  UPLOAD_SRC_DIR: "" # 替换成自己的需要上传的文件的路径 本地路径
  UPLOAD_FILE: "a.txt"    # 替换成自己的需要上传的文件或者目录 本地文件
  UPLOAD_DST_DIR: "/tmp/" # 上传后的路径 远程路径

commands:
  upload:
    desc: Upload tar
    upload:
      - src: $UPLOAD_SRC_DIR/$UPLOAD_FILE
        dst: $UPLOAD_DST_DIR

  my_test:
    run: echo "hello world!"
```

$ sup -D -f supfile.yaml -e UPLOAD_SRC_DIR=. -e SUP_USER=root my_vps upload
看到目标机器的 /tmp/a.txt 确实有了

$ sup -f supfile.yaml local my_test
chenduo@localhost | hello world!

$ sup -f supfile.yaml my_vps my_test
root@192.168.64.4:22 | hello world!

## 遇到的问题

1 rsa 算法不被支持的问题
> ssh: unable to authenticate, attempted methods [none publickey], no supported methods remain

Ubuntu 20.04 之后默认不再支持 rsa 算法，要用ed25519 才行
https://github.com/appleboy/ssh-action#if-you-are-using-openssh

所以 ssh-keygen -t ed25519 -a 200 生成一个新的密钥对来用

2 sup 提示 ssh: Must specify HostKeyCallback

Golang 不允许HostKeyCallback参数值为 nil 了
https://github.com/golang/go/issues/19767

但是看 sup 的代码里并不是 nil 
我把代码下下来自己编译一下就 ok 了
估计是我之前 `go install github.com/pressly/sup/cmd/sup@latest` 的代码都不是最新的导致
