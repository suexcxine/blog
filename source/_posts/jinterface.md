title: jinterface
date: 2021-08-01 12:00:00

tags: [java, jinterface, erlang]
---

今天试一把传说中的 jinterface 是什么感觉

能让 Java 模拟一个 erlang 结点与 erlang 结点用 erlang 的模式通信

<!--more-->

## 效果展示

先启动 java 侧(使用 -DOtpConnection.trace=4 开启了最高级别的调试日志)

```shell
$ java -DOtpConnection.trace=4 -cp .:/Users/chenduo/erls/23.3/lib/jinterface-1.11.1/priv/OtpErlang.jar JNodeServer.java
-> PUBLISH (r4) j1@127.0.0.1 port=49304
<- OK
Started node: #Pid<j1@127.0.0.1.1.0>
```

再启动 erlang 侧并发出请求消息, 可以看到顺利拿到了结果

```shell
$ erlc jcomplex.erl
$ erl -name haha@127.0.0.1 -setcookie secret
Erlang/OTP 23 [erts-11.2] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Eshell V11.2  (abort with ^G)
(haha@127.0.0.1)1> jcomplex:foo(100).
{<9266.1.0>,101}
ok
(haha@127.0.0.1)2> jcomplex:bar(100).
{<9266.1.0>,200}
ok
```

java 侧也显示收到了消息 `{call,#Pid<haha@127.0.0.1.90.0>,{foo,100}}`, 并返回了`{#Pid<j1@127.0.0.1.1.0>,200}`, 如下

```
<- ACCEPT FROM com.ericsson.otp.erlang.OtpSocketTransport@1bec2ee2
<- HANDSHAKE ntype=110 dist=6 remote=haha@127.0.0.1
-> HANDSHAKE sendStatus status=ok local=j1@127.0.0.1
-> HANDSHAKE sendChallenge flags=50794388 challenge=1299681012 local=j1@127.0.0.1
<- HANDSHAKE recvChallengeReply from=haha@127.0.0.1 challenge=-618201795 digest=5197602eb7b83cf9c68dabe1c56db99c local=j1@127.0.0.1
-> HANDSHAKE sendChallengeAck digest=4db9c4ba35afc84d6eb858074681d700 local=j1@127.0.0.1
<- MD5 ACCEPTED 127.0.0.1
<- REG_SEND {6,#Pid<haha@127.0.0.1.90.0>,'',java}
   {call,#Pid<haha@127.0.0.1.90.0>,{foo,100}}
message: {#Pid<haha@127.0.0.1.90.0>, {foo, 100}}
-> SEND {2,'',#Pid<haha@127.0.0.1.90.0>}
   {#Pid<j1@127.0.0.1.1.0>,101}
<- REG_SEND {6,#Pid<haha@127.0.0.1.90.0>,'',java}
   {call,#Pid<haha@127.0.0.1.90.0>,{bar,100}}
message: {#Pid<haha@127.0.0.1.90.0>, {bar, 100}}
-> SEND {2,'',#Pid<haha@127.0.0.1.90.0>}
   {#Pid<j1@127.0.0.1.1.0>,200}
```



## 源码

JNodeServer.java

```java
import com.ericsson.otp.erlang.*;

public class JNodeServer {
    private OtpNode node;
    private OtpMbox mbox;

    public JNodeServer() throws Exception {
        node = new OtpNode("j1@127.0.0.1", "secret");
        mbox = node.createMbox("java");
        OtpErlangPid pid = mbox.self();
        System.out.println("Started node: " + pid.toString());
    }

    public void process() {
        while (true) {
            try {
                OtpErlangTuple msg = (OtpErlangTuple) mbox.receive();
                OtpErlangPid from = (OtpErlangPid) msg.elementAt(1);
                OtpErlangTuple tuple = (OtpErlangTuple) msg.elementAt(2);
                String fn = ((OtpErlangAtom) tuple.elementAt(0)).atomValue();
                int arg = (int) ((OtpErlangLong) tuple.elementAt(1)).longValue();
                System.out.println("message: {" + from.toString() + ", {" + fn + ", " + arg + "}}");
                JComplexCalculation complexCalc = new JComplexCalculation();
                Integer result = null;
                switch (fn) {
                case "foo":
                    result = complexCalc.foo(arg);
                    break;
                case "bar":
                    result = complexCalc.bar(arg);
                    break;
                default:
                }

                OtpErlangTuple reply = null;
                if (result == null) {
                    reply = new OtpErlangTuple(new OtpErlangObject[] { mbox.self(), new OtpErlangString("error") });
                } else {
                    reply = new OtpErlangTuple(new OtpErlangObject[] { mbox.self(), new OtpErlangInt(result) });
                }

                mbox.send(from, reply);
            } catch (OtpErlangExit | OtpErlangDecodeException e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) throws Exception {
        JNodeServer server = new JNodeServer();
        server.process();
    }
}
```

jcomplex.erl

```erlang
-module(jcomplex).
-export([foo/1, bar/1]).

foo(X) ->
  call_jnode({foo, X}).
bar(Y) ->
  call_jnode({bar, Y}).

call_jnode(Msg) ->
  {java, 'j1@127.0.0.1'} ! {call, self(), Msg},
  receive
    Any ->
      io:format("~p~n", [Any])
  end.
```



## 参考链接

http://erlang.org/doc/apps/jinterface/jinterface_users_guide.html

