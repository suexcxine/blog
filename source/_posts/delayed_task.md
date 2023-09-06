title: 延时任务处理系统：一个 Golang 和 PostgreSQL 的解决方案
date: 2023-09-06
tags: [go, postgresql]
---

延时任务（不是定时任务，比如每天12:00做点什么）是一个常见的需求。在这篇博客中，我将探讨如何使用 Golang 和 PostgreSQL 来构建一个高效、可靠的延时任务处理系统。

<!--more-->

## 背景

在构建一个分布式系统时，我经常会遇到需要延时处理的任务。比如用户 5 分钟内没有响应的话要自动结束流程。注意这里不讨论 crontab 那种定时任务。

为了解决这个问题，我提出了一个基于 Golang 和 PostgreSQL 的延时任务处理方案。该方案结合了数据库的持久性和 Golang 的并发处理能力，以实现一个高效、可靠的延时任务处理系统。

注：本文主要考虑 web 服务的场景。

## 方案概述

我的方案包括以下几个关键步骤：

1. **创建延时任务**：每当我们需要创建一个延时任务时，首先我们将任务的相关信息存储到数据库中，确保任务的信息不会因为系统的重启或故障而丢失。随后，我们利用 Golang 的 `time.NewTimer` 方法来初始化一个内存中的计时器，这样可以精确控制任务的执行时间。
    
2. **服务器启动时的任务加载**：为了避免在系统升级或重启时丢失尚未处理的任务，我们在服务器启动时从数据库中检索所有待处理的延时任务。每个检索到的任务都会被分配一个新的 `time.NewTimer` 计时器，以重新开始计时，确保任务能够在预定的时间得到执行。
    
3. **TimerManager**：尽管我们已经实施了服务器启动时的任务加载机制，但在某些情况下仍然存在任务丢失的风险。例如，在我们进行系统升级时，如果我们首先启动新的节点然后再关闭旧的节点，新节点在启动时可能无法检索到旧节点上的无主任务。此外，如果我们减少了节点的数量或节点宕机，也可能会丢失一些任务。为了解决这些问题，我们设计了 TimerManager。它每隔分钟会自动从数据库中拉取当前无主的待处理任务，确保这些任务不会因为系统的变化而丢失。
    
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
	err := createTask(task.Content, task.ExecuteAt)
	if err != nil {
		log.Println("Failed to create task:", err)
		return
	}
	
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

func createTask(content string, executeAt time.Time) error {
	_, err := db.Exec(`
		INSERT INTO tasks (content, status, execute_at)
		VALUES ($1, 'pending', $2)
	`, content, executeAt)
	return err
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

### 其他

推荐的发版方式是关一个启一个。

延时任务处理失败的情况下可以自行做错误处理，这个方案内没有考虑。非重要业务打一个日志方便后面查问题就可以了。

如果拉取任务时发现已经超过预定的执行时间了的话，可以按业务需求加一些类型, 比如需要补的，超出多长时间以内可以补的，不需要补的，等等。

如果介意一个结点下线时要等到下一个结点启动或5分钟后这个时间间隔太长的话，可以在一个结点下线时往一个 MQ 发一条消息（在此之前先把消费者关了避免被自己消费到），其他结点中的某一个消费时拉取这些定时任务即可大幅缩短这个时间间隔。

如果不想用 pg 想用 redis 的话，首先需要设置 redis 持久化，其次用一个 SortedSet 来存时间戳的排序和任务id, 然后再加一个 hash 来存任务的其他信息，最后需要用 lua 脚本来保证相关操作的隔离性避免并发问题。

如果能接受多一个依赖，也可以考虑 RocketMQ 的延时消息，弊端是时间只有几个档位（比如5秒，10秒，1分钟，10分钟），不灵活。





