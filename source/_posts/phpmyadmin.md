title: phpmyadmin
date: 2015-08-13
tags: [mysql, db, linux]
---
基于web的图形化mysql管理工具
<!--more-->
## 安装
```bash
sudo apt-get install phpmyadmin
```
系统默认安装在了/usr/share/下
到/var/www/html下建立一个软连接,指向/usr/share/phpmyadmin
```bash
sudo ln -s /usr/share/phpmyadmin phpmyadmin
```
打开浏览器进入
http://localhost/phpmyadmin

## 解决导航面板翻页问题
默认50张表导航面板就会翻页,在第1页的搜索框里搜不到第2页的表,影响工作效率
config.inc.php配置文件中加入以覆盖默认值,改为200条或更大
$cfg['MaxNavigationItems']=200

