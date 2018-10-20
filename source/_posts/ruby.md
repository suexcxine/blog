title: ruby问题集
date: 2018-10-20
tags: [ruby, rbenv, ssl]
---
据说是由于ruby官网用的 ssl 从 sha1 改到 sha256 导致的问题(完整的背景见参考链接)

安装 gem 时出现如下问题
```
SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed
```

命令行更新 ruby 也更新不了, 只能从官网下载了个 2.5.2 的 ruby 的安装包,
又装了个 rbenv (为了不和 macos 系统自带的 ruby 相冲突), 安装了 ruby 之后
才成功地 gem install 了几个 gem

<!--more-->

## 参考链接
https://gist.github.com/luislavena/f064211759ee0f806c88
https://bundler.io/v1.16/guides/rubygems_tls_ssl_troubleshooting_guide.html#troubleshooting-certificate-errors

