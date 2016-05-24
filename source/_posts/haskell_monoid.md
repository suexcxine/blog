title: Haskell Monoid
date: 2016-01-22
tags: [haskell]
---

二元函数的共性, 参数与返回值类型相同, 且存在一个值在操作前后不变如
```
1 * N = N, N * 1 = N
[] ++ List = List, List ++ [] = List
```

<!--more-->

## monoid定义

Monoid是一个type class
```haskell
class Monoid m where
    mempty :: m
    mappend :: m -> m -> m
    mconcat :: [m] -> m
    mconcat = foldr mappend mempty
```

mappend,命名来自++这种append,但是像乘法*这样的,并不是append,理解为参数与返回值类型的二元函数就可以    
mconcat函数可以重写(某些情况下效率比默认的实现好),但大多数情况下用默认的实现就很好.

## monoid法则
```haskell
mempty `mappend` x = x
x `mappend` mempty = x
(x `mappend` y) `mappend` z = x `mappend` (y `mappend` z)
```

## newtype
```haskell
newtype ZipList a = ZipList { getZipList :: [a] }
```

使用现有类型定义一个新类型
newtype会比用data包装旧类型的性能要好

另外,举例说明,如果我们想把tuple定义成符合functor, 
且fmap (+3) (1, 1)的结果是(4, 1),
由于functor都是对后一个type parameter做处理(如Either a b)
想让tuple的第一个元素被fmap作用就有点难
看newtype怎么解决这个问题:
```haskell
newtype Pair b a = Pair { getPair :: (a, b) }
```

### newtype Laziness
because Haskell knows that types made with the newtype keyword can have only one constructor, 
it doesn’t need to evaluate the value passed to the function to 
make sure that the value conforms to the (CoolBool _) pattern,
because newtype types can have only one possible value constructor and one field

Pattern matching on newtype values isn’t like taking something out of a box (as it is with data ), 
but more about making a direct conversion from one type to another.

## ghci
导入package
import Data.Monoid

## 一些monoid的例子
#### List
```haskell
instance Monoid [a] where
    mempty = []
    mappend = (++)
    
ghci> "one" `mappend` ("two" `mappend` "tree")
"onetwotree"
```

#### Num
由于数字有加法和乘法均满足monoid, 此处就可以使用newtype分别实现Monoid type class
```haskell
newtype Product a = Product { getProduct :: a }
    deriving (Eq, Ord, Read, Show, Bounded)
    
instance Num a => Monoid (Product a) where
    mempty = Product 1
    Product x `mappend` Product y = Product (x * y)

ghci> getProduct $ Product 3 `mappend` Product 4 `mappend` Product 2
24
```

加法类似
```haskell
ghci> getSum . mconcat . map Sum $ [1,2,3]
6
```

#### Bool

```haskell
newtype Any = Any { getAny :: Bool }
    deriving (Eq, Ord, Read, Show, Bounded)
    
instance Monoid Any where
    mempty = Any False
    Any x `mappend` Any y = Any (x || y)

newtype All = All { getAll :: Bool }
    deriving (Eq, Ord, Read, Show, Bounded)

instance Monoid All where
    mempty = All True
    All x `mappend` All y = All (x && y)

ghci> getAny . mconcat . map Any $ [False, False, False, True]
True
ghci> getAll . mconcat . map All $ [True, True, False]
False
```

#### Ordering
```haskell
instance Monoid Ordering where
    mempty = EQ
    LT `mappend` _ = LT
    EQ `mappend` y = y
    GT `mappend` _ = GT

```
```haskell
lengthCompare :: String -> String -> Ordering
lengthCompare x y = let a = length x `compare` length y
                        b = x `compare` y
                    in if a == EQ then b else a
```
可以改写为    
```haskell
lengthCompare :: String -> String -> Ordering
lengthCompare x y = (length x `compare` length y) `mappend`
                    (x `compare` y)
```
比第一种写法省一个if,且省a, b变量定义
且带有自动短路功能

#### Maybe
```haskell
instance Monoid a => Monoid (Maybe a) where
    mempty = Nothing
    Nothing `mappend` m = m
    m `mappend` Nothing = m
    Just m1 `mappend` Just m2 = Just (m1 `mappend` m2)
```

```haskell
ghci> Just (Sum 3) `mappend` Just (Sum 4)
Just (Sum {getSum = 7})
```
考虑到Maybe的内容的类型不是monoid的情况(Maybe的mappend定义要求m1和m2都是monoid类型),
于是有了First类型
```haskell
newtype First a = First { getFirst :: Maybe a }
    deriving (Eq, Ord, Read, Show)
instance Monoid (First a) where
    mempty = First Nothing
    First (Just x) `mappend` _ = First (Just x)
    First Nothing `mappend` x = x

ghci> getFirst $ First (Just 'a') `mappend` First (Just 'b')
Just 'a'
```

First is useful when we have a bunch of Maybe values and we just want to know if any of them is a Just.

与First相应的,还有一个Last类型

### Folding with Monoids
```haskell
Foldable type class
foldMap :: (Monoid m, Foldable t) => (a -> m) -> t a -> m
```

以Tree为例
```haskell
data Tree a = EmptyTree | Node a (Tree a) (Tree a) deriving (Show)

instance F.Foldable Tree where
    foldMap f EmptyTree = mempty
    foldMap f (Node x l r) = F.foldMap f l `mappend`
                                       f x `mappend`
                             F.foldMap f r
ghci> getAny $ F.foldMap (\x -> Any $ x == 3) testTree
True
ghci> F.foldMap (\x -> [x]) testTree
[1,3,6,5,8,9,10]
```

