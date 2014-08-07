---
layout: post
title: "1_as_identity_functionという超便利gemを作ったけどRuby 2.2により有難味が薄れる模様"
date: 2014-08-08 01:31:32 +0900
comments: true
categories: 
---

[Ruby2.2でObject#itselfというメソッドが導入されるとのこと](http://niku.name/articles/2014/08/06/Ruby2.2%E3%81%AB%E5%85%A5%E3%82%8BObject%23itself%E3%81%AE%E4%BD%BF%E3%81%84%E3%81%A9%E3%81%93%E3%82%8D)。

`group_by`等のメソッドで「その要素自身」を返すブロックを渡したいことはたまにあるので、`{|x| x}` のかわりに`&:itself`って書けばいいのは便利ですね。

という記事を読んで、以前同じ動機でgemを作ったことを思い出した。

[1_as_identity_function](https://github.com/todesking/1_as_identity_function)

名前そのままなんだけど、なんと！！ `&1` で `{|x| x}` 相当です。便利。

```ruby
group_by {|x| x}
group_by(&:itself)
group_by(&1)
```
itselfなげえ……


ちなみになぜ`&1`かというと、
<a href="http://commons.wikimedia.org/wiki/File:Lead_Photo_For_Category_(mathematics)0-41319275833666325.png#mediaviewer/File:Lead_Photo_For_Category_(mathematics)0-41319275833666325.png">圏論ではidentityを表現するのに`1`を使う風習があって</a>
かっこよかったからです
