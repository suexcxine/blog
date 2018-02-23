title: fcm
date: 2018-02-23
tags: [push, firebase, android, ios]
---
FCM(firebase cloud messaging)用于推送服务(主要目标是移动设备),
在app进程被杀死后仍然可以通过android自带的google服务做到推送
<!--more-->
首先, 用firebase需要梯子. 用httpc的话, 如下设置http代理(不支持socks5代理, 需要自己把socks5代理转接成http代理):
```
httpc:set_options([{proxy, {{"localhost", 8123}, ["localhost"]}}]).
```

fcm client library for erlang
```
https://github.com/softwarejoint/fcm-erlang
```

好, 开始使用, 如下提供api key做为初始化参数, 启动一个gen server(干活的进程)
```
fcm:start(test2, "AAAAC53t-ac:APA91bHYDiZFPOYA5jwNedEv7TOCfQQncPtgXCpxpB1WwZ6oSsJu_3SGJ7poaqQpd8o1SQ5YUXpp1E5OWOQmjwKLEKLExcQtyS22bD_SI76OcmSQFYRSnl-NKJxW_QQsW2qbvmxmt7qU").
```

给目标注册令牌(registration token, 注意这个东西可能会变)推送一条通知栏消息
```
fcm:push(test2, <<"eLeCIjv0u1Y:APA91bGwRLEOycNjLq5OPpwdIsxdn5aQcMbMu7DuRXU9RirWnofW82YlJFGB4DxhXr30sepd0t99bd6CfGbr5P5x6tdlzUlhNQz6Lq3yYyEZFMtLa7ZmKfavr22d3L9YrkOX75BVuqpv">>, [{<<"data">>, [{<<"message">>, <<"a message">>}]}, {<<"notification">>, [{<<"title">>, <<"Title chenduo">>}, {<<"body">>, <<"Content chenduo">>}]}]).
```

给主题(topic)推送一条通知栏消息
```
fcm:push(test2, <<"/topics/testTopic">>, [{<<"data">>, [{<<"message">>, <<"a message">>}]}, {<<"notification">>, [{<<"title">>, <<"Title chenduo">>}, {<<"body">>, <<"Content chenduo">>}]}]).
```

