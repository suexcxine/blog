title: Ubuntu下Caps Lock键替换成Ctrl键
date: 2015-07-16
tags: linux
---

## 交换左ctrl和caps lock键
```bash
setxkbmap -option ctrl:swapcaps # Swap Left Control and Caps Lock
```
## 将caps lock键改为ctrl键
```bash
setxkbmap -option ctrl:nocaps # Make Caps Lock a Control key
```
## 或者在/etc/default/keyboard 文件中
```bash
XKBOPTIONS="ctrl:nocaps"
```
