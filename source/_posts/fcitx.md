title: fcitx
date: 2015-08-06
tags: linux
---

## 安装
```
sudo apt-get install fcitx
sudo apt-get install fcitx-table-all
sudo apt-get install fcitx-mozc // 日语输入法
```

## 设fcitx为默认
```
sudo apt-get install im-config
进入im-config图形界面设置fcitx为默认输入法
```

## 添加具体输入法
将系统设置里的keyboard里的shortcuts里的"Switch to next source"和"Switch to previous source"disable掉，鼠标点击后按Backspace键即可disable.
点击右上角任务栏里的键盘样图标，选择Configure Current Input Method，点击左下角的+号，清掉"Only Show Current Language"复选框后添加你想要的输入法

Logout或Restart

Ctrl+Space开启或关闭输入法， Ctrl+Shift切换输入法

Enjoy!

