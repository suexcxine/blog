title: erlang inet&tcp
date: 2015-09-06
tags: erlang
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
gen_tcp:accept里面也就是调了lookup_socket和register_socket
% patch up the socket so it looks like one we got from                       
% gen_tcp:accept/1                                                           
{ok, Mod} = inet_db:lookup_socket(LSock),                                    
% 内部调用erlang:port_set_data记录信息
inet_db:register_socket(Sock, Mod),

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

