title: screen 
date: 2015-11-05
tags: linux
---
将.screenrc文件放到home目录即~下即可在screen里显示窗口列表

screen -S name 新建一个session

screen -ls 列出当前所有虚拟终端
screen -rd sessionid 断开(detach)其他连接并进入(reattach)指定的虚拟终端

C-a ? 帮助
C-a w 窗口列表
C-a c 创建一个
C-a A 当前的改名
C-a k 杀掉当前的
C-a d 退出screen, 但screen里的窗口依然保持, 之后还可以attach

C-a [ 进入copy mode, 可以滚动窗口和选择文本拷贝

C-a n 切换到下一个 window 
C-a p 切换到前一个 window 
C-a 0..9 切换到第 0..9 个 window 

