title: bash
date: 2015-09-07
tags: linux
---
## .bash_profile和.bashrc的异同
**.bash_profile** console登录时执行
**.bashrc** 非登录的交互式shell执行

## 可以在.bash_profile里加入如下代码
```bash
if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi
```
这样通过console登录时也会执行.bashrc

## bash -c
bash -c command 执行命令

## 用source命令执行脚本文件和用sh执行脚本文件的区别
用source执行脚本文件，执行过程不另开进程，脚本文件中设定的变量在当前shell中可以看到；
用sh执行脚本文件，是在当前进程另开子进程来执行脚本命令，脚本文件中设定的变量在当前shell中不能看到。

## select语句
提示用户选一项
```bash
#!/bin/bash
mystack='a 123 test'
select entry in $mystack; do
    if [ $entry ]; then
        echo "You select the choice '$entry'"
    else
        echo "choice invalid"
    fi
done
```

