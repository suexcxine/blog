title: Windows下Caps Lock键替换成Ctrl键
date: 2015-10-16
tags: [windows]
---
修改注册名映射键位
<!--more-->
![修改注册表](/pics/windows_nocaps.png)
如图:
>  [HKEY_LOCAL_MACHINE] 
>  +[SYSTEM] 
>  +[CurrentControlSet] 
>  +[Control] 
>  +[Keyboard Layout]

添加"Scancode Map"二进制项，内容为
> 00 00 00 00 00 00 00 00
> 03 00 00 00 1D 00 3A 00
> 00 00 00 00 00 00 00 00

