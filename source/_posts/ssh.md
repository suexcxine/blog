title: ssh
date: 2015-08-03
tags: [internet, linux]
---
## 安装
sudo apt-get install openssh-server
sudo service ssh start
验证服务是否已启动
ps -e | grep ssh
<!--more-->
## 配置
/etc/ssh/sshd_config

不允许使用密码登录
PasswordAuthentication no

是否允许Root登录(no不允许, without-password不允许密码登录, yes允许密码登录)
PermitRootLogin without-password
默认是yes, 建议改成without-password或者no(先用别的用户登进去然后再切换到root)

重启服务或重新加载配置文件
sudo service ssh restart
或
sudo service ssh reload

## 客户端生成密钥
ssh-keygen -t rsa

## 服务端加入公钥
在.ssh目录下创建authorized_keys文件,加入Client端的公钥内容
修改权限
chmod 600 authorized_keys
要允许哪个用户登录就在哪个用户的home目录下的.ssh目录里的authorized_keys加上对应的公钥, 
如果要允许ssh登录root,则需要在/root/.ssh/authorized_keys里加上对应的公钥
ssh-copy-id -i ~/.ssh/id_rsa.pub username@hostname -p port

## 客户端登录
ssh username@192.168.1.112
省略username也可以,好像是以当前用户名登录
ssh 192.168.1.112

## 反向隧道
autossh -M 3333 -f -NR 4444:localhost:22 username@host -p 5555
-M  指定monitor的端口
-f  后台运行
-N  ssh参数, Do not execute a remote command(比如在远程启动shell?).  This is useful for just forwarding ports (protocol version 2 only).
-R  ssh参数, [bind_address:]port:host:hostport, port填监听的远程端口,host和hostport填自己和自己的端口
其中22也可以是其他端口,比如80,或者任意其他的端口比如6789

查看反向隧道是否成功
<pre>
# netstat -onltp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State       PID/Program name    Timer
tcp        0      0 127.0.0.1:4444              0.0.0.0:*                   LISTEN      5310/sshd           off (0.00/0/0)
tcp        0      0 ::1:4444                    :::*                        LISTEN      5310/sshd           off (0.00/0/0)
</pre>

连接到发起反向隧道的机器
ssh username@127.0.0.1 -p 4444

## config
把一些参数放到config里, 方便平常输命令, config文件示例如下:
<pre>
contents of $HOME/.ssh/config
Host dev
    HostName dev.example.com
    Port 22000
    User fooey
Host github-project1
    User git
    HostName github.com
    IdentityFile ~/.ssh/github.project1.key
Host github-org
    User git
    HostName github.com
    IdentityFile ~/.ssh/github.org.key
Host github.com
    User git
    IdentityFile ~/.ssh/github.key
Host tunnel
    HostName database.example.com
    IdentityFile ~/.ssh/coolio.example.key
    LocalForward 9906 127.0.0.1:3306
    User coolio
</pre>

## 参考链接
http://nerderati.com/2011/03/17/simplify-your-life-with-an-ssh-config-file/
http://linux.die.net/man/1/ssh-copy-id
http://linux.die.net/man/5/ssh_config

