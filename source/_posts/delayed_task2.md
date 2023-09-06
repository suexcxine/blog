title: 使用 Redis 和 Go 实现高效的延时任务队列
date: 2023-09-07
tags: [go, redis]
---

如何使用 Redis 的 Sorted Set 数据结构和 Go 语言来实现一个高效的延时任务队列。我愁了很久才想出来这个。

<!--more-->
## 方案设计

我的方案是创建一个延时任务队列，其中每个任务都有一个执行时间。我将使用 Redis 的 Sorted Set 数据结构来存储这些任务，其中任务的执行时间作为分数。每个 Go web server 结点都将运行一个 TaskManager go routine，它将周期性地查询 Redis 来检索和执行到期的任务。

### 数据结构

我将使用 Redis 的 Sorted Set 数据结构来存储任务，其中任务的执行时间（Unix 时间戳）作为分数。

### 任务处理流程

1. **添加任务到 Sorted Set**：当创建一个新的延时任务时，将其添加到 Sorted Set 中，使用任务的执行时间作为分数。
2. **TaskManager Go Routine**：创建一个 TaskManager Go routine，它每秒查询 Redis 来找到和执行到期的任务。
3. **执行任务**：根据任务 ID 执行相应的任务逻辑。

## 代码实现

### 1. 加载 Lua 脚本

首先，创建一个函数来加载 Lua 脚本到 Redis 服务器，并返回脚本的 SHA1 散列：

```go
func loadScript(redisClient *redis.Client) (string, error) {
	script := `
		local tasks = redis.call('ZRANGEBYSCORE', 'tasks', '-inf', ARGV[1], 'LIMIT', 0, 100)
		if #tasks > 0 then
		  redis.call('ZREM', 'tasks', unpack(tasks))
		end
		return tasks
	`
	return redisClient.ScriptLoad(script).Result()
}
```

或者预先把 lua 脚本加载到 redis 里。

### 2. 执行 Lua 脚本

然后，创建一个函数来使用 `EVALSHA` 命令执行 Lua 脚本：

```go
func getAndRemoveDueTasks(redisClient *redis.Client, scriptSha string, now int64) ([]string, error) {
	result, err := redisClient.EvalSha(scriptSha, []string{"tasks"}, now).Result()
	if err != nil {
		return nil, err
	}

	tasks, ok := result.([]interface{})
	if !ok {
		return nil, errors.New("failed to cast result to []interface{}")
	}

	taskIDs := make([]string, len(tasks))
	for i, task := range tasks {
		taskIDs[i], ok = task.(string)
		if !ok {
			return nil, errors.New("failed to cast task to string")
		}
	}

	return taskIDs, nil
}
```

### 3. 主函数

在你的主函数中，你可以加载 Lua 脚本，并将其 SHA1 散列传递给 `taskManager` 函数：

```go
func main() {
	redisClient := redis.NewClient(&redis.Options{
		Addr: "localhost:6379",
	})

	scriptSha, err := loadScript(redisClient)
	if err != nil {
		log.Fatal(err)
	}

	go taskManager(redisClient, scriptSha)

	select {}
}
```

### 4. TaskManager 函数

在 `taskManager` 函数中，你可以使用 `getAndRemoveDueTasks` 函数来获取和删除到期的任务：

```go
func taskManager(redisClient *redis.Client, scriptSha string) {
	for {
		now := time.Now().Unix()
		taskIDs, err := getAndRemoveDueTasks(redisClient, scriptSha, now)
		if err != nil {
			log.Println("Error fetching tasks:", err)
		} else {
			for _, taskID := range taskIDs {
				// Execute the task
				executeTask(taskID)
			}
		}

		time.Sleep(1 * time.Second)
	}
}
```

### 5. 任务执行函数

`executeTask` 函数应该根据任务 ID 执行相应的任务逻辑：

```go
func executeTask(taskID string) {
	// Your task execution logic here
	log.Println("Executing task:", taskID)
}
```


## 扩展

当一个 sorted set 出现性能瓶颈的时候，可以用 redis cluster 并使用多个 sorted set，
比如某延时任务的量很大，那么可以把那一类延时任务放到一个 sorted set 里，其余量比较小的放到另一个 sorted set 里。
注意：这样的话，taskManager 也建议搞两个。

## 结论

通过使用 Redis 的 Sorted Set 数据结构和 Lua 脚本，可以创建一个高效和可扩展的延时任务队列系统。这种设计不仅可以确保任务的原子性和一致性，而且可以轻松地扩展到多个节点，从而提高系统的吞吐量和可靠性。
