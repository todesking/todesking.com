---
layout: post
title: "ScalaプロジェクトをCircleCIでビルド+テストして、scoverageで計測したカバレッジをCOVERALLSに送るための諸設定をした"
date: 2014-11-18 18:24:16 +0900
comments: true
categories: 
---

タイトルがわかりやすい。

## 環境

* Scala 2.11.4
* sbt 0.13.6

テストフレームワークはScalaTest使ってます

## sbtでカバレッジを測定する+COVERALLSに送信する

Scalaのカバレッジ測定、[scct](http://mtkopone.github.io/scct/)というのが一般的だったけど、なにか色々あって現在は[Scoverage](https://github.com/scoverage/scalac-scoverage-plugin)という名前になって開発が継続されています。

Scoverageの最新バージョンはScala2.10をサポートしていないので注意しましょう(旧バージョン指定したら動くかも。試してないけど。)

導入は以下の通り。

```scala
// project/plugins.sbt

resolvers += Classpaths.sbtPluginReleases

// sbtでScoverage使えるようにするプラグイン
addSbtPlugin("org.scoverage" %% "sbt-scoverage" % "0.99.11")

// Scoverageの結果をCOVERALLSに送信するプラグイン
addSbtPlugin("org.scoverage" %% "sbt-coveralls" % "0.99.0")
```

```scala
// build.sbt

// scoverage
instrumentSettings

org.scoverage.coveralls.CoverallsPlugin.coverallsSettings

// この設定をしないと、結果レポートのhtmlのハイライトがおかしくなる
ScoverageKeys.highlighting := true
```

これでカバレッジ測定用のsbtタスクが使えるようになります。

* `sbt scoverage:compile`
  * カバレッジ計測のためのデータつきでコンパイルする
* `sbt scoverage:test`
  * カバレッジ計測してレポートを生成
* `sbt coveralls`
  * 生成されたレポートをCOVERALLSに送る
  * 環境変数 `COVERALLS_REPO_TOKEN` が設定されてる必要あり。

人間が見られる形式のレポートは、`target/scala-2.11/scoverage-report/index.html` にある。


## CircleCIでビルド+テスト+カバレッジ測定する

`circle.yml` の書き方は[公式ドキュメント](https://circleci.com/docs/configuration)参照。

sbtのバージョンは、`project/build.properties` で指定しておけばそれを使ってくれるようです。

```
# project/build.properties
sbt.version=0.13.6
```

```yml
# circle.yml

# scoverageのレポートを保存するよう設定
general:
  artifacts:
    - "target/*/scoverage-report"

# テスト準備コマンドを上書きしてScoverageに対応させる
dependencies:
  override:
    - "sbt scoverage:compile"

test:
  override:
    - "sbt scoverage:test"
  post:
    - "sbt coveralls" # テスト終了後COVERALLSに結果送信
```

COVERALLSのトークンを入れる環境変数 `COVERALLS_REPO_TOKEN` は、リポジトリに含めたくないのでCircleCIのプロジェクト設定画面から追加する。

あと、CircleCIはjunit形式のテスト結果xmlを認識してくれるようなのでその設定もする。

```scala
// build.sbt

// ScalaTest: Generate junit-style xml report
testOptions += Tests.Argument(TestFrameworks.ScalaTest, "-u", {val dir = System.getenv("CI_REPORTS"); if(dir == null) "target/reports" else dir} )
```

xmlは環境変数 `CI_REPORTS` から探されるので、ScalaTestのオプションとしてxmlの出力先を適切に指定してやる。


## 結果

CircleCI。 ビルド結果の"Artifacts"からカバレッジレポートのhtmlが見られる。

![](http://gyazo.todesking.com/b4ffe67050647aba5dabd934266a73af.png)



COVERALLS。結果が取れていてよかったですね。

![](http://gyazo.todesking.com/5eef870d97eef3522afcf468d5d66bb3.png)


以上、ご査収の程お願いしたく。
