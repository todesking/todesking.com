---
layout: post
title: "innerText(textContent)/innerHTMLを使ったHTMLエスケープは充分でないので今すぐやめろ、お前たちはもう終わりだ"
date: 2015-02-05 17:51:24 +0900
comments: true
categories: 
---

JavaScriptでHTMLエスケープする方法を検索すると、以下のようなサンプルが上位を占めている。

```javascript
// jQueryでHTMLエスケープする例
function escape(content) { return $('<div />').text(content).html() }
```

テキストとして解釈してHTMLとして読み出せば確かに安全だ、これはいける！！！！！１１１ と思ってこういうことをすると

```javascript
container.innerHTML = '<a href="/path/to/some_content/' + escape(user_input) + '">CLICK HERE THIS IS SAFE I PROMISE</a>'
```

こういう入力が来て、インターネットがめちゃくちゃになってしまうので今すぐ悔い改めてほしい。

```javascript
var user_input = '" onclick="alert(1)" "'

escape(user_input)
// => '" onclick="alert(1)" "'
```

以上、`innerHTML`は`"`をエスケープしてくれるとは限らないという話でした。

じゃあどうすればいいのかというと、危険な文字を手動で置き換えるしかないんじゃないでしょうか……(下記で本当に安全なのか、それほど自信がない)

```javascript
function escapeHtml(content) {
  return content.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}
```
