title: HTML <script> defer 属性
date: 2016-06-14 19:19:00
tags: [html, javascript, web]
---

自己搭建的博客使用了swiftype之后, 有些css的渲染经常中断, 具体是博文的标签没显示出来
查了半天, 貌似是swiftype加载过程会中断页面渲染,
找到一个defer属性, 要求必须和src属性配合着用,
于是又把swiftype提供的<script>内嵌代码移到一个单独的js文件中,
使用src属性引用, 即如下这样:
```
<script defer src="/js/swiftype.js" type="text/javascript"></script>
```

这么改完之后情况好多了, 基本没再出现标签显示不出来的问题了

