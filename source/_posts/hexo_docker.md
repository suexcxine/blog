title: hexo in docker
date: 2016-05-30
tags: [hexo, docker]
---

最近有点迷上docker, 打算把电脑里的服务一个个地都做成docker image..

### 思路

hexo做为把markdown转换成html的工具而存在
博客的markdown放github, 包括Dockerfile, _config.yml, package.json, source目录和themes目录即整套环境
博客的html放vps上, 用nginx做静态服务器
即创作在自己电脑上,其他都交给docker

### 写博客流程

在自己电脑上写markdown(最好是带预览的那种编辑器如atom), 提交github, 
ssh vps执行
```
docker start hexo && docker exec hexo sh -c 'git pull' && docker exec hexo hexo g
```
刷新自己的网站即可看到更新

### docker image设计

基于node image来做, 
首先clone git仓库, 由于仓库里需要的目录和文件都有, 故不需要执行hexo init,
安装hexo和依赖项即可
```
npm install hexo-cli -g
npm install
```

### vps上的部署

使用Dockerfile build一个image

