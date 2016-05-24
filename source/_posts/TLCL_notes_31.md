title: <<The Linux Command Line>> 第三一章笔记 疑难排解
date: 2015-09-07 20:00:31
tags: [linux, bash]
---
## 追踪
bash 还提供了一种名为追踪的方法，这种方法可通过 -x 选项和 set 命令加上 -x 选项两种途径实现。 
拿我们之前的 trouble 脚本为例，给该脚本的第一行语句添加 -x 选项，我们就能追踪整个脚本。
```
#!/bin/bash -x
# trouble: script to demonstrate common errors
number=1
if [ $number = 1 ]; then
    echo "Number is equal to 1."
else
    echo "Number is not equal to 1."
fi
```
当脚本执行后，输出结果看起来像这样:
```
[me@linuxbox ~]$ trouble
+ number=1
+ '[' 1 = 1 ']'
+ echo 'Number is equal to 1.'
Number is equal to 1.
```

追踪生效后，我们看到脚本命令展开后才执行。行首的加号表明追踪的迹象，使其与常规输出结果区分开来。 
加号是追踪输出的默认字符。它包含在 PS4（提示符4）shell 变量中。可以调整这个变量值让提示信息更有意义。 
这里，我们修改该变量的内容，让其包含脚本中追踪执行到的当前行的行号。
注意这里必须使用单引号是为了防止变量展开，直到 提示符真正使用的时候，就不需要了。

```
[me@linuxbox ~]$ export PS4='$LINENO + '
[me@linuxbox ~]$ trouble
5 + number=1
7 + '[' 1 = 1 ']'
8 + echo 'Number is equal to 1.'
Number is equal to 1.
```

我们还可以使用 set 命令加上 -x 选项，为脚本中的一块选择区域，而不是整个脚本启用追踪。

```
#!/bin/bash
# trouble: script to demonstrate common errors
number=1
set -x # Turn on tracing
if [ $number = 1 ]; then
    echo "Number is equal to 1."
else
    echo "Number is not equal to 1."
fi
set +x # Turn off tracing
```
我们使用 set 命令加上 -x 选项来启动追踪，+x 选项关闭追踪。这种技术可以用来检查一个有错误的脚本的多个部分。

## Bash Debugger
对于真正的高强度的调试，参考这个：
http://bashdb.sourceforge.net/

