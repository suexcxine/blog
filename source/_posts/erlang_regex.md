title: erlang 正则表达式
date: 2018-10-08
tags: [erlang, regex, re]
---

<!--more-->

当时打算搞一个校验密码的正则,
各种特殊符号和转义搞死我了

最后还是用这种才得救, 不用一个个写允许哪些符号了
```erlang
re:run(Password, "^[\x21-\x7E]{6,20}$")
```
6-20位长度, 键盘上看得见的符号都允许

### 参考链接
http://www.asciitable.com/
https://www.regular-expressions.info/posixbrackets.html

