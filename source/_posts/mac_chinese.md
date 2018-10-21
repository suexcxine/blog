title: mac 点滴
date: 2018-10-12
tags: [mac,乱码,unicode,encoding,emoji]
---

点滴积累

* mac读取txt中文乱码问题解决
* mac如何输入emoji

<!--more-->

## mac读取txt中文乱码问题解决
mac貌似只认unicode, 有些txt文件是GB2312或GB18030之类的, 需要转码

```
iconv -c -f GB2312 -t UTF-8 [你要看的文件] >> [新文件的名称]
```

## mac如何输入emoji
control-command+space

### 参考链接
https://www.zhihu.com/question/20353626

