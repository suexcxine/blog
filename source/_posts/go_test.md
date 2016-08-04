title: go语言测试
date: 2016-08-04 22:30:00
tags: [go]
---

* 使用_test做为包名做黑盒测试, 使用import . xxx导入要测试的包, 有时为了打破循环引用也需要用这种方式
* t.Skip(), 当检测到有些测试条件不满足时(比如外部依赖,环境变量没设等情况)可以跳过这个case
* go test -short, TestCase里用testing.Short判断用户使用了-short参数时,可以做判断跳过耗时的case
* go test -timeout 1s, 指定耗时, 超时就失败
* go test -run TestNameRegexp 只执行指定的测试用例
* t.Parallel() 标记为可以并行测试, 在Test case函数体一开始就调用

## 参考链接
https://splice.com/blog/lesser-known-features-go-test/

