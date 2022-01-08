title:  记一次 elixir remote_console 报错
date: 2022-01-08

tags: [erlang, elixir]
---

使用 systemd 部署一个 elixir 服务到 qa 环境， 结果用不到 remote_console ，多难受的一件事 :(
遇到的还是一个从来没见过的报错, 下面就来一起看一下

<!--more-->

```
Interactive Elixir (1.10.4) - press Ctrl+C to exit (type h() ENTER for help)


*** ERROR: Shell process terminated! (^G to start new job) ***
2022-01-06 14:08:06.471 [error]  #PID<9048.3828.0> Process #PID<9048.3828.0> on node :"ribbon@10.125.161.13" raised an exception
** (ArgumentError) argument error
    :erlang.monitor(:process, {:error, {{:badmatch, :error}, [{System, :user_home, 0, [file: 'lib/system.ex', line: 315]}, {System, :user_home!, 0, [file: 'lib/system.ex', line: 328]}, {Path, :resolve_home, 1, [file: 'lib/path.ex', line: 697]}, {Path, :expand, 1, [file: 'lib/path.ex', line: 161]}, {Enum, :"-map/2-lists^map/1-0-", 2, [file: 'lib/enum.ex', line: 1396]}, {Enum, :"-map/2-lists^map/1-0-", 2, [file: 'lib/enum.ex', line: 1396]}, {IEx.Evaluator, :load_dot_iex, 2, [file: 'lib/iex/evaluator.ex', line: 169]}, {IEx.Evaluator, :init, 4, [file: 'lib/iex/evaluator.ex', line: 23]}]}})
    (iex 1.10.4) lib/iex/server.ex:85: IEx.Server.run_without_registration/1
```

这个是因为 /etc/systemd/system/example.service 文件中的 User=chenduo 被删了， 导致 erlang 启动时缺一个 -home 的参数(例如下面就有, `ps aux` 命令显示出来的)，而查看 elixir 源码可以看到 System.user_home 用的是 :init.get_argument(:home), 没有这个 -home 参数就失败，于是上述 System.user_home 也就失败了
```
/opt/homebrew/Cellar/erlang@23/23.3.4.7/lib/erlang/erts-11.2.2.6/bin/beam.smp -sbwt none -sbwtdcpu none -sbwtdio none -- -root /opt/homebrew/Cellar/erlang@23/23.3.4.7/lib/erlang -progname erl -- -home /Users/chenduo -- -kernel shell_history enabled -noshell -s elixir start_cli -- -extra -e ElixirLS.LanguageServer.CLI.main()
```
