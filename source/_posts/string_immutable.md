title: 为什么在许多语言里, String类型都是immutable的?
date: 2016-08-21 13:24:00
tags: [cs]
---

String做成immutable的意义何在?
一句话回答: 为了安全, 并发和复用, 详情请入内

<!--more-->

# 安全

### hash中用做key

如果可变string做了hash的key, 以"a"为例,

1 hash表计算出"a"的hash值并存储"a"和对应的value,
2 之后这个"a"被修改成了"b"
3 其他代码以另一个"a"(原来那个"a"已经被改掉了)去hash表中取值,
hash表计算"a"的hash值找到了正确的位置, 但是当比较key时, 发现"a" != "b", 于是取不到值...

### set

假设String是可变的,那么下面的代码
HashSet<String> set = new HashSet<String>();
set.add(new String("a"));
set.add(new String("b"));
set.add(new String("c"));

for(String a: set)
    a.value = "a";
将会使得Set中出现重复, 违背了Set的本义

### security

网络连接,文件操作中,如果string可以被修改,那么可能某函数以为它操作的对象是XXX,但是其实不是,因为被改了(比如黑客改了),导致安全问题
如下:
boolean connect(string s){
    if (!isSecure(s)) {
        throw new SecurityException();
    }
    // here will cause problem, if s is changed before this by using other references.
    causeProblem(s);
}

# 并发(Thread Safe)

因为不会被改变, 可以在线程中共享, 而无须加锁,
更新这个值其实是整个读出来, 在另一个地方做运算, 最后用整个新值替换原值,
所以不会出现中间状态, 于是无须用锁等同步手段来保护中间状态不被其他线程看到

而如果是可变类型的话, 则程序员很可能会把中间状态写回同一个内存地址,
导致中间状态被其他线程看到, 于是需要用锁等同步手段

所以关键点就是中间状态会不会被其他代码看到

另外还有一种情况:
有字符串"abc", 和一个去掉字符串首字母的函数, 两个线程几乎同时执行这个函数
那么即使是immutable string, 也有可能两个函数都读到"abc"并写回"bc", 而正确结果应该是"c"
这种情况还是要加锁

而actor模型能够保证这种情况也不出问题,
字符串"abc"存在一个actor中, 另外两个actor给这个actor发消息,
这个actor顺序处理这两条消息

# 复用

JVM用String常量池实现String的复用, 下次用到时省得分配内存,
由于一个String常量可能被多个变量名引用, 所以不能允许String被修改, 否则就影响到其他引用该String的变量了,
也因此String类还被标记为final, 不允许修改其行为

erlang里的值也可以因immutable而省内存, 如A = [1,2,3], B = A, C = [4|B] 这种情况,
内存里其实只有[1,2,3]和连到[1,2,3]上的4, 而不是两份[1,2,3]和一份[4,1,2,3], 也就是说[1,2,3]被三个变量共用, 节省了内存

# 杂谈

有人说String a = "a";之后可以a = "b";修改
这里其实string没有被修改, 只是a这个引用改了而已, 指向新的"b"字符串了
虽然String是immutable的, 但是引用的变量不是immutable的, 其实a是个内存地址嘛

erlang里就没有这个问题, A = "a"之后, 不能再A = "b", 编译不过

