---
layout: post
title: "Scala、unapplyまとめ"
date: 2014-10-03 17:33:55 +0900
comments: true
categories: 
---

`match`式のパターンとして`unapply`/`unapplySeq`が定義されたオブジェクトを指定することで、動作をカスタマイズできる。

参考資料は例によって[Scala Language Specification Version 2.9(pdf)](http://scala-lang.org/files/archive/nightly/pdfs/ScalaReference.pdf)。ちょっと古いけどこのへんのルールは今も変わってないと思われる。Chapter 8あたり。


| 引数 | メソッド |
| :--  | :--      |
| `()` | `unapply(a:A):Boolean` |
| `(p1)` | `unapply(a:A):Option[T1]` |
| `(p1, ..., pn)` | `unapply(a:A):Option[(T1, ..., Tn)]` |
| `(p1, ..., _*)` | `unapplySeq(a:A):Seq[T]` |



