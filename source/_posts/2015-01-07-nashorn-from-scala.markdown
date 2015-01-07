---
layout: post
title: "ScalaでNashornを使うときは、ScriptEngineManagerのコンストラクタにnullを渡す必要がある"
date: 2015-01-07 23:51:17 +0900
comments: true
categories: 
---

```scala
import javax.script.ScriptEngineManager
val engineManager = new ScriptEngineManager(null);
```

`ScriptEngineManager`の引数には目的の`ScriptEngine`をロード可能な`ClassLoader`を指定する必要があるんですが、
引数省略時には`Thread.currentThread.contextClassLoader`が使用されるようになっており、`sbt run`で起動した場合に謎のクラスローダーが使われることになってJDKのextensionであるNashornのエンジンがロード不能。なので明示的に`null`を渡す必要があります。

これ、`sbt console`だと引数省略でもうまくいったりするので闇が深い。sbtのクラスローダには気をつけましょう。

ref: http://stackoverflow.com/questions/23567500/how-to-use-scriptengine-in-scalatest
