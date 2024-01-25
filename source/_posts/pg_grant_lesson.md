title: 理解 PostgreSQL 权限管理：GRANT SELECT 和 ALTER DEFAULT PRIVILEGES 的坑
date: 2024-01-25

tags: [pg, db, postgres]
---

记录我遇到的一个问题, 现象是我发现我的只读用户看不到新表...

<!--more-->
#### 为现有表授权

当你想要为只读用户授权访问现有的表时，`GRANT SELECT`命令是你的首选。这个命令会为指定的用户或角色提供对现有表的读取权限。例如，假设我们有一个只读用户`user_readonly`，我们想要让这个用户能够查询`public`模式下的所有现有表，我们可以使用如下命令：

```sql
GRANT SELECT ON ALL TABLES IN SCHEMA public TO user_readonly;
```

这条命令将为`user_readonly`用户授予对`public`模式下所有当前存在的表的读取权限。重要的是要注意，这个授权仅适用于命令执行时已经存在的表。未来创建的新表不会自动继承这些权限。

#### 为未来的表设置默认权限

如果你希望确保某个用户未来创建的所有新表都自动为只读用户`user_readonly`授予`SELECT`权限，你需要使用`ALTER DEFAULT PRIVILEGES`命令。这个命令设置了新对象的默认权限，但它只适用于执行该命令的用户或指定的角色创建的新对象。

例如，如果你是以`admin`用户身份登录，并且希望所有`admin`用户创建的新表都为`user_readonly`用户授予`SELECT`权限，你可以使用如下命令：

```sql
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO user_readonly;
```

你也可以设置对于由特定用户或属于特定角色的用户创建的新对象的默认权限。通过使用`FOR USER`或`FOR ROLE`子句，你可以精确控制哪些用户或角色创建的新表将自动应用这些默认权限。

```sql
ALTER DEFAULT PRIVILEGES FOR USER creating_user IN SCHEMA public GRANT SELECT ON TABLES TO user_readonly;
```

在这个例子中，`creating_user`应该被替换为创建新表的用户的用户名。这意味着只有`creating_user`用户在`public`模式下创建的新表，才会自动授予`user_readonly`用户`SELECT`权限。

如果你希望这个规则适用于所有用户创建的新表，你需要为每个潜在的表创建者重复执行这个命令，或者更实际的做法是，为所有这些用户设置一个共同的角色，并为那个角色设置默认权限。

#### 注意事项

- **执行用户**：执行`GRANT SELECT`命令的用户需要有足够的权限来对指定的表执行授权操作。通常，这意味着数据库的所有者、超级用户或者具有足够权限的用户。
- **默认权限的范围**：`ALTER DEFAULT PRIVILEGES`命令仅适用于执行该命令的用户或指定角色之后创建的对象。因此，正确设置执行用户或角色是关键。

