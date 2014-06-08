---
layout: post
title: "Scalaプロジェクトをmvnリポジトリに公開する"
date: 2014-06-08 20:50:22 +0900
comments: true
categories: 
---

github.ioにプライベートリポジトリ作ってそこにアップロードするというのをやってみた。

```scala
// build.sbt

organization := "com.todesking"

name := "library_name"

version := "1.2.3"

scalaVersion := "2.10.4"

publishTo := Some(Resolver.file("com.todesking", file("./repo/"))(Patterns(true, Resolver.mavenStyleBasePattern)))
```

くらいを指定しておく。

最後のpublishToがライブラリ出力先の指定。

この状態で `sbt publish` することで`./repo/`に成果物ができるので、その内容をアップロードすればよし。

使用時には、

```scala
resolvers += "resolver name" at "http://成果物ルートディレクトリの場所"

libraryDependencies += "(organization)" %% "(name)" % "(version)"
```

とすればよし。

