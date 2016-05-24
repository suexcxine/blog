title: firewalld
date: 2016-01-21
tags: [linux, internet]
---
使用iptables, 与内核负责过滤包的Netfilter交互
firewalld的好处:
* 支持动态更新, 不用重启服务
* zone概念, 相当于预定义规则, 使用方便
<!--more-->

## 安装firewalld
yum install firewalld
yum install firewall-config

## 启动和关闭firewalld
systemctl start firewalld
systemctl stop firewalld

## 检测firewalld状态
systemctl status firewalld
firewall-cmd --state

## 开机自启
systemctl enable firewalld
systemctl disable firewalld

## zone
firewall可以把网络隔离为几个不同的zone, 每个interface都属于一个zone, 
/etc/firewalld/下的zone配置文件里有如下几个预定义的zone,
* drop 扔掉所有进来的packet, 不发送应答, 只允许出去的网络连接
* block 所有进来的连接都被拒绝,应答为IPv4: icmp-host-prohibited, IPv6: icmp6-adm-prohibited, 只允许内部发起连接
* public 适用于公共领域(即警戒姿态, 不相信网络里的其他电脑), 只有选中的进来的连接才能被接受
* external 适用于外部网络, 对router自动伪装(masquerading), 只有选中的进来的连接才能被接受
* dmz 适用于可以有限访问内部网络的对外开放的网络, 只有选中的进来的连接才能被接受
* work 适用于公司的网络, 只有选中的进来的连接才能被接受	
* home 适用于家里的网络, 只有选中的进来的连接才能被接受
* internal 适用于内部网络, 只有选中的进来的连接才能被接受
* trusted 接受所有连接

## 配置
gui下拉框选项runtime和permanent
runtime: 每一个修改都立即生效, 要小心对其他用户的影响
permanent: 下次(restart, reload)生效

### 查看zone相关信息
firewall-cmd --get-active-zones
firewall-cmd --get-zones
firewall-cmd --get-zone-of-interface=eno16777736
firewall-cmd --zone=public --list-interfaces
firewall-cmd --zone=public --list-all

### 添加interface到zone
firewall-cmd --zone=public --add-interface=em1

### 绑定zone的源地址
firewall-cmd --zone=trusted --add-source=192.168.1.114/32

### 配置服务(service)
Ports and Protocols: 编辑协议类型和端口
Netfilter helper module:
Destination: 指定只允许到目标地址和协议类型(IPv4, IPv6)的流量

### 设置zone的service
firewall-cmd --zone=work --add-service=smtp
firewall-cmd --zone=work --remove-service=smtp

#### 通过编辑xml文件设置zone的service
如果/etc/firewalld/zones/下没有对应文件, 把默认文件cp过去
cp /usr/lib/firewalld/zones/work.xml /etc/firewalld/zones/
编辑/etc/firewalld/zones/work.xml
添加
```
<service name="smtp"/>
```

### 开放端口
对所有主机或网络开放指定协议(tcp, udp)的端口或端口范围
firewall-cmd --zone=dmz --add-port=8080/tcp
firewall-cmd --zone=dmz --add-port=5060-5061/udp
firewall-cmd --zone=dmz --remove-port=8080/tcp
firewall-cmd --zone=dmz --list-ports
注意这个命令不会显示以--add-services命令打开的端口

### 启用IP地址masquerade
将IPv4地址转换为指定的单一外部地址
firewall-cmd --zone=external --add-masquerade
firewall-cmd --zone=external --remove-masquerade
firewall-cmd --zone=external --query-masquerade

### 配置端口转发
需要启用masquerade, 仅限ipv4
firewall-cmd --zone=external --add-forward-port=port=22:proto=tcp:toport=3753
firewall-cmd --zone=external --add-forward-port=port=22:proto=tcp:toaddr=192.0.2.55
firewall-cmd --zone=external --add-forward-port=port=22:proto=tcp:toport=2055:toaddr=192.0.2.55

### 配置ICMP filter
选择想要过滤的ICMP消息
在Permanent模式下可编辑ICMP类型

## 使用命令行工具(CLI)firewall-cmd
使用--permanent选项持久化(除了--direct的,这种无法持久化), 没有--permanent选项的视为runtime修改,
runtime修改是临时修改, 在reload或restart后会丢失
如果需要立即生效又需要持久化, 执行两次命令, 一次带--permanent一次不带, 这样比--permanent然后reload要快
而且reload期间由于安全原因built-in chains会先被设为DROP,reload完成后再设为ACCEPT, 由此可能造成服务被打断

### 查service列表
显示/usr/lib/firewalld/services/以及当前加载的自定义服务/etc/firewalld/services/, xml文件名必须是servicename.xml
firewall-cmd --get-services
要包含未加载的自定义服务, 可以
firewall-cmd --permanent --get-services

### panic mode
firewall-cmd --panic-on
firewall-cmd --panic-off
firewall-cmd --query-panic
启用时打印yes返回0,否则打印no返回1
如果panic模式持续时间不长, 已有的连接可能还可以继续工作

### reload
firewall-cmd --reload

如果想要重新加载并打断用户连接, 放弃状态信息, 使用如下命令
这条命令只应在出现严重的防火墙问题时才使用, 比如防火墙规则没问题但是无法建立连接
firewall-cmd --complete-reload

### 修改默认zone
firewall-cmd --set-default-zone=public
不需要reload
或编辑
/etc/firewalld/firewalld.conf
```none
# default zone
# The default zone used if an empty zone string is used.
# Default: public
DefaultZone=home
```
然后reload
firewall-cmd --reload

## 使用XML文件配置firewall
XML文件路径/etc/firewalld/
/usr/lib/firewalld/zones/下的文件不要编辑,它们只在/etc/firewalld/zones/下没有对应文件时作为默认文件
可以直接创建和修改xml文件或者使用图形和命令行工具间接创建和修改
可以使用RPM文件分发配置文件以方便管理和版本控制, Puppet等工具可以用于分发这种配置文件

## --direct选项
如果不熟悉iptables, 使用--direct选项比较危险, 可能会给firewall打开一个裂口
该模式用于在运行时添加特殊的防火墙规则
通过firewall-cmd --permanent --direct命令或修改/etc/firewalld/direct.xml文件可以持久化

firewall-cmd --direct --add-rule ipv4 filter IN_public_allow 0 -m tcp -p tcp --dport 666 -j ACCEPT
firewall-cmd --direct --remove-rule ipv4 filter IN_public_allow 0 -m tcp -p tcp --dport 666 -j ACCEPT
firewall-cmd --direct --get-rules ipv4 filter IN_public_allow
注意--get-rules只能获取通过--add-rule加上的规则, 不会列出既存的通过其他方式添加的iptables规则

## Rich Language
firewall-cmd [--zone=zone] --add-rich-rule='rule' [--timeout=timeval]
firewall-cmd [--zone=zone] --remove-rich-rule='rule'
firewall-cmd [--zone=zone] --query-rich-rule='rule'
timeout选项表示仅在指定时间内有效(时间到即自动移除), 单位可以是s(秒), m(分)或h(时), 默认是秒
```none
rule [family="rule family"]
    [ source address="address" [invert="True"] ]
    [ destination address="address" [invert="True"] ]
    [ element ]
    [ log [prefix="prefix text"] [level="log level"] [limit value="rate/duration"] ]
    [ audit ]
    [ action ]
```
规则与zone关联, 一个zone可以有多条规则, 如果多条规则相关或冲突, 以第一条规则为准

## 获取帮助
man firewall-cmd 1
man firewalld.icmptype 5
man firewalld.service 5
man firewalld.zone 5
man firewalld.direct 5
firewall-cmd --version
firewall-cmd --help

## 参考链接
http://www.centoscn.com/CentOS/help/2015/0208/4667.html
https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Security_Guide/sec-Using_Firewalls.html

