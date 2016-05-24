title: mysql查询
date: 2015-12-04
tags: [db]
---

select语句用法
<!--more-->

## distinct
select distinct vend_id, vend_name from products;
distinct 关键字用于去除重复的值, 注意该关键字作用于所有列而不仅是一列

## limit
select prod_name from products limit 5;
select prod_name from products limit 5, 5;
limit 限制行数, 可以指定从第几行(第一行是行0)开始要几行, limit 1, 1表示只要第二行

使用完全限定名
select crashcourse.product.prod_name from crashcourse.products;

## between
闭区间范围限定
select prod_name, prod_price from products where prod_price between 5 and 10;

## 空值判定
select prod_name from products where prod_price IS NULL;

## in 
指定条件范围
select prod_name, prod_price from products where vend_id in (1002, 1003);
in的最大优点是可以包含其他SELECT语句,使得能够更动态地建立WHERE子句

## not
select prod_name, prod_price from products where vend_id not in (1002, 1003);
支持not in, not between, not exists

## 通配符
% 匹配任意字符出现任意次数(包括0次)
select prod\_name, prod\_price from products where prod\_name LIKE '%anvil1%';

\_(下划线) 匹配任意单个字符
select prod\_name, prod\_price from products where prod\_name LIKE '_ ton anvil';

注意: 
通配符不能匹配NULL
不要过度使用通配符,性能不是很好,确实需要使用时,尽量不要用在搜索模式的开始处(最慢)

## regexp 正则表达式
可以用如下方式测试正则表达式
select 'hello' regexp '[0-9]';
select 'D34' regexp '[^abc][3-7][[:alnum:]]';

使用binary可以区分大小写
select 'C34' regexp binary '[abc][3-7][[:alnum:]]';

[[:<:]]匹配词的开始
select 'hello world' regexp '[[:<:]]w';

[[:>:]]匹配词的结尾
select 'hello world' regexp 'd[[:>:]]';

转义字符\\\\, 是两个反斜杠, 要匹配反斜杠本身, 用\\\\\\,
为什么要用两个反斜杠呢,MySQL自己解释一个,正则表达式库解释另一个

## group by 分组
HAVING: 过滤分组
select cust_id, count(\*) as orders from orders where prod_price >= 10 
group by cust_id having orders >= 2;
HAVING与WHERE的区别, WHERE在分组前过滤, HAVING在分组后过滤

WITH ROLLUP: 可以得到分组汇总信息
select vend_id, count(\*) as num_prods from products group by vend_id with rollup;

## select子句顺序
select
from
where
group by 
having
order by
limit

## 子查询
例1:用于where in
```
select cust_id from orders where order_num in
    (select order_num from orderitems where prod_id = 'TNT2');
```
例2:
```
select 
  cust_name, 
  cust_state, 
  (select count(*) from orders where orders.cust_id = customers.cust_id) as orders 
from customers
order by cust_name;
```

子查询的处理顺序是从内向外

## 连接
select vend_name, prod_name, prod_price 
from vendors, products
where vendors.vend_id = products.vend_id
连接可以是多个表

cross join 交叉连接
没有连接条件的表关系返回的结果为笛卡尔积, 返回的行数目是两个表行数的乘积

equijoin 内部连接, 即等值连接
```
select vend_name, prod_name, prod_price 
from vendors inner join products
  on vendors.vend_id = products.vend_id
```

### 自连接
select p1.id, p1.name from player as p1, player as p2 where p1.lvl = p2.lvl and p2.id = 301;

### 自然连接
指的是不出现重复列名的连接
```
select c.*, o.order_num, oi.prod_id
from customers as c, orders as o, orderitems as oi
where c.cust_id = o.cust_id
  and oi.order_num = o.order_num
  and prod_id = 'FB';
```
这个效果由我们自己完成,即只对一个表使用\*通配符,
其他表的字段都显示写出,这样来保证不出现重复列表

### 外连接
包含相关表中没有关联行的行
```
select customers.cust_id, orders.order_num
from customers left outer join orders
  on customers.cust_id = orders.cust_id
```
返回的结果可能会有10002 -> NULL这样的行, 这就是左外连接的目的,以左边的表为主,保留这样的行,
右外连接类似,即以右边的表为主

## 组合查询
union, 会自动去除重复行, 这种多数情况下与在where里加上or条件的效果相同
union all, 不会自动去除重复行, 这种行为无法使用where子句代替
order by子句必须出现在最后一个select之后
union可以将不同表的select结果拼接在一起,只要列的数量相同且数据类型可相互转换即可

## 全文本搜索
```
create table productnotes
(
  note_id int not null auto_increment,
  note_text text null,
  primary key(note_id),
  fulltext(note_text)
) engine=myisam;
```
mysql创建指定列中各词的一个索引
导入数据时使用fulltext不如在导入完成后再添加索引,
因为一边导入一边更新索引耗费的时间长,而导入完成后一次性创建索引比较快

select note_text from productnotes where match(note_text) against('rabbit');
select note_text, match(note_text) against('rabbit') as rank from productnotes;
全文检索会按匹配等级排序, rank为0的行就会被排除在外

select note_text from productnotes where match(note_text) against('rabbit' with query expansion);
查询扩展,会找出即使不包含rabbit,但是包含一些相关词的行

布尔检索
比较复杂,这里不介绍了

MyISAM引擎支持全文本搜索,
InnoDB引擎5.6版本才支持(不支持中文,据说也有支持的开源项目)
可以考虑使用外部索引程序, 例如solr

## 聚集函数
* count
使用count(\*)计算所有行,包括NULL的行
使用count(column)忽略NULL
select count(1) from player; 比 select count(\*) from player; 效率高一点, 省了\*的转换,也省得取多列的数据
* sum: select sum(item_price * quantity) from orderitems;
* min
* max
* avg: select avg(distinct prod_price) as avg_price from products; 加distinct可以忽略重复的项
* group_concat 

## 字符串函数
* concat: select concat('abc', 'def');
* trim, ltrim, rtrim: select trim('  abc   ');
* upper
* lower
* left
* right
* length
* locate
* substring
* soundex
soundex将字符串转换为描述其语音的字母数字模式
select cust_name, cust_contact from customers where soundex(cust_contact) = soundex('Y Lie');
可以找到发音与'Y Lie'的行, 如 'Y Lee'

## 日期时间函数
* adddate
* addtime
* curdate
* curtime
* date
* time
* datediff
* date_add
* date_format
* year
* month
* day
* dayofweek
* hour
* minute
* second
* now
SQL语句中使用的日期格式是yyyy-mm-dd, 如
select cust_id from orders where date(order_date) = '2005-09-01'

### 两位数年份
00-69表示2000-2069, 70-99表示1970-1999
但是尽量不要使用两位数年份这样有隐性规定的东西

### from_unixtime()与unix_timestamp()
```
mysql> select from_unixtime(1195488000, '%Y%m%d')    
20071120  
mysql> select from_unixtime(1195488000, '%Y年%m月%d')   
2007年11月20  
```
unix_timestamp是与之相对正好相反的时间函数  
```
mysql> select unix_timestamp('2007-11-20');
1195488000  
```

## 数值处理函数
* rand
* abs
* mod
* pi
* exp
* sqrt
* sin
* cos
* tan

