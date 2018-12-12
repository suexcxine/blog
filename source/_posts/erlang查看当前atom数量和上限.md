title: 如何检查当前的atom数量和上限
date: 2015-07-22
tags: erlang
---

### 在shell里Ctrl+a并选择info, index_table:atom_tab的entries项是当前atom数量,limit是上限
> BREAK: (a)bort (c)ontinue (p)roc info (i)nfo (l)oaded
>        (v)ersion (k)ill (D)b-tables (d)istribution
> i
> =memory
> total: 8482456
> processes: 1109318
> processes_used: 1109318
> system: 7373138
> atom: 194289
> atom_used: 171350
> binary: 935568
> code: 3736765
> ets: 252896
> =hash_table:atom_tab
> size: 4813
> used: 3599
> objs: 6751
> depth: 7
> =index_table:atom_tab
> size: 7168
> limit: 1048576
> entries: 6751
> ...

### 另一种方法, 使用erlang:system_info(info)获得上述输出的binary形式
输出文件
```erlang
file:write_file("info", erlang:system_info(info)).
```
只看前20项,不会太长了
```erlang
lists:sublist(string:tokens(binary_to_list(erlang:system_info(info)),"\n"), 20).
```

### 另一种方法, crash_dump文件里也会有上述输出
Ctrl+a并输入A,回车后可以产生crash_dump文件,还有core文件

### 更新: OTP 20.0 新增
erlang:system_info/1 atom_count and atom_limit

