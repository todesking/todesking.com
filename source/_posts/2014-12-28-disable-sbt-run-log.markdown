---
layout: post
title: "`sbt run` でログメッセージを出さない"
date: 2014-12-28 01:06:19 +0900
comments: true
categories: 
---

ref: http://stackoverflow.com/questions/9968300

`--error`オプションでログレベル変更、`showSuccess := false` で終了時のメッセージ非表示。
たぶんERRORレベルのメッセージは出るけど、問題なかろう。

```sh
sbt --error 'set showSuccess := false' run
```
