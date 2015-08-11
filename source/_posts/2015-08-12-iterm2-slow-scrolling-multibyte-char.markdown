---
layout: post
title: "iTerm2の日本語表示が重いのは、フォント設定を変えれば解決するかもしれない"
date: 2015-08-12 02:36:30 +0900
comments: true
categories: 
---

<blockquote class="twitter-tweet" lang="en"><p lang="ja" dir="ltr">2015年になってもターミナルの表示が重いとか言っているしムーアの法則とはなんだったのか???????</p>&mdash; トデス子&#39;\ (@todesking) <a href="https://twitter.com/todesking/status/631139152956755968">August 11, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

* 環境: iTerm2 2.1.1

iTerm2で、非ASCII文字が大量に表示されていると描画が異常に重くなるという問題にぶつかりまして。

アンチエイリアス無効やスクロールバッファ小さくしても無駄。試行錯誤した結果、Non-ASCII Fontに設定したフォントによって表示が重くなるようだ。


![](http://gyazo.todesking.com/6ae18a372bc1c51d9a352b0d75103abb.png)

↑最初の設定(重い)

![](http://gyazo.todesking.com/71d8041a43a29ce9488f72df9d967d9f.png)

↑Non-ASCII Fontに日本語フォントを設定(軽い)


設定を変更することで、ASCII文字のみ表示されてる時と遜色ない速度になりました(めでたし)
