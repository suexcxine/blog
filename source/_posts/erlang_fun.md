title: erlang fun
date: 2016-03-03
tags: erlang
---

## Funs with names(eep0037)
```erlang
> Fun = fun Quicksort([H|T]) -> Quicksort([I || I <- T, I =< H]) ++ [H] ++ Quicksort([I || I <- T, I > H]); Quicksort([]) -> [] end.
#Fun<erl_eval.30.54118792>
> Fun([1,2,3,4,5,6,4,3,2,1]).
[1,1,2,2,3,3,4,4,5,6]
```

