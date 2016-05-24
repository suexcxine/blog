title: vim erlang tags
date: 2015-10-09
tags: [erlang, vim]
---

## 安装
使用vundle
在.vimrc中加入
```
Plugin 'vim-erlang/vim-erlang-tags' 
```

## 生成tags
在vim中执行`:ErlangTags`即可
在当前目录会生成一个tags文件,其中包含了关键单词与位置的对应关系,如下
> \#player ./include/player.hrl    /^-\s\*record\s\*(\s\*player\>/;"   r

## 生成tags时忽略指定目录
编辑vimrc, 加入
```
" 使ErlangTags不包含_rel目录里的文件                                             
let g:erlang_tags_ignore=["_rel", "ebin"]
```

## 参考链接
https://github.com/vim-erlang/vim-erlang-tags
