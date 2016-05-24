title: gen_server:cast与erlang:send的区别
date: 2015-11-05
tags: [erlang]
---
在Request前加了一个'$gen_cast'做为Tag,用于handle_cast,handle_info以及print_event时做区分
在调用erlang:send前使用noconnect,
如果需要connect,即会被阻塞一小会(连接目标结点),则spawn另一个进程来erlang:send以避免阻塞
ps: 只是noconnect并不是nosuspend,nosuspend会在port busy时放弃
源码如下:
```erlang
cast({global,Name}, Request) ->                                                  
    catch global:send(Name, cast_msg(Request)),                                  
    ok;                                                                          
cast({via, Mod, Name}, Request) ->                                               
    catch Mod:send(Name, cast_msg(Request)),                                     
    ok;                                                                          
cast({Name,Node}=Dest, Request) when is_atom(Name), is_atom(Node) ->             
    do_cast(Dest, Request);                                                      
cast(Dest, Request) when is_atom(Dest) ->                                        
    do_cast(Dest, Request);                                                      
cast(Dest, Request) when is_pid(Dest) ->                                         
    do_cast(Dest, Request).                                                      
                                                                                 
do_cast(Dest, Request) ->                                                        
    do_send(Dest, cast_msg(Request)),                                            
    ok.                                                                          
                                                                                 
cast_msg(Request) -> {'$gen_cast',Request}.  

do_send(Dest, Msg) ->                                                            
    case catch erlang:send(Dest, Msg, [noconnect]) of                            
    noconnect ->                                                                 
        spawn(erlang, send, [Dest,Msg]);                                         
    Other ->                                                                     
        Other                                                                    
    end. 
```
