title: fcitx
date: 2015-08-06
tags: linux
---
## 安装
sudo apt-get install fcitx
sudo apt-get install fcitx-table-all

## 设为默认输入法
sudo apt-get install im-switch
im-switch -s fcitx -z default

## 卸载ibus
sudo apt-get remove ibus
sudo apt-get remove ibus-gtk
sudo apt-get remove ibus-gtk3

## 解决卸载ibus后导致系统设置里图标变少的问题
sudo apt-get install ubuntu-desktop

