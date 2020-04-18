title: erlang vm args
date: 2020-04-18
tags: erlang
---
erlang VM(OTP 22.3) 参数调优

<!--more-->
## 内存
erlang:memory(total) 报告的内存用量是 active used 用量,
这个值与操作系统报告(如 htop)的 RES 不同, 有时差异很大
原因是 erlang VM 从操作系统通过 mmap(mseg_alloc) 或 malloc(sys_alloc) 分配的内存由 VM 自行管理

### mseg_alloc
mseg_alloc 分配的 carrier(称为 mbc: multi block carrier, 即一大块内存, 如 8 MB, 用于满足大量小块的内存需求),
当需要使用内存时, 再从 carrier 内部找到一块能够满足需要的内存(称为 block)

### sys_alloc
sys_alloc 分配的 carrier(称为 sbc: single block carrier, 这种 carrier 内只会有一个 block, 用于满足单个大块内存需求)

## 记一次内存参数调优
erlang:memory(total) 是 6G
linux report 的 RES 竟然是 12G
分析发现利用率低的原因在于 binary_alloc , erlang:memory(binary) 是 3G,

### 问题
```
> {:ok, {_, l}} = :instrument.carriers(%{allocator_types: [:binary_alloc]}); l |> Enum.map(fn i -> elem(i, 1)end) |> Enum.sum
9147547648
> l |> Enum.map(fn i -> elem(i, 3) end) |> Enum.sum
3227022288
> length(l)
1086
> l |> Enum.filter(fn i -> elem(i, 1) == 8388608 end) |> Enum.count
993
```
这里可以看出, 仅 binary_alloc 就从 OS 那里拿了 9G 多, 只使用了 3G 多, 利用率仅 30% 多
绝大多数 carrier 都是 8M 大小

### recon_alloc:fragmentation
```
> for {{:binary_alloc, _}, _} = i <- :recon_alloc.fragmentation(:current), do: i
[
   {{:binary_alloc, 1},
   [
     sbcs_usage: 1.0,
     mbcs_usage: 0.11764846584230272,
     sbcs_block_size: 0,
     sbcs_carriers_size: 0,
     mbcs_block_size: 256630480,
     mbcs_carriers_size: 2181332992
   ]},
   ...
```
这里的数据和上面的数据相似, 只是按各个 scheduler 分开了, 各个 scheduler 因忙碌程度不同数据有所不同
这里是无法直视的 0.117 的 usage
另外各 scheduler 都没有 sbc , 100% mbc

### 惨不忍睹的 cache_hit_rates
```
> :recon_alloc.cache_hit_rates
[
  {{:instance, 2},
   [hit_rate: 0.07593661451298644, hits: 198688, calls: 2616498]},
  {{:instance, 1},
   [hit_rate: 0.07875297434572018, hits: 206590, calls: 2623266]},
  {{:instance, 3},
   [hit_rate: 0.07236038356379897, hits: 178458, calls: 2466239]},
  {{:instance, 4},
   [hit_rate: 0.07046272138745954, hits: 146002, calls: 2072046]},
  {{:instance, 5},
   [hit_rate: 0.06508099839392721, hits: 103979, calls: 1597686]},
  {{:instance, 6}, [hit_rate: 0.06482833535152076, hits: 65529, calls: 1010808]},
  {{:instance, 7}, [hit_rate: 0.04520865314353365, hits: 23943, calls: 529611]},
  {{:instance, 0}, [hit_rate: 0.5870402814606035, hits: 657744, calls: 1120441]},
  {{:instance, 8}, [hit_rate: 0.035719675041223455, hits: 13019, calls: 364477]}
]
```
根据该函数的doc来看, 该值应该在 0.80(80%)以上才正常

### instrument:allocations
```
> :instrument.allocations
{:ok,
 {128, 233015472,
  %{
    jiffy: %{
      binary: {0, 71325, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      drv_binary: {56252, 2907, 5212, 6400, 633, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      nif_internal: {128608, 2749, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       0}
    },
    prim_file: %{
      drv_binary: {0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    },
    spawn: %{drv_binary: {0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
    system: %{
      binary: {0, 251, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      driver: {0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      driver_control_data: {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       0},
      driver_mutex: {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      driver_rwlock: {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      driver_tsd: {2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      drv_binary: {713173, 141795, 4301, 4045, 2001, 104, 1, 0, 0, 0, 0, 0, 0,0, 0, 0, 0, 0},
      drv_internal: {0, 0, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      microstate_accounting: {1, 29, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       0, 0},
      nif_internal: {12, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      port: {0, 0, 68, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      port_data_lock: {2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    },
    tcp_inet: %{
      driver_tid: {8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      driver_tsd: {8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      drv_binary: {2, 260, 3928, 37343, 4713, 575, 2, 0, 0, 0, 3257, 5871, 0, 0, 0, 0, 0, 0},
      drv_internal: {109, 10, 54143, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       0},
      port: {0, 0, 53852, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    }
  }}}
```
如下写了一个小函数来计算 histogram 里的总内存量
```
> f = fn(start, histogram) ->
  :erlang.tuple_to_list(histogram)
  |> Enum.reduce({start, 0}, fn(i, {size_level, acc}) -> {size_level * 2, i * size_level + acc}  end)
end
> f.(128, {2, 260, 3928, 37343, 4713, 575, 2, 0, 0, 0, 3257, 5871, 0, 0, 0, 0, 0, 0})
{33554432, 2018289920}
```
显示绝大部分都是 tcp_inet 占用的, < 2018289920 (约2G)
这里看起来是正常的

### 当时使用的内存参数
```
> :erlang.system_info(:allocator)
   ...
   binary_alloc: [
     e: true,
     t: true,
     atags: true,
     ramv: false,
     sbct: 524288,
     asbcst: 4145152,
     rsbcst: 20,
     rsbcmt: 80,
     rmbcmt: 50,
     mmbcs: 32768,
     mmmbc: 18446744073709551615,
     mmsbc: 256,
     lmbcs: 5242880,
     smbcs: 262144,
     mbcgs: 10,
     acul: 0,
     acnl: 0,
     acfml: 0,
     as: :aoffcbf
   ],
   ...
```

### 尝试 disable binary_alloc
```
+MBe false
```
disable 之后连 erlang:memory 都返回 :notsup 的错误, 看不了了.... :(
压力测试下来比原参数 RES 占用可能少 20% 多的样子
但是看不了 erlang:memory 等数据无法接受

### 关于 background gc
这个 background gc 每 10 分钟自动对几乎所有 process 做一次 fullsweep gc
```
for p <- :erlang.processes(),
  {:status, :waiting} == :erlang.process_info(p, :status),
  do: :erlang.garbage_collect(p)
```
发现改成 1 天一次以后, memory fragmentation 有逐渐改善(3 天后降下来 2G 左右)
fullsweep gc 与 memory fragmentation 之间的关系还需要研究

### reference
erts_alloc, instrument docs by erlang
http://erlang.org/doc/man/erts_alloc.html
http://erlang.org/doc/apps/erts/CarrierMigration.html
http://blog.erlang.org/Memory-instrumentation-in-OTP-21/
https://erlang.org/doc/man/instrument.html

memory management: battle stories by Lukas Larsson
https://www.youtube.com/watch?v=nuCYL0X-8f4
https://www.erlang-factory.com/static/upload/media/139454517145429lukaslarsson.pdf
https://www.cnblogs.com/zhengsyao/p/erts_allocators_speech_by_lukas_larsson.html

memory fragmentation case, and recon_alloc tool, erlang-in-anger book written by Fred Hebert
https://blog.heroku.com/archives/2013/11/7/logplex-down-the-rabbit-hole
https://github.com/ferd/recon/blob/master/src/recon_alloc.erl
https://www.erlang-in-anger.com

RabbitMQ default flags
https://www.rabbitmq.com/runtime.html#allocators
https://groups.google.com/forum/#!msg/rabbitmq-users/LSYaac9frYw/LNZDZUlrBAAJ

## CPU
### reference
+sbwt
https://stressgrid.com/blog/beam_cpu_usage/

+stbt Rabbit MQ default
https://www.rabbitmq.com/runtime.html#scheduler-bind-type

someone says using `+stbt ts` reduced context switching for 4 times
https://github.com/rabbitmq/rabbitmq-server/issues/612

Whatsapp use tnnps
https://www.youtube.com/watch?v=tW49z8HqsNw&feature=youtu.be&t=11m2s

## Inter-node Communication Buffer Size
+zdbbl

Rabbit MQ explain
https://www.rabbitmq.com/runtime.html#distribution-buffer

## 最终选用的参数

经过本地压力测试(10k websocket connections + 10k nsq message consumption per second, send those nsq binary to websocket)
可能因为时间不够长(30 minutes, 然而根据 ferd 的博客, memory fragmentation 要数周才体现出来), 压力不够大,
测试结果: 以下参数对比默认参数, RES 减少 10 % 多

```
+P 1048576
+Q 1048576

+sbwt none
+sbwtdcpu none
+sbwtdio none

+swt very_low

+stbt db

+zdbbl 81920

+MBas ageffcbf
+MHas ageffcbf

+MBlmbcs 512
+MBsmbcs 512
+MHlmbcs 512
+MHsmbcs 512

+MMmcs 30
```

erl flags doc
http://erlang.org/doc/man/erl.html

## TODO

* +M<S>ramv <bool>
* +M<S>acul <utilization>|de
* carrier pool
* carrier header size
