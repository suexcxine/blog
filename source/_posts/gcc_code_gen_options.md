title: gcc code gen options
date: 2015-12-28
tags: [c]
---

生成一个shared library(.so)往往要用到-fPIC, 这是什么意思呢?
<!--more-->
例如:
gcc -fPIC -shared -o niftest.so niftest.c -I $ERL_ROOT/usr/include/

-fPIC表示生成位置(地址)无关代码, 意味着生成的机器码不依赖于特定的位置(地址)
例如: 跳转会以相对地址生成而不是绝对地址
<pre>
PIC:

100: COMPARE REG1, REG2
101: JUMP_IF_EQUAL CURRENT+10
...
111: NOP

Non-PIC:

100: COMPARE REG1, REG2
101: JUMP_IF_EQUAL 111
...
111: NOP
</pre>

## 参考链接
https://gcc.gnu.org/onlinedocs/gcc/Code-Gen-Options.html#Code-Gen-Options
http://stackoverflow.com/questions/5311515/gcc-fpic-option

