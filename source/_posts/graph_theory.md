title: graph theory
date: 2016-03-03
tags: [algorithm]
---

整理了一些图论基础知识和相关算法

<!--more-->

## 基本概念
顶点,边,
无向图,有向图,完全图,子图,连通图,非连通图,
路径,路径长度,简单路径,回路,
邻接,入度,出度

## 表示法
* 邻接矩阵, 用一个一维数组存放顶点数据;用一个二维数组存放边的数据，这个二维数组称为邻接矩阵。
* 邻接表, 是一种顺序分配和链式分配相结合的存储结构。把每个结点的所有相邻结点都存放在一个单向链表里。

## 深度优先搜索(Depth First Search)
访问当前结点,记当前结点为已访问并递归访问当前结点的未访问邻接结点
```c
void traverse(int k, void (*visit)(int))
{
	(*visit)(k);
	visited[k] = 1;
	link t;
	for (t = adj[k]; t != NULL; t = t -> next) {
		if (! visited[t -> v]) traverse(t -> v, visit);
	}
}
```

## 广度优先搜索(Breadth First Search)
指定一个顶点,经过一条边进入另一个顶点后,继续进入下一个顶点,直到没有未访问的顶点
再对其他边也这样做,直到没有未处理的边
```c
void traverse(int k, void (*visit)(int))
{
	QUEUEinit();
	QUEUEput(k);
	link t;
	while(! QUEUEempty()) {
		if (! visited[k = QUEUEget()]) {
			(*visit)(k);
			visited[k] = 1;
			for (t = adj[k]; t != NULL; t = t -> next) {
				if (! visited[t -> v]) QUEUEput(t -> v);
			} 
		} 
	}
}
```

## dijikstra算法(单源最短路径算法)
感觉这个算法和动态规划找零钱的算法本质上相同,
但是计算找零钱的时候用的是从1-N这样自底向上的遍历法,而dijikstra需要用另一种方式遍历(类似BFS)
图上连着的结点表示可行,就像1元结点到4元结点有3元硬币这条路径可行而5元硬币不可行,
即找零钱的问题也可以转换为如下图的最短路径问题, 路径权重均为1(因为都是1枚硬币), 
<pre>
0元 -> 1元 -> 2元 -> 3元 -> 4元
 |--------------------^     ^
        |-------------------|
从0元到4元的单源最短路径为0元到1元再到4元,即一枚1元硬币和一枚3元硬币,路程为2最短
</pre>

```c
#include <stdio.h>
#include <limits.h>

#define V 9

// 找出未处理的结点中路径最短的
int get_min_vertex(int dist[], int processed[])
{
	int min = INT_MAX;
	int min_index;
	for (int v = 0; v < V; v ++) {
		if (! processed[v] && dist[v] < min) {
			min = dist[v];
			min_index = v;
		}
	}
	return min_index;
}

void dijikstra(int graph[V][V])
{
	int dist[V];
	int processed[V];
	
	dist[0] = 0;
	
	int count;
	for (count = 0; count < V; count ++) {
		int u = get_min_vertex(dist, processed);
		
		// 遍历邻接矩阵
		for (int v = 0; v < V; v ++) {
			if (! processed[v] && graph[u][v] && 
				dist[u] + graph[u][v] < dist[v]) {
				dist[v] = dist[u] + graph[u][v];
			}
		}
		
		processed[v] = 1;
	}
}
```
## Floyd算法

如果要让任意两点(例如从顶点a到顶点b)之间的路程变短，
只能引入第三个点(顶点k)，并通过这个顶点k中转即a->k->b，才可能缩短原来从顶点a到顶点b的路程。
```c
for (int i = 0; i <= n; i ++) {
	for (int j = 0; j <= n, j ++) {
		for (int k = 0; k <= n, k ++) {
			if (e[i][j] > e[i][k] + e[k][j])
				e[i][j] = e[i][k] + e[k][j];
		}	
	}
}
```
## 树遍历 
树是无环图

* 前序preorder遍历, 节点->左子树->右子树
* 中序inorder遍历, 左子树->节点->右子树
* 后序postorder遍历, 左子树->右子树->节点
* 层序levelorder遍历, 类似图的广度优先遍历

#### 递归前序遍历
```c
void traverse(Node *node, void (*visit)(Node *))
{
	if (node == NULL) return;
	(*visit)(node);
	traverse(node -> left, visit);
	traverse(node -> right, visit);
}
```

#### 递归中序遍历
```c
void traverse(Node *node, void (*visit)(Node *))
{
	if (node == NULL) return;
	traverse(node -> left, visit);
	(*visit)(node);
	traverse(node -> right, visit);
}
```
#### 递归后序遍历
```c
void traverse(Node *node, void (*visit)(Node *))
{
	if (node == NULL) return;
	traverse(node -> left, visit);
	traverse(node -> right, visit);
	(*visit)(node);
}
```
#### 非递归的前序遍历
```c
void traverse(Node *node, void (*visit)(Node *))
{
	if (node == NULL) return;
	STACKinit(max);
	STACKpush(node);
	while (! STACKempty())
	{
		(*visit)(node = STACKpop());
		if (node -> right != NULL) STACKpush(node -> right);
		if (node -> left != NULL) STACKpush(node -> left);
	}
}
```

## 拓扑排序
对一个有向无环图(Directed Acyclic Graph简称DAG)G进行拓扑排序，
是将G中所有顶点排成一个线性序列，使得图中任意一对顶点u和v，若边(u,v)∈E(G)，则u在线性序列中出现在v之前。
通常，这样的线性序列称为满足拓扑次序(Topological Order)的序列，简称拓扑序列。
简单的说，由某个集合上的一个偏序得到该集合上的一个全序，这个操作称之为拓扑排序。

拓扑排序通常用来处理具有依赖关系的任务。
如有先修课要求的课程,任务A开始之前任务B必须已完成等。

算法思路:
用一个队列存储返回值
找出入度为0的结点放入队列
从队列取出一个,打印出来,并将该结点的邻结点的入度-1,如果-1后为0则放入队列,循环该处理
 
## 最小生成树(Minimum-Cost Spannning Tree)

遍历的路径就是一个树, 如深度优先生成树, 广度优先生成树
而最小生成树是指有权重的图中总权重最小的生成树

算法思路:
将各边按权值从小到大排序,
只要不会形成环, 就逐一加入边, 直到所有的点都已经连接上
如何检查环?如果一条边的两个顶点同属于某一个集合(已经连接起来的顶点们),就会形成环,
即lists:any(fun(Set) -> lists:member(A, Set) andalso lists:member(B, Set) end, sets:to_list(Sets)).
