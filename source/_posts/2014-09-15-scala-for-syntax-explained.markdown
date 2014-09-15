---
layout: post
title: "Scala for内包表記(for comprehension)変換ルールメモ"
date: 2014-09-15 19:26:43 +0900
comments: true
categories: 
---

Scalaの`for`は構文糖衣なんだけど、書き方に応じて`map`や`flatMap`や`forEach`に変換されてよくわからないので、ルールをまとめた。

参考資料: [Scala Language Specification Version 2.9(pdf)](http://scala-lang.org/files/archive/nightly/pdfs/ScalaReference.pdf)。ちょっと古いけどこのへんのルールは今も変わってないと思われる。

## ステップ1

出現する全てのnot irrefutableなパターン部(※)を持つジェネレータ`p <- e`を以下の形に変形する

`p <- e.withFilter { case p => true; case _ => false }`


※not irrefutable: 必ずマッチするとは限らないようなパターンの意。


## ステップ2

すべてのfor内包表記が消滅するまで、以下のルールを繰り返し適用する

### ジェネレータの変換に関するルール

#### パターン: `p <- e; if g`

`p <- e.withFilter((x1, ..., xn) => g )`、ただしx1, ..., xn はpの自由変数

#### パターン: `p1 <- e1; p2 = e2`

`(p1, p2) <- for(x1@p1 <- e1) yield { val x2@p2 = e2; (x1, x2) }`

### for内包表記の変換に関するルール

#### パターン: `for(p <- e) yield ee`

`e.map { case p => ee }`


#### パターン: `for(p1 <- e1; p2 <- e2 ...) yield ee`

`e1.flatMap { case p1 => for(p2 <- e2 ...) yield ee }`

#### パターン: `for(p <- e) ee`

`e.foreach { case p => ee }`

#### パターン: `for(p1 <- e1; p2 <- e2 ...) ee`

`e1.foreach { case p1 => for(p2 <- e2 ...) ee }`

## 難しすぎるので5秒でわかるようにしろ

* yield?
	* いいえ → foreach
	* はい → generatorの数は1個?
		* はい → map
		* いいえ → flatMap

| generator | yield? | メソッド |
|--:|--:|--:|
| 1 | yes | map |
| >1| yes | flatMap |
| >0 | no | foreach |
