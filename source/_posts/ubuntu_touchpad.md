title: ubuntu如何禁用笔记本触摸板
date: 2016-07-17 12:38:00
tags: [ubuntu, linux]
---

用笔记本时碰到很多次在打字的时候碰到触摸板导致误操作。
<!--more-->

## 快捷键方法
多数笔记本支持Fn+F6功能键可以禁用和启用触摸板。

## modprobe
```
 sudo modprobe -r psmouse #关闭 
 sudo modprobe psmouse    #打开
```

## 安装touchpad-indicator
可以检测是否有插上鼠标来确定是否去关闭触摸板。
```
sudo add-apt-repository ppa:atareao/atareao 
sudo apt-get update 
sudo apt-get install touchpad-indicator
```

