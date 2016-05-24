title: Haskell Monad
date: 2016-01-22
tags: [haskell]
---

如果我们有一个环境和值m a, 还有一个函数a -> m b, 
怎样才能调用这个函数呢?
我们需要monad, 它是对Applicative Functor的补充
<!--more-->

## monad
```haskell
class Monad m where
    return :: a -> m a
    (>>=) :: m a -> (a -> m b) -> m b
    (>>) :: m a -> m b -> m b
    x >> y = x >>= \_ -> y
    fail :: String -> m a
    fail msg = error msg
```
感觉class定义里应该有Applicative m, 但是没有, 
这是因为早期haskell并不认为Applicative Functor适合Haskell
但是现在证明适合, 并且所有的Monad都是Applicative Functor, 虽然class定义里没有说
```haskell
instance Monad Maybe where
    return x = Just x
    Nothing >>= f = Nothing
    Just x >>= f = f x
    fail _ = Nothing
```

原来Monad提供了类似F#的从左向右调用的功能, 就是\>>=

### 一个Monad应用实例
```haskell
type Birds = Int
type Pole = (Birds, Birds)

landLeft :: Birds -> Pole -> Maybe Pole
landLeft n (left, right)
    | abs ((left + n) - right) < 4 = Just (left + n, right)
    | otherwise = Nothing
landRight :: Birds -> Pole -> Maybe Pole
landRight n (left, right)
    | abs (left - (right + n)) < 4 = Just (left, right + n)
    | otherwise = Nothing

ghci> return (0, 0) >>= landRight 2 >>= landLeft 2 >>= landRight 2
Just (2,4)
ghci> return (0, 0) >>= landLeft 1 >> Nothing >>= landRight 1
Nothing
```

当每一步都有可能失败的时候,好的做法是允许每一步的调用返回Maybe类型
反例, 如果不使用Monad代码可能像这样
```haskell
routine :: Maybe Pole
routine = case landLeft 1 (0, 0) of
    Nothing -> Nothing
    Just pole1 -> case landRight 4 pole1 of
        Nothing -> Nothing
        Just pole2 -> case landLeft 2 pole2 of
            Nothing -> Nothing
            Just pole3 -> landLeft 1 pole3
```
Monad展示了错误处理的境界

## do
```haskell
  Just 3 >>= (\x -> Just (show x ++ "!"))
即Just 3 >>= (\x -> Just "!" >>= (\y -> Just (show x ++ y)))
像let x = 3; y = "!" in show x ++ y
```

加换行以求清晰一些
```haskell
foo :: Maybe String
foo = Just 3 >>= (\x ->
      Just "!" >>= (\y ->
      Just (show x ++ y)))
```
干脆发明一个do语法
```haskell
foo :: Maybe String
foo = do
    x <- Just 3
    y <- Just "!"
    Just (show x ++ y)
```

前例也可以使用do语法改写为:
```haskell
routine :: Maybe Pole
routine = do
    start <- return (0, 0)
    first <- landLeft 2 start
    Nothing
    second <- landRight 2 first
    landLeft 1 second
```
明显不如原版可读性好

do语法里可以使用pattern match
```haskell
justH :: Maybe Char
justH = do
    (x:xs) <- Just "hello"
    return x
```

When pattern matching fails in a do expression, the fail function (part of the Monad type class) enables it to 
result in a failure in the context of the current monad, instead of making the program crash.

### List Monad

```haskell
instance Monad [] where
    return x = [x]
    xs >>= f = concat (map f xs)
    fail _ = []
    
ghci> [1,2] >>= \n -> ['a','b'] >>= \ch -> return (n, ch)
[(1,'a'),(1,'b'),(2,'a'),(2,'b')]

listOfTuples :: [(Int, Char)]
listOfTuples = do
    n <- [1,2]
    ch <- ['a','b']
    return (n, ch)

ghci> [ (n, ch) | n <- [1,2], ch <- ['a','b'] ]
[(1,'a'),(1,'b'),(2,'a'),(2,'b')]
```
In fact, list comprehensions are just syntactic sugar for using lists as monads.

### MonadPlus and the guard Function
```haskell
ghci> [ x | x <- [1..50], '7' `elem` show x ]
[7,17,27,37,47]

class Monad m => MonadPlus m where
    mzero :: m a
    mplus :: m a -> m a -> m a
```
The MonadPlus type class is for monads that can also act as monoids.
mzero is synonymous with mempty from the Monoid type class, and mplus corresponds to mappend.

```haskell
instance MonadPlus [] where
    mzero = []
    mplus = (++)
    
guard :: (MonadPlus m) => Bool -> m ()
guard True = return ()
guard False = mzero

ghci> [1..50] >>= (\x -> guard ('7' `elem` show x) >> return x)
[7,17,27,37,47]

sevensOnly :: [Int]
sevensOnly = do
    x <- [1..50]
    guard ('7' `elem` show x)
    return x
```

## Monad Laws
Left Identity
```haskell
return x >>= f 即 f x
```
Right Identity
```haskell
m >>= return 即 m
```
Associativity
```haskell
(m >>= f) >>= g 即 m >>= (\x -> f x >>= g)
```

### the mtl package

ghc-pkg list

### Writer Monad
```haskell
newtype Writer w a = Writer { runWriter :: (a, w) }

instance (Monoid w) => Monad (Writer w) where
    return x = Writer (x, mempty)
    (Writer (x, v)) >>= f = let (Writer (y, v')) = f x in Writer (y, v `mappend` v')
```
附加数据, 往往做日志有用

### Difference List
保证效率连接List(即总是在List头部++而不是尾部++)的一个类型
```haskell
newtype DiffList a = DiffList { getDiffList :: [a] -> [a] }
instance Monoid (DiffList a) where
    mempty = DiffList (\xs -> [] ++ xs)
    (DiffList f) `mappend` (DiffList g) = DiffList (\xs -> f (g xs))
```
结果DiffList就是一个function composition, 相当于把++的顺序倒了过来
这样原来慢的变成快的,原来快的变成慢的

### Function as Monad(Reader)
```haskell
instance Monad ((->) r) where
    return x = \_ -> x
    h >>= f = \w -> f (h w) w
```
函数的环境是,还缺一个值,我们需要对这个值调用这个函数来取得返回值

```haskell
addStuff :: Int -> Int
addStuff = do
    a <- (*2)
    b <- (+10)
    return (a+b)
```

函数的Monad也叫Reader, 所有的函数都从同一个数据源取值
当我们有许多操作针对同样的值, 就可以考虑使用Reader

### State
把状态封装在Monad的环境里
```haskell
newtype State s a = State { runState :: s -> (a, s) }

instance Monad (State s) where
    return x = State $ \s -> (x, s)
    (State h) >>= f = State $ \s -> let (a, newState) = h s (State g) = f a in g newState
```
return x返回一个一元函数,该函数接受一个状态返回一个State Monad,该Monad的值是x,环境是这个状态
\>>= 里This lambda will be our new stateful computation.

()基本上当void或erlang的ok来用

### type class MonadState

### Maybe的Nothing只告诉我们失败了, 却没有失败的原因
Control.Monad.Error
```haskell
instance (Error e) => Monad (Either e) where
    return x = Right x
    Right x >>= f = f x
    Left err >>= f = Left err
    fail msg = Left (strMsg msg)
```
其中e必须符合Error这个type class

### liftM
有了liftM,我们可以不必实现Functor type class, liftM类似fmap, 就像return和pure是一样的
```haskell
liftM :: (Monad m) => (a -> b) -> m a -> m b
liftM f m = m >>= (\x -> return (f x))
```
函数ap类似<*>
```haskell
ap :: (Monad m) => m (a -> b) -> m a -> m b
ap mf m = do
    f <- mf
    x <- m
    return (f x)
```

```haskell
liftA2 :: (Applicative f) => (a -> b -> c) -> f a -> f b -> f c
liftA2 f x y = f <$> x <*> y
```
这是一个方便的函数
liftM2至liftM5做的事情相同, 只不过类型要求是Monad

可以直接定义Applicative Functor的pure为return, <*>为ap

### join
```haskell
join :: (Monad m) => m (m a) -> m a
join mm = do
    m <- mm
    m
```

```haskell
ghci> join [[1,2,3],[4,5,6]]
[1,2,3,4,5,6]
ghci> join (Just (Just 9))
Just 9
ghci> join (Just Nothing)
Nothing
ghci> join Nothing
Nothing
ghci> runWriter $ join (Writer (Writer (1, "aaa"), "bbb"))
(1,"bbbaaa")
```

m >>= f 即 join (fmap f m)

### filterM
```haskell
filterM :: (Monad m) => (a -> m Bool) -> [a] -> m [a]
filterM _ []     =  return []
filterM p (x:xs) =  do
   flg <- p x
   ys  <- filterM p xs
   return (if flg then x:ys else ys)
```
filterM过滤后不仅返回Bool, 还带一个环境(可能包含原因等信息)

例子:
```haskell
keepSmall :: Int -> Writer [String] Bool
keepSmall x
    | x < 4 = do
        tell ["Keeping " ++ show x]
        return True
    | otherwise = do
        tell [show x ++ " is too large, throwing it away"]
        return False
```
```haskell
ghci> fst $ runWriter $ filterM keepSmall [9,1,5,2,10,3]
[1,2,3]
ghci> mapM_ putStrLn $ snd $ runWriter $ filterM keepSmall [9,1,5,2,10,3]
9 is too large, throwing it away
Keeping 1
5 is too large, throwing it away
Keeping 2
10 is too large, throwing it away
Keeping 3
```

```haskell
powerset :: [a] -> [[a]]
powerset xs = filterM (\x -> [True, False]) xs
```
```haskell
ghci> powerset [1,2,3]
[a] -> [m a]的结果是: [[[1], []], [[2], []], [[3], []]]
下一步[m a] -> m [a]应该是:
[x `mappend` y `mappend` z | x <- [[1], []], y <- [[2], []], z <- [[3], []]]
即: [[1,2,3],[1,2],[1,3],[1],[2,3],[2],[3],[]]
```

### foldM
```haskell
foldM :: (Monad m) => (a -> b -> m a) -> a -> [b] -> m a
```

### Composing Monadic Functions
```haskell
ghci> let f = (+1) . (*100)
ghci> f 4
401
ghci> let g = (\x -> return (x+1)) <=< (\x -> return (x*100))
ghci> Just 4 >>= g
Just 401
```
这是Monad与非Monad的类比,其实操作都很像,换几个符号而已

```haskell
ghci> let f = foldr (.) id [(+1),(*100),(+1)]
ghci> f 1
201
```

Rational类似与Float不同, 不会丢失精度

