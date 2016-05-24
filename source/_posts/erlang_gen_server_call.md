title: erlang gen_server:call消息未得到执行的情况
date: 2016-02-16
tags: [erlang]
---

gen_server:call的应用场景往往是需要有一个已处理的保障
哪些情况下请求未得到执行?该怎么处理这些情况?
<!--more-->

## gen_server:call
gen_server:call会monitor目标进程, monitor可能会发'DOWN'消息给当前进程
目标进程不存在时Info是noproc,
远程结点无连接时Info是noconnection,
等待过程中进程die(如call时目标进程正在terminate或目标进程处理其他消息时内部错误崩溃)时Info是exit reason
处理消息过程中进程die(目标进程内部错误崩溃)时Info也是exit reason

gen_server:call异常情况下返回的都是exit类型,
使用try catch来捕捉的话, 可以使用如下的pattern,
```erlang
try
    gen_server:call(Process, Req)
of
    {ok, Result} ->
        % do something
    Other ->
        % do something
catch
    exit:{timeout,{gen_server, call, Args}} ->
        % 超时的情况, 不确定消息有没有得到执行, call/3且Timeout为infinity时无此情况
        % do something    
    exit:{Reason,{gen_server, call, Args}} 
        when Reason =:= noproc; element(1, Reason) =:= nodedown; Reason =:= normal ->
        % 消息因进程不存在或无连接或正常退出未得到处理的情况, 一般算正常情况
        % do something
    exit:{Reason,{gen_server, call, Args}} ->
        % 其他情况, 写日志并按异常处理, 应该是出bug了
end
```
注意: 目标进程内部崩溃erlang:error的Reason里有调用栈信息, erlang:exit的Reason里没有调用栈信息

## 参考erlang源码
gen_server.erl
```erlang
call(Name, Request, Timeout) ->                                                  
    case catch gen:call(Name, '$gen_call', Request, Timeout) of                  
    {ok,Res} ->                                                                  
        Res;                                                                     
    {'EXIT',Reason} ->                                                           
        exit({Reason, {?MODULE, call, [Name, Request, Timeout]}})                
    end. 
```

gen.erl
```erlang
do_call(Process, Label, Request, Timeout) ->                                     
    try erlang:monitor(process, Process) of                                      
    Mref ->                                                                      
        %% If the monitor/2 call failed to set up a connection to a              
        %% remote node, we don't want the '!' operator to attempt                
        %% to set up the connection again. (If the monitor/2 call                
        %% failed due to an expired timeout, '!' too would probably              
        %% have to wait for the timeout to expire.) Therefore,                   
        %% use erlang:send/3 with the 'noconnect' option so that it              
        %% will fail immediately if there is no connection to the                
        %% remote node.                                                          
                                                                                 
        catch erlang:send(Process, {Label, {self(), Mref}, Request},             
          [noconnect]),                                                          
        receive                                                                  
        {Mref, Reply} ->                                                         
            erlang:demonitor(Mref, [flush]),                                     
            {ok, Reply};                                                         
        {'DOWN', Mref, _, _, noconnection} ->                                    
            Node = get_node(Process),                                            
            exit({nodedown, Node});                                              
        {'DOWN', Mref, _, _, Reason} ->                                          
            exit(Reason)                                                         
        after Timeout ->                                                         
            erlang:demonitor(Mref, [flush]),                                     
            exit(timeout)                                                        
        end                                                                      
    catch                                                                        
    error:_ ->                                                                   
        %% Node (C/Java?) is not supporting the monitor.                         
        %% The other possible case -- this node is not distributed               
        %% -- should have been handled earlier.                                  
        %% Do the best possible with monitor_node/2.                             
        %% This code may hang indefinitely if the Process                        
        %% does not exist. It is only used for featureweak remote nodes.         
        Node = get_node(Process),                                                
        monitor_node(Node, true),                                                
        receive                                                                  
        {nodedown, Node} ->                                                      
            monitor_node(Node, false),                                           
            exit({nodedown, Node})                                               
        after 0 ->                                                               
            Tag = make_ref(),                                                    
            Process ! {Label, {self(), Tag}, Request},                           
            wait_resp(Node, Tag, Timeout)                                        
        end                                                                      
    end. 
```

gen_server.erl
```erlang
try_handle_call(Mod, Msg, From, State) ->                                        
    try                                                                          
    {ok, Mod:handle_call(Msg, From, State)}                                      
    catch                                                                        
    throw:R ->                                                                   
        {ok, R};                                                                 
    error:R ->                                                                   
        Stacktrace = erlang:get_stacktrace(),                                    
        {'EXIT', {R, Stacktrace}, {R, Stacktrace}};                              
    exit:R ->                                                                    
        Stacktrace = erlang:get_stacktrace(),                                    
        {'EXIT', R, {R, Stacktrace}}                                             
    end. 
```

## 参考链接
https://github.com/erlang/otp/blob/maint/lib%2Fstdlib%2Fsrc%2Fgen_server.erl
https://github.com/erlang/otp/blob/maint/lib%2Fstdlib%2Fsrc%2Fgen.erl
http://erlang.org/doc/man/erlang.html#monitor-2
