title: Haskell基础
date: 2015-11-20
tags: [haskell]
---

## 简介
静态,纯函数式通用编程语言                                                        
命名源自美国逻辑学家Haskell Brooks Curry，他在数学逻辑方面的工作使得函数式编程语言有了广泛的基础。
Haskell语言是1990年在编程语言Miranda的基础上标准化的，并且以λ演算（Lambda-Calculus)为基础发展而来。
具有“证明即程序、结论公式即程序类型”的特征。这也是Haskell语言以希腊字母「λ」（Lambda）作为自己标志的原因。
Haskell语言的最主要的执行环境是GHC。

<!--more-->
                                                                                 
发音为: /ˈheskəl/ 

## 引用透明 referential transparency     

一个函数以同样的参数调用两次,得到的结果一定相同,这种性质称为引用透明.            
组合使用多个这样的函数得到的函数仍然可以保持引用透明.
这有助于写出容易测试,容易复用,可读性更好的程序,还能支持惰性求值
                        
## 什么是副作用

## 惰性求值 Lazy Evaluation                                                      
大多数语言是热情求值 Eager Evaluation
不到要使用值的时候不求值,引用透明使这一点成为可能.                               
如果明确了函数的执行结果仅与参数相关,那么早执行或晚执行都是一样的.               
Haskell利用这一点省去了不必要的运算.                                             
所有的代码在执行之前都只是定义,最后需要用值(比如io)的时候才运算.                 
如                                                                               
xs = [1,2,3,4,5,6,7,8]                                                           
print (take 1 (doubleMe(xs)))
只会把第一个元素*2                                                               

另如无限列表,                                                                      
cycle函数,无限循环一个列表的元素从而生成一个无限列表                             
```                                                                              
ghci> take 10 (cycle [1,2,3])                                                    
[1,2,3,1,2,3,1,2,3,1]                                                            
ghci> take 12 (cycle "LOL ")                                                     
"LOL LOL LOL "                                                                   
```

repeat函数,生成单个元素的无限列表                                                
```
ghci> take 10 (repeat 5)                                                         
[5,5,5,5,5,5,5,5,5,5]
```

## 静态类型                                                                      
使编译器能够做更多的编译检查                                                     
                                                                                 
## 类型推导                                                                      
多数时候不需要程序员在代码里注明类型信息                                         
如一个函数定义是                                                                 
add x y = x + y                                                                  
能够推导出是可以+的类型                                                          
                                                                                 
## 前缀和中缀                                                                    
1 + 2这样的函数调用,+函数是中缀形式                                              
add(1, 2)或 (+ 1 2)这样的是前缀形式                                              
lisp语言大家族的函数是前缀的,包括像+这样的函数                                   
haskell默认前缀,也可以中缀,调用时加两反引号即可                                  
假如我们自定义一个div函数表示除法                                                
ghci> div 92 10                                                                  
9                                                                                
ghci> 92 \`div\` 10                                                                
9                                                                                

### 函数名可以用字符'
就像数学里那样,一般用来表示与原来的函数有一点区别的版本
```
doubleSmallNumber' x = (if x > 100 then x else x*2) + 1
```

### list
与erlang类似
经典示例:
```
ghci> let rightTriangles' = [ (a,b,c) | c <- [1..10], a <- [1..c], b <- [1..a], a^2 + b^2 == c^2, a+b+c == 24]
ghci> rightTriangles'
[(6,8,10)]
```
不同点:
* list内的元素必须类型相同
* 取元素时下标从0开始
* zip, 两个列表长度不同时erlang会报错,haskell以短的list为准,所以允许和无限列表zip(估计这才是目的)
```
ghci> zip [5,3,2,6,2,7,2,5,4,6,6] ["im","a","turtle"]
[(5,"im"),(3,"a"),(2,"turtle")]
ghci> zip [1..] ["apple", "orange", "cherry", "mango"]
[(1,"apple"),(2,"orange"),(3,"cherry"),(4,"mango")]
```

### tuple
> (1,3)
> (3,'a',"hello")
> (50,50.4,"hello",'b')

元组的类型由长度和每一个元素的类型决定,
如下形式都会报错,因为list不允许不同类型的元素共存
[(1,2),(8,11,5),(4,5)]
[(1,2),("One",2)]

## type
```
addThree :: Int -> Int -> Int -> Int
addThree x y z = x + y + z
```

## type variable
```
ghci> :t head
head :: [a] -> a
```
a表示可以为任意类型,a只是与后续可能出现的b相区别
这里用类型变量实现了多态
```
ghci> let add' x y = x + y
ghci> :t add'
add' :: Num a => a -> a -> a
```
这里表示add'的x和y的参数类型可以是任意一个符合Num要求的类型
于是Float也可以Int也可以,Integer也可以

## type class
```
ghci> :t (==)
(==) :: (Eq a) => a -> a -> Bool
```

函数名仅由符号组成的函数默认中缀,加上一对括号变成前缀形式
(Eq a) =>这部分是类型约束,表示a类型符合Eq这个type class

Eq表示支持检测是否相等,对应的需要实现的函数是==和/=,
即一个type要支持Eq这个type class,需要实现==和/=,有点像jave里的interface
下述数值的类型都符合Eq类型约束
> ghci> 5 == 5
> True
> ghci> 5 /= 5
> False
> ghci> 'a' == 'a'
> True
> ghci> "Ho Ho" == "Ho Ho"
> True
> ghci> 3.432 == 3.432
> True

### 其他常见type class
* Ord 允许比大小, 即支持>, >=, <, <=, 需要实现compare函数
* Show 允许转换为字符串, 需要实现show函数, 相当于java的toString()
* Read Show的逆操作,将字符串转换成值,如"1" -> 1
* Enum 允许取上一个和下一个元素和range,如3的上一个是2,下一个是4, succ 'b'返回'c', [3..5]返回[3,4,5]
* Bounded 允许取边界, 如Int的边界是minBound返回-2147483648
* Num 表示数值类型
* Floating 表示符点型
* Integral 表示整型 

类型class也有前提关系,Ord的前提是Eq,即要实现Ord必须先实现Eq

### type annotation 类型声明
```
Prelude> read "5" 

<interactive>:36:1:
    No instance for (Read a0) arising from a use of `read'
    The type variable `a0' is ambiguous
    Possible fix: add a type signature that fixes these type variable(s)
    Note: there are several potential instances:
      instance Read () -- Defined in `GHC.Read'
      instance (Read a, Read b) => Read (a, b) -- Defined in `GHC.Read'
      instance (Read a, Read b, Read c) => Read (a, b, c)
        -- Defined in `GHC.Read'
      ...plus 25 others
    In the expression: read "5"
    In an equation for `it': it = read "5"
```
报错了,因为read "5"返回的值的类型不知道具体是Int还是Integer还是Float还是Double还是什么??
所以此时要使用类型声明
Prelude> read "5":: Double
5.0
此时因为是REPL模式立即要显示所以才会报错,代码中如果环境里能推断出来类型也不会报错了


## Curried Functions
Haskell的所有函数都只有一个参数,
多个参数的函数实际上接受一个参数然后返回一个接受两个参数的函数,然后再接受一个参数, ...

```
ghci> max 4 5
5
ghci> (max 4) 5
5
```
以上两个实际上相同,(max 4)返回一个一参的函数,叫做partially applied function
看类型:
```
ghci> :t max
max :: (Ord a) => a -> a -> a
```
可以理解为
```
max :: (Ord a) => a -> (a -> a)
```
即接受一个函数返回一个函数

这是一个制造函数的好办法,我们可以把partially applied function传到别的地方去

### sections
```
isUpperAlphanum :: Char -> Bool
isUpperAlphanum = (`elem` ['A'..'Z'])
```
这里(\`elem\` ['A'..'Z'])是一个partially applied function
```
Prelude> (`elem` ['A'..'Z']) 'B'
True
Prelude> (`elem` ['A'..'Z']) 'a'
False
Prelude> let isUpperAlphanum = (`elem` ['A'..'Z'])
Prelude> isUpperAlphanum 'a'
False
```

(-4)表示负4,想要减4的函数要用(subtract 4)

## high order function
```
applyTwice :: (a -> a) -> a -> a
applyTwice f x = f (f x)
```
```
ghci> applyTwice (+3) 10
16
ghci> applyTwice (++ " HAHA") "HEY"
"HEY HAHA HAHA"
ghci> applyTwice ("HAHA " ++) "HEY"
"HAHA HAHA HEY"
ghci> applyTwice (multThree 2 2) 9
144
ghci> applyTwice (3:) [1]
[3,3,1]
ghci> map (map (^2)) [[1,2],[3,4,5,6],[7,8]]
[[1,4],[9,16,25,36],[49,64]]
```
这里可以看到Curry化的好处, 在需要传入一个函数的时候,可以根据需要传入不同元数的Curry化函数

### lambda
```
\xs -> length xs > 15
```
相当于
```
fun(L) -> length(L) > 15 end
```
比较简洁

```haskell
addThree :: Int -> Int -> Int -> Int
addThree x y z = x + y + z

addThree :: Int -> Int -> Int -> Int
addThree' = \x -> \y -> \z -> x + y + z
```

### fold
foldl和foldr的函数里参数顺序不同, 一个是acc x,另一个是x acc
```haskell
foldl (\acc x -> (x+1):acc) [] [1,2,3]
[4,3,2]
foldr (\x acc -> (x+1):acc) [] [1,2,3]
[2,3,4]
```
foldr可以对无限列表操作,而foldl不可以

foldl1和foldr1不需要提供初始值, 以第一个元素的值为初始值, 空列表会报错

foldl'是strict的版本, 如果List较大使用foldl可能导致stack overflow, 
此时使用foldl'可以少占用内存, 类似尾递归

### scan

与fold不同的是,每一步的结果都会放到返回值的List里
```haskell
ghci> scanl (+) 0 [3,5,2,1]
[0,3,8,10,11]
```

### Function Application with $

定义: <pre>($) :: (a -> b) -> a -> b
f $ x = f x </pre> 由于函数调用(即函数后面跟一个空格)的优先级非常高,f x就相当于f(x),
于是x如果是一个复杂结构的话,一定是先将x内部的运算算完才后调用f,
事实上做到了($)的优先级最低

函数调用是左结合: f a b c 相当于((f a) b) c)
于是: 
<pre>f $ g $ h x
即 f(g $ h x)
即 f(g(h x)) </pre> 事实上做到了右结合

例如:
```haskell
sum $ map sqrt [1..130] 相当于
sum (map sqrt [1..130]) 
```
这样就省去了括号

又如:
```haskell
ghci> sum $ filter (> 10) $ map (*2) [2..10]
ghci> sum(filter (> 10) $ map (*2) [2..10])
ghci> sum(filter (> 10) (map (*2) [2..10]))
80
```

\$还能允许我们把参数包装成函数, 如(\$ 3), 这样就可以在map中使用了
```haskell
ghci> map ($ 3) [(4+), (10*), (^2), sqrt]
ghci> [($ 3) (4+), ($ 3) (10*), ($ 3) (^2), ($ 3) sqrt]
ghci> [(4+) $ 3, (10*) $ 3, (^2) $ 3, sqrt $ 3]
ghci> [(4+) 3, (10*) 3, (^2) 3, sqrt 3]
[7.0,30.0,9.0,1.7320508075688772]
```

## Function Composition

```
(.) :: (b -> c) -> (a -> b) -> a -> c
f . g = \x -> f (g x)
```
f g x是((f g) x), 这可能不是你想要的, 
所以想要先执行g再执行f的话就得写成\x -> f (g x),
那么定义了(.)函数后就可以不用写\x -> f (g x)这么麻烦,直接用f . g就可以了
如下:
```
ghci> map (\x -> negate (abs x)) [5,-3,-6,7,-3,2,-19,24]
[-5,-3,-6,-7,-3,-2,-19,-24]
ghci> map (negate . abs) [5,-3,-6,7,-3,2,-19,24]
[-5,-3,-6,-7,-3,-2,-19,-24]
ghci> map (\xs -> negate (sum (tail xs))) [[1..5],[3..6],[1..7]]
[-14,-15,-27]
ghci> map (negate . sum . tail) [[1..5],[3..6],[1..7]]
[-14,-15,-27]
```
```
sum (replicate 5 (max 6.7 8.9))
(sum . replicate 5) max 6.7 8.9
sum . replicate 5 $ max 6.7 8.9
```

Function Composition是右结合(f . g . h即\x -> f((g . h) x)),
可以使代码更清晰更简洁,相当于用一些函数生成了新的函数,与惰性求值结合将多遍求值化为一遍求值,
如list的处理

#### Point-Free Style
```haskell
sum' :: (Num a) => [a] -> a
sum' xs = foldl (+) 0 xs
```
可以把xs约掉,化简为
```haskell
sum' :: (Num a) => [a] -> a
sum' = foldl (+) 0
```
另例
fn x = ceiling (negate (tan (cos (max 50 x))))
化简为:
fn = ceiling . negate . tan . cos . max 50
Function Composition改变了我们的思维方式
从围绕数据转变为围绕函数

## 副作用都封装在IO类型里

分离副作用的代码和纯粹的代码
不是告诉计算机第一步做什么第二步做什么,而是告诉计算机各种定义和规则
函数不允许有副作用,无法想像一个加法的函数里嵌入了一个打开洗衣机的api调用,不知道的人以为只是加法,调了几次之后发现家养的猫死在洗衣机里

## random
erlang在进程字典里记了random状态
每次调用random:uniform()返回值都不同,这当然违反了函数式的要旨引用透明

System.Random库里的
random :: (RandomGen g, Random a) => g -> (a, g)
RandomGen: 随机种子
Random: 随机值,可以是Bool, Int, String等

mkStdGen函数用于手动得到一个随机种子
```
ghci> random (mkStdGen 100) :: (Int, StdGen)
(-1352021624,651872571 1655838864)
ghci> random (mkStdGen 100) :: (Int, StdGen)
(-1352021624,651872571 1655838864)
两次执行结果是一样的
ghci> random (mkStdGen 949494) :: (Int, StdGen)
(539963926,466647808 1655838864)
换一个随机种子结果变化
ghci> random (mkStdGen 949488) :: (Float, StdGen)
(0.8938442,1597344447 1655838864)
ghci> random (mkStdGen 949488) :: (Bool, StdGen)
(False,1485632275 40692)
```
帅呆了,可以直接获得各种类型的随机值

取指定范围的随机数并返回新的随机种子
```
ghci> randomR (1,6) (mkStdGen 359353)
(6,149428957840692)
ghci> randomR (1,6) (mkStdGen 35935335)
(3,125003105740692)
```

System.Random库的函数getStdGen, 类型IO StdGen, 从全局变量里取随机种子
newStdGen函数更新全局变量的随机种子

取a-z范围内的20个随机值
```
import System.Random
main = do
    gen <- getStdGen
    putStrLn $ take 20 (randomRs ('a','z') gen)
```
```
$ ./random_string
pybphhzzhuepknbykxhe
```
haskell生成随机数都要求以参数形式传入种子,
这样有利于测试,得到与当时相同的随机结果以重现问题,同时不违背引用透明

## lazy io

## pattern matching 模式匹配

### As-pattern
```
firstLetter :: String -> String
firstLetter "" = "Empty string, whoops!"
firstLetter all@(x:xs) = "The first letter of " ++ all ++ " is " ++ [x]
```
类似于erlang的
```
firstLetter([]) -> "Empty string, whoops!"
firstLetter([H|T] = All) -> "The first letter of " ++ All ++ " is " ++ [H]
```

## Guards
```
bmiTell :: Double -> Double -> String
bmiTell weight height
    | bmi <= skinny = "You're underweight, you emo, you!"
    | bmi <= normal = "You're supposedly normal. Pffft, I bet you're ugly!"
    | bmi <= fat = "You're fat! Lose some weight, fatty!"
    | otherwise = "You're a whale, congratulations!"
    where bmi = weight / height ^ 2
          skinny = 18.5
          normal = 25.0
          fat = 30.0
```

### where子句里定义函数
```
calcBmis :: [(Double, Double)] -> [Double]
calcBmis xs = [bmi w h | (w, h) <- xs]
    where bmi weight height = weight / height ^ 2
```
where子句不是表达式

### let

let内定义的变量, 其作用域只在let表达式内, 不包含guard
```haskell
cylinder :: Double -> Double -> Double
cylinder r h =
    let sideArea = 2 * pi * r * h
        topArea = pi * r ^ 2
    in sideArea + 2 * topArea
```
let语句是表达式, 例如
```haskell
ghci> 4 * (let a = 9 in a + 1) + 2
42
ghci> (let a = 100; b = 200; c = 300 in a*b*c, let foo="Hey "; bar = "there!" in foo ++ bar)
(6000000,"Hey there!")
```
```haskell
calcBmis :: [(Double, Double)] -> [Double]
calcBmis xs = [bmi | (w, h) <- xs, let bmi = w / h ^ 2]
```

### if
if是表达式(expression),必须有返回值,而不是语句(statement)
所以必须有else
```haskell
doubleSmallNumber x = if x > 100
                      then x
                      else x*2
```

### case
```haskell
case expression of pattern -> result
                   pattern -> result
                   pattern -> result
                   ...
```

### recursive 递归
类似erlang

## 与erlang的不同                                                                
没有原子
元组最多62元素,erlang无此限制
有Bool类型,不像erlang用两个原子做 
有Char类型,表示一个Unicode字符,erlang没有
提供有边界的Int类型(机器字长度),另有Integer与erlang的int相同
guards等语法有缩进要求

## 总结
Haskell程序通常会比其他语言短,                                                   
程序短的程序可读性强,可维护性会好,bug也会少    

## 业界
Concurrent Haskell, 借鉴erlang                                                   
Yesod, 做网站                                                                    
Industrial Haskell网站                                                               
金融系统

