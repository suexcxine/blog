title: erlang eep 53 Alias
date: 2021-12-10

tags: [erlang]
---

OTP 24 的 highlights 之一

<!--more-->

以前遇到过这样的问题

一个进程(client) call 另一个进程(server)时，5秒超时了

但是 server 侧并不知道你已经不要这个消息了， 于是还是把 result 给 client 发了回去

结果导致 client 侧出错，于是 client 侧要做得比较细致， 要忽略掉那些晚到的消息

另外比如你用了一个库， 那个库里会去 call 一个进程，超时后你自己的进程的 mailbox 里收到了一些奇怪的消息

所以大家一般都写个保底的 handle_info 丢弃掉所有不认识的消息



新出的 alias 功能可以取得一个 reference 临时当 pid 用

unalias(比如超时了)之后收到发给这个alias的消息会在进入mailbox之前就被丢弃掉

官方 example:

```erlang
server() ->
    receive
        {request, AliasReqId, Request} ->
            Result = perform_request(Request),
            AliasReqId ! {reply, AliasReqId, Result}
    end,
    server().

client(ServerPid, Request) ->
    AliasReqId = alias([reply]),
    ServerPid ! {request, AliasReqId, Request},
    %% Alias will be automatically deactivated if we receive a reply
    %% since we used the 'reply' option...
    receive
        {reply, AliasReqId, Result} -> Result
    after 5000 ->
            unalias(AliasReqId),
            %% Flush message queue in case the reply arrived
            %% just before the alias was deactivated...
            receive {reply, AliasReqId, Result} -> Result
            after 0 -> exit(timeout)
            end
    end.
```

官方博客称 gen_server, gen_statem 等都已经是用类似这种方式了

https://www.erlang.org/blog/my-otp-24-highlights/#eep-53-process-aliases



