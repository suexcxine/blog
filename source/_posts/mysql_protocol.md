title: mysql protocol
date: 2021-08-03

tags: [mysql, erlang]
---

使用 polardb 时, 遇到 erlang 的 driver 无法连上 polardb 的集群地址(是个 proxy)的问题,

不得不走上了读 mysql protocol 的不归路..

<!--more-->

### 问题解决过程

我们使用的是 mysql-otp 这个 driver, 在试了 myxql 之后发同 myxql 是可以连上 polardb 的 proxy 的

于是详细对比了一下两个 driver 发出的 handshake 的内容到底哪里不同

mysql-otp:

```erlang
<<
(9,162,15,0)(capabilities_flags),
(0,0,0,1)(max_packet_size, 16777216, litter endian),
(45)(character set),
(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)(reserved required by mysql),
(116,101,115,116,0)(user name: test, null terminated),
(20)(length of hashed password),
(240,217,6,18,194,115,215,166,255,68,229,72,170,23,127,2,123,170,124,121)(hashed password),
(116,101,115,116,0)(database name: test, null terminated)
>>
```

myxql:

```erlang
<<
(10,162,10,0)(capabilities_flags),
(255,255,255,0),
(45),
(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
(116,101,115,116,0),
(20),
(66,23,96,57,142,116,57,159,164,213,252,38,94,85,123,211,156,59,118,170),(116,101,115,116,0),
(109,121,115,113,108,95,110,97,116,105,118,101,95,112,97,115,115,119,111,114,100,0)
>>
```

可以看到除了 capabilities_flags 和 max_packet_size 之外, 就只在末尾多了一个字段, 也就是 auth_plugin_name, 

值为 "mysql_native_password"

于是我把这个字段在 mysql-otp 也加上, 问题就解决了~

PR: https://github.com/mysql-otp/mysql-otp/pull/178



**To Be Continued**

## 参考链接

https://dev.mysql.com/doc/internals/en/connection-phase-packets.html#packet-Protocol::HandshakeResponse