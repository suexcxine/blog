title: hexo写博客指南
date: 2015-07-17
tags: [internet]
---
github pages + node.js + hexo 写博客
<!--more-->
### 安装node.js
```bash
curl https://raw.githubusercontent.com/creationix/nvm/v0.16.1/install.sh | bash
nvm ls-remote
nvm install 0.12
```

### 安装hexo
```bash
npm install hexo-cli -g
hexo init blog
cd blog/
npm install
npm install hexo-deployer-git --save
```

### 配置_config.yml
```
deploy:
  type: git
  repository: http://github.com/suexcxine/suexcxine.github.io.git
  branch: master
```

### 写博客
```bash
hexo new "Hello Hexo" 或 hexo n "Hello Hexo" 生成一个markdown文件骨架用于填写内容
```

### markdown文件头部, 支持多标签
```
title: Ubuntu下安装phpmyadmin
date: 2015-07-17
tags: [ubuntu, phpmyadmin]
---
```

### 发布博客
```bash
hexo generate 或 hexo g 写完博客后, 生成静态内容
hexo server 或 hexo s 启动本地服务器可以先看一下效果
hexo deploy 或 hexo d 发布到外网
```

### 怎样将域名绑定到github pages博客上
在source目录下添加一个CNAME文件,没有后缀名,里面内容为你的域名(如test.com),不需要添加http/www等前缀
到域名解析服务商如DNSPod里添加相应的DNS CNAME记录

### 每次重启电脑都需要nvm use启动
```bash
nvm use 0.12
```

### 解决半角引号变成全角引号,--变成全角的问题
hexo使用的markdown parser是marked,
在_config.yml中加入一行(空格不能省略)
```
marked: {smartypants: false}
```
即可

## 参考链接
http://ibruce.info/2013/11/22/hexo-your-blog/
http://blog.maxwi.com/2014/02/22/first-post/
https://zespia.tw/blog/2012/10/11/hexo-debut/
https://hexo.io/
https://github.com/creationix/nvm/
https://github.com/hexojs/hexo
https://github.com/hexojs/hexo/wiki
https://github.com/hexojs/hexo/issues/1492
https://github.com/chjj/marked#smartypants

