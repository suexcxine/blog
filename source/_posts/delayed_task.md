title: 延时任务处理系统：一个 Golang 和 PostgreSQL 的解决方案
date: 2023-09-06
tags: [go, postgresql]
---

延时任务是一个常见的需求。在这篇博客中，我将探讨如何使用 Golang 和 PostgreSQL 来构建一个高效、可靠的延时任务处理系统。

<!--more-->

## 背景

在构建一个分布式系统时，我经常会遇到需要延时处理的任务。这些任务可能是由于各种原因而不能立即执行的，例如需要等待某个条件满足或等待其他任务完成。

为了解决这个问题，我提出了一个基于 Golang 和 PostgreSQL 的延时任务处理方案。该方案结合了数据库的持久性和 Golang 的并发处理能力，以实现一个高效、可靠的延时任务处理系统。

注：本文主要考虑 web 服务的场景。

## 方案概述

我的方案包括以下几个关键步骤：

1. **创建延时任务**：每当我们需要创建一个延时任务时，首先我们将任务的相关信息存储到数据库中，确保任务的信息不会因为系统的重启或故障而丢失。随后，我们利用 Golang 的 `time.NewTimer` 方法来初始化一个内存中的计时器，这样可以精确控制任务的执行时间。
    
2. **服务器启动时的任务加载**：为了避免在系统升级或重启时丢失尚未处理的任务，我们在服务器启动时从数据库中检索所有待处理的延时任务。每个检索到的任务都会被分配一个新的 `time.NewTimer` 计时器，以重新开始计时，确保任务能够在预定的时间得到执行。
    
3. **TimerManager**：尽管我们已经实施了服务器启动时的任务加载机制，但在某些情况下仍然存在任务丢失的风险。例如，在我们进行系统升级时，如果我们首先启动新的节点然后再关闭旧的节点，新节点在启动时可能无法检索到旧节点上的无主任务。此外，如果我们减少了节点的数量，也可能会丢失一些任务。为了解决这些问题，我们设计了 TimerManager。它每隔5分钟会自动从数据库中拉取当前无主的待处理任务，确保这些任务不会因为系统的变化而丢失。
    
4. **任务执行**：当计时器到达预定的时间点时，它会触发相应的任务执行程序。一旦任务成功执行，我们将从数据库中删除该任务的记录或将其标记为已完成，以保持数据的准确性和一致性。

## 技术实现

下面我将深入探讨每个步骤的技术实现细节。

### 数据库设计

我使用 PostgreSQL 作为我的数据库系统。在数据库中，我创建了一个 `tasks` 表来存储任务信息。该表包含以下几个字段：

- `id`: 任务的唯一标识符。
- `content`: 任务的内容或数据（optional）。
- `status`: 任务的状态，可以是 'pending'、'processing' 或 'completed'。
- `execute_at`: 任务的执行时间。

### Golang 代码实现

我使用 Golang 来实现我的延时任务处理系统。以下是我的 Golang 代码实现的关键部分：

```go
package main

import (
	"database/sql"
	"log"
	"time"
	_ "github.com/lib/pq"
)

type Task struct {
	ID       int
	Content  string
	Status   string
	ExecuteAt time.Time
}

var db *sql.DB

func init() {
	var err error
	db, err = sql.Open("postgres", "user=youruser dbname=yourdb sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
}

func main() {
	// 启动时加载待处理的延时任务
	loadPendingTasks()

	// 启动 TimerManager
	go timerManager()

	select {}
}

func loadPendingTasks() {
	tasks, err := getPendingTasks()
	if err != nil {
		log.Fatal(err)
	}

	for _, task := range tasks {
		go scheduleTask(task)
	}
}

func getPendingTasks() ([]Task, error) {
	// 这里利用了 pg 的特性即 update 可以有返回值
	// 用这种 update 的方式可以在一个事务中完成任务状态的更新和任务数据的获取
	// 从而保证操作的原子性，并避免任务在多个结点重复执行。
	rows, err := db.Query(`
		UPDATE tasks
		SET status = 'processing'
		WHERE status = 'pending'
		RETURNING id, content, status, execute_at
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tasks []Task
	for rows.Next() {
		var task Task
		if err := rows.Scan(&task.ID, &task.Content, &task.Status, &task.ExecuteAt); err != nil {
			return nil, err
		}
		tasks = append(tasks, task)
	}
	return tasks, nil
}


func scheduleTask(task Task) {
	delay := task.ExecuteAt.Sub(time.Now())
	timer := time.NewTimer(delay)
	<-timer.C

	// 执行任务
	executeTask(task)
}

func executeTask(task Task) {
	// 执行任务的逻辑
	// ...

	// 更新任务状态为已完成
	_, err := db.Exec("UPDATE tasks SET status = 'completed' WHERE id = $1", task.ID)
	if err != nil {
		log.Println("Failed to update task status:", err)
	}
}

func timerManager() {
	ticker := time.NewTicker(1 * time.Minute)
	for {
		<-ticker.C

		// 每分钟拉取新的待处理任务
		tasks, err := getPendingTasks()
		if err != nil {
			log.Println("Failed to get pending tasks:", err)
			continue
		}

		for _, task := range tasks {
			go scheduleTask(task)
		}
	}
}

```

### 事务隔离级别

为了保证数据的一致性和避免并发问题，我选择了“读已提交（Read Committed）”作为我的事务隔离级别。这个隔离级别可以避免脏读问题，同时保持了较好的系统性能。

如果读者在意可重复读的问题，也可以改用 Repeatable Read 。

