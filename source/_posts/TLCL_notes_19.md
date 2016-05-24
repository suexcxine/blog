title: <<The Linux Command Line>> 第十九章笔记 归档和备份
date: 2015-09-07 20:00:19
tags: [linux, bash]
---
## gzip, gunzip, zcat, zless

## bzip2, bunzip2, bzcat, bzip2recover

## tar
是 tape archive 的简称
除非你是超级用户，要不然从归档文件中抽取的文件 和目录的所有权由执行此复原操作的用户所拥有，而不属于原始所有者。

tar 命令另一个有趣的行为是它处理归档文件路径名的方式。默认情况下，路径名是相对的，而不是绝对 路径。
当创建归档文件的时候，tar 命令会简单地删除路径名开头的斜杠。
z参数使用gzip压缩, j参数使用bzip2压缩
```
find playground -name 'file-A' | tar czf playground.tgz -T -
```

## zip, unzip

## rsync
(remote sync之意), 用来备份挺好的,  
```
sudo rsync -av --delete /etc /home /usr/local /media/BigDisk/backup
sudo rsync -av --delete --rsh=ssh /etc /home /usr/local remote-sys:/backup
rsync -av -delete rsync://rsync.gtlib.gatech.edu/fedora-linux-core/development/i386/os fedora-devel
```

