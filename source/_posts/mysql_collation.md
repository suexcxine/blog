title: mysql校对规则
date: 2016-08-03 21:27:00
tags: [mysql, db]
---

mysql校对规则用于字符的比较和排序

<!--more-->

查看字符集相关变量
```
SHOW VARIABLES LIKE 'character%';
```

查看校对相关变量
```
SHOW VARIABLES LIKE 'collation_%';
```

查看可用的校对选项
```
show collation like 'utf8%';
```

两个字符串比较，要求两者必须有相同的校对规则，
或者两者的校对规则是相容的—— 所谓相容是指，两种校对规则优先级不同，
比较的时候两者使用高优先级的校对规则进行比较，比如latin1_bin的优先级相对较高。
如校对规则同级，则不能进行比较；如果强行比较的话，就会报错.

可以在sql语句中强制指定校对规则进行比较, 
```
select * from tbl where col_b COLLATE latin1_danish_ci = col_c COLLATE latin1_danish_ci;
```

