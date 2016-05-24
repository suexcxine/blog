title: svn client
date: 2015-11-27
tags: [versioncontrol]
---
subversion客户端常用命令
<!--more-->
## 常用命令
1、将文件checkout到本地目录
svn checkout path（path是服务器上的目录）
例如：svn checkout svn://192.168.1.1/pro/domain
简写：svn co

2、往版本库中添加新的文件
svn add file
例如：svn add test.php(添加test.php)
svn add \*.php(添加当前目录下所有的php文件)

3、将改动的文件提交到版本库
svn commit -m "LogMessage" [-N] [--no-unlock] PATH(如果选择了保持锁，就使用--no-unlock开关)
例如：svn commit -m "add test file for my test" test.php
简写：svn ci

4、加锁/解锁
svn lock -m "LockMessage" [--force] PATH
例如：svn lock -m "lock test file" test.php
svn unlock PATH

5、更新到某个版本
svn update -r m path
例如：
svn update如果后面没有目录，默认将当前目录以及子目录下的所有文件都更新到最新版本。
svn update -r 200 test.php(将版本库中的文件test.php还原到版本200)
svn update test.php(更新，于版本库同步。如果在提交的时候提示过期的话，是因为冲突，需要先update，修改文件，然后清除svn resolved，最后再提交commit)
简写：svn up

6、查看文件或者目录状态
1）svn status path（目录下的文件和子目录的状态，正常状态不显示）
【?：不在svn的控制中；M：内容被修改；C：发生冲突；A：预定加入到版本库；K：被锁定】
2）svn status -v path(显示所有文件详细状态)
第一列保持相同，第二列显示工作版本号，第三和第四列显示最后一次修改的版本号和修改人。
注：svn status、svn diff和 svn revert这三条命令在没有网络的情况下也可以执行的，
原因是svn在本地的.svn中保留了本地版本的原始拷贝。
简写：svn st

7、删除文件
svn delete path -m "delete test fle"
例如：svn delete svn://192.168.1.1/pro/domain/test.php -m "delete test file"
或者先svn delete test.php 然后再svn ci -m "delete test file"，推荐使用这种
简写：svn (del, remove, rm)

8、查看日志
svn log path
例如：svn log test.php 显示这个文件的所有修改记录，及其版本号的变化
svn log -l 10 path
参数 -l N 表示查看最近的N个版本
svn log -r {2015-10-7}:{2015-11-15} --search "chenduo" -v
参数 -r {2015-10-7}:{2015-11-15} 查看指定日期区间的版本
参数 --search "chenduo" 指定一个search pattern, 可用于筛选指定用户提交的版本
参数 -v 表示查看详细信息, 会显示这个版本具体改动的路径列表

9、查看文件详细信息
svn info path
例如：svn info test.php

10、比较差异
svn diff path(将修改的文件与基础版本比较)
例如：svn diff test.php
svn diff -r m:n path(对版本m和版本n比较差异)
例如：svn diff -r 200:201 test.php
简写：svn di
svn di -c 559 src/world/team_mgr.erl --diff-cmd meld
参数 -c 查看指定版本的修改内容
参数 --diff-cmd meld 使用指定的外部命令查看差分

11、分支合并
新建分支
svn copy http://mysvn.com/svn/server/trunk http://mysvn.com/svn/server/myname -m "我的分支"

svn merge -r m:n path
例如：svn merge -r 200:205 test.php
（将版本200与205之间的差异合并到当前文件，但是一般都会产生冲突，需要处理一下）

svn merge --dry-run -r r3050:r3113 http://mysvn.com/svn/server/trunk
--dry-run参数表示并不实际执行,只是想看一下合并后是什么状态
注意区分方向: merge命令是把path里的内容合并到当前分支, 而不是把当前内容推到外面, 是pull而不是push

12、SVN 帮助
svn help
如: svn help ci

13、版本库下的文件和目录列表
svn list path
显示path目录下的所有属于版本库的文件和目录
简写：svn ls

14、创建纳入版本控制下的新目录
svn mkdir: 创建纳入版本控制下的新目录。
用法:
1、mkdir PATH…
每一个以工作副本 PATH 指定的目录，都会创建在本地端，并且加入新增调度，以待下一次的提交。
2、mkdir URL…
每个以URL指定的目录，都会通过立即提交于仓库中创建。在这两个情况下，所有的中间目录都必须事先存在。

15、撤销本地修改
svn revert: 恢复为原始未改变的工作副本文件 (撤销大部份的本地修改)。
用法: revert PATH…
注意: 本子命令不会存取网络，并且会解除冲突的状况。但是它不会恢复被删除的目录
svn revert -R path
参数 -R 对path的文件和子目录递归操作,比较危险,慎用

16、代码库URL变更
svn switch (sw): 更新工作副本至不同的URL。
用法: 
1、switch URL [PATH]
更新你的工作副本，映射到一个新的URL，
其行为跟“svn update”很像，也会将服务器上文件与本地文件合并。
这是将工作副本对应到同一仓库中某个分支或者标记的方法
2、switch --relocate FROM TO [PATH...]
改写工作副本的URL元数据，以反映单纯的URL上的改变。
当仓库的根URL变动(比如方案名或是主机名称变动)，
但是工作副本仍旧对映到同一仓库的同一目录时使用这个命令更新工作副本与仓库的对应关系。

17、移除冲突状态
svn resolved: 移除工作副本的目录或文件的“冲突”状态。
用法: resolved PATH…
注意: 本子命令不会依语法来解决冲突或是移除冲突标记；它只是移除冲突的相关文件，然后让PATH可以再次提交。

18、输出指定文件或URL的内容
svn cat 目标[@版本]…如果指定了版本，将从指定的版本开始查找。
svn cat -r PREV filename > haha 
(PREV 是上一版本,也可以写具体版本号,这样可以得到一个文件haha,其内容是指定版本的filename的内容)

19、设置属性
svn propedit svn:ignore .
上例表示编辑当前目录(.)的svn:ignore属性

20、blame(查看指定文件每一行的作者相关信息)
svn blame src/player/gm_command.erl -r 3000:4349 -v | less
参数 -v 查看详细信息,包含时间戳

## 参数链接
http://www.rjgc.net/control/content/content.php?nid=4418
