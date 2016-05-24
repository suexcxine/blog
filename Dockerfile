# use the node base image provided by official repo
FROM node:latest
MAINTAINER Suex Cxine "suex.bestwishes@gmail.com"

# fetch blog contents
WORKDIR root
RUN git clone https://github.com/suexcxine/blog.git && \
    git config --global user.email "suex.bestwishes@gmail.com" && \
    git config --global user.name "Suex Cxine"
WORKDIR blog
# install hexo
RUN npm install hexo-cli -g && \
    npm install && \
    npm install hexo-deployer-git --save

# 支持中文显示
ENV LC_CTYPE=C.UTF-8

# 设置时区
RUN echo "Asia/Shanghai" > /etc/timezone
ENV TZ="Asia/Shanghai"

# 安装vim
RUN apt-get update && apt-get install -y vim

# replace this with your application's default port
EXPOSE 4000

# run hexo server
CMD ["hexo", "server","-i","0.0.0.0"]

