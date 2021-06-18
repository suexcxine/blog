title: erlang config研究
date: 2021-06-18

tags: [erlang, config, mix, rebar, distillery]
---

erlang 的配置还是走了一段很曲折的路, ... 

<!--more-->

下面这种写法里

```shell
RELX_REPLACE_OS_VARS=true NODE_NAME=exampleapp@106.15.72.22 PORT=5001 bin/exampleapp start
```

RELX_REPLACE_OS_VARS=true 告诉系统要在结点启动时将 sys.config 以及 vm.args 文件里的形如 `${PORT}` 的值用对应环境变量的值替换掉

```
%% sys.config
[
 {appname, [{port, "${PORT}"}]}
].
```



*如果是 elixir + distillery 的项目, RELX_REPLACE_OS_VARS 换成 REPLACE_OS_VARS*

*相关代码在这里: bin/exampleapp -> bin/exampleapp_rc_exec.sh -> releases/VERSION/exampleapp.sh -> releases/VERSION/libexec/config.sh*

*限制: 这种方式下sys.config下只能配字符串, 需要在应用层去做类型转换*



#### 问题

上面这种做法本质上其实是个 hack

导致我们在 release 之后不方便修改 sys.config 里的配置, 只能通过环境变量来改那些用了这种写法的地方, 不灵活 



#### 新的选择(OTP-21+ and Rebar3 3.6+)

可以在 config/sys.config.src, config/vm.args.src 文件中使用  ${PORT}, ${NODE_NAME} 这样的写法, 不再有强制字符串的限制

作用方式仍然是在结点启动时将下述模板里的变量用环境变量的值替换

```
%% sys.config.src
[
  {appname, [{port, ${PORT}}]}
].
```

(http://rebar3.org/docs/deployment/releases/#environment-variable-replacement)



#### 新的选择(Distillery 2.0+)

提出了 [config_provider](https://hexdocs.pm/distillery/config/runtime.html#config-providers) 概念

允许使用 toml, yaml, json 等格式, 通过修改 boot script 在启动之前执行 Provider 模块用以帮助生成最终需要的 sys.config 文件

这样做到了支持使用通用配置文件(yaml等), 并且不受限于环境变量



例: rel/config.exs 这里配置 provider 等信息

```elixir
Copied to clipboard
environment :prod do
  set config_providers: [
    {Toml.Provider, [path: "${RELEASE_ROOT_DIR}/config.toml"]}
  ]
  set overlays: [
    {:copy, "config/defaults.toml", "config.toml"}
  ]
end
```

