title: 正则表达式
date: 2015-09-06
tags: linux
---
## 关于[A-Z]的ASCII顺序和字典顺序的问题
[A-Z]这种正则表达式可能被解释为[ABCDEFGHIJKLMNOPQRSTUVWXYZ](ASCII顺序),
也可能被解释为[AbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ](字典顺序)

例如, shell:
$ ls /usr/sbin/[A-Z]*
/usr/sbin/bccmd     /usr/sbin/fdformat    /usr/sbin/lpinfo    /usr/sbin/readprofile    /usr/sbin/update-dictcommon-hunspell

$ ls /usr/sbin/[[:upper:]]*
/usr/sbin/ModemManager  /usr/sbin/NetworkManager

而, erlang:
> filelib:wildcard("/usr/sbin/[A-Z]*").
["/usr/sbin/ModemManager","/usr/sbin/NetworkManager"]

貌似只有shell有这个问题

