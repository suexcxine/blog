title: <<The Linux Command Line>> 第四章笔记
date: 2015-09-07 20:00:04
tags: [linux, bash]
---
## 探究操作系统

ls允许同时列出多个指定目录的内容。在这个例子中，将会列出用户家目录（用字符“~”代表）和/usr 目录的内容方便对比：
```
[me@linuxbox ~]$ ls ~ /usr
```

下面这个例子，ls 命令有两个选项， “l” 选项产生长格式输出，“t”选项按文件修改时间的先后来排序。

```
[me@linuxbox ~]$ ls -lt
```

加上长选项 “--reverse”或短选项-r，则结果会以相反的顺序输出：

```
[me@linuxbox ~]$ ls -lt --reverse
```
或
```
[me@linuxbox ~]$ ls -ltr
```

ls部分选项
* -d     --directory          通常，如果指定了目录名，ls 命令会列出这个目录中的内容，而不是目录本身。 把这个选项与 -l 选项结合使用，可以看到所指定目录的详细信息，而不是目录中的内容。
* -F     --classify           这个选项会在每个所列出的名字后面加上一个指示符。例如，如果名字是 目录名，则会加上一个'/'字符。
* -h     --human-readable     当以长格式列出时，以人们可读的格式，而不是以字节数来显示文件的大小。
* -S                          命令输出结果按照文件大小来排序。
* -i                          显示inode id
* -A                          与-a相比不显示.和..目录

ls -l的输出解释:
-rw-r--r-- 1 root root   32059 2007-04-03 11:05 oo-cd-cover.odf
-rw-r--r--     
对于文件的访问权限。第一个字符指明文件类型。在不同类型之间， 开头的“－”说明是一个普通文件，“d”表明是一个目录。
其后三个字符是文件所有者的 访问权限，再其后的三个字符是文件所属组中成员的访问权限，最后三个字符是其他所 有人的访问权限。这个字段的完整含义将在第十章讨论。
1     
文件的硬链接数目。参考随后讨论的关于链接的内容。
root     
文件属主的用户名。
root     
文件所属用户组的名字。

```
file filename
```
确定文件类型

ASCII（发音是”As-Key”）

* /     根目录，万物起源。
* /bin     包含系统启动和运行所必须的二进制程序。
* /boot     包含 Linux 内核，最初的 RMA 磁盘映像（系统启动时，由驱动程序所需），和 启动加载程序。
* /dev     这是一个包含设备结点的特殊目录。“一切都是文件”，也使用于设备。 在这个目录里，内核维护着它支持的设备。
* /etc     这个目录包含所有系统层面的配置文件。它也包含一系列的 shell 脚本， 在系统启动时，这些脚本会运行每个系统服务。这个目录中的任何文件应该是可读的文本文件。
* /home     在通常的配置环境下，系统会在/home 下，给每个用户分配一个目录。普通只能 在他们自己的目录下创建文件。这个限制保护系统免受错误的用户活动破坏。
* /lib     包含核心系统程序所需的库文件。这些文件与 Windows 中的动态链接库相似。
* /lost+found     每个使用 Linux 文件系统的格式化分区或设备，例如 ext3文件系统， 都会有这个目录。当部分恢复一个损坏的文件系统时，会用到这个目录。除非文件系统 真正的损坏了，那么这个目录会是个空目录。
* /media     在现在的 Linux 系统中，/media 目录会包含可移除媒体设备的挂载点， 例如 USB 驱动器，CD-ROMs 等等。这些设备连接到计算机之后，会自动地挂载到这个目录结点下。
* /mnt     在早些的 Linux 系统中，/mnt 目录包含可移除设备的挂载点。
* /opt     这个/opt 目录被用来安装“可选的”软件。这个主要用来存储可能 安装在系统中的商业软件产品。
* /proc     这个/proc 目录很特殊。从存储在硬盘上的文件的意义上说，它不是真正的文件系统。 反而，它是一个由 Linux 内核维护的虚拟文件系统。它所包含的文件是内核的窥视孔。这些文件是可读的， 它们会告诉你内核是怎样监管计算机的。
* /root     root 帐户的家目录。
* /sbin     这个目录包含“系统”二进制文件。它们是完成重大系统任务的程序，通常为超级用户保留。
* /tmp     这个/tmp 目录，是用来存储由各种程序创建的临时文件的地方。一些配置，导致系统每次 重新启动时，都会清空这个目录。
* /usr     在 Linux 系统中，/usr 目录可能是最大的一个。它包含普通用户所需要的所有程序和文件。
* /usr/bin     /usr/bin 目录包含系统安装的可执行程序。通常，这个目录会包含许多程序。
* /usr/lib     包含由/usr/bin 目录中的程序所用的共享库。
* /usr/local     这个/usr/local 目录，是非系统发行版自带，却打算让系统使用的程序的安装目录。 通常，由源码编译的程序会安装在/usr/local/bin 目录下。新安装的 Linux 系统中，会存在这个目录， 但却是空目录，直到系统管理员放些东西到它里面。
* /usr/sbin     包含许多系统管理程序。
* /usr/share     /usr/share 目录包含许多由/usr/bin 目录中的程序使用的共享数据。 其中包括像默认的配置文件，图标，桌面背景，音频文件等等。
* /usr/share/doc     大多数安装在系统中的软件包会包含一些文档。在/usr/share/doc 目录下， 我们可以找到按照软件包分类的文档。
* /var     除了/tmp 和/home 目录之外，相对来说，目前我们看到的目录是静态的，这是说， 它们的内容不会改变。/var 目录是可能需要改动的文件存储的地方。各种数据库，假脱机文件， 用户邮件等等，都驻扎在这里。
* /var/log     这个/var/log 目录包含日志文件，各种系统活动的记录。这些文件非常重要，并且 应该时时监测它们。其中最重要的一个文件是/var/log/messages。注意，为了系统安全，在一些系统中， 你必须是超级用户才能查看这些日志文件。

