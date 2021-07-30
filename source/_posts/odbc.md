title: odbc
date: 2021-07-30 12:00:00

tags: [odbc, erlang]
---

今天想试试用 erlang/elixir 通过 odbc 读 excel, 结果...

<!--more-->

从 erlang mail list(http://erlang.org/pipermail/erlang-questions/2009-April/043094.html)这里读到可以通过 odbc 来读 excel, 就不用再去读 excel 的各个版本的 format(几百页...) 了

立即着手去找 excel 的 odbc driver, 结果只找到一个 cdata 出的商业版的, 

立即下载试用, 安装后照着目录里带的 help.htm 操作了一波装好 driver

先试一波 excel 2003, 即 xls

```erlang
1> odbc:start().
ok
2> ConnStr = "Driver={CData ODBC Driver for Excel};URI=/Users/chenduo/Downloads/53KF_broken.xls".
"Driver={CData ODBC Driver for Excel};URI=/Users/chenduo/Downloads/53KF_broken.xls"
3> {ok, Ref} = odbc:connect( ConnStr, [{timeout, 45000}] ).
{ok,<0.95.0>}
4> odbc:sql_query(Ref, "SELECT * FROM Worksheet;").
{error,"This Excel file version is not supported. SQLSTATE IS: HY000"}
```

歇菜...

再试一波 excel 2007+, 即 xlsx

```erlang
1> odbc:start().
ok
2> ConnStr = "Driver={CData ODBC Driver for Excel};URI=/Users/chenduo/Downloads/test.xlsx".
"Driver={CData ODBC Driver for Excel};URI=/Users/chenduo/Downloads/test.xlsx"
3> {ok, Ref} = odbc:connect( ConnStr, [{timeout, 45000}] ).
{ok,<0.95.0>}
4> odbc:sql_query(Ref, "SELECT * FROM sheet1;").
{selected,["RowId","head1","head2","head3","head4","head5"],
          [{2,
            <<97,0,0,0,50,0,0,0>>,
            <<49,0,0,0,48,0,0,0,48,0,0,0>>,
            <<98,0,0,0,50,0,0,0>>,
            <<99,0,0,0,50,0,0,0>>,
            <<100,0,0,0,50,0,0,0>>},
           {3,
            <<101,0,0,0,50,0,0,0>>,
            <<97,0,0,0,51,0,0,0>>,
            <<98,0,0,0,51,0,0,0>>,
            <<101,0,0,0,51,0,0,0>>,
            <<99,0,0,0,51,0,0,0>>}]}
```

成功了, 我的excel内容是这样的

| head1 | head2 | head3 | head4 | head5 |
| ----- | ----- | ----- | ----- | ----- |
| a2    | 100   | c2    | d2    | e2    |
| a3    | b3    | c3    | d3    | e3    |

看来它是把每一个字符变成 32bit 的 binary 给我返回来了, 表头的 "RowId"也不知道是啥

总之算不上很好用, 而且这个 CData 还是 commercial 的

## 参考链接

excel 的 format 链接如下:

[loc的pdf](https://www.loc.gov/preservation/digital/formats/digformatspecs/Excel97-2007BinaryFileFormat(xls)Specification.pdf)

[openoffice的pdf](http://www.openoffice.org/sc/excelfileformat.pdf)

odbc相关链接

http://www.unixodbc.org/

https://www.cdata.com/drivers/excel/download/odbc/#macos

https://www.connectionstrings.com/

