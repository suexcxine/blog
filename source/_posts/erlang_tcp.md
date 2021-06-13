title: erlang inet&tcp
date: 2020-04-25

tags: [erlang, tcp]
---
## gen_tcp:shutdown
函数配合{exit_on_close, false}选项可以实现tcp半开的效果

## inet_db:lookup_socket
可以获取socket对应的模块
> {ok, S} = gen_tcp:listen(10000, []).
{ok,#Port<0.4423655>}
> inet_db:lookup_socket(S).
{ok,inet_tcp}
> {ok, S2} = gen_udp:open(10001).
{ok,#Port<0.4429431>}
> inet_db:lookup_socket(S2).
{ok,inet_udp}

## inet_db:register_socket
下面这种做法没有直接调用gen_tcp:accept而是伪装成使用了gen_tcp:accept

> gen_tcp:accept里面也就只是调了lookup_socket和register_socket
> % patch up the socket so it looks like one we got from
> % gen_tcp:accept/1
> {ok, Mod} = inet_db:lookup_socket(LSock),
> % 内部调用erlang:port_set_data记录信息
> inet_db:register_socket(Sock, Mod),

## inet:getaddr
检查是否支持ipv6
> inet:getaddr("localhost", inet).
{ok,{127,0,0,1}}
> inet:getaddr("localhost", inet6).
{error,nxdomain}

## inet_parse:address
> inet_parse:address("192.168.1.1").
{ok,{192,168,1,1}}

## inet:sockname
## inet:peername

## inet_parse:ntoa
> inet_parse:ntoa({192,168,1,113}).
"192.168.1.113"

## inet:getstat
查socket的状态

## inet:getif
```
{ok,[{{172,17,42,1},{0,0,0,0},{255,255,0,0}},
    {{172,16,205,1},{172,16,205,255},{255,255,255,0}},
    {{192,168,117,1},{192,168,117,255},{255,255,255,0}},
    {{192,168,1,114},{192,168,1,255},{255,255,255,0}},
    {{127,0,0,1},{0,0,0,0},{255,0,0,0}}]}
```

## 如何检查当前环境下的 sndbuf, recbuf, buffer 这些参数的默认值
OSX sysctl
```
sysctl -a | grep space
net.local.stream.sendspace: 8192
net.local.stream.recvspace: 8192
net.local.dgram.recvspace: 4096
net.inet.tcp.sendspace: 131072
net.inet.tcp.recvspace: 131072
net.inet.udp.recvspace: 786896
net.inet.raw.recvspace: 8192
net.stats.sendspace: 2048
net.stats.recvspace: 8192
```
OSX default
```
Erlang/OTP 22 [erts-10.7] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Eshell V10.7  (abort with ^G)
1> {ok, LSock} = gen_tcp:listen(12345, []).
{ok,#Port<0.5>}
2> spawn(fun() -> {ok, Sock} = gen_tcp:accept(LSock), io:format("~p", [inet:getopts(Sock, [recbuf, sndbuf, buffer])]), receive _ -> ok end end).
<0.86.0>
3> inet:getopts(LSock, [recbuf, sndbuf, buffer]).
{ok,[{recbuf,131072},{sndbuf,131072},{buffer,1460}]}
4> {ok, S} = gen_tcp:connect("127.0.0.1", 12345, []).
{ok,#Port<0.7>}
{ok,[{recbuf,408300},{sndbuf,146988},{buffer,1460}]}
5> inet:getopts(S, [recbuf, sndbuf, buffer]).
{ok,[{recbuf,408300},{sndbuf,146988},{buffer,1460}]}
```
OSX 4096
```
Erlang/OTP 22 [erts-10.7] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Eshell V10.7  (abort with ^G)
1> {ok, LSock} = gen_tcp:listen(12345, [{sndbuf, 4096}, {recbuf, 4096}]).
{ok,#Port<0.5>}
2> spawn(fun() -> {ok, Sock} = gen_tcp:accept(LSock), io:format("~p", [inet:getopts(Sock, [recbuf, sndbuf, buffer])]), receive _ -> ok end end).
<0.86.0>
3> inet:getopts(LSock, [recbuf, sndbuf, buffer]).
{ok,[{recbuf,4096},{sndbuf,4096},{buffer,4096}]}
4> {ok, S} = gen_tcp:connect("127.0.0.1", 12345, [{sndbuf, 4096}, {recbuf, 4096}]).
{ok,#Port<0.7>}
{ok,[{recbuf,326640},{sndbuf,65328},{buffer,4096}]}
5> inet:getopts(S, [recbuf, sndbuf, buffer]).
{ok,[{recbuf,326640},{sndbuf,65328},{buffer,4096}]}
```
Ubuntu
```
# cat /proc/sys/net/ipv4/tcp_rmem
4096    131072  6291456
# cat /proc/sys/net/ipv4/tcp_wmem
4096    16384   4194304
# cat /proc/sys/net/core/rmem_default
212992
# cat /proc/sys/net/core/wmem_default
212992
```
Ubuntu default
```
Erlang/OTP 22 [erts-10.7] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Eshell V10.7  (abort with ^G)
1> {ok, LSock} = gen_tcp:listen(12345, []).
{ok,#Port<0.6>}
2> spawn(fun() -> {ok, Sock} = gen_tcp:accept(LSock), io:format("~p", [inet:getopts(Sock, [recbuf, sndbuf, buffer])]), receive _ -> okend end).
<0.83.0>
3> inet:getopts(LSock, [recbuf, sndbuf, buffer]).
{ok,[{recbuf,131072},{sndbuf,16384},{buffer,1460}]}
4> {ok, S} = gen_tcp:connect("127.0.0.1", 12345, []).
{ok,#Port<0.8>}
{ok,[{recbuf,131072},{sndbuf,2626560},{buffer,1460}]}
5> inet:getopts(S, [recbuf, sndbuf, buffer]).
{ok,[{recbuf,131072},{sndbuf,2626560},{buffer,1460}]}
```
Ubuntu 4096
```
Erlang/OTP 22 [erts-10.7] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Eshell V10.7  (abort with ^G)
1> {ok, LSock} = gen_tcp:listen(12345, [{recbuf,4096},{sndbuf,4096}]).
{ok,#Port<0.6>}
2> spawn(fun() -> {ok, Sock} = gen_tcp:accept(LSock), io:format("~p", [inet:getopts(Sock, [recbuf, sndbuf, buffer])]), receive _ -> okend end).
<0.83.0>
3> inet:getopts(LSock, [recbuf, sndbuf, buffer]).
{ok,[{recbuf,8192},{sndbuf,8192},{buffer,4096}]}
4> {ok, S} = gen_tcp:connect("127.0.0.1", 12345, [{recbuf,4096},{sndbuf,4096}]).
{ok,#Port<0.8>}
{ok,[{recbuf,8192},{sndbuf,8192},{buffer,4096}]}
5> inet:getopts(S, [recbuf, sndbuf, buffer]).
{ok,[{recbuf,8192},{sndbuf,8192},{buffer,4096}]}
```

