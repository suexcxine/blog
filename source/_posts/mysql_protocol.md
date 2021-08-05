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

参考: https://dev.mysql.com/doc/internals/en/connection-phase-packets.html#packet-Protocol::HandshakeResponse

可以看到除了 capabilities_flags 和 max_packet_size 之外, 就只在末尾多了一个字段, 也就是 auth_plugin_name, 

值为 "mysql_native_password"

于是我把这个字段在 mysql-otp 也加上, 问题就解决了~

PR: https://github.com/mysql-otp/mysql-otp/pull/178

### HandshakeV10

从 mysql server 收到的 initial handshake packet

```erlang
<<
(10)(protocol version),
(53,46,55,46,50,56,45,108,111,103,0)(mysql version),
(207,125,157,32)(connection id),
(74,70,74,33,71,103,56,80)(auth-plugin-data-part-1),
(0)(filler),
(223,247)(capability flags lower 2 bytes),
(33)(character set),
(2,0)(status flags),
(15,1)(capability flags upper 2 bytes),
(21)(length of auth-plugin-data),
(0,0,0,0,0,0,0,0,0,0)(reserved),
(65,49,40,59,69,52,36,65,102,60,91,64,0)(auth-plugin-data-part-2),(109,121,115,113,108,95,110,97,116,105,118,101,95,112,97,115,115,119,111,114,100,0)(auth-plugin name)
>>
```

参考: https://dev.mysql.com/doc/internals/en/connection-phase-packets.html#packet-Protocol::Handshake

### capabilities flags

mysql-otp:

CLIENT_PROTOCOL_41, 16#00000200
CLIENT_TRANSACTIONS, 16#00002000
CLIENT_SECURE_CONNECTION, 16#00008000
CLIENT_CONNECT_WITH_DB, 16#00000008
CLIENT_MULTI_STATEMENTS, 16#00010000
CLIENT_MULTI_RESULTS, 16#00020000
CLIENT_PS_MULTI_RESULTS, 16#00040000
CLIENT_PLUGIN_AUTH, 16#00080000
CLIENT_LONG_PASSWORD, 16#00000001

myxql:

CLIENT_PROTOCOL_41, 16#00000200
CLIENT_TRANSACTIONS, 16#00002000
CLIENT_SECURE_CONNECTION, 16#00008000
CLIENT_CONNECT_WITH_DB, 16#00000008
CLIENT_MULTI_RESULTS, 16#00020000
CLIENT_PLUGIN_AUTH, 16#00080000
CLIENT_FOUND_ROWS, 16#00000002

主要相差 CLIENT_MULTI_STATEMENTS , 话说这个东西不怎么好, 还不如去掉呢

**To Be Continued**

