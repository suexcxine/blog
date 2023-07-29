title: 如何确保关于一个实体的请求得到串行处理，避免并发问题
date: 2023-07-29

tags: [distribution, concurrency]
---

在处理并发请求的过程中，保证同一实体的HTTP请求的处理得到顺序(串行)处理是非常重要的。
这种处理方式能够有效地避免因并发导致的数据一致性问题。

假设你正在开发一个电子商务系统，每个用户都有一个购物车实体，用户可以同时向购物车中添加多个商品，但是购物车有一个上限。如果系统不能保证对同一购物车的所有操作都顺序执行，就可能导致购物车的状态出现不一致。例如，一个操作可能正在读取购物车中的商品数量，如果还未超限就往里添加，而此时另一个同样的操作也在进行。如果这两个操作并发执行，就可能导致两边都认为购物车还有空间，从而让购物车中的商品数量超过限制。

因此，为了避免这种并发问题，你可以设计你的系统，使得所有对同一购物车的操作都顺序执行(比如在同一个 goroutine 中处理)。这样，即使有多个并发的 http 请求，也可以保证对购物车状态的操作总是一致的。

具体方案如下：

<!--more-->

### 方案1 粘性会话
粘性会话这个选择的意义在于起码同一个实体的请求到了同一个结点，然后在结点内部可以通过内存中的一些锁或者channel来做并发控制了，就不需要搞分布式锁了。

注意：
* 为了避免出现负载不均匀的情况， 实体的粒度需要尽可能小。
* 另外就是要用一致性哈希，这样增减结点时的影响要小些。

缺陷：
* 逻辑的一部分要放到网关层面上，感觉web server这边的逻辑不够完整。
* 增减结点可能是一个问题。具体来说，原来映射到各个旧结点的请求会有一部分被映射到新结点，切换的那一会儿可能会出并发问题。因为无法要求网关等到旧结点上的请求都处理完毕再把那些实体的请求路由到新结点。
* 滚动重启发版可能是另一个问题。具体来说，k8s 通知 pod 结束的时候，pod 停止 http 监听，并开始执行 graceful shutdown ，在此期间 pod 里的逻辑还在跑，然后 LB 在收到新请求时看到这个 pod 已经连不上了，就会把流量发到另一个结点。于是还是可能产生并发问题。

### 方案2 请求队列
为每个实体创建一个请求队列，所有关于同一实体的请求都被放入同一队列中，然后在goroutine中依次处理。

缺陷：
* 拿不到返回值。无论是发到 kafka 利用 partition 的特性来避免并发问题还是通过 redis 的 list 来做消息队列然后搞一个goroutine来消费都是一样的。就是 http 请求对应的那个 goroutine 无法拿到处理的返回值用于返回给前端。在不需要返回值的情况下可以。比如 kafka 的消费者处理完毕后通过 ws 或者什么通知到前端，纯异步的。

### 方案3 实体锁
每个实体有一个对应的锁（由于通常实体，比如访客，可能上万甚至更多，所以这个粒度就很细了，不用担心不均匀的问题和串行执行的性能问题），当 goroutine 处理请求时，需要首先获取该实体的锁。这样可以确保同一时间内，只有一个 goroutine 能处理该实体相关的请求。

注意：
* 当客户端在设置锁后突然宕机，可能会导致锁无法被正常释放，需要通过设置过期时间解决长时间死锁的问题。正常发版导致重启的情况需要通过 graceful shutdown 保证任务可以正常执行完于是锁可以正常被释放。
* 当锁的持有者还未完成任务，锁就已经过期并被其他客户端获取，这就可能导致多个客户端并发操作，破坏锁的互斥性。需要保证处理可以在过期时间内完成，未能完成的情况要有日志等发现的手段。具体检测可以这样：获取锁时，写进一个随机字符串。当任务完成时，使用 GETDEL key 时检测是否成功删除了。只有当 GET 出来的值与自己一开始写进去的值相同才是正常。如果 GETDEL key 时发现 key 已经没了（锁过期或过期后有别的客户端获取了锁然后执行完任务又把锁删了），或者 GET 出来的值与一开始写进去的值不同，那么就是锁过期后有其他客户端写了锁进去。建议打日志以方便排查问题。

一个可能的实现如下, elixir:
```
  # 加锁以实现并发控制
  # 有一种情况会导致死循环, 即参数中的 key 事先已经存在并且没有设 expire
  # 等多久也白等
  # 为了避免这种情况, 增加了最大尝试次数的配置
  def with_lock(key, f, key_timeout \\ 10, sleep_time \\ 500, max_n \\ 10, n \\ 0)

  def with_lock(_key, _f, _key_timeout, _sleep_time, max_n, n) when n >= max_n do
    {:error, :too_many_times}
  end

  def with_lock(key, f, key_timeout, sleep_time, max_n, n) do
    case do_with_lock(key, f, key_timeout) do
      :locked ->
        # 别的请求已经在刷新 token 了，等待 500 毫秒后再取
        Logger.info("with_lock encountered locked, key: #{key}")
        :timer.sleep(sleep_time)
        with_lock(key, f, key_timeout, sleep_time, max_n, n + 1)

      {:ok, r} ->
        {:ok, r}

      {:error, err} ->
        {:error, err}
    end
  end

  def do_with_lock(key, f, key_timeout) do
    val = (:rand.uniform(4294967296) - 1) |> to_string
    try do
      # 此处的 expire 仅为了防止意外导致 key 永远被锁住
      case RedisClusterPool.command!(:cluster, ["SET", key, val, "NX", "EX", key_timeout]) do
        "OK" ->
          # 成功取到锁
          r = f.()
          # 释放锁
          release_lock(key, val)
          {:ok, r}

        nil ->
          :locked
      end
    catch
      _, err ->
        Logger.error("error happened in do_with_lock, err: #{inspect(err)}")
        release_lock(key, val)
        {:error, err}
    end
  end

  def release_lock(key, val) do
    deleted_v = RedisClusterPool.command!(:cluster, ["GETDEL", key])
    # NOTE(chenduo) != key 意味着任务执行时长超过了锁的 expire 时长，也就是说
    # 在任务还没来得及执行完的时候，其他 client 取到了锁
    # 然后在这一步又被释放掉了, 这种情况需要打日志
    cond do
      deleted_v == nil ->
        Logger.error("task longer than lock expire, key: #{inspect(key)}, val: #{val}")
      deleted_v != val ->
        Logger.error("task longer than lock expire, key: #{inspect(key)}, val: #{val}, and another lock was released before it should be: #{deleted_v}")
      true ->
        :ok
    end
  end
```


### 方案4 利用数据库的事务或乐观锁等
事务可以保证 ACID，其中的 I 就是隔离性。各请求之间不会相互影响到。

乐观锁举例来说，在 select 时读到表的 version 字段(假设变量名为 ver), 然后 update table set xx = yy, version = ver + 1 where version = ver 这样如果在 select 和 update 之间有其他的请求改变了数据库，这里的 update 修改的行数就会是 0，于是就知道冲突了，反正啥也没改到，过一会儿 retry （无论客户端重试还是服务端重试）就可以了。

其他的还有 insert on duplicate update 这种 upsert 语义。可以解决一些 insert 遇到 duplicate primary key 或 unique key 的情况。

缺陷：
* 不能解决全部问题。这些都只能解决一个数据库内部的情况，对于跨库以及跨服务的情况无能为力。

### 方案5 Erlang/Akka 的全局注册
每个实体对应一个 actor, 在 actor 内的逻辑都是串行执行的。有一个全局注册记录这些 actor 在哪个结点。于是 http 请求来的时候，查询全局注册找到 actor 之后就用同步的方式请求 actor ，得到响应之后再返回给前端。

注意：
* 会产生结点间流量。整个方案较复杂大部分人不理解。


### 总结

部分简单的情况可以通过方案 4 解决，其他较复杂情况用方案 3。

