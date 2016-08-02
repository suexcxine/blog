title: go语言编码规范
date: 2016-08-02 22:30:00
tags: [go]
---

编码规范统一,很有必要

<!--more-->

* 注释要用完整的句子,以函数名开头,以逗号结束,这样比较好排,可读性也好,也方便grep文档.

* 定义空slice时,用var t []string而不是t := []string{},在这个slice不被append时,前者不占用内存.

* 导出函数均应有注释.

* error string不要以大写开头,除非是缩略词等,且不要以标点结束,以免printf时前面有大写时又出现多余的大写和标点位置不合适等情况.

* import . <packagename> 这种语法除了测试的场景以外不要用.

* 先写异常逻辑,后写正常逻辑,尽量不要让正常逻辑缩进,而让异常逻辑缩进,这样可读性好.方便阅读正常逻辑.
```
if err != nil {
    // error handling
    return // or continue, etc.
}
// normal code
```

* 尽量不要在if里赋值
```
if x, err := f(); err != nil {
    // error handling
    return
} else {
    // use x
}
```
改为
```
x, err := f()
if err != nil {
    // error handling
    return
}
// use x
```

* 缩略词要大小写一致,HTTP或http,不要Http, ServeHTTP而不是ServeHttp.

* 一行不要太长,没有严格标准,稍长一点可读性好时无须强行改短.

* 返回值参数命名,如果有相同类型的,最好命个名可读性好一些.

* 不使用裸return.

* 不大的参数尽量用值传递.

* receive命名,不要使用me,self,this等通用词,可读性不好,用一两字母,如c表示Client.

* receive type,大致上不变类型或基本类型用值类型,否则用指针类型.特殊情况除外.

* Test Case失败应该给出input,output和expect的值,要不然不明不白,先写output再写expect.
```
if got != tt.want {
    t.Errorf("Foo(%q) = %d; want %d", tt.in, got, tt.want)
}
```

* 变量名采用驼峰标准，不要使用_来命名变量名.

* 错误处理的原则就是不能丢弃任何有返回err的调用，不要采用_丢弃，必须全部处理.

## 参考链接
https://github.com/golang/go/wiki/CodeReviewComments

