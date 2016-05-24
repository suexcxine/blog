title: Haskell Applicative
date: 2016-01-22
tags: [haskell]
---

Applicative Functor允许Functor的链式调用
<!--more-->

## Applicative Functor
Control.Applicative模块
```haskell
class (Functor f) => Applicative f where
    pure :: a -> f a
    (<*>) :: f (a -> b) -> f a -> f b
```
pure将一个值包装到一个最简单的(默认或者说最小)环境里
<*>可以使用环境里的函数处理另一个环境

### Maybe
```haskell
instance Applicative Maybe where
    pure = Just
    Nothing <*> _ = Nothing
    (Just f) <*> something = fmap f something
```

### Maybe Applicative 链式调用
```haskell
(<$>) :: (Functor f) => (a -> b) -> f a -> f b
f <$> x = fmap f x

ghci> pure (+) <*> Just 3 <*> Just 5
ghci> fmap (+) Just 3 <*> Just 5
ghci> (+) <$> Just 3 <*> Just 5
Just 8
```
这种方式使我们不需要理会环境,直接处理环境内的值

### List
```haskell
instance Applicative [] where
    pure x = [x]
    fs <*> xs = [f x | f <- fs, x <- xs] 笛卡尔积
```
```haskell
ghci> [(+),(*)] <*> [1,2] <*> [3,4]
[4,5,5,6,3,4,6,8]
ghci> (++) <$> ["ha","heh","hmm"] <*> ["?","!","."]
["ha?","ha!","ha.","heh?","heh!","heh.","hmm?","hmm!","hmm."]
```

使用applicative style取代list comprehension
```haskell
ghci> [ x*y | x <- [2,5,10], y <- [8,10,11]]
[16,20,22,40,50,55,80,100,110]
ghci> (*) <$> [2,5,10] <*> [8,10,11]
[16,20,22,40,50,55,80,100,110]
```
这里好像可以得出这样一个结论,
那就是Haskell在尽可能地消除变量
上面的例子里x,y都没有了,只有行为和数据

### IO也是applicative functor

### function也是applicative functor
```haskell
instance Applicative ((->) r) where
    pure x = (\_ -> x)
    f <*> g = \x -> f x (g x)
```

```haskell
ghci> (+) <$> (+3) <*> (*100) $ 5
ghci> fmap (+) (+3) <*> (*100) $ 5
ghci> ((+) . (+3)) <*> (*100) $ 5
((+) . (+3)) $ 5 即(\x -> (+(x+3))) $ 5的结果是 (+8)
按照<*>的定义, 继续化简为
ghci> (\x -> ((+) . (+3)) x ((*100) x)) $ 5
ghci> (+8) (5*100)
ghci> (+8)  500
508
```
```haskell
ghci> (\x y z -> [x,y,z]) <$> (+3) <*> (*2) <*> (/2) $ 5
ghci> (\x y z -> [x+3,y,z]) <*> (*2) <*> (/2) $ 5
按照<*>的定义,第一元不变,将第二元改为使用第一元调用(*2),即
ghci> (\x z -> [x+3,x*2,z]) <*> (/2) $ 5
ghci> (\x -> [x+3,x*2,x/2]) $ 5
[8.0,10.0,2.5]
```

<\$\>左边的得是一个二(N,右边有N个一元函数的情况)元函数,即函数的函数,即函数在一个环境(这个环境恰好也是一个函数)里
每执行一个<$>或<*>就减一元,到最后只剩一元(即前面的几个函数合成成的新函数,根据curry化,一元就是N元)
最后接受一个参数可得结果,
所以function使用applicative的效果依然是类似function composition

本以为函数的applicative会定义成这样
```haskell
instance Applicative ((->) r) where
    pure x = (\_ -> x)
    f <*> g = \x y -> f x (g y)
```
这样元数不会减少, 但是就只对二元函数有用了,
不如官方的定义有用吧
<*>的意义是将f这个functor(恰好也是个function)里的function取出来修饰g这个一元函数(也是functor)
到此为止吧,我也没完全明白

## ZipList as Applicative Functor
```haskell
instance Applicative ZipList where
    pure x = ZipList (repeat x)
    ZipList fs <*> ZipList xs = ZipList (zipWith (\f x -> f x) fs xs)

ghci> getZipList $ (+) <$> ZipList [1,2,3] <*> ZipList [100,100,100]
[101,102,103]
ghci> getZipList $ (+) <$> ZipList [1,2,3] <*> ZipList [100,100..]
[101,102,103]
ghci> getZipList $ max <$> ZipList [1,2,3,4,5,3] <*> ZipList [5,3,1,2]
[5,3,3,4]
ghci> getZipList $ (,,) <$> ZipList "dog" <*> ZipList "cat" <*> ZipList "rat"
[('d','c','r'),('o','a','a'),('g','t','t')]
```
这里的ZipList可以取代zipWithN函数
getZipList函数用来从ZipList取出List

## Applicative法则
```haskell
pure f <*> x = fmap f x
pure id <*> v = v
pure (.) <*> u <*> v <*> w = u <*> (v <*> w)
pure f <*> pure x = pure (f x)
u <*> pure y = pure ($ y) <*> u
```

## liftA2
```haskell
liftA2 :: (Applicative f) => (a -> b -> c) -> f a -> f b -> f c
liftA2 f a b = f <$> a <*> b
```
With ordinary functors, we can just map functions over one functor value. 
With applicative functors, we can apply a function between several functor values.

我们可以实现这样一个函数,把Applicative值都拼到一个List里
```haskell
sequenceA :: (Applicative f) => [f a] -> f [a]
sequenceA [] = pure []
sequenceA (x:xs) = (:) <$> x <*> sequenceA xs

ghci> sequenceA [(+3),(+2),(+1)] 3
ghci> (\x y z -> [x,y,z]) <$> (+3) <*> (+2) <*> (+1) $ 3
[6,5,4]

ghci> map (\f -> f 7) [(>4),(<10),odd]
[True,True,True]
ghci> and $ map (\f -> f 7) [(>4),(<10),odd]
True
可以改写成
ghci> sequenceA [(>4),(<10),odd] 7
[True,True,True]
ghci> and $ sequenceA [(>4),(<10),odd] 7
True
```

