title: 系统设计点滴
date: 2019-02-01 20:04:00
tags: design
---
日常引起思考的点点滴滴
<!--more-->

#### RBAC和ABAC
RBAC其实就是ABAC, 的简化版,
权限控制其实是一个 `predicate(params) -> bool`
RBAC差不多是 `predicate(role, operation_type) -> bool`
ABAC差不多是 `predicate(my_attrs[role, department, location, ...], operation_type, target_attrs[location, ...], environment[nowtime, ...]) -> bool`

另外, 为了方便, 有 grant 方式和 deny 方式, 类似白名单和黑名单
例如:
* A user can view a document if the document is in the same department as the user
* A user can edit a document if they are the owner and if the document is in draft mode
* Deny access before 9am

广泛一些来说, 就是 predicate 返回 bool, 不仅用户操作权限控制要用到,
其他地方, 如 api 访问权限, 流控, 规则引擎(比如优惠券是否适用)等处都会用到
游戏后端的协议层也是如此, 有很多check要在执行操作前判断完

参考链接
http://blog.identityautomation.com/rbac-vs-abac-access-control-models-iam-explained
https://en.wikipedia.org/wiki/Attribute-based_access_control

