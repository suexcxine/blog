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

所以, 要么用 vm.args 来配, 要么用 runtime config

所以什么是 elixir 的 [runtime config](https://hexdocs.pm/mix/Mix.Tasks.Release.html#module-runtime-configuration) ?

