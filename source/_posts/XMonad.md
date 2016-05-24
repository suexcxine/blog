title: XMonad
date: 2015-07-29
tags: [linux, haskell, gui]
---
平铺式窗口管理器,清爽
<!--more-->
## 安装
sudo apt-get install xmonad suckless-tools
安装完成后,登出并点击登录窗口右侧的图标,选择XMonad再登入,
登入后界面是空白的,别害怕,就是这样子的,按Alt+Shift+Enter可以打开一个终端

## 快捷键
Alt+Shift+Enter 打开一个终端
Alt+J or Alt+K 移动到其他窗口,另外焦点也跟随鼠标
Alt+Space 在各种平铺风格之间切换
Alt+P 下拉应用启动器,可以输入应用程序名并找开
Alt+Shift+C 关闭当前窗口
Alt+Enter 交换当前窗口和主窗口
Alt+Shift+J & Alt+Shift+K 交换当前窗口和下一窗口
Alt+H & Alt+L 放大缩小当前窗口
Alt+, Alt+. 增减主区窗格数
Alt+鼠标左键 移出并移动浮动窗口
Alt+T 将浮动窗口移回
Alt+Shift+Q 退出Xmonad
Alt+1 - Alt+9 切换工作区
Alt+Shift+3 将当前窗口移动到指定工作区
Alt+Q 重新加载配置

## 配置文件路径 
~/.xmonad/xmonad.hs

## 参考链接
https://wiki.haskell.org/Xmonad/Using_xmonad_in_Gnome
https://wiki.haskell.org/Xmonad/Config_archive/Template_xmonad.hs_%280.8%29
https://wiki.haskell.org/Xmonad/General_xmonad.hs_config_tips

