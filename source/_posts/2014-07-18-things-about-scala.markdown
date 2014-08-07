---
layout: post
title: "Scala雑記"
date: 2014-07-18 18:05:15 +0900
comments: true
categories: 
---

しばらく前ですが、[Scalive #1](http://connpass.com/event/6903/)というところでLTしてきました。

<iframe src="//www.slideshare.net/slideshow/embed_code/37032167" width="427" height="356" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px 1px 0; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe>  <a href="https://www.slideshare.net/todesking/scala3" title="Scalaのコンパイルを3倍速くした話" target="_blank">Scalaのコンパイルを3倍速くした話</a> 

こういう実務寄りのScalaイベントって珍しい気がしますね。なんと発表者が誰もモナドって言わなかった！！ その代わりコンパイル速度について言及されまくってましたが……。


3月末からScalaでアドテクやるという会社に転職したのでScalaでアドテクをやってますが、Rubyでソシャゲやるのとそれほど感覚は変わらない。どちらも制限時間付きの大量リクエストをさばく必要があるけど、それなりのインフラがあれば、あとはふつうに高品質なコードを書いて粛々とレスポンスを返すのみですよワハハ。なのでハイパフォーマンスまわりのおもしろい話はできません。まあ常識で設計してふつうに開発すればいいんじゃないの。とか言ってると強い人から殴られそうだな……


最近は技術的負債の返済を主なミッションとしてビルドシステムの見直しとかフラジャイルなテストを叩いて直すとかやっているのだけど、とにかく依存性管理に悩まされることが多い。これはScalaというよりJavaのエコシステムに起因してるのだけど、とにかくお前らライブラリをちゃんと管理してほしい……。


例を挙げる。

* プロジェクトが依存している `hbase` が `jruby-complete` に依存しており、`jruby-complete`にはなぜか`joda-time`ライブラリ(古い)のクラスまで同梱されている
* いっぽうプロジェクト自身も`joda-time`(新しい)へ依存している

その結果、クラスパスの順序によってコンパイルが通ったり通らなかったりする。


この手の「複数のモジュールが同じクラスを含んでいる」問題があまりにだるいので[sbt-conflict-classes](https://github.com/todesking/sbt-conflict-classes)というsbtプラグインを作った。クラスパス内の衝突しているクラスを抽出して表示するという代物で、トラブルシュートにたいへん便利。このへんの依存性解決ノウハウはそのうちまとめたいです。あとジャバコミュニティは同一jarに別ライブラリのクラスを同梱したりバージョンアップ時にorganization名変えたりするのをやめろ(みんな困ってないんだろうか……)。
