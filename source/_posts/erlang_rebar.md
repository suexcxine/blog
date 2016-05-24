title: erlang rebar
date: 2015-09-14
tags: erlang
---
## 获取帮助
> rebar -c
> 获取指定命令的帮助如clean
> rebar help clean

## 新建项目
> rebar create-app appid=myapp

## 编译
> rebar compile

## 清理
> rebar clean

## 单元测试
在文件头部加上:
> -ifdef(TEST).
> -include_lib("eunit/include/eunit.hrl").
> -endif.

在文件尾部加上类似如下代码:
> -ifdef(TEST).
> 
> simple_test() ->
>     ok = application:start(myapp),
>     ?assertNot(undefined == whereis(myapp_sup)).
> 
> -endif.

执行单元测试
> rebar compile eunit

## 覆盖率测试
在rebar.config配置文件中加上:
> {cover_enabled, true}.

执行覆盖率测试
> $ rebar compile eunit
> ==> myapp (compile)
> ==> myapp (eunit)
>   Test passed.
> Cover analysis: /Users/dizzyd/tmp/myapp/.eunit/index.html

可以打开.eunit/index.html文件检查覆盖率的分析报告

## Rebar conventions
* rebar会在test目录中寻找EUnit测试代码
* c_src文件夹存储用于编译port driver的c代码文件

## Dynamic configuration
这个功能提供一些定制空间

如果存在rebar.config.script文件(与rebar.config在同一目录),
那么该文件会被以file:script/2函数读取并执行,最后一个表达式的值会被返回做为结果
同样的,对其他自定义的rebar.config文件也适用,
如rebar -C special_config会尝试读取special.config.script文件
例如:
> case os:getenv("REBAR_DEPS") of
>     false -> CONFIG; % env var not defined
>     []    -> CONFIG; % env var set to empty string
>     Dir ->
>     lists:keystore(deps_dir, 1, CONFIG, {deps_dir, Dir})
> end.

这段代码的功能是,如果想自定义一个依赖目录而不是每次都从github取依赖的话设置REBAR_DEPS环境变量
反过来,不设置REBAR_DEPS环境变量则会从github取依赖

## 优先编译
```
{erl_first_files, ["src/mymib1.erl", "src/mymib2.erl"]}.
```

## 条件编译
可以使用另一个config来做条件编译之用
如:rebar_ct.config
> {erl_opts, [debug_info, {d, `'TEST'`, true}]}.

使用-C参数指定config文件(非默认的rebar.config),
进一步可以使用Makefile
记得先clean掉之前的编译结果,因为rebar只会编译未编译过的模块,
如果不clean,那么已编译的模块不会被重新编译
```bash
./rebar -C "rebar_ct.config" clean compile ct
```

## lib_dirs配置
rebar.config:
```erlang
{lib_dirs, ["deps"]}.
```
编译代码时,有时出现Warning: behaviour ranch_protocol undefined这样的错误,
原因是compile:file执行时无法在搜索路径里找到ranch_protocol:behaviour_info/1函数,
而对于rebar这样一个escript程序,无法使用-pa,-pz来扩展搜索路径,
只能在代码里使用code:add_pathsa等来动态添加, 其依据即为lib_dirs配置
参考链接: http://erlang.2086793.n4.nabble.com/Behavior-undefined-warning-td2088824.html




