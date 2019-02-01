title: 系统设计点滴
date: 2019-02-01 20:04:00
tags: design
---
日常引起思考的点点滴滴
<!--more-->

#### RBAC和ABAC
RBAC其实就是ABAC, 的简化版
权限控制其实是一个 `predicate(params) -> bool`
RBAC差不多是 `predicate(role, operation_type) -> bool`
ABAC差不多是 `predicate(my_attrs[role, department, location, ...], target_attrs[operation_type, location, ...], environment[nowtime, ...]) -> bool`

参考链接
http://blog.identityautomation.com/rbac-vs-abac-access-control-models-iam-explained

