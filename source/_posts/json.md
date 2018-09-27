title: json整型最大值
date: 2018-09-27
tags: [json]
---
遇到 json 整型最大值的问题, 发现我发的 1537955357010001012 变成了1537955357010001000,
原来 json 支持不了 long 型

<!--more-->
超过 Number.MAX_SAFE_INTEGER 的值都无法正常表示

```javascript
Number.MAX_SAFE_INTEGER
9007199254740991
```
这个值是 2 ^ 52 - 1

貌似根源是 javascript 的 Number 类型用的是 double , 用 double 表示整型要保证精度
就只能到这个数

解决方案大概只能是先用字符串传, 到了对面再想办法

## 参考链接
https://stackoverflow.com/questions/47188449/json-max-int-number/47188576
https://stackoverflow.com/questions/13502398/json-integers-limit-on-size

