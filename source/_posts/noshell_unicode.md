title: -noshell参数启动的erlang如何让standard_io支持unicode
date: 2016-06-13 19:29:00
tags: [erlang, unicode]
---

使用relx自动生成的启动脚本有foreground模式, 适合docker使用,
使用后发现docker logs里出来的日志有许多乱码...
<!--more-->

查看脚本发现如下一行
```
FOREGROUNDOPTIONS="-noshell -noinput +Bd"
```
google搜索"noshell unicode", 在erlang文档里stdlib app的user guide中发现如下这段话:

> io:setopts/{1,2} and the -oldshell/-noshell flags.
> When Erlang is started with -oldshell or -noshell, the I/O-server for standard_io is default set to bytewise encoding, while an interactive shell defaults to what the environment variables says.
> 
> With the io:setopts/2 function you can set the encoding of a file or other I/O-server. This can also be set when opening a file. Setting the terminal (or other standard_io server) unconditionally to the option {encoding,utf8} will for example make UTF-8 encoded characters being written to the device regardless of how Erlang was started or the users environment.
> 
> Opening files with encoding option is convenient when writing or reading text files in a known encoding.
> 
> You can retrieve the encoding setting for an I/O-server using io:getopts().

找出error_logger的group_leader进程pid
```
> process_info(whereis(error_logger), group_leader).
{group_leader,<0.615.0>}
```
发现是user进程
```
> process_info(pid(0,615,0), registered_name).
{registered_name,user}
```
发现encoding为latin1
```
> io:getopts(user).                                 
[{binary,false},{encoding,latin1}]
```
设为unicode
```
> io:setopts(user, [{encoding, unicode}]).          
ok
> io:getopts(user).                       
[{binary,false},{encoding,unicode}]
```

解决!

## 参考链接
http://erlang.org/doc/apps/stdlib/unicode_usage.html

