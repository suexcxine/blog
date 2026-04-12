title: rails_kubernetes
date: 2024-06-11

tags: [rais, kubernetes, performance]
---

在K8s环境下部署Ruby on Rails应用时，有时候会遇到请求积压（一个直接返回 ok 的接口 60 秒超时）但CPU和内存资源利用率却很低（30%）的情况。本文将探讨这种现象背后的原因，并提供一些可能的解决方案。

<!--more-->

### 在K8s环境下部署Rails应用：处理请求积压与资源利用率低的问题

#### 现象描述

在K8s环境中，QPS高的情况下，Rails应用的请求队列会堆积，导致响应时间大幅变长甚至请求超时（60秒都很正常）。然而，当检查K8s节点的资源使用情况时，CPU和内存的占用率却相对较低（比如只有30%），于是运维以为系统性能没问题。。然后就觉得响应时间60秒是出在其他地方（比如网络），搞错了方向耽误了大量时间，坑死我了。

#### 原因分析

1. **线程和工作进程配置不足**
   Rails应用通常通过Puma或Unicorn等应用服务器来处理并发请求。这些服务器依赖于线程和工作进程来并发处理请求。如果线程数和工作进程数配置不足，应用无法充分利用K8s节点的CPU和内存资源。

2. **请求处理瓶颈**
   Rails应用中的某些操作可能非常耗时，比如数据库查询、文件IO操作或调用外部API。如果这些操作没有得到优化，尽管K8s节点的资源充足，应用服务器仍然会因为这些操作而阻塞，从而导致请求堆积。

#### 解决方案

1. **调整线程和工作进程配置**
   根据K8s节点的资源情况，合理配置Puma的线程和工作进程数。例如，可以通过以下方式配置Puma：
   ```ruby
   threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
   threads threads_count, threads_count

   workers ENV.fetch("WEB_CONCURRENCY") { 2 }
   ```

#### 结论

在K8s环境下部署Rails应用时，合理配置线程和工作进程、优化请求处理逻辑、合理配置资源请求和限制以及使用水平自动扩展，可以有效解决请求积压但资源利用率低的问题。通过这些措施，可以充分利用K8s的强大功能，提升Rails应用的性能和稳定性。

现在像 golang, erlang 这些技术的并发模型和调度机制保证可以充分利用多核CPU，就不会出现类似的问题。。



## 参考链接
https://github.com/puma/puma/blob/9282a8efa5a0c48e39c60d22ca70051a25df9f55/docs/kubernetes.md#workers-per-pod-and-other-config-issues