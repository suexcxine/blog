title: erlang receive after infinity时启动timer么
date: 2016-02-16
tags: [erlang]
---

找了一段emulator的代码看来是不会启动timer
<!--more-->

不启动timer的话, 使用infinity确实可以省一个timer

## 参考erlang源码
beam_emu.c
```erlang
     if (timeout_value != make_small(0)) {

     if (timeout_value == am_infinity)
         c_p->flags |= F_TIMO;
     else {
         int tres = erts_set_proc_timer_term(c_p, timeout_value);
         if (tres == 0) {
         /*
          * The timer routiner will set c_p->i to the value in
          * c_p->def_arg_reg[0].  Note that it is safe to use this
          * location because there are no living x registers in
          * a receive statement.
          * Note that for the halfword emulator, the two first elements
          * of the array are used.
          */
         BeamInstr** pi = (BeamInstr**) c_p->def_arg_reg;
         *pi = I+3;
         }
         else { /* Wrong time */
         OpCase(i_wait_error_locked): {
             erts_smp_proc_unlock(c_p, ERTS_PROC_LOCKS_MSG_RECEIVE);
             /* Fall through */
         }
         OpCase(i_wait_error): {
             c_p->freason = EXC_TIMEOUT_VALUE;
             goto find_func_info;
         }
         }
     }
```
     
## 参考链接
https://github.com/erlang/otp/blob/a03b7add86b92d0d7d2d744e5555314bedbc2197/erts/emulator/beam/beam_emu.c

