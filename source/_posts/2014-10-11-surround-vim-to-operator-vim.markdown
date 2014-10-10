---
layout: post
title: "Surround.vimからvim-operator-surroundに移行した"
date: 2014-10-11 02:49:49 +0900
comments: true
categories: 
---

プリセットされた設定を使うぶんには問題なかったんだけど、textobj-userで定義したテキストオブジェクトを
surroundでも使おうとしたら不可能なことが発覚(削除処理決め打ちでカスタマイズの余地がない)。
どうしたものかと思って調査してたら[vim-operator-surround](https://github.com/rhysd/vim-operator-surround)が良さそうだったので乗り換えた。

# 基本設定

```vim
" surround.vimはアンインストールしておきましょう
NeoBundle 'kana/vim-operator-user'
NeoBundle 'rhysd/vim-operator-surround'

" 公式サンプルだとsa/sd/srだがsurround.vimに合わせた
nmap ys <Plug>(operator-surround-append)
nmap ds <Plug>(operator-surround-delete)
nmap cs <Plug>(operator-surround-replace)
```

基本機能使うならこれだけでよし。注意点としては、surround.vimとはキーストロークが変わる。

* surround.vim: cs{surround text objectを表す一文字}
* operator-surround: cs{テキストオブジェクトを選択する任意のキーストローク(a", i'等)}

具体的には、surround.vimにおいて囲みの種類を変更するキーストローク`cs'(`は、operator-surroundでは`csa'(`になります。
削除も同様。
囲みを追加する`ysaw"`等については、変更なしでそのまま通る。


# textobjの追加

新しいsurround text objを定義したいときは `g:operator#surround#blocks` を設定します。

```vim
" デフォルト値を使いつつユーザ定義を追加する。もっとマシな方法ある気がするけど動くのでまあよし。
" この例は関数呼び出しっぽいパターンを定義してる。
let g:operator#surround#blocks = deepcopy(g:operator#surround#default_blocks)
call add(g:operator#surround#blocks['-'],
\     {'block': ['\<\[a-zA-z0-9_?!]\+\[(\[]', '\[)\]]'], 'motionwise': 'char', 'keys': ['c']} )
```

`block`に囲み開始と終了のパターン、`motionwise`は選択モード(文字、行、ブロック)、`keys`は囲みを追加するときのキー。
囲みの追加は、パターンが正規表現だとうまく動きません。

正規表現を使用する場合、`\V`前提なので注意。

surround.vimと比較してカスタマイズは大幅に楽になったので、乗り換える価値はあった。

