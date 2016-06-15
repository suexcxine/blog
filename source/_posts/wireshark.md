title: wireshark interface list为空的问题
date: 2016-06-15 15:31:00
tags: [internet, linux]
---

执行以下命令并重启
```
sudo dpkg-reconfigure wireshark-common 
sudo usermod -a -G wireshark $USER
```

## 参考链接
http://stackoverflow.com/questions/8255644/why-doesnt-wireshark-detect-my-interface

