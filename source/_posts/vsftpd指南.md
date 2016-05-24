title: vsftpd指南
date: 2015-07-23
tags: [linux, ftp]
---
vsftpd: very secure ftp daemon
<!--more-->
### 安装vsftpd
```bash
$ sudo apt-get install vsftpd
```

### 虚拟用户配置
创建虚拟用户数据库
```bash
$ sudo mkdir /etc/vsftpd
$ cd /etc/vsftpd
$ sudo vi vusers.txt
```
输入以下内容:
> vivek
> vivekpass
> sayali
> sayalipass

```bash
$ sudo apt-get install db-util
$ sudo db_load -T -t hash -f vusers.txt vsftpd-virtual-user.db 
$ sudo chmod 600 vsftpd-virtual-user.db
$ sudo rm vusers.txt
$ sudo vi /etc/vsftpd.conf
```
输入以下内容:
> anonymous_enable=NO
> local_enable=YES
> write_enable=YES 
> virtual_use_local_privs=YES
> pam_service_name=vsftpd.virtual
> guest_enable=YES
> user_sub_token=$USER
> local_root=/home/vftp/$USER
> chroot_local_user=YES
> force_dot_files=YES
> hide_ids=YES

$ sudo vi /etc/pam.d/vsftpd.virtual
输入以下内容:
```
#%PAM-1.0
auth       required     pam_userdb.so db=/etc/vsftpd/vsftpd-virtual-user
account    required     pam_userdb.so db=/etc/vsftpd/vsftpd-virtual-user
session    required     pam_loginuid.so
```
创建ftp使用的目录
```bash
$ sudo mkdir /home/vftp
$ sudo mkdir -p /home/vftp/{vivek,sayali}
$ sudo chown -R ftp:ftp /home/vftp
```

### 查看/etc/ftpusers
如有vftp则去掉, 这个文件存的是黑名单

### 重启FTP服务器
> $ sudo service vsftpd restart
> vsftpd stop/waiting
> vsftpd start/running, process 7482

### 测试ftp连接
> $ ftp localhost
> Connected to localhost.
> 220 Welcome to suex FTP service.
> Name (localhost:chenduo): sayali
> 331 Please specify the password.
> Password:
> 230 Login successful.
> Remote system type is UNIX.
> Using binary mode to transfer files.
> ftp> 

### 解决问题: 500 OOPS: vsftpd: refusing to run with writable root inside chroot()
* /etc/vsftpd.conf文件中添加一行: allow_writeable_chroot=YES
* 或者也可以用命令sudo chmod a-w /home/vsftp/vivek去除用户根目录的写权限, 
  并在vivek文件夹下再建子文件夹(这个要有w权限)让用户写

### TLS/SSL/FTPS
如果你是从Internet连接到你的服务器，必须确定使用这个，否则密码会有明文传输等安全问题。
让vsftpd使用加密（更安全），修改或添加下列选项（某些选项不在原始配置文件中，需要添加）
在/etc/vsftpd.conf文件中加入如下配置:
> ssl_enable=YES
> allow_anon_ssl=NO
> force_local_data_ssl=YES
> force_local_logins_ssl=YES
> ssl_tlsv1=YES
> ssl_sslv2=YES
> ssl_sslv3=YES

使用Filezilla客户端时，使用加密"FTPES - FTP over explicit TLS/SSL"选项，以使用TLS/SSL/FTPS连接到你的服务器。

