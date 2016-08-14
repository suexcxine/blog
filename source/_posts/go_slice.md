title: go语言 array与slice
date: 2016-08-14 21:27:00
tags: go
---

深入看一下这两个家伙...

<!--more-->

### 长度与类型
array的长度是类型的一部分,即长度不同的array不是一个类型,
slice的类型则不包含长度

    var a [4]int // 这样就分配了4个int的内存空间,
    var b []int // 这是个nil的slice类型,没有分配内存

array是immutable值类型
slice不是

### 字面值

array字面值

    b := [2]string{"Penn", "Teller"}
    b := [...]string{"Penn", "Teller"}
    s := b[:] // s引用b这个array
    // 上面相当于s := []string{"Penn", "Teller"}

slice字面值, 先分配一个array然后再引用这个array

    letters := []string{"a", "b", "c", "d"}

### make

make分配一个数组的内存和一个引用这个数组的slice并返回

    var s []byte
    s = make([]byte, 5, 5)
    // 相当于s == []byte{0, 0, 0, 0, 0}

对于nil的slice,len和cap函数都返回0
var p []int, 这种写法没有分配内存, 但是对这个p执行append是支持的, 所以推荐先这样定义p, 之后用for之类的赋值,
如果for一次也没有执行,就省了内存了, 因为p := []int{}这样是要分配内存的
https://github.com/golang/go/wiki/CodeReviewComments#declaring-empty-slices

slice内部包含一个指向array某一个元素的指针和长度
以及以此元素为起点的cap值. 类似于type Slice struct { p, len, cap }这种感觉
所以len(slice)不需要遍历,是O(1)的

可以像下面这样将slice扩展到末尾

    s = s[:cap(s)]

### append函数

循环append时要小心,如果次数很多数量很大的话,可能会产生特别多内存碎片并都成为垃圾,
加重gc负担,并且内存分配也很费,而且*2的扩展逻辑也可能造成最后一次分配了过多的内存.
所以如果预先知道有多少元素或大概知道,最好在make的时候就指定好,性能差异很大.

    file, err := os.Open("itsover.9000")
    if err != nil { ..handle .. }
    defer file.Close()
    stat, _ := file.Stat()
    bytes := make([]byte, stat.Size())
    file.Read(bytes)

### copy函数

append里用到的copy内建函数

    func copy(dst, src []T) int

copy函数会考虑长度,不会越界访问,可以安心

### 当slice很小而背后的array很大,觉得浪费内存的时候

array只要还被引用就不会被gc, 所以有时候像下面这样做省点内存

    func CopyDigits(filename string) []byte {
        b, _ := ioutil.ReadFile(filename)
        b = digitRegexp.Find(b)
        // 这种情况下b很小而背后的array(整个文件)很大, 像下面这样弄一个新数组返回
        return append(make([]byte, 0), b...)
    }
