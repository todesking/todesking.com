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

## Conscriptは何をしているのか

* GitHub上の`launchconfig`を元に、`sbt-launcher`のラッパーコマンドを作成する
* `sbt-launcher`は、`launchconfig`の内容に応じて依存ライブラリの解決とアプリケーションの起動を行う

最初勘違いしてたんだけど、GitHubからソース一式落としてきてビルドしてるわけじゃないです。`launchconfig`以外はmvnリポジトリ経由で取得しているので、ビルド済みのjarを公開しておかないとインストールできない。

`launchconfig`の書き方などが知りたいときは[sbt-launcherのドキュメント](http://www.scala-sbt.org/0.13/docs/Launcher-Configuration.html)読むと書いてあります。


## 既存プロジェクトに導入する場合

### `launchconfig`

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
  todesking: http://todesking.github.io/mvn/
```

インストール時は`[repositories]`の定義を元に依存ライブラリ(アプリ本体含む)を探すので、必要な物を書いておく。
`[app] class:`には起動用のクラスを指定する。`xsbti.AppMain`を継承している必要がある。


sbtと定義内容がかぶってるので、自動生成するようにしてみた。`version`は「現在mvnリポジトリから入手可能なバージョン」である必要があるので微妙なことをしている……。

```scala
// build.sbt
compile <<= (compile in Compile) dependsOn Def.task {
    val content = s"""[app]
      |  version: ${version.value.replaceAll("\\+$", "")}
      |  org: ${organization.value}
      |  name: ${name.value}
      |  class: com.todesking.nyandoc.Main
      |[scala]
      |  version: ${scalaVersion.value}
      |[repositories]
      |  local
      |  scala-tools-releases
      |  maven-central
      |  todesking: http://todesking.github.io/mvn/""".stripMargin
    val dir = (sourceDirectory in Compile).value / "conscript" / "nyandoc"
    dir.mkdirs()
    val launchconfig = dir / "launchconfig"
    IO.write(launchconfig, content)
  }
```

### AppMain

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

### sbt plugin

Conscript sbt plugin を指定することで、依存関係とか設定してくれるっぽい。

```scala
// project/plugins.sbt
addSbtPlugin("net.databinder" % "conscript-plugin" % "0.3.5")
```

```scala
// build.sbt
seq(conscriptSettings :_*)
```

### publish設定

自前のリポジトリでjarをホスティングするためのpublish設定の例。
この設定で`sbt publish`すると`./repo/`以下に必要なファイル一式が出力されるので、適当なサーバに公開するとよい。

```scala
// build.sbt
publishTo := Some(Resolver.file("com.todesking", file("./repo/"))(Patterns(true, Resolver.mavenStyleBasePattern)))
```
