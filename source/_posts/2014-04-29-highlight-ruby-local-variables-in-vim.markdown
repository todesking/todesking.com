---
layout: post
title: "Rubyのローカル変数をシンタクスハイライトするVimプラグインを書いた"
date: 2014-04-29 19:34:27 +0900
comments: true
categories: 
---

Rubyはローカル変数への参照と無引数のメソッド呼び出しを同じ記法で書けるので、コードを読むときに混乱したりtypoでNoMethodErrorを出してがっかりすることが多々あります。
幸いなことにこれらは静的に解析することができるので、ローカル変数への参照を色付けするVimプラグインを書いた。

![](/images/2014-04/demo.gif)

[Github/ruby_hl_lvar.vim](https://github.com/todesking/ruby_hl_lvar.vim)


すごく便利な気がする！！！！！！！

Rubyインタフェース(>=1.9)が有効になったVimが必要なのでご注意ください。MacVim 7.4 KaoriYa 20140107で動作確認しました。

## しくみ

Ruby1.9以降に標準添付されているripperというライブラリで、Rubyの構文解析をしてローカル変数への参照を取り出しています。

```ruby
require 'ripper'

Ripper.sexp(<<EOS)
a = 10
b = 20
c = a + b + foo
EOS

# =>
[:program,
 [[:assign, [:var_field, [:@ident, "a", [1, 0]]], [:@int, "10", [1, 4]]],
  [:assign, [:var_field, [:@ident, "b", [2, 0]]], [:@int, "20", [2, 4]]],
  [:assign,
   [:var_field, [:@ident, "c", [3, 0]]],
   [:binary,
    [:binary,
     [:var_ref, [:@ident, "a", [3, 4]]],
     :+,
     [:var_ref, [:@ident, "b", [3, 8]]]],
    :+,
    [:vcall, [:@ident, "foo", [3, 12]]]]]]]
```

ripperを使うとこのように位置情報付きの構文木が取れるので、ここからローカル変数への参照(`:var_ref`や`:assign`内の`:var_firld`等)を抽出しています。
構文木をパターンマッチして処理するのに[PATM](https://github.com/todesking/patm)というパターンマッチgemを作ったんですが詳細はいずれ。


## Vimで`matchadd()`を使ってキーワードをハイライトさせる方法

抽出したローカル変数への参照情報は、`[識別子, 行, 列]`という形式になっています。`\%(行)l\%(列)c....(識別子の文字数分)`という正規表現を使うことで指定した位置の識別子を指定可能。

できた正規表現を`matchadd()`で指定することでハイライトを登録しています。

注意点として、`matchadd()`はwindow単位で有効となるため(なぜだ)、バッファ切替時にはそれに合わせて適切に`matchdelete()`してやる必要があります。

```vim
autocmd BufWinEnter * call ruby_hl_lvar#redraw()
autocmd BufWinLeave * call ruby_hl_lvar#redraw()
autocmd WinEnter    * call ruby_hl_lvar#redraw()
autocmd WinLeave    * call ruby_hl_lvar#redraw()
autocmd TabEnter    * call ruby_hl_lvar#redraw()
autocmd TabLeave    * call ruby_hl_lvar#redraw()

function! ruby_hl_lvar#redraw()
  if w:現在のマッチ == b:現在のマッチ
    return
  endif
  call matchdelete(w:現在のマッチID)
  if b:現在のマッチ
    let w:現在のマッチID = matchadd(b:現在のマッチ)
    let w:現在のマッチ = b:現在のマッチ
  endif
endfunction
```

みたいな処理になってる。これでたぶん大丈夫なはず(自信なし)。

