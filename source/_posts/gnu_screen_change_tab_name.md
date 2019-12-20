title: gnu screen 修改 tab 名称遇到自动跳回的问题和解决
date: 2019-12-20 11:28:00
tags: [linux, gnu, screen]
---

需要在shell执行如下命令避免 tab 名称自动跳回
```
export PROMPT_COMMAND=
```
然后再用 screen 快捷键 `Ctrl a A` 修改 tab 名称之后就不再跳回了

