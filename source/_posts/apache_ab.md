title: apache ab
date: 2016-06-06 17:07:00
tags: [internet, test]
---

压力测试常用工具, apache bench
下例, 模拟1500并发连接, 3000次请求
```
apt-get install apache2-utils
ab -n 3000 -c 1500 -w http://blog.suexcxine.cc/ >> 1.html
```

