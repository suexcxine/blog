title: <<The Linux Command Line>> 第七章笔记 重定向
date: 2015-09-07 20:00:07
tags: [linux, bash]
---
## uniq
报道或省略重复行
如果只想看哪些行是重复的, 使用参数-d

## 重定向
标准输入0,标准输出1,标准错误2
重定向错误输出
```
[me@linuxbox ~]$ ls -l /bin/usr 2> ls-error.txt
```
重定向标准输出和错误到同一个文件
```
[me@linuxbox ~]$ ls -l /bin/usr &> ls-output.txt
```
为了隐瞒命令错误信息，我们这样做：
```
[me@linuxbox ~]$ ls -l /bin/usr 2> /dev/null
```

## cat
连接用法
因为cat可以接受不只一个文件作为参数，所以它也可以用来把文件连接在一起。
比方说我们下载了一个大型文件，这个文件被分离成多个部分（USENET 中的多媒体文件经常以这种方式分离），
我们能用这个命令把它们连接起来：
```
cat movie.mpeg.0* > movie.mpeg
```
因为通配符总是以有序的方式展开，所以这些参数会以正确顺序安排。

重定向标准输入
```
[me@linuxbox ~]$ cat < lazy_dog.txt
```

## wc
打印行，字和字节数
* -w, --words            显示单词计数
* -l, --lines            print the newline counts
* -c, --bytes            print the byte counts
* -m, --chars            print the character counts

## head & tail
head 命令打印文件的前十行
tail 命令打印文件的后十行
默认情况下，两个命令 都打印十行文本，但是可以通过”-n”选项来调整命令打印的行数。

## tee
从 Stdin 读取数据，并同时输出到 Stdout 和文件
```
[me@linuxbox ~]$ ls /usr/bin | tee ls.txt | grep zip
```

