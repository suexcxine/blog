title: erlang点滴
date: 2018-06-01
tags: [erlang]
---
这里记录一些点滴知识
<!--more-->

### PROGRESS REPORT 这种日志怎么关掉

sys.config里加上如下内容
```
    {sasl, [
        {errlog_type, error}
    ]}
```

