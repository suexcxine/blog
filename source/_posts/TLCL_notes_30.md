title: <<The Linux Command Line>> 第三十章笔记
date: 2015-09-07 20:00:30
tags: [linux, bash]
---
## 流程控制：while/until 循环
```
#!/bin/bash
# while-count: display a series of numbers
count=1
while [ $count -le 5 ]; do
    echo $count
    count=$((count + 1))
done
echo "Finished."
```

### break & continue
bash 提供了两个内部命令，它们可以用来在循环内部控制程序流程。
这个 break 命令立即终止一个循环， 且程序继续执行循环之后的语句。
这个 continue 命令导致程序跳过循环中剩余的语句，且程序继续执行 下一次循环。

### until
这个 until 命令与 while 非常相似，除了当遇到一个非零退出状态的时候， while 退出循环， 而 until 不退出。一个 until 循环会继续执行直到它接受了一个退出状态零。

### 使用循环读取文件
while 和 until 能够处理标准输入。这就可以使用 while 和 until 处理文件。
```
#!/bin/bash
# while-read: read lines from a file
while read distro version release; do
    printf "Distro: %s\tVersion: %s\tReleased: %s\n" \
        $distro \
        $version \
        $release
done < distros.txt
```

