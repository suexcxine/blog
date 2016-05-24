title: 火狐+FoxyProxy Standard实现Chrome+SwitchyProxy的效果
date: 2015-07-24
tags: internet
---
### 下载FoxyProxy Standard插件并安装
https://addons.mozilla.org/en-us/firefox/addon/foxyproxy-standard/

### 配置
进入FoxyProxy的选项
* 代理服务器->新建一个使用SOCKS v5的代理服务器
* 将工作模块修改为"为全部Urls启动代理服务器XXXX",即使用全局模式,以便能下载(更新)gfwlist
* 模式订阅->添加新的模式订阅 Format: AutoProxy, Obfuscation: Base64
* 订阅网址 http://autoproxy-gfwlist.googlecode.com/svn/trunk/gfwlist.txt
* 为模式订阅选择代理服务器, 即跟上面的SOCKS v5代理绑定
* 将工作模式修改为"使用基于其预定义模板的代理服务器",实现需要的用代理,不需要的直接连
* 重启浏览器

