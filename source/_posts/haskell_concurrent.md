title: Parallel and Concurrent Programming in Haskell 1
date: 2016-02-02
tags: [haskell]
---

## parallel和concurrent
parallel是在多个计算硬件上同时计算
concurrent则是一个逻辑概念,使用多个逻辑线程,不一定需要多个计算硬件

<!--more-->

## 确定性的编程模型和非确定性的编程模型
deterministic programming model: each program can give only one result(执行多次结果都一样)
nondeterministic programming model: admits programs that may have different results, depending on some aspect of the execution(执行多次结果可能不一样).
Concurrent programming models are necessarily nondeterministic because they must interact with
external agents that cause events at unpredictable times. Nondeterminism has some
notable drawbacks, however: Programs become significantly harder to test and reason about.

In Haskell, most parallel programming models are deterministic.

## 安装threadscope
sudo apt-get install threadscope

## 下载示例代码
cabal unpack parconc-examples
cd parconc-examples
cabal install --only-dependencies
cabal configure
cabal build

## 编译器能否自动为我们代码做并行化
You might wonder whether the compiler could automatically parallelize programs for us. 
After all, it should be easier to do this in a purely functional language, 
where the only dependencies between computations are data dependencies, 
which are mostly perspicuous and thus readily analyzed. However, even in a purely functional language,
automatic parallelization is thwarted by an age-old problem: To make the program faster, 
we have to gain more from parallelism than we lose due to the overhead of adding it, 
and compile-time analysis cannot make good judgments in this area. 
An alternative approach is to use runtime profiling to find good candidates for parallelization and 
to feed this information back into the compiler. 
Even this, however, has not been terribly successful in practice.

## weak head normal form
weak head normal form, 即未完全求值的形式, 完全求值的形式叫做normal form
haskell的求值顺序与eager evaluation的语言(先对参数求值, 再对函数求值)相反, 
即从外向里, 先对函数求值, 再对参数求值, 于是参数有可能因为不需要而被省掉求值运算

下面这一段说明了haskell的求值顺序
```haskell
Prelude> let xs = map (+1) [1..10] :: [Int]
Prelude> :sprint xs
xs = _
Prelude> seq xs ()
()
Prelude> :sprint xs
xs = _ : _
Prelude> length xs
10
Prelude> :sprint xs
xs = [_,_,_,_,_,_,_,_,_,_]
Prelude> sum xs
65
Prelude> :sprint xs
xs = [2,3,4,5,6,7,8,9,10,11]
```
可见, 执行length并不需要完全求值, 诸如此类的情况节约了计算资源

## The Eval Monad, rpar, and rseq
Control.Parallel.Strategies

几种模式
```haskell
runEval $ do
    a <- rpar (f x)
    b <- rpar (f y)
    return (a,b)

runEval $ do
    a <- rpar (f x)
    b <- rseq (f y)
    return (a,b)

runEval $ do
    a <- rpar (f x)
    b <- rseq (f y)
    rseq a
    return (a,b)
    
runEval $ do
    a <- rpar (f x)
    b <- rpar (f y)
    rseq a
    rseq b
    return (a,b)
```
执行示例代码
```
ghc -O2 rpar.hs -threaded
./rpar 1 +RTS -N2
ghc -O2 sudoku1.hs -rtsopts
./sudoku1 sudoku17.1000.txt
./sudoku1 sudoku17.1000.txt +RTS -s
The argument +RTS -s instructs the GHC runtime system to emit the statistics shown.
ghc -O2 sudoku2.hs -rtsopts -threaded
./sudoku2 sudoku17.1000.txt +RTS -N2 -s
rm sudoku2; ghc -O2 sudoku2.hs -threaded -rtsopts -eventlog
./sudoku2 sudoku17.1000.txt +RTS -N2 -l
threadscope sudoku2.eventlog
```

## 动态分配任务
spark的概念
overflowed
dud
GC’d
fizzled

## Amdahl's law
1 / ((1 - P) + P/N)
其中P/N在N为无穷大时为零, 所以串行部分即1 - P的值决定了并行效率的上限为1 / (1 - P)

## NFData类型
```haskell
force :: NFData a => a -> a
class NFData a where
    rnf :: a -> ()
    rnf a = a `seq` ()
```
自定义的类型可能需要自己实现NFData类
如:
```haskell
instance NFData a => NFData (Tree a) where
    rnf Empty = ()
    rnf (Branch l a r) = rnf l `seq` rnf a `seq` rnf r
```

## Evaluation Strategies

目的是将业务逻辑与并行策略分离开, 就像下面这样
(fib 35, fib 36) `using` parPair -- 使用并行
(fib 35, fib 36)                 -- 不使用并行
注意: the Strategys must obey the identity property
type Strategy a = a -> Eval a

## Parameterized Strategies

we can write a Strategy over a pair of pairs that evaluates the first component (only) of both pairs in parallel.
evalPair (evalPair rpar r0) (evalPair rpar r0) :: Strategy ((a,b),(c,d))

## A Strategy for Evaluating a List in Parallel

对一个列表的每一个元素使用指定的并发策略
let solutions = map solve puzzles `using` parList rseq

## Example: The K-Means Problem

## Parallelizing Lazy Streams with parBuffer

A common pattern in Haskell programming is to use a lazy list as a stream so that the
program can consume input while simultaneously producing output and consequently
run in constant space.
此时并发如果实现得不好,可能会破坏这种lazy流属性导致消耗大量的内存

## Chunking Strategies

