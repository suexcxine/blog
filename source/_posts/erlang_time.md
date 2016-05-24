title: erlang time 
date: 2015-09-10
tags: [erlang]
---
erlang 18.0重新实现了time相关功能,性能更好,可伸缩性更好,精度更好
<!--more-->
## 取系统时间
使用erlang:system_time/1取当前系统时间,可能按自己想要的单位取
使用erlang:timestamp/0可以得到与erlang:now/0相同格式的返回值

## 计算时间差
使用erlang:monotonic_time/0取时间戳,并用普通减法取差值,结果是native的时间单位,
可以使用erlang:convert_time_unit/3转换成想要的时间单位
也可以使用erlang:monotonic_time/1取想要的时间单位并取差值,但是这样会损失精度

## 确定事件发生的顺序
各事件发生时保存erlang:unique_integer([monotonic])的返回值,
以此确定事件发生的顺序
更精确的话可以这样
```erlang
Time = erlang:monotonic_time(),
UMI = erlang:unique_integer([monotonic]),
EventTag = {Time, UMI}
```
如果需要知道事件发生的时间点,可以在元组最后再附加erlang:time_offset/0,
Erlang monotonic time加上time offset就是Erlang系统时间

## 生成一个当前运行时内的唯一值
使用erlang:unique_integer/0,
使用erlang:unique_integer([positive])得到正数.

## 生成一个随机值给随机数做seed
使用erlang:monotonic_time(), erlang:time_offset(), erlang:unique_integer()的组合做seed

## time correction和time warp mode的命令行参数
```
erl +c [true|false]
erl +C [no_time_warp|single_time_warp|multi_time_warp]
```

## 监控系统时间跳变
erlang:monitor(time_offset, clock_service).
当time offset变化时, 监控的进程会收到如下消息:
{'CHANGE', MonitorReference, time_offset, clock_service, NewTimeOffset}

