title: mysql性能优化
date: 2015-12-05
tags: [db]
---

记录一点优化的经验
<!--more-->

## transaction优化多条语句的性能
```
> tc_avg(fun() -> 
    [db_util:update(<<"people">>, ["silver"], [random:uniform(1000000)], [<<"id">>], I) || I <- L]
end, 30).
Range: 86791 - 112256 microseconds
Median: 99040 microseconds
Average: 98503.03 microseconds
98503.03
> tc_avg(fun() -> 
    F = fun() -> [db_util:update(<<"people">>, ["silver"], [random:uniform(1000000)], [<<"id">>], I) || I <- L] end, 
    db_util:transaction(F) 
end, 30).
Range: 5999 - 9691 microseconds
Median: 6388 microseconds
Average: 6840.17 microseconds
6840.17
```
可见此例的性能差距接近15倍(平均98.5毫秒对6.8毫秒)

## 将多条语句合成一条语句
### 使用insert on duplicate key update取代多条update语句
```
insert into t_member (id, name, email) values
    (1, 'nick', 'nick@126.com'),
    (4, 'angel','angel@163.com'),
    (7, 'brank','ba198@126.com')
on duplicate key update name=values(name), email=values(email);
```

### 使用replace into取代多条update语句
```
replace into test_tbl (id,dr) 
values (1,'2'),(2,'3'),...(x,'y');
```
replace into和insert into on duplicate key update的不同在于：
replace into操作本质是对重复的记录(不一定主键,唯一索引重复也算)先delete后insert，
如果更新的字段不全会将缺失的字段置为缺省值

### 使用case取代多条update语句
```
update categories
    set display_order = case id
        when 1 then 3
        when 2 then 4
        when 3 then 5
    end,
    title = case id
        when 1 then 'new title 1'
        when 2 then 'new title 2'
        when 3 then 'new title 3'
    end
where id in (1,2,3)
```

### 使用临时表取代多条update语句
```
create temporary table tmp(id int primary key, sum int);
insert into tmp (select player_id, count(*) from `pet` group by player_id);
update counter, tmp set counter.data=tmp.sum 
    where counter.player_id=tmp.id and counter.domain = 0 and counter.id = 3;
```

## show processlist; 
显示所有活动进程(每条都是一个连接)以及它们的线程id和执行时间

## explain语句
查询执行计划

## 其他
* 导入数据时应关闭自动提交, 可能先删除fulltext等索引(导入完成后再建索引)
* 当select语句中有复杂的or条件时,分拆select并使用union可能会提升性能
* 索引有利于读,不利于写,看哪种操作比较频繁,根据需要优化
* like很慢

## 参考链接
http://www.crackedzone.com/mysql-muti-sql-not-sugguest-update.html
http://dev.mysql.com/doc/refman/5.0/en/insert.html
http://www.educity.cn/shujuku/692086.html

