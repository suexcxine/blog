title: erlang app启动顺序
date: 2015-10-13
tags: [erlang]
---

## application启动顺序
由.boot文件决定,
.boot文件(二进制文件)由.script编译而来,
.script文件摘抄如下,可见emysql在ranch之前启动
<pre>{path,["$ROOT/lib/emysql-0.4.1/ebin"]},                                     
  {primLoad,                                                                  
    [emysql,emysql_app,emysql_auth,emysql_conn,emysql_conn_mgr,             
     emysql_conv,emysql_statements,emysql_sup,emysql_tcp,emysql_util,       
     emysql_worker]},                                                       
{path,["$ROOT/lib/ranch-1.0.0/ebin"]},                                      
  {primLoad,                                                                  
    [ranch,ranch_acceptor,ranch_acceptors_sup,ranch_app,ranch_conns_sup,    
     ranch_listener_sup,ranch_protocol,ranch_server,ranch_ssl,ranch_sup,    
     ranch_tcp,ranch_transport]}, 
...
</pre>

.script文件由.rel文件决定
<pre>{release,{"suex_1","1"}, {erts,"7.0"},                                                           
         [{kernel,"4.0"},
          {stdlib,"2.5"},
          {crypto,"3.6"},
          {sasl,"2.5"},
          {emysql,"0.4.1"},
          {ranch,"1.0.0"},
          {recon,"2.2.2"},
          {suex,"1"}]}.
</pre>

而使用relx的情况下,.rel文件由relx根据各application的.app文件和relx.config生成
suex.app
<pre>{applications, [                                                             
         kernel, stdlib, crypto, sasl                                             
]}, 
</pre>

relx.config
<pre>{release, {suex_1, "1"}, [emysql, ranch, recon, suex]}. 
</pre>

## 参考链接
http://www.erlang.org/doc/man/rel.html
http://www.erlang.org/doc/man/script.html

