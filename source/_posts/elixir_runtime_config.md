title: elixir runtime config
date: 2021-06-26

tags: [elixir, config]
---

有次在 config.exs 里给 kernel application 配了点东西,

结果出了下面这样的警告:

<!--more-->

```elixir
Cannot configure base applications: [:kernel]

These applications are already started by the time the configuration
executes and these configurations have no effect.

If you want to configure these applications for a release, you can
specify them in your vm.args file:

	-kernel config_key config_value

Alternatively, if you must configure them dynamically, you can wrap
them in a conditional block in your config files:

  if System.get_env("RELEASE_MODE") do
    config :kernel, ...
  end

and then configure your releases to reboot after configuration:

  releases: [
    my_app: [reboot_system_after_config: true]
  ]

This happened when loading config/config.exs or
one of its imports.

```

由于 kernel, stdlib 这些启动得比 config 要早, 所以 config 没法对它们生效

于是, 如果想在 config 里配它们的参数, 要么用 vm.args 来配, 

要么用 [runtime config](https://hexdocs.pm/mix/Mix.Tasks.Release.html#module-runtime-configuration) + reboot_system_after_config(在 mix.exs 里配) 才能搞, 就是加载完 config 然后再重启VM(在同一个操作系统进程内) 的方式

也就是下面这种效果

```erlang
> bin/test_app start_iex
Erlang/OTP 23 [erts-11.2] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Erlang/OTP 23 [erts-11.2] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

...... other logs
```

要我选的话还是 vm.args 吧~



## runtime config

runtime config 的意义在于, 以前 config.exs(以及import_config加进来的其他东西)是一个编译时的东西, 即编译生成 sys.config 文件. 这样的话, 比如在 config.exs 里用了环境变量的话, 也要重新编译并发布才能生效, 失去环境变量的意义, 太麻烦. 

有了 runtime config 的话, 在启动过程中一个比较早的时间点会加载一次配置, 这样环境变量就是在运行时加载了, 另外手动修改配置文件(如 releases/VSN/runtime.exs)也可以生效, 这两种情况就都不需要重新编译和发布了. 太棒啦!

