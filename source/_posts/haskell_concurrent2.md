title: Parallel and Concurrent Programming in Haskell 2
date: 2016-02-03
tags: [haskell]
---

大数组怎么并行
使用GPU并行 

<!--more-->

There is nothing in the types to stop you from returning an IVar from
runPar and passing it to another call of runPar . This is a Very Bad
Idea; don’t do it. The implementation of the Par monad assumes that
IVar s are created and used within the same runPar , and breaking this
assumption could lead to a runtime error, deadlock, or worse.

runPar $ do
    i <- new
    j <- new
    fork (put i (fib n))
    fork (put j (fib m))
    a <- get i
    b <- get j
    return (a+b)

## Data Parallel Programming with Repa

大数组怎么并行呢 
import Data.Array.Repa as Repa

## GPU Programming with Accelerate
GPU有大量并行计算单元
the processors of a GPU all run exactly the same code in lockstep, 
so they are suitable only for data-parallel tasks where the operations to perform on each data item are identical.

GPU与CPU指令集不同,需要专门的编译器为GPU编译代码,源码一般也类似受限制的C(CUDA和OpenCL)
Accelerate库是一个EDSL(嵌入的领域专门语言),使我们不需要写CUDA或OpenCL也可以使用GPU的计算能力

cabal install accelerate
cabal install accelerate-cuda

