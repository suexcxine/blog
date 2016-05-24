title: erlang nif
date: 2015-12-28
tags: [erlang]
---

NIF(Native Implemented Function)比port driver更简单有效，
尤其适合编写同步程序, 替Erlang完成一些Erlang不擅长的运算(heavy lifting)
<!--more-->
## 环境(ErlNifEnv)
<pre>
struct enif_environment_t /* ErlNifEnv */
{                                                                                
    struct erl_module_nif* mod_nif;   
    Process* proc;                                                               
    Eterm* hp;                                                                   
    Eterm* hp_end;                                                               
    ErlHeapFragment* heap_frag;                                                  
    int fpe_was_unmasked;                                                        
    struct enif_tmp_obj_t* tmp_obj_list;                                         
    int exception_thrown; /* boolean */                                          
}; 
</pre>
ErlNifEnv表示host erlang term的环境
所有的erlang term都属于某一个环境
list/tuple/map等容器, 都必须和其内部元素在同一个环境内

#### 绑定进程的环境(process bound environment)
所有NIF的第一个参数都是这种环境, 给NIF的所有参数都属于这个环境, NIF的返回值也必须属于这个环境,
此类环境仅包含关于调用进程的瞬时信息, 仅在NIF执行期间那一个线程有效, 
所以在这类环境中保存指针给下次NIF使用是无效且危险的行为

#### 非绑定进程的环境(process independent environment)
使用enif_alloc_env创建, 在enif_free_env或enif_send被调用之前一直有效,
所以可以用于在多次调用NIF之间保存erlang term

## 源码
erts/emulator/beam/global.h
erts/emulator/beam/erl_nif.c
                                                                                 
## 参考链接
http://blog.suexcxine.cc/2015/09/07/erlang_interoperability/
http://blog.suexcxine.cc/2015/12/25/erlang_native_array_nif/

