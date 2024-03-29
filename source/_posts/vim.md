title: vim
date: 2015-08-06
tags: [linux, erlang]
---
## 安装vim
sudo apt-get install vim

## 安装vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

拷贝github上的.vimrc的部分到自己的.vimrc
进入vim执行:PluginInstall
sudo apt-get install cscope
vim-scripts/cscope.vim 这个插件不能用master分支下面的,要用1.01或者1.0?

## 让vim把.swp统一放到指定的文件夹
Vim默认可以将.swp保存到指定的位置，而不是当前文件夹下，在 vimrc 中加入：
```bash
set directory=~/.vimbak,/tmp
```
Vim会先找 ~/.vimbak,如果有，.swp 文件就暂时放到此处，如果没有就会找下一个，路径用逗号隔开，逗号后面不要加空格。

## 查找功能
循环查找
:set wrapscan
:set nowrapscan

## vim插件scrooloose/syntastic
erlang对应的语法检查文件是:
~/.vim/bundle/syntastic/syntax_checkers/erlang/erlang_check_file.erl

如果代码里用到了include以外路径的头文件,那么需要加一个i参数,如下
```erlang
Defs = [strong_validation,
        warn_export_all,
        warn_shadow_vars,
        warn_obsolete_guard,
        warn_unused_import,
        report,
        {i, Dir ++ "/include"},
        {i, Dir ++ "/src"}],
```

## 使Vim工作在vi兼容模式下:
set cp
set nocp

## 大小写转换
gu 小写
gU 大写
后面跟范围即可, 如guw, guip

## 二进制模式

把所有的行(%)用本地(!)的xxd程序打开
```
:%!xxd
```

返回正常显示： 
```
:%!xxd -r 
```

xxd程序的文档
```
man xxd
```

## 忽略大小写
有时候希望查找忽略大小写
```
:set ic
```
即ignore case
```
:set noic
```
大小写敏感



## vimdiff 命令很好用