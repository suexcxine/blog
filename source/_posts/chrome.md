title: chrome
date: 2016-01-05
tags: [web]
---

## 快捷键
C-w             关闭当前标签页,
C-M-t           重新打开关闭的标签页
C-t             打开新标签页
C-M-点击链接    打开并切换到新标签页
C-1至8          切换到指定编号的标签页
C-9             切换到最后一个标签页

## 开发者工具

下面这个输入地址栏可以看到网络交互

    chrome://net-internals/#events

如果需要在打开新tab时trace network, 先在console里执行下面的语句
就可以不打开新tab了

    [].forEach.call(document.querySelectorAll('a'),
        function(link){
            if(link.attributes.target) {
                link.attributes.target.value = '_self';
            }
        });
    window.open = function(url) {
        location.href = url;
    };

## 参考链接
http://stackoverflow.com/questions/16210468/chrome-dev-tools-how-to-trace-network-for-a-link-that-opens-a-new-tab

