title: DNS SRV
date: 2021-12-02 16:18:00

tags: [internet, dns]
---

什么是 DNS SRV 记录？这么多年竟然没见过

<!--more-->

# 什么是DNS SRV

看下面一段 dig 命令的返回， 主要就是多了端口信息

```
;; ANSWER SECTION:
elixir-plug-poc.default.svc.cluster.local. 30 IN SRV 0 50 4000 elixir-plug-poc-0.elixir-plug-poc.default.svc.cluster.local.
elixir-plug-poc.default.svc.cluster.local. 30 IN SRV 0 50 4000 elixir-plug-poc-1.elixir-plug-poc.default.svc.cluster.local.
```

比如上面的信息中， 空格分隔的字段分别是

name: elixir-plug-poc.default.svc.cluster.local.

TTL: 30

class: IN

type: SRV

priority: 0

weight: 50 # priority 相同的情况下才会看 weight

port: 4000

target: elixir-plug-poc-0.elixir-plug-poc.default.svc.cluster.local. # 注意这个不能是CNAME， 即必须是A或AAAA



感觉这个 SRV 记录主要是以前的一些东西（XMPP， SIP之类的）需要用，

比如 `_xmpp._tcp.example.com. 86400 IN SRV 10 5 5223 server.example.com.`

看起来这个 SRV 就是用来做服务发现和负载均衡



# DNS SRV 记录如何帮助 elixir 结点组成集群

kubernetes headless service 会创建 SRV 记录

libcluster(https://github.com/bitwalker/libcluster), 一个 elixir 的库, 使用 DNS SRV 策略来自动创建集群

测试用的 elixir-plug-poc.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: elixir-plug-poc
  labels:
    app: elixir-plug-poc
spec:
  ports:
  - port: 4000
    name: web
  clusterIP: None
  selector:
    app: elixir-plug-poc
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: elixir-plug-poc
spec:
  serviceName: "elixir-plug-poc"
  replicas: 2
  selector:
    matchLabels:
      app: elixir-plug-poc
  template:
    metadata:
      labels:
        app: elixir-plug-poc
    spec:
      containers:
      - name: elixir-plug-poc
        image: binarytemple/elixir_plug_poc
        args:
          - foreground
        env:
          - name: ERLANG_COOKIE
            value: "cookie"
        imagePullPolicy: Always
        ports:
        - containerPort: 4000
          name: http
          protocol: TCP
```

启动

```bash
$ kubectl apply -f elixir-plug-poc.yaml

$ kubectl get pods
NAME                READY   STATUS    RESTARTS   AGE
elixir-plug-poc-0   1/1     Running   0          3m28s
elixir-plug-poc-1   1/1     Running   0          3m23s
```

进入 container 看一下

```
kubectl -n tutorial exec -it elixir-plug-poc-0 /bin/bash
bash-5.0# ERLANG_COOKIE="cookie" bin/elixir_plug_poc remote_console
Erlang/OTP 22 [erts-10.4.3] [source] [64-bit] [smp:1:1] [ds:1:1:10] [async-threads:1] [hipe]

Interactive Elixir (1.9.0) - press Ctrl+C to exit (type h() ENTER for help)

# 下面发现用的是 libcluster 的 DNSSRV 集群策略, 而且指定了 k8s 的 namespace 是 default
iex(elixir_plug_poc@elixir-plug-poc-0.elixir-plug-poc.tutorial.svc.cluster.local)> Application.get_all_env(:libcluster)
[
  debug: true,
  topologies: [
    k8s_example: [
      strategy: Cluster.Strategy.Kubernetes.DNSSRV,
      config: [
        service: "elixir-plug-poc",
        application_name: "elixir_plug_poc",
        namespace: "default",
        polling_interval: 10000
      ]
    ]
  ]
]
```

可以看出这两个结点确实组成了集群

```
iex(elixir_plug_poc@elixir-plug-poc-0.elixir-plug-poc.default.svc.cluster.local)> Node.list
[:"elixir_plug_poc@elixir-plug-poc-1.elixir-plug-poc.default.svc.cluster.local"]
iex(elixir_plug_poc@elixir-plug-poc-0.elixir-plug-poc.default.svc.cluster.local)2>
User switch command
 --> q
```

再来看一下 DNS SRV 记录

```bash
bash-5.0# hostname -f
elixir-plug-poc-0.elixir-plug-poc.default.svc.cluster.local

bash-5.0# dig SRV elixir-plug-poc.default.svc.cluster.local

; <<>> DiG 9.14.3 <<>> SRV elixir-plug-poc.default.svc.cluster.local
;; global options: +cmd
;; Got answer:
;; WARNING: .local is reserved for Multicast DNS
;; You are currently testing what happens when an mDNS query is leaked to DNS
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 57399
;; flags: qr aa rd; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 3
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 17381c155e5d95dd (echoed)
;; QUESTION SECTION:
;elixir-plug-poc.default.svc.cluster.local. IN SRV

;; ANSWER SECTION:
elixir-plug-poc.default.svc.cluster.local. 30 IN SRV 0 50 4000 elixir-plug-poc-0.elixir-plug-poc.default.svc.cluster.local.
elixir-plug-poc.default.svc.cluster.local. 30 IN SRV 0 50 4000 elixir-plug-poc-1.elixir-plug-poc.default.svc.cluster.local.

;; ADDITIONAL SECTION:
elixir-plug-poc-0.elixir-plug-poc.default.svc.cluster.local. 30	IN A 10.0.1.6
elixir-plug-poc-1.elixir-plug-poc.default.svc.cluster.local. 30	IN A 10.0.2.6

;; Query time: 1 msec
;; SERVER: 192.168.58.213#53(192.168.58.213)
;; WHEN: Tue Nov 09 10:00:09 UTC 2021
;; MSG SIZE  rcvd: 472
```

符合预期



# 参考链接

https://hexdocs.pm/libcluster/Cluster.Strategy.Kubernetes.DNSSRV.html
