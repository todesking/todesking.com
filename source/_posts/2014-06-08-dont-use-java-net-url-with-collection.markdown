---
layout: post
title: "java.net.URLをHashMapに突っ込むと大変なことになるのでやめろ、それどころかequalsを呼ぶだけでも大変なことに"
date: 2014-06-08 17:01:54 +0900
comments: true
categories: 
---

参照: http://stackoverflow.com/questions/2348399/why-does-java-net-urls-hashcode-resolve-the-host-to-an-ip

公式ドキュメントによると:

> public boolean equals(Object obj)
>
> ...
>
> 2 つの URL オブジェクトが等しいのは、同じプロトコルを持ち、同じホストを参照し、ホスト上のポート番号が同じで、ファイルとファイルのフラグメントが同じ場合です。
>
> 2 つのホストが等価と見なされるのは、両方のホスト名が同じ IP アドレスに解決されるか、どちらかのホスト名を解決できない場合は、大文字小文字に関係なくホスト名が等しいか、両方のホスト名が null に等しい場合です。
>
> <strong>ホスト比較には名前解決が必要なので、この操作はブロック操作です。</strong>
>
> <cite>[java.net.URL#equals()](http://docs.oracle.com/javase/jp/7/api/java/net/URL.html#equals\(\))</cite>

もちろん等価性に依存する`hashCode()`などのこの影響を受けるので、うっかりコレクションに`URL`を格納すると大量の名前解決が発生して死ぬほど遅くなる。

## 代替案:`java.net.URI`を使う

ではどうするのがいいかというと、`java.net.URI`のほうを使うと名前解決しないので良いです。

基本的には同じような操作が可能ですが、`java.net.URL`より書式に厳密なので注意。不正な文字列を与えると`java.net.URISyntaxException`になります。

よくある日本語文字列がそのまま入ったURLなどもアウトなので、事前に`java.net.URLEncoder`などを使ってダメな文字をエスケープする必要があります。


