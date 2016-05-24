title: dialyzer
date: 2015-07-29
tags: erlang
---
```bash
dialyzer --build_plt --apps erts kernel stdlib crypto mnesia sasl common_test eunit --output_plt .dialyzer_plt
dialyzer --add_to_plt --apps ssl reltool --plt .dialyzer_plt
dialyzer -r ebin/ -q --plt .dialyzer_plt 
```

