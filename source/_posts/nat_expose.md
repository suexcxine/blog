title: 内网穿透
date: 2018-09-13
tags: [linux, nat, ssh]
---

用于在家办公访问公司内网等场景
<!--more-->

在内网机器如下创建文件 /etc/systemd/system/autossh.service 并将权限设置为644
```
[Unit]
Description=Auto SSH Tunnel
After=network-online.target

[Service]
User=username
Type=simple
ExecStart=/usr/local/bin/autossh -p 22 -o "ServerAliveInterval 60" -o "ServerAliveCountMax 6" -M 0 -NR '*:6766:localhost:22' servercloud
ExecReload=/usr/bin/kill -HUP $MAINPID
KillMode=process
Restart=always

[Install]
WantedBy=multi-user.target
```

在内网机器启动autossh(自定义)服务
```
sudo systemctl start autossh
```

如下可以通过外网服务器直接连到内网服务器
```
ssh -p 6766 username@servercloud
```

## 参考链接
http://arondight.me/2016/02/17/%E4%BD%BF%E7%94%A8SSH%E5%8F%8D%E5%90%91%E9%9A%A7%E9%81%93%E8%BF%9B%E8%A1%8C%E5%86%85%E7%BD%91%E7%A9%BF%E9%80%8F/
http://www.cnblogs.com/starof/p/4709805.html
https://www.jianshu.com/p/a9a2344e0c6d

