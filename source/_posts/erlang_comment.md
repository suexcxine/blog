title: erlang评论
date: 2016-08-17 21:27:00
tags: erlang
---

### 对erlang并行及性能的精彩评论
在stack overflow看到一段话, 句句说到心坎里,
忍不住转载如下

Almost any language can be parallelized. In some languages it's simple, in others it's a pain in the butt, but it can be done. If you want to run a C++ program across 8000 CPU's in a grid, go ahead! You can do that. It's been done before.

**Erlang doesn't do anything that's impossible in other languages.** If a single CPU running an Erlang program is less efficient than the same CPU running a C++ program, then two hundred CPU's running Erlang will also be slower than two hundred CPU's running C++.

**What Erlang does do is making this kind of parallelism easy to work with. It saves developer time and reduces the chance of bugs.**

So I'm going to say no, there is no tipping point at which Erlang's parallelism allows it to outperform another language's numerical number-crunching strength.

Where Erlang scores is in making it easier to scale out and do so correctly. But it can still be done in other languages which are better at number-crunching, if you're willing to spend the extra development time.

And of course, let's not forget the good old point that **languages don't have a speed**. A sufficiently good Erlang compiler would yield perfectly optimal code. **A sufficiently bad C compiler would yield code that runs slower than anything else.**

### 调度问题
Erlang has preemptive scheduling, and so there is no guarantee that a central process will necessarily get all of the CPU time it needs to flush data,
unless raising the process' priority, but if not done carefully, you can hog a scheduler and make everything rather unfair.
In any case, you want to avoid the pattern where a lot of work is done on a single process.

## 参考链接
http://stackoverflow.com/questions/1308527/when-does-erlangs-parallelism-overcome-its-weaknesses-in-numeric-computing

