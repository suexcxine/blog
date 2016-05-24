title: grep 
date: 2015-09-06
tags: linux
---
## 开发目录下写一个脚本叫g, 用起grep来方便一点
grep -rn $@ . --exclude=tags --exclude-dir=.svn | grep -v "匹配到二进制文件"

