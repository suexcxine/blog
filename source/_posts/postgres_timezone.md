title: PostgreSQL 时区处理详解：AT TIME ZONE
date: 2026-04-12
tags: [postgresql, timezone, database]
---

`AT TIME ZONE` 是 PostgreSQL 中处理时区的核心操作符，却也是最容易让人困惑的特性之一。它看似简单，实则身兼两种截然相反的职责。本文梳理清楚它的工作机制。

<!--more-->

## 两种截然不同的用途

`AT TIME ZONE` 有两种用途：

1. **为无时区的时间戳添加时区**：`TIMESTAMP WITHOUT TIME ZONE` → `TIMESTAMP WITH TIME ZONE`
2. **将有时区的时间戳转换到另一时区并去除时区标记**：`TIMESTAMP WITH TIME ZONE` → `TIMESTAMP WITHOUT TIME ZONE`

用一句话概括：输入类型不同，行为完全不同。SQL 标准要求这个操作符承担这两种职责，尽管看起来有点奇怪。

---

## 用途一：为无时区时间戳加上时区

当输入是 `::timestamp`（即 `TIMESTAMP WITHOUT TIME ZONE`）时，`AT TIME ZONE` 的语义是：

> "把这个日期时间值**解读为**指定时区的本地时间，然后换算到当前会话时区显示。"

```sql
SELECT '2018-09-02 07:09:19'::timestamp AT TIME ZONE 'America/Chicago';
-- 结果：2018-09-02 08:09:19-04
```

上面的例子中，`07:09:19` 被解读为芝加哥时间（UTC-5），换算到会话时区（UTC-4）后显示为 `08:09:19-04`。

### 输入字符串里的时区会被忽略

`::timestamp` 的转换会丢弃输入字符串中携带的任何时区信息：

```sql
SELECT '2018-09-02 07:09:19'::timestamp;
-- 结果：2018-09-02 07:09:19

SELECT '2018-09-02 07:09:19-10'::timestamp;
-- 结果：2018-09-02 07:09:19   ← -10 被忽略

SELECT '2018-09-02 07:09:19-12'::timestamp;
-- 结果：2018-09-02 07:09:19   ← -12 被忽略
```

因此，不管输入字符串里写了什么时区偏移，加上 `::timestamp` 后再接 `AT TIME ZONE`，结果都相同：

```sql
SELECT '2018-09-02 07:09:19'::timestamp    AT TIME ZONE 'America/Chicago';
-- 2018-09-02 08:09:19-04

SELECT '2018-09-02 07:09:19-10'::timestamp AT TIME ZONE 'America/Chicago';
-- 2018-09-02 08:09:19-04

SELECT '2018-09-02 07:09:19-12'::timestamp AT TIME ZONE 'America/Chicago';
-- 2018-09-02 08:09:19-04
```

三条查询结果完全一致，因为 `::timestamp` 强制去除了时区信息。

更多示例，AT TIME ZONE 指定不同时区时的输出（会话时区均为 UTC-4）：

```sql
SELECT '2018-09-02 07:09:19'::timestamp AT TIME ZONE 'America/Chicago';
-- 2018-09-02 08:09:19-04   （芝加哥 UTC-5，换算 +1 小时）

SELECT '2018-09-02 07:09:19'::timestamp AT TIME ZONE 'America/Los_Angeles';
-- 2018-09-02 10:09:19-04   （洛杉矶 UTC-7，换算 +3 小时）

SELECT '2018-09-02 07:09:19'::timestamp AT TIME ZONE 'Asia/Tokyo';
-- 2018-09-01 18:09:19-04   （东京 UTC+9，换算 -13 小时，跨了一天）
```

---

## 用途二：将有时区的时间戳转换到指定时区

当输入是 `::timestamptz`（即 `TIMESTAMP WITH TIME ZONE`）时，`AT TIME ZONE` 的语义是：

> "把这个绝对时刻**转换到**指定时区的本地时间，并去掉时区标记。"

```sql
SELECT '2018-09-02 07:09:19-04'::timestamptz AT TIME ZONE 'America/Chicago';
-- 结果：2018-09-02 06:09:19

SELECT '2018-09-02 07:09:19-04'::timestamptz AT TIME ZONE 'America/Los_Angeles';
-- 结果：2018-09-02 04:09:19

SELECT '2018-09-02 07:09:19-04'::timestamptz AT TIME ZONE 'Asia/Tokyo';
-- 结果：2018-09-02 20:09:19
```

注意：返回值没有时区标记，是 `TIMESTAMP WITHOUT TIME ZONE`。这个特性很实用——通常你需要修改会话的 `TimeZone` 参数才能看到其他时区的时间，用 `AT TIME ZONE` 可以不改全局配置直接换算。

### 这时输入的时区很重要

与用途一不同，这里输入值携带的时区偏移至关重要，它决定了这个时刻在世界时间轴上的位置：

```sql
SELECT '2018-09-02 07:09:19-04'::timestamptz AT TIME ZONE 'America/Chicago';
-- 2018-09-02 06:09:19   （UTC-4 换算到 UTC-5）

SELECT '2018-09-02 07:09:19-05'::timestamptz AT TIME ZONE 'America/Chicago';
-- 2018-09-02 07:09:19   （已经是 UTC-5，不变）

SELECT '2018-09-02 07:09:19-06'::timestamptz AT TIME ZONE 'America/Chicago';
-- 2018-09-02 08:09:19   （UTC-6 换算到 UTC-5，+1 小时）
```

输入偏移不同，结果差了整整一小时，这与用途一形成鲜明对比。

---

## 不加显式转换时的行为

如果不加 `::timestamp` 或 `::timestamptz` 转换，PostgreSQL 默认把输入当作 `TIMESTAMP WITH TIME ZONE`，没有指定时区时使用会话时区：

```sql
SELECT '2018-09-02 07:09:19' AT TIME ZONE 'America/Chicago';
-- 2018-09-02 06:09:19   （当前会话为 UTC-4，换算到 UTC-5）

SELECT '2018-09-02 07:09:19-10' AT TIME ZONE 'America/Chicago';
-- 2018-09-02 12:09:19   （UTC-10 换算到 UTC-5）
```

结果没有时区标记（`TIMESTAMP WITHOUT TIME ZONE`），走的是用途二的逻辑。

---

## 连续使用两次 AT TIME ZONE

### 相同时区：互相抵消

```sql
SELECT '2018-09-02 07:09:19'::timestamp
    AT TIME ZONE 'America/Chicago'
    AT TIME ZONE 'America/Chicago';
-- 结果：2018-09-02 07:09:19

SELECT '2018-09-02 07:09:19-04'::timestamptz
    AT TIME ZONE 'America/Chicago'
    AT TIME ZONE 'America/Chicago';
-- 结果：2018-09-02 07:09:19-04
```

两次操作类型互逆，恰好抵消，还原原始值。

### 不同时区：时区换算

```sql
SELECT '2018-09-02 07:09:19'::timestamp
    AT TIME ZONE 'Asia/Tokyo'
    AT TIME ZONE 'America/Chicago';
-- 结果：2018-09-01 17:09:19
```

这个写法非常实用：将东京时间 `07:09:19` 换算成芝加哥对应的本地时间 `17:09:19`（前一天），是跨时区时间换算的简洁写法。

---

## 小结

| 输入类型 | AT TIME ZONE 的行为 | 输出类型 |
|---|---|---|
| `TIMESTAMP WITHOUT TIME ZONE` (`::timestamp`) | 将该值**解读为**指定时区的本地时间，转换到会话时区显示 | `TIMESTAMP WITH TIME ZONE` |
| `TIMESTAMP WITH TIME ZONE` (`::timestamptz`) | 将该绝对时刻**换算到**指定时区的本地时间，去除时区标记 | `TIMESTAMP WITHOUT TIME ZONE` |

记住一个关键点：**`::timestamp` 会丢弃输入中的时区信息，`::timestamptz` 则保留并使用它**。

理解了这一点，`AT TIME ZONE` 的行为就不再神秘。

---

## 参考

- [Postgres AT TIME ZONE Explained - EnterpriseDB](https://www.enterprisedb.com/postgres-tutorials/postgres-time-zone-explained)
- [PostgreSQL 官方文档：AT TIME ZONE](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-ZONECONVERT)
