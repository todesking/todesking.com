---
layout: post
title: "Scalaで作ったコンソールアプリケーションをConscriptで配布する"
date: 2014-11-27 21:03:17 +0900
comments: true
categories: 
---
[Conscript](https://github.com/n8han/conscript)の概要は[README日本語訳などを参照](http://blog.twiwt.org/e/58baf0)。

ざっくり説明すると、ConscriptというのはGitHub上のコンソールアプリプロジェクトを自動でビルド+インストールしてくれるツール。
何かツールを配布したいときは、自分のプロジェクトにConscriptの設定ファイルを含めておけば`cs`コマンド一発でインストール可能になって便利というやつです。


[Giter8](https://github.com/n8han/giter8)というプロジェクトテンプレート管理システム用に[Conscriptプロジェクトのテンプレート](https://github.com/n8han/conscript.g8)が提供されてるので、新規プロジェクトの時はこれ使うと良さそう。

## 既存プロジェクトに導入する場合

まず`src/main/conscript/(実行ファイル名)/launchconfig` に設定を書く

```
[app]
  version: 1.0.0
  org: com.todesking
  name: example
  class: com.todesking.example.Main
[scala]
  version: 2.11.4
[repositories]
  local
  scala-tools-releases
  maven-central
```

versionとかの指定がbuild.sbtと重複するのでだるい。このファイル自動生成するようにしたい。

`[repositories]`に何書けばいいのかはよくわからんけど初期状態で動いたんでまあいいや(雑)


`[app] class:`には起動用のクラスを指定する。`xsbti.AppMain`を継承している必要がある。

テンプレートを参照にして以下のように。

```scala
package com.todesking.example

case class Exit(val code: Int) extends xsbti.Exit
class Main extends xsbti.AppMain {
  def run(config: xsbti.AppConfiguration) = {
    Exit(Main.run(config.arguments))
  }
}

object Main {
  def main(args: Array[String]): Unit = {
    System.exit(run(args))
  }

  def run(args: Array[String]): Int = {
    // ここに実際の処理を書く

    0 // exit code
  }
}
```

Conscript sbt plugin を指定することで、依存関係とか設定してくれるっぽい。

```scala
// project/plugins.sbt
addSbtPlugin("net.databinder" % "conscript-plugin" % "0.3.5")
```

```scala
// build.sbt
seq(conscriptSettings :_*)
```


このような設定してGitHubにpushすると、

```
cs github_user_name/repo_name
```

でインストール可能になるのですごい。
