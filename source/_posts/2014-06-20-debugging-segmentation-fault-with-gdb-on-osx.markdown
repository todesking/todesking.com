---
layout: post
title: "GDBでsegmentation faultの原因を調査する(on OSX)"
date: 2014-06-20 18:55:00 +0900
comments: true
categories: 
---
作業ログです。

```
§ ./ctags -R ~/.vim
Segmentation fault: 11
```

グエッ。というわけで原因を調査するはめに。

# コアダンプ取る

```
$ ulimit -c unlimited
```

で`/cores/core.{PID}`にコアダンプが出力されるようになる。


なんか`core file size: cannot modify limit: Operation not permitted`とか言われて変更できないことがある([参照](http://superuser.com/questions/79717/bash-ulimit-core-file-size-cannot-modify-limit-operation-not-permitted))けど、どうにかする。

# gdbでコアダンプ読む

```
$ gdb -c /cores/core.1234
GNU gdb (GDB) 7.7.1
....
"/cores/core.1234": no core file handler recognizes format
(gdb)
```

とか言われて読み込みに失敗する。いったいなんなんだ(未解決)


検索すると普通にこれで読めるという説と対応してねえよという説があって謎。


# コンパイルオプションをあれしてGDBであれする

```
# Makefile
CFLAGS	= -g -O0 -ggdb
```

`-ggdb` でGDB用デバッグ情報を付与できる。


```
$ gdb ./ctags
...
Reading symbols from ./ctags...done.
(gdb) r -R ~/.vim
Starting program: ./ctags -R ~/.vim

Program received signal SIGSEGV, Segmentation fault.
0x00007fff8b85ef80 in ?? ()
```

フムー落ちた

スタックトレース見る
```
(gdb) bt
#0  0x00007fff8b85ef80 in ?? ()
#1  0x00007fff5fbfee10 in ?? ()
#2  0x0000000100033fa8 in findVimTags () at vim.c:720
Backtrace stopped: frame did not save the PC
```


フレーム #2 の中身見る
```
(gdb) frame 2
#2  0x0000000100033fa8 in findVimTags () at vim.c:720
720             if ( strncmp ((const char*) line, "UseVimball", (size_t) 10) == 0 )
```


`line`という変数怪しいですね

```
(gdb) p line
$1 = (const unsigned char *) 0x0
```

ヌル


で、ソースの該当箇所を見るとNULLチェック忘れてるということがわかる。
```c
	line = readVimLine(); // May returns NULL

	if ( strncmp ((const char*) line, "UseVimball", (size_t) 10) == 0 )
	{
		parseVimBallFile (line);
	}
```


おわり
