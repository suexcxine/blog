title: ssl
date: 2016-03-09
tags: [internet]
---

SSL(Secure Sockets Layer 安全套接层), 及其继任者传输层安全（Transport Layer Security，TLS）
是为网络通信提供安全及数据完整性的一种安全协议。TLS与SSL在传输层对网络连接进行加密。
<!--more-->

## CA
CA(certificate authority), 数字证书授权机构

## 根证书
根证书是未被签名的公钥证书或自签名的证书，是CA认证中心给自己颁发的证书，是信任链的起始点。安装根证书意味着对这个CA认证中心的信任。

## 证书链
A信任B,B信任C,C信任D,...这就是证书链

在互联网上使用的SSL服务器证书需要第三方机构签署。但是证书签署机构不一定会用它的根证书签署你的证书。
如使用GeoTrust SSL CA签署的二级证书(intermediate certificate)，签署该证书的是GeoTrust Global CA。
这个根证书是大多数浏览器很操作系统所信任的。一般而且多数浏览器和服务器并不保存二级证书。如果二级证书没有传到客户端，就无法验证服务器证书的有效性。只有把二级证书也传递到客户端，通过客户端信任GeoTrust Gloabal CA，GeoTrust Global CA信任GeoTrust SSL CA，而Geo SSL CA又信任你的SSL证书构建起的证书的信任链。由此可见，只要服务器证书不是用根证书签署的，就必须让服务器把二级证书也传输到客户端。
在配置服务器传输证书链而非单个证书之前需要生成证书链文件，也可以从CA那里获得。该文件是一些以pem格式的证书文件按照从服务器证书到根证书的顺序叠加在一起。

## ubuntu下根证书信任操作
/etc/ssl/certs/ca-certificates.crt文件保存了所有根证书

添加受信任的根证书
sudo cp yourcrt.crt /usr/local/share/ca-certificates
sudo update-ca-certificates

删除受信任的根证书
编辑 /etc/ca-certificates.conf 文件
使用前缀!号表示不信任,或干脆删除那一行
sudo update-ca-certificates

## nginx配置https
安装
yum install nginx

启动nginx
/etc/init.d/nginx start

测试
curl localhost:80
或者在浏览器上输入ip地址或域名测试

添加域名解析
通过startssl验证域名, 获取证书

使用在startssl设定的密码将已加密的私钥解开,得到私钥
openssl rsa -in ssl.key -out ssl.key

从startssl下载crt bundle, 
将crt和key文件配置到nginx
如:
```
server {
    listen       443;
    server_name  yourdomain;

    ssl                  on;
    ssl_certificate      yourcrt.crt;
    ssl_certificate_key  yourkey.key;
}
```
重新加载配置
/etc/init.d/nginx reload

在浏览器上输入https://yourdomain测试https是否配置成功

到下面的网站验证服务器的安全性
https://www.ssllabs.com

## 安装 Let’s Encrypt 客户端
记住要在服务器(提供nginx服务的机器)上安装
装前准备，更新系统和安装 git & bc：
apt-get update
apt-get -y install git bc
克隆 Let’s Encrypt 到  /opt/letsencrypt:
git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt

## 获取证书
首先关闭 Nginx：
service nginx stop

并且检查一下 80 端口没有被占用：
netstat -onltp | grep ':80.*LISTEN'

运行 Let’s Encrypt:
cd /opt/letsencrypt
./letsencrypt-auto certonly --standalone

注意：Let’s Encrypt 需要超级用户权限，如果你没有使用 sudo 命令，可能会让你输入密码。

之后会出现图形界面输入邮箱、条款、域名等信息
支持多域名，只需要用空格或者英文逗号分隔就好了。

签发的证书位于 /etc/letsencrypt，注意备份。

如果使用国内 VPS，此处可能会由于 DNS 问题出错，可以尝试更换 VPS 的 DNS 为第三方，比如 8.8.8.8。

每一个域名都会自动生成四个文件，位于 /etc/letsencrypt/archive/domain 目录下：
cert.pem: 域名证书
chain.pem: The Let’s Encrypt 证书
fullchain.pem: 上面两者合体
privkey.pem: 证书密钥

## 配置 Nginx
有了域名证书，就开始配置 Nginx 了。

打开对应网站的配置文件，一般在 /etc/nginx/sites-available/default 或者 /usr/local/nginx/conf/ 中，试你自己的情况。
```
server {
    listen 443 ssl;
    server_name your_domain_name;
    …
    
    ssl on;
    ssl_certificate /etc/letsencrypt/live/your_domain_name/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your_domain_name/privkey.pem;
    
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
    
    …
}
```
如果你想开启全站 https，需要将 http 转向到 https，再添加一个 server 就好了：

```
server {
    listen 80;
    server_name your_domain_name;
    return 301 https://$host$request_uri;
}
```
注意以上配置文件需要根据实际情况修改。
保存，重启 Nginx
service nginx restart

此时，打开你的域名比如 https:// 就能看到绿色的地址栏了。

## 自动续签证书
Let’s Encrypt 证书只有 90 天的有效期，这和之前按年使用的商业证书有些区别，
所以我们还需要设置自动续签，好让证书一直有效。

安装 Webroot 插件
这是一个可以不用停止 Web 服务就能让 Let’s Encrypt 验证域名的插件，再次打开 Nginx 配置文件，在 ssl 下面添加：
```
location ~ /.well-known {
    allow all;
}
```
保存。

使用命令行续签证书
```
cd /opt/letsencrypt
./letsencrypt-auto certonly -a webroot --agree-tos --renew-by-default --webroot-path=/usr/share/nginx/html -d example.com -d www.example.com
```
注意修改 webroot-path 参数，这是你的网站路径。
重新加载 Nginx 配置文件。
service nginx reload

创建  Let’s Encrypt 续签配置文件
cp /opt/letsencrypt/examples/cli.ini /usr/local/etc/le-renew-webroot.ini

我们将直接编辑示例配置文件：
vi /usr/local/etc/le-renew-webroot.ini

修改以下几行：
```
rsa-key-size = 4096
email = you@example.com
domains = example.com, www.example.com
webroot-path = /usr/share/nginx/html
```

于是可以使用配置文件续签证书
cd /opt/letsencrypt
./letsencrypt-auto certonly -a webroot --renew-by-default --config /usr/local/etc/le-renew-webroot.ini

下载续签脚本并设置权限：
```
curl -L -o /usr/local/sbin/le-renew-webroot https://gist.githubusercontent.com/thisismitch/e1b603165523df66d5cc/raw/fbffbf358e96110d5566f13677d9bd5f4f65794c/le-renew-webroot
chmod +x /usr/local/sbin/le-renew-webroot
```
注意：确保上一步创建的 续签配置文件 /usr/local/etc/le-renew-webroot.ini 存在，否则脚本将无法运行。
试运行脚本：
le-renew-webroot

创建定时任务：
crontab -e
添加下面一行，让每周一早上 2 点 30 分运行一次，并记录到日志文件中。
30 2 * * 1 /usr/local/sbin/le-renew-webroot >> /var/log/le-renewal.log

## 什么是ACME?
The Automated Certificate Management Environment (ACME) protocol 
is a communications protocol for automating interactions between certificate authorities and their users' web servers, 
allowing the automated deployment of public key infrastructure at very low cost. 
It was designed by the Internet Security Research Group for their Let's Encrypt service.

## 遇到过的问题

有一次从网上下载一个数字证书, 以为下下来了, 结果下的是一个html, 但是文件名却是对的, xxx.crt
将xxx.crt添加到/usr/local/share/ca-certificates并update-ca-certificates后
git命令出现了如下错误:
$ git pull
fatal: unable to access 'https://github.com/erlang/otp.git/': Problem with the SSL CA cert (path? access rights?)
多方找解决方案而不得, 最后发现/etc/ssl/certs/ca-certificates.crt文件里有一大堆html, 
删掉那些html代码后恢复正常

## 参考链接
https://program-think.blogspot.com/2010/02/introduce-digital-certificate-and-ca.html
https://www.evssl.cn/ev-ssl-ask/122.html
https://support.ssl.com/Knowledgebase/Article/View/19/0/der-vs-crt-vs-cer-vs-pem-certificates-and-how-to-convert-them
https://en.wikipedia.org/wiki/Automated_Certificate_Management_Environment
https://letsencrypt.org/getting-started/
https://letsencrypt.org/how-it-works/
https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-14-04
https://www.ssllabs.com/
http://nginx.org/en/docs/http/configuring_https_servers.html
http://schnell18.iteye.com/blog/2048296
http://chenling1018.blog.163.com/blog/static/1480254201058112410789/
http://www.appinn.com/use-letsencrypt-with-nginx/

