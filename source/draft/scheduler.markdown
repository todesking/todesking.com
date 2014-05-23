---
title: "test"
date: 2014-05-01 14:36:11 +0900
comments: true
categories: 
---


スレッド切替時のレイテンシが重要となる事案があったので、いろいろ調べた。

## スケジューラの歴史
2.4ではO(1)スケジューラが採用されている。
2.6.23からはCFS(Completely Fair Scheduler)になった

## スレッドとプロセス

2.6以前はプロセスがスケジューリングの単位、スレッドに対する特別なサポートはなし。

2.6になってNTPL(Native POSIX Thread Library)が入り、task(スレッドとプロセスの抽象概念)がスケジューリングの単位となった。
プロセスとスレッドは区別なくスケジューリングされる。

http://stackoverflow.com/questions/8463741/how-linux-handles-threads-and-process-scheduling
http://en.wikipedia.org/wiki/Native_POSIX_Thread_Library

## CFS

Linux カーネル 2.6 Completely Fair Scheduler の内側 http://www.ibm.com/developerworks/jp/linux/library/l-completely-fair-scheduler/

本邦初？ あまり知られていないCFS概略 http://www.atmarkit.co.jp/flinux/rensai/watch2009/watch09c.html
http://www.atmarkit.co.jp/flinux/rensai/watch2009/watch09a.html
CFSのスケジューリングアルゴリズムとパラメータについての解説。

Linuxカーネル開発者が語るスケジューラの最新動向(2008, 2.6.23)
http://news.mynavi.jp/articles/2008/07/10/lfjs/


あとでよむ
Completely Fair Scheduler and its tuning(2009, PDF)
http://www.fizyka.umk.pl/~jkob/prace-mag/cfs.pdf

あとでよむ
http://stackoverflow.com/questions/8016154/linux-cfs-completely-fair-scheduler-latency

あとでよむ
http://cs2.swfu.edu.cn/~wx672/lecture_notes/linux_sys_analysis/slides/process-scheduling-a.pdf



## パフォーマンス計測

### dstat -p
```
$ dstat -p
run blk new
0.0   0 1.0
...
```

`run`の列でキューに入ってるtaskの数が見える(たぶん全CPUの合計)

### sar -P ALL

全CPUの使用率履歴が見られる。

### /proc/sched_debug

なんか出る

### /proc/(PID)/task/(PID)/sched

### /proc/(PID)/task/(PID)/schedstat

### /proc/schedstat, /proc/(PID)/task/(PID)/stat

http://eaglet.rain.com/rick/linux/schedstat/

### perf sched

http://lwn.net/Articles/353295/

CentOSの場合perfパッケージ入れる必要あるっぽい

## チューニング

```
sysctl -A|grep sched|grep -v domain
```

でなんか出る。
