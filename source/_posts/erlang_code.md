title: erlang各编译期的代码
date: 2015-09-11
tags: [erlang]
---
对于如下源码test.erl
```erlang
-module(test).      
-export([fac/1]).                                                                
fac(1) -> 1;                                                                     
fac(N) -> N * fac(N - 1).
```
在各编译期有不同的形式
<!--more-->
可以在erlang shell里使用c命令编译
> Erlang/OTP 18 [erts-7.0] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]
> 
> Eshell V7.0  (abort with ^G)
> 1> `c(test, 'P')`.    
> ** Warning: No object file created - nothing loaded **

也可以用erlc
> $ erlc -help
> Usage: erlc [Options] file.ext ...
> Options:
> ...
> -E             generate listing of expanded code (Erlang compiler)
> -S             generate assembly listing (Erlang compiler)
> -P             generate listing of preprocessed code (Erlang compiler)
> +term          pass the Erlang term unchanged to the compiler

## P
生成经过预处理和parse transform的代码, 扩展名.P
$ erlc -P test.erl
```erlang
-file("test.erl", 1).                                                            
                                                                                 
-module(test).                                                                   
                                                                                 
-export([fac/1]).                                                                
                                                                                 
fac(1) ->                                                                        
    1;                                                                           
fac(N) ->                                                                        
    N * fac(N - 1). 
```

## E
生成经过所有源代码处理的代码, 扩展名.E
$ erlc -E test.erl
```erlang
-file("test.erl", 1).                                                            
                                                                                 
fac(1) ->                                                                        
    1;                                                                           
fac(N) ->                                                                        
    N * fac(N - 1).                                                              
                                                                                 
module_info() ->                                                                 
    erlang:get_module_info(test).                                                
                                                                                 
module_info(X) ->                                                                
    erlang:get_module_info(test, X).
```

## S
生成中间汇编码, 扩展名.S
$ erlc -S test.erl
```
{module, test}.  %% version = 0                                                  
                                                                                 
{exports, [{fac,1},{module_info,0},{module_info,1}]}.                            
                                                                                 
{attributes, []}.                                                                
                                                                                 
{labels, 8}.                                                                     
                                                                                 
                                                                                 
{function, fac, 1, 2}.                                                           
  {label,1}.                                                                     
    {line,[{location,"test.erl",3}]}.                                            
    {func_info,{atom,test},{atom,fac},1}.                                        
  {label,2}.                                                                     
    {test,is_eq_exact,{f,3},[{x,0},{integer,1}]}.                                
    return.                                                                      
  {label,3}.                                                                     
    {allocate_zero,1,1}.                                                         
    {line,[{location,"test.erl",4}]}.                                            
    {gc_bif,'-',{f,0},1,[{x,0},{integer,1}],{x,1}}.                              
    {move,{x,0},{y,0}}.                                                          
    {move,{x,1},{x,0}}.                                                          
    {line,[{location,"test.erl",4}]}.                                            
    {call,1,{f,2}}.                                                              
    {line,[{location,"test.erl",4}]}.                                            
    {gc_bif,'*',{f,0},1,[{y,0},{x,0}],{x,0}}.                                    
    {deallocate,1}.                                                              
    return.                                                                      
                                                                                 
                                                                                 
{function, module_info, 0, 5}.                                                   
  {label,4}.                                                                     
    {line,[]}.                                                                   
    {func_info,{atom,test},{atom,module_info},0}.                                
  {label,5}.                                                                     
    {move,{atom,test},{x,0}}.                                                    
    {line,[]}.                                                                   
    {call_ext_only,1,{extfunc,erlang,get_module_info,1}}.                        
                                                                                 
                                                                                 
{function, module_info, 1, 7}.                                                   
  {label,6}.                                                                     
    {line,[]}.                                                                   
    {func_info,{atom,test},{atom,module_info},1}.                                
  {label,7}.                                                                     
    {move,{x,0},{x,1}}.                                                          
    {move,{atom,test},{x,0}}.                                                    
    {line,[]}.                                                                   
    {call_ext_only,2,{extfunc,erlang,get_module_info,2}}.
```

## erts_debug:df/1
从beam生成VM opcode, 扩展名dis
> $ erl
> Erlang/OTP 18 [erts-7.0] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]
> 
> Eshell V7.0  (abort with ^G)
> 1> erts_debug:df(test).
> ok

```
00007F0BDC63C3D0: i_func_info_IaaI 0 test start_link 0                           
00007F0BDC63C3F8: move_nx [] x(2)                                                
00007F0BDC63C408: move_x1_c test                                                 
00007F0BDC63C418: move_nx [] x(3)                                                
00007F0BDC63C428: move_cr {local,test} x(0)                                      
00007F0BDC63C438: i_call_ext_only_e gen_server:start_link/4                      
                                                                                 
00007F0BDC63C448: i_func_info_IaaI 0 test init 1                                 
00007F0BDC63C470: is_nil_fr f(00007F0BDC63C448) x(0)                             
00007F0BDC63C480: allocate_tt 0 0                                                
00007F0BDC63C490: self_r x(0)                                                    
00007F0BDC63C498: move_x1_c haha                                                 
00007F0BDC63C4A8: send                                                           
00007F0BDC63C4B0: move_deallocate_return_crQ {ok,{state}} x(0) 0                 
                                                                                 
00007F0BDC63C4C8: i_func_info_IaaI 0 test handle_call 3                          
00007F0BDC63C4F0: test_heap_It 4 3                                               
00007F0BDC63C500: i_put_tuple_rI x(0) 3  reply ok x(2)                           
00007F0BDC63C528: return                                                         
                                                                                 
00007F0BDC63C530: i_func_info_IaaI 0 test handle_cast 2                          
00007F0BDC63C558: test_heap_It 3 2                                               
00007F0BDC63C568: i_put_tuple_rI x(0) 2  noreply x(1)                            
00007F0BDC63C588: return                                                         
                                                                                 
00007F0BDC63C590: i_func_info_IaaI 0 test handle_info 2                          
00007F0BDC63C5B8: allocate_heap_tIt 1 2 2                                        
00007F0BDC63C5D0: move_xy x(1) y(0)                                              
00007F0BDC63C5E0: put_list_rnx x(0) [] x(1)                                      
00007F0BDC63C5F0: i_move_call_ext_cre "received: ~p~n" x(0) io:format/2          
00007F0BDC63C608: test_heap_It 3 0                                               
00007F0BDC63C618: i_put_tuple_rI x(0) 2  noreply y(1)                            
00007F0BDC63C638: deallocate_return_Q 1                                          
                                                                                 
00007F0BDC63C648: i_func_info_IaaI 0 test terminate 2                            
00007F0BDC63C670: move_return_cr ok x(0)                                         
                                                                                 
00007F0BDC63C680: i_func_info_IaaI 0 test code_change 3                          
00007F0BDC63C6A8: test_heap_It 3 2                                               
00007F0BDC63C6B8: i_put_tuple_rI x(0) 2  ok x(1)                                 
00007F0BDC63C6D8: return                                                         
                                                                                 
00007F0BDC63C6E0: i_func_info_IaaI 0 test module_info 0                          
00007F0BDC63C708: move_cr test x(0)                                              
00007F0BDC63C718: allocate_tt 0 1                                                
00007F0BDC63C728: call_bif_e erlang:get_module_info/1                            
00007F0BDC63C738: deallocate_return_Q 0                                          
                                                                                 
00007F0BDC63C748: i_func_info_IaaI 0 test module_info 1                          
00007F0BDC63C770: move_rx x(0) x(1)                                              
00007F0BDC63C780: move_cr test x(0)                                              
00007F0BDC63C790: allocate_tt 0 2                                                
00007F0BDC63C7A0: call_bif_e erlang:get_module_info/2                            
00007F0BDC63C7B0: deallocate_return_Q 0 
```

## Core Erlang
Core Erlang是Erlang的一种中间表现形式, 尽可能保持语法简单, 稳定和可读性以方便工具解析或手工修改
换句话说,通过Core Erlang我们可以透过语法糖看到真实的代码逻辑
> $ erl
> Erlang/OTP 18 [erts-7.0] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]
> 
> Eshell V7.0  (abort with ^G)
> 1> c(test,[to_core]).
> ** Warning: No object file created - nothing loaded **
> ok

```erlang
module 'test' ['fac'/1,                                                          
           'module_info'/0,                                                      
           'module_info'/1]                                                      
    attributes []                                                                
'fac'/1 =                                                                        
    %% Line 3                                                                    
    fun (_cor0) ->                                                               
    case _cor0 of                                                                
      <1> when 'true' ->                                                         
          1                                                                      
      %% Line 4                                                                  
      <N> when 'true' ->                                                         
          let <_cor1> =                                                          
          call 'erlang':'-'                                                      
              (N, 1)                                                             
          in  let <_cor2> =                                                      
              apply 'fac'/1                                                      
              (_cor1)                                                            
          in  call 'erlang':'*'                                                  
              (N, _cor2)                                                         
    end                                                                          
'module_info'/0 =                                                                
    ( fun () ->                                                                  
      ( call ( 'erlang'                                                          
           -| ['compiler_generated'] ):( 'get_module_info'                       
                         -| ['compiler_generated'] )                             
        (( 'test'                                                                
           -| ['compiler_generated'] ))                                          
        -| ['compiler_generated'] )                                              
      -| ['compiler_generated'] )                                                
'module_info'/1 =                                                                
    ( fun (( _cor0                                                               
         -| ['compiler_generated'] )) ->                                         
      ( call ( 'erlang'                                                          
           -| ['compiler_generated'] ):( 'get_module_info'                       
                         -| ['compiler_generated'] )                             
        (( 'test'                                                                
           -| ['compiler_generated'] ), ( _cor0                                  
                          -| ['compiler_generated'] ))                           
        -| ['compiler_generated'] )                                              
      -| ['compiler_generated'] )                                                
end
```

## 参考链接
http://www.cnblogs.com/me-sa/p/know-a-little-erlang-opcode.html
http://blog.yufeng.info/archives/498

