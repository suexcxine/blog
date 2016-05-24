title: unicode
tag: charsets
date: 2015-09-06
---
## UTF-8 字节流模板
1字节
000000 - 00007F 0xxxxxxx
2字节
000080 - 0007FF 110xxxxx 10xxxxxx
3字节
000800 - 00FFFF 1110xxxx 10xxxxxx 10xxxxxx
4字节
010000 - 10FFFF 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
据此可以算出当前的字符会占几个字节

## 16#4e00-16#9fff是中日韩字符的unicode范围
以此为依据判断一个字符是否中文字符?

    
