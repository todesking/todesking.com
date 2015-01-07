---
layout: post
title: "Java8 Nashornのパフォーマンス特性"
date: 2015-01-07 20:34:47 +0900
comments: true
categories: 
---
コンパイラ型言語において、動的に生成した処理を実行したいという状況がある。例えば、

* 言語処理系
* DBに格納された複雑な条件を元にしたフィルタ処理
* [遺伝的プログラミング](http://ja.wikipedia.org/wiki/遺伝的プログラミング)

Javaには以前からJavaScriptエンジン(Rhino)が同梱されていたが、[Java 8からはNashornと呼ばれる高速化されたエンジンになった](https://blogs.oracle.com/wlc/entry/javaee_c117)。従来よりも圧倒的に速いらしいので、動的コード生成が必要な場所で使えるかどうか、パフォーマンス特性について調べてみた。

結論としては、

* 関数の実行速度は超高速。Scalaでナイーブに実装したインタプリタより速い。
* かわりに関数定義が遅い(すごく)
* 動的に生成したい処理が小数で、評価回数が*すごく*多い場合はインタプリタ作るよりもJSに変換してNashornで実行したほうが高速。
* 関数定義/実行比が大きい場合は、オーバヘッドがあるので自分でインタプリタ書いたほうがいい。

以下詳細。[ベンチマークコードはこちら](https://github.com/todesking/sandbox/blob/master/nashorn_benchmark/src/main/scala/Main.scala)


## 関数の実行速度はすごい

適当にでっち上げたLisp風言語インタプリタもどきと比較して、同内容の処理が1.5 〜 2倍速い。

```
Native(N=12000000): 38[ms]
Neive(N=12000000): 4245[ms]
Oracle Nashorn(+)(N=12000000): 1709[ms]
Oracle Nashorn(function)(N=12000000): 2673[ms]
```

NeiveがScala、下の二つがJS。律儀に関数呼び出ししても1.5倍、+に展開すると2倍速い。

NativeはふつうにScalaの関数オブジェクトで書いたやつ。静的に定義可能な処理は静的に定義したほうがいいのがわかる。

## 関数定義は遅い

```
Oracle Nashorn define function(cached)(N=1000): 35[ms]
Oracle Nashorn define function(uncached)(N=1000): 1280[ms]
```

`(cached)`は同一の関数定義を1000回繰り返したケース。`(uncached)`は一回ごとに関数定義内の定数を変えている。
関数定義があまりにも遅いのでキャッシュが実装されているらしいことが伺える。

## 適用例

[Scalaによる遺伝的プログラミング実装](https://github.com/todesking/sandbox/blob/master/gp/src/main/scala/main.scala)に、[ツリーの内容をJSに変換する最適化処理を実装してみた](https://github.com/todesking/sandbox/blob/nashorn/gp/src/main/scala/main.scala)んですが、このユースケース(関数1k回定義→600k回実行くらい。実行速度はナイーブ実装で1ms以下)だと10倍くらい遅くなるので使えななかったです(´･_･`)
