---
layout: post
title: "Javadoc/Scaladocをmarkdown形式に変換するユーティリティ作った"
date: 2015-01-24 19:55:04 +0900
comments: true
categories: 
---
[todesking/nyandoc](https://github.com/todesking/nyandoc)

Javadoc/Scaladocのhtmlをmarkdownに変換するコマンドを作りました。便利です。

scala-libraryの変換済みアーカイブも提供してます:

* http://todesking.github.io/nyandoc/scala-docs-markdown-2.11.5.zip

<iframe src="//www.slideshare.net/slideshow/embed_code/43851666" width="425" height="355" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"> <strong> <a href="//www.slideshare.net/todesking/nyandoc-scaladocjavadoc-to-markdown" title="Nyandoc: Scaladoc/Javadoc to markdown converter" target="_blank">Nyandoc: Scaladoc/Javadoc to markdown converter</a> </strong> from <strong><a href="//www.slideshare.net/todesking" target="_blank">todesking</a></strong> </div>


## インストール

[Conscript](https://github.com/n8han/conscript)ユーザの人は

```shell-session
$ cs install todesking/nyandoc
```

でインストール可能です。

それ以外の人はプロジェクトをcloneしてきて`sbt run`するなどしてください。

## 使い方

```shell-session
$ nyandoc <source-location> <dest-dir>
$ sbt 'run <source-location> <dest-dir>'
```

`source-location`にあるドキュメントをmarkdown化して`dest-dir`に保存します。

## ドキュメントの探し方

* Scala API Documentation
	* [2.11.5](http://scala-lang.org/download/2.11.5.html)
* JDK API Documentation
	* [JDK8](http://www.oracle.com/technetwork/java/javase/documentation/jdk8-doc-downloads-2133158.html)
	* [JDK7](http://www.oracle.com/technetwork/java/javase/documentation/java-se-7-doc-download-435117.html)
	* [Japanese document(1.4 - 8)](http://www.oracle.com/technetwork/jp/java/java-sun-1440465-ja.html)
* その他のドキュメント
	* mavenで配布されてるライブラリのドキュメントについては、[maven.org](http://search.maven.org)からjarが落とせる事が多い。

## ctagsを使う

`~/.ctags` にこのような設定を書いておく

```
--langdef=markdown-scala-nyandoc
--regex-markdown-scala-nyandoc=/^#+ .*(def|val|var|type)[[:space:]]+([^ (\[]+)/\2/

--langdef=markdown-java-nyandoc
--regex-markdown-java-nyandoc=/^#+ .*[[:space:]]([a-zA-Z0-9]+(<.+>)?)\(/\1/
```

ドキュメントのあるディレクトリで以下のコマンドを実行すればタグファイルができます。

```shell-session
ctags --langmap=markdown-scala-nyandoc:.md -R . # Scalaドキュメント用
ctags --langmap=markdown-java-nyandoc:.md -R .  # Javaドキュメント用
```

## Vimで閲覧する

私は`unite.vim`を使ってます。

* [unite.vim](https://github.com/Shougo/unite.vim)
* [unite-outline](https://github.com/Shougo/unite-outline)

```vim
:Unite file:.nyandoc/ -default-action=rec
```

![select-document-type](http://gyazo.todesking.com/081766c99138daccd741f3656860f637.png)

`scala-2.11.2`を選択

![select-document](http://gyazo.todesking.com/d06d318d4699b73a67fd0dad74120bf4.png)

`immutable/Seq.md`を選択

![view-document](http://gyazo.todesking.com/0ffb76891bab32d34412a3d961279e72.png)

```vim
:Unite outline
```

![view-document-outline](http://gyazo.todesking.com/70f1cb0bf27c18c1facd4ab9198ea9ac.png)

便利です。
