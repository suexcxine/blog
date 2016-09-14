title: mysql DML
date: 2015-12-04
tags: [db]
---

insert update delete
<!--more-->

## insert
insert into customers values(..., ...);
这种形式values里必须提供所有的列值,不推荐,当表结构变化时语句失效
insert into customers(xxx, yyy, ...) values(..., ...);
这种形式指定插入哪些值,当表结构变化时语句仍然有效
insert into customers(xxx, yyy, ...) values(..., ...), (..., ...), ...;
可以一次插入多行

insert low_priority into 表示低优先级(可能想让SELECT先执行)
low_priority关键字也适用于update和delete

insert select功能, 可以将select得到的结果插入表中
insert into customers(xxx, yyy, ...) select xxx, yyy, ... from tablename;

## update
update customers set cust_email = 'elmer@fudd.com' where cust_id = 10005;
注意update和delete语句一定要写where子句, 应用程序里最好把where子句为空的情况直接报错处理
如果确实要对所有行更新,可以明确使用where 1,避免出现where子句忘写的bug情况

update ignore customers set ...
表示更新过程中即使出现错误也继续更新,不回滚

## delete
delete from customers where cust_id = 10006;
truncate table(直接删表重建)比delete(逐行删除)效率高

## create
create if not exists 表示仅在不存在时创建表
是否使用NULL值: 默认允许NULL, NOT NULL表示不允许NULL

auto_increment必须被索引,且只能定义一列
可以覆盖auto_increment列的值,后续增量将在该基础上继续

select last_insert_id()
返回最后一个auto_increment的值

default关键字
表示插入行时没有值的列使用的默认值, 很多时候倾向使用default而不是null

## alter
增删字段
alter table vendors add vend_phone char(20);
alter table vendors drop column vend_phone;

外键约束
alter table orderitems
add constraint fk_orderitems_orders
foreign key (order_num) references orders (order_num);

修改自增列的起点值
ALTER TABLE penguins AUTO_INCREMENT=1001;

查看指定表的create语句
show create table tablename

## drop
drop table customers;

## rename
rename table xxx to yyy;

