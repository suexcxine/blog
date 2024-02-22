title: PostgreSQL中的表所有者：一个不容忽视的概念
date: 2024-02-22

tags: [pg, db]
---

记录我遇到的一个问题, 现象是更新表结构时报错：
PG::InsufficientPrivilege: ERROR: must be owner of table ......

<!--more-->

## 表所有者的概念

在PostgreSQL中，每个数据库对象（如表、视图或序列）都有一个“所有者”，通常是创建该对象的数据库用户。所有者对其所拥有的对象拥有广泛的权限，包括修改结构、更改权限以及删除对象等。

## 遇到的挑战

### 权限不足错误

当尝试修改或更新一个表时，如果你不是该表的所有者，可能会遇到`PG::InsufficientPrivilege`错误。这通常发生在数据库迁移或执行特定的数据库操作时，提示你没有足够的权限。

## 应对策略

### 查看表所有者

```sql
SELECT * FROM pg_tables WHERE tablename = 'my_tbl';
```
### 更改表所有者

如果必要，可以通过执行`ALTER TABLE`命令来更改表的所有者，使之匹配执行操作的用户。例如：

```sql
ALTER TABLE my_tbl OWNER TO newowner;
```

