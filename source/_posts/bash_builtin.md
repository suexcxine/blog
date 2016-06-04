title: bash builtin
date: 2016-06-04 20:23:00
tags: [linux, bash]
---

## export

导出环境变量或函数到当前shell的所有的子进程
```
export varname=value
export -f functionname # exports a function in the current shell.
```

## eval
将所有的参数拼到一起并执行
```
if [ ! -z $1 ]
then
    proccomm="ps -e -o pcpu,cpu,nice,state,cputime,args --sort pcpu | grep $1"
else
    proccomm="ps -e -o pcpu,cpu,nice,state,cputime,args --sort pcpu"
fi
eval $proccomm
```

## pwd
pwd与/bin/pwd不同, /bin/pwd不是shell builtin
pwd返回的是${PWD}, 有软链时/bin/pwd可返回真实路径

## hash
linux记录最近使用的命令的路径, 以避免每次执行命令都去$PATH里搜索
hash命令返回hash的命令路径和使用次数
-d可以删一条, -r全清
```
$ hash
hits    command
2    /usr/bin/ps
4    /usr/bin/ls
```

如下可用于判断某命令是否在$PATH里存在
```
$ hash xxx
bash: hash: xxx: 未找到
```

## readonly
标记一个变量或函数为只读

## shift
位置参数左移, 如每次以$1取参数配合shift就可以遍历所有参数

## test
判断并返回0或1

## set
不带参数的set返回所有的变量和值, set命令还用于设置位置参数的值

```
$ set +o history # To disable the history storing.
+o disables the given options.

$ set -o history
-o enables the history

$ cat set.sh
var="Welcome to thegeekstuff"
set -- $var
echo "\$1=" $1
echo "\$2=" $2
echo "\$3=" $3

$ ./set.sh
$1=Welcome
$2=to
$3=thegeekstuff
```

## 参考链接
http://www.thegeekstuff.com/2010/08/bash-shell-builtin-commands/

