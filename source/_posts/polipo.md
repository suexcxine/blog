title: polipo
date: 2016-08-07
tags: [internet, linux, proxy]
---

有时光有socks5代理还不行, 有些应用只认http代理,
无奈, socks5 -> http

<!--more-->

## 结合polipo将socks5转换成http代理                                              

    sudo apt-get install polipo                                                      
    sudo vim /etc/polipo/config 

配置如下:                                                                        

    logSyslog = true                                                                 
    logFile = /var/log/polipo/polipo.log                                                 
    socksParentProxy = "127.0.0.1:1080"                                              
    socksProxyType = socks5                                                          
    proxyAddress = "::0"        # both IPv4 and IPv6                                 
    # or IPv4 only                                                                   
    # # proxyAddress = "0.0.0.0"                                                     
    proxyPort = 8123  
启动, 最好不用sudo(基本原则,能不用root权限就不用root权限),

    polipo -c /opt/local/etc/polipo/config
使用浏览器可以访问如下页面, 测试polipo是否已启动                                 
http://localhost:8123/                                                           
测试是否可用                                                                     

    curl --proxy http://127.0.0.1:8123 https://www.google.com  
其他使用方法                                                                     

    http_proxy=http://localhost:8123 apt-get update                                  
    http_proxy=http://localhost:8123 curl www.google.com                             
    http_proxy=http://localhost:8123 wget www.google.com                             
    git config --global http.proxy 127.0.0.1:8123                                    
    git clone https://github.com/xxx/xxx.git                                         
    git xxx                                                                          
    git xxx                                                                          
    git config --global --unset-all http.proxy  
重启                                                                             

    sudo service polipo restart  
帮助                                                                             

    man polipo 

## 手动编译

编译后在后台启动
```
$ sudo polipo daemonise=true logFile="/var/log/polipo.log"
```

## 参考链接
https://github.com/jech/polipo/blob/master/INSTALL
https://github.com/shadowsocks/shadowsocks/wiki/Convert-Shadowsocks-into-an-HTTP-proxy

