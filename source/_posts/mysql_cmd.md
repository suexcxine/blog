title: mysql命令行
date: 2015-12-04
tags: [db]
---

mysql, mysqladmin, mysqldump
<!--more-->

## 登录sql
mysql -u ben -p -h myserver -P 9999
默认端口3306

## mysql命令
* show databases; 显示数据库列表
* use databasename; 选择数据库
* show tables; 显示数据表列表
* desc tablename; 显示表tablename的详细信息
* show columns from tablename; 与desc tablename命令相同
* show status; 显示服务器状态信息
* show grants; 显示权限信息
* show errors; 显示错误信息
* show warnings; 显示警告信息
* help commandname; 显示commandname如show, use, desc的帮助信息
* \G  显示从横排变成竖排,有时会清晰很多

## mysqladmin
创建数据库
mysqladmin -u root -p create newdatabase

删除数据库
mysqladmin -u root -p drop testdatabase

修改用户密码
mysqladmin -u root -p password "new password"

## 附1: 命令行帮助1
<pre>
mysql> help

For information about MySQL products and services, visit:
   http://www.mysql.com/
For developer information, including the MySQL Reference Manual, visit:
   http://dev.mysql.com/
To buy MySQL Enterprise support, training, or other products, visit:
   https://shop.mysql.com/

List of all MySQL commands:
Note that all text commands must be first on line and end with ';'
?         (\?) Synonym for `help'.
clear     (\c) Clear the current input statement.
connect   (\r) Reconnect to the server. Optional arguments are db and host.
delimiter (\d) Set statement delimiter.
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically.
exit      (\q) Exit mysql. Same as quit.
go        (\g) Send command to mysql server.
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
notee     (\t) Don't write into outfile.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash.
source    (\.) Execute an SQL script file. Takes a file name as an argument.
status    (\s) Get status information from the server.
system    (\!) Execute a system shell command.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
use       (\u) Use another database. Takes database name as argument.
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
warnings  (\W) Show warnings after every statement.
nowarning (\w) Don't show warnings after every statement.

For server side help, type 'help contents'
</pre>

## 附2: 命令行帮助2
<pre>
$ mysql --help
mysql  Ver 14.14 Distrib 5.5.44, for debian-linux-gnu (x86_64) using readline 6.3
Copyright (c) 2000, 2015, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Usage: mysql [OPTIONS] [database]
  -?, --help          Display this help and exit.
  -I, --help          Synonym for -?
  --auto-rehash       Enable automatic rehashing. One doesn't need to use
                      'rehash' to get table and field completion, but startup
                      and reconnecting may take a longer time. Disable with
                      --disable-auto-rehash.
                      (Defaults to on; use --skip-auto-rehash to disable.)
  -A, --no-auto-rehash 
                      No automatic rehashing. One has to use 'rehash' to get
                      table and field completion. This gives a quicker start of
                      mysql and disables rehashing on reconnect.
  --auto-vertical-output 
                      Automatically switch to vertical output mode if the
                      result is wider than the terminal width.
  -B, --batch         Don't use history file. Disable interactive behavior.
                      (Enables --silent.)
  --character-sets-dir=name 
                      Directory for character set files.
  --column-type-info  Display column type information.
  -c, --comments      Preserve comments. Send comments to the server. The
                      default is --skip-comments (discard comments), enable
                      with --comments.
  -C, --compress      Use compression in server/client protocol.
  -#, --debug[=#]     This is a non-debug version. Catch this and exit.
  --debug-check       Check memory and open file usage at exit.
  -T, --debug-info    Print some debug info at exit.
  -D, --database=name Database to use.
  --default-character-set=name 
                      Set the default character set.
  --delimiter=name    Delimiter to be used.
  --enable-cleartext-plugin 
                      Enable/disable the clear text authentication plugin.
  -e, --execute=name  Execute command and quit. (Disables --force and history
                      file.)
  -E, --vertical      Print the output of a query (rows) vertically.
  -f, --force         Continue even if we get an SQL error.
  -G, --named-commands 
                      Enable named commands. Named commands mean this program's
                      internal commands; see mysql> help . When enabled, the
                      named commands can be used from any line of the query,
                      otherwise only from the first line, before an enter.
                      Disable with --disable-named-commands. This option is
                      disabled by default.
  -i, --ignore-spaces Ignore space after function names.
  --init-command=name SQL Command to execute when connecting to MySQL server.
                      Will automatically be re-executed when reconnecting.
  --local-infile      Enable/disable LOAD DATA LOCAL INFILE.
  -b, --no-beep       Turn off beep on error.
  -h, --host=name     Connect to host.
  -H, --html          Produce HTML output.
  -X, --xml           Produce XML output.
  --line-numbers      Write line numbers for errors.
                      (Defaults to on; use --skip-line-numbers to disable.)
  -L, --skip-line-numbers 
                      Don't write line number for errors.
  -n, --unbuffered    Flush buffer after each query.
  --column-names      Write column names in results.
                      (Defaults to on; use --skip-column-names to disable.)
  -N, --skip-column-names 
                      Don't write column names in results.
  --sigint-ignore     Ignore SIGINT (CTRL-C).
  -o, --one-database  Ignore statements except those that occur while the
                      default database is the one named at the command line.
  --pager[=name]      Pager to use to display results. If you don't supply an
                      option, the default pager is taken from your ENV variable
                      PAGER. Valid pagers are less, more, cat [> filename],
                      etc. See interactive help (\h) also. This option does not
                      work in batch mode. Disable with --disable-pager. This
                      option is disabled by default.
  -p, --password[=name] 
                      Password to use when connecting to server. If password is
                      not given it's asked from the tty.
  -P, --port=#        Port number to use for connection or 0 for default to, in
                      order of preference, my.cnf, $MYSQL_TCP_PORT,
                      /etc/services, built-in default (3306).
  --prompt=name       Set the mysql prompt to this value.
  --protocol=name     The protocol to use for connection (tcp, socket, pipe,
                      memory).
  -q, --quick         Don't cache result, print it row by row. This may slow
                      down the server if the output is suspended. Doesn't use
                      history file.
  -r, --raw           Write fields without conversion. Used with --batch.
  --reconnect         Reconnect if the connection is lost. Disable with
                      --disable-reconnect. This option is enabled by default.
                      (Defaults to on; use --skip-reconnect to disable.)
  -s, --silent        Be more silent. Print results with a tab as separator,
                      each row on new line.
  -S, --socket=name   The socket file to use for connection.
  --ssl               Enable SSL for connection (automatically enabled with
                      other flags).
  --ssl-ca=name       CA file in PEM format (check OpenSSL docs, implies
                      --ssl).
  --ssl-capath=name   CA directory (check OpenSSL docs, implies --ssl).
  --ssl-cert=name     X509 cert in PEM format (implies --ssl).
  --ssl-cipher=name   SSL cipher to use (implies --ssl).
  --ssl-key=name      X509 key in PEM format (implies --ssl).
  --ssl-verify-server-cert 
                      Verify server's "Common Name" in its cert against
                      hostname used when connecting. This option is disabled by
                      default.
  -t, --table         Output in table format.
  --tee=name          Append everything into outfile. See interactive help (\h)
                      also. Does not work in batch mode. Disable with
                      --disable-tee. This option is disabled by default.
  -u, --user=name     User for login if not current user.
  -U, --safe-updates  Only allow UPDATE and DELETE that uses keys.
  -U, --i-am-a-dummy  Synonym for option --safe-updates, -U.
  -v, --verbose       Write more. (-v -v -v gives the table output format).
  -V, --version       Output version information and exit.
  -w, --wait          Wait and retry if connection is down.
  --connect-timeout=# Number of seconds before connection timeout.
  --max-allowed-packet=# 
                      The maximum packet length to send to or receive from
                      server.
  --net-buffer-length=# 
                      The buffer size for TCP/IP and socket communication.
  --select-limit=#    Automatic limit for SELECT when using --safe-updates.
  --max-join-size=#   Automatic limit for rows in a join when using
                      --safe-updates.
  --secure-auth       Refuse client connecting to server if it uses old
                      (pre-4.1.1) protocol.
  --server-arg=name   Send embedded server this as a parameter.
  --show-warnings     Show warnings after every statement.
  --plugin-dir=name   Directory for client-side plugins.
  --default-auth=name Default authentication client-side plugin to use.

Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf /usr/etc/my.cnf ~/.my.cnf 
The following groups are read: mysql client
The following options may be given as the first argument:
--print-defaults        Print the program argument list and exit.
--no-defaults           Don't read default options from any option file.
--defaults-file=#       Only read default options from the given file #.
--defaults-extra-file=# Read this file after the global files are read.

Variables (--variable-name=value)
and boolean options {FALSE|TRUE}  Value (after reading options)
--------------------------------- ----------------------------------------
auto-rehash                       TRUE
auto-vertical-output              FALSE
character-sets-dir                (No default value)
column-type-info                  FALSE
comments                          FALSE
compress                          FALSE
debug-check                       FALSE
debug-info                        FALSE
database                          (No default value)
default-character-set             auto
delimiter                         ;
enable-cleartext-plugin           FALSE
vertical                          FALSE
force                             FALSE
named-commands                    FALSE
ignore-spaces                     FALSE
init-command                      (No default value)
local-infile                      FALSE
no-beep                           FALSE
host                              (No default value)
html                              FALSE
xml                               FALSE
line-numbers                      TRUE
unbuffered                        FALSE
column-names                      TRUE
sigint-ignore                     FALSE
port                              3306
prompt                            mysql> 
quick                             FALSE
raw                               FALSE
reconnect                         TRUE
socket                            /var/run/mysqld/mysqld.sock
ssl                               FALSE
ssl-ca                            (No default value)
ssl-capath                        (No default value)
ssl-cert                          (No default value)
ssl-cipher                        (No default value)
ssl-key                           (No default value)
ssl-verify-server-cert            FALSE
table                             FALSE
user                              (No default value)
safe-updates                      FALSE
i-am-a-dummy                      FALSE
connect-timeout                   0
max-allowed-packet                16777216
net-buffer-length                 16384
select-limit                      1000
max-join-size                     1000000
secure-auth                       FALSE
show-warnings                     FALSE
plugin-dir                        (No default value)
default-auth                      (No default value)
</pre>
