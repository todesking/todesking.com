---
layout: post
title: "H2 Database、マルチスレッドでアクセスするとLock timeoutが頻発する件の解決法について"
date: 2014-06-12 19:54:20 +0900
comments: true
categories: 
---

h2 1.3.176で確認。

`jdbc:h2:file:....`でローカルのDBを開いて、マルチスレッドでクエリ発行してるとテーブルのlock timeoutでエラーになる。

```
Caused by: org.h2.jdbc.JdbcSQLException: Timeout trying to lock table "USER";
```

みたいなやつ。

同時アクセスを相当制限しても低確率で発生するし、タイムアウト長くしても発生するし、何らかのバグがある気がする……。

接続時のjdbc文字列に、`MVCC=TRUE`オプションを指定したら解決しました。

http://stackoverflow.com/questions/4162557/timeout-error-trying-to-lock-table-in-h2

