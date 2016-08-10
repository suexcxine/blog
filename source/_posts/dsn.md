title: data source name
date: 2016-08-10
tags: [db]
---

<pre>
[username[:password]@][protocol[(address)]]/dbname[?param1=value1&...&paramN=valueN]
</pre>
大概长这样:
<pre>
username:password@protocol(address)/dbname?param=value
</pre>

为了方便定义数据库源的一种格式化的字符串,
程序用起来还是又要parse又要format的(看下面参考链接里的go实现,复杂+不爽),
也许觉得对人类友好吧,
真的友好吗?

## 参考链接
https://github.com/go-sql-driver/mysql#dsn-data-source-name
https://github.com/go-sql-driver/mysql/blob/66312f7fe2678aa0f5ec770f96702f4c4ec5aa8e/dsn.go#L246

