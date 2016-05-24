title: Haskell Functor
date: 2015-12-21
tags: [haskell]
---

Haskell没有继承关系(做得太对了!), 都是interface的感觉, 一个type class就是一个interface, 以此实现多态
functor, 也是一个type class, 指内容允许被maped over, 如list, 内部元素可以被map, 从而得到另一个list
<!--more-->
## Functor定义
```haskell
class Functor f where
    fmap :: (a -> b) -> f a -> f b
```
functor修饰了a(如Int)这样的类型变成了f a(如lists Int)这种,这才是一个具体的类型
这里的f 也叫 type constructor, a 也叫 type parameter, f a才是一个concrete type
另例: Maybe String里的Maybe 也是 type constructor, String 是 type parameter, Maybe String是concrete type
functor实质上定义了一个盒子(box),只有一个fmap函数,该函数可以把盒子里的内容转换成别的内容,而盒子不变

## list对functor的实现
```haskell
map :: (a -> b) -> [a] -> [b]

instance Functor [] where
fmap = map
```

<pre>
ghci> fmap (*2) [1..3]
[2,4,6]
ghci> map (*2) [1..3]
[2,4,6]
</pre>

## 其他例子
Tree 也是 functor
```haskell
instance Functor Tree where
    fmap f EmptyTree = EmptyTree
    fmap f (Node x left right) = Node (f x) (fmap f left) (fmap f right)
```
Maybe 也是 functor
```haskell
instance Functor Maybe where
    fmap f (Just x) = Just (f x)
    fmap f Nothing = Nothing
```
Either a 也是 functor, 注意这里有一个a, 因为Either本身有两个类型参数, 而fmap只能带一个, 
```haskell
instance Functor (Either a) where
    fmap f (Right x) = Right (f x)
    fmap f (Left x) = Left x
```
Map k 同理也是一个functor, 因为Map也有两个类型参数(Map k v)

### IO也是functor
```haskell
instance Functor IO where
    fmap f action = do
        result <- action
        return (f result)
```

### function也是functor
The function type r -> a can be rewritten as (->) r a , much like we can write 2 + 3 as (+) 2 3 .
(->) r, 即(r ->), 也是一个functor
```haskell
instance Functor ((->) r) where
    fmap f g = (\x -> f (g x))
推导过程:
   fmap :: (a -> b) -> f a -> f b
将(->) r代入f
即 fmap :: (a -> b) -> ((->) r a) -> ((->) r b)
即 fmap :: (a -> b) -> (r -> a) -> (r -> b)
```
其实这就是(.), function composition

fmap一个function会得到另一个function,就像fmap一个Maybe会得到另一个Maybe, fmap一个List会得到另一个List
(->)的第二个type parameter被fmap从a换成b,于是原来的函数从r -> a变成了r -> b
函数也被认为是值和其环境, functor是环境

我们可以以另一个角度看fmap的定义
将fmap :: (a -> b) -> f a -> f b
看成fmap :: (a -> b) -> (f a -> f b) 
可以理解为fmap接受一个函数返回另一个函数(这叫做lifting),
这个函数接受一个f环境a类型值返回f环境b类型值
即fmap把(a -> b)这样一个函数升格(lift)成了处理functor的函数(f a -> f b)

### Functor法则
在实现一个functor时应当遵守以下两点
* fmap id = id, id即\x -> x
* fmap (f . g) = fmap f . fmap g
不符合法则的一个例子
```haskell
instance Functor CMaybe where
fmap f CNothing = CNothing
fmap f (CJust counter x) = CJust (counter+1) (f x)

ghci> fmap id (CJust 0 "haha")
CJust 1 "haha"
ghci> id (CJust 0 "haha")
CJust 0 "haha"
```

