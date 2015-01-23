---
layout: post
title: "Mac OSX: Vimで選択した領域をHTML化してクリップボードにコピーするコマンド"
date: 2015-01-23 21:02:29 +0900
comments: true
categories: 
---

KeyNoteでスライド作ってると、シンタクスハイライトしたコードを貼りたくなることがあるのですが、Vimでやろうとすると非常に厄介。

* 選択領域のHTML化自体は`:TOhtml`コマンドで可能
* HTMLをそのままKeyNoteにコピペするとプレインテキスト扱いになる
* 生成されたHTMLをファイルに保存→Safariで開く→コピペ という手順を踏むことで貼り付け可能

あまりにもつらいので調査したところ、`textutil`と`pbcopy`コマンド(どちらもMac標準だと思います)を組み合わせることで解決することがわかった。

[copy_html.vim](https://github.com/todesking/vimfiles/blob/master/plugin/copy_html.vim)
```vim
" 選択領域(またはファイル全体)のハイライトをHTML化→rtf化してクリップボードにコピーするコマンド
command! -nargs=0 -range=% CopyHtml call s:copy_html()

function! s:copy_html() abort " {{{
	'<,'>TOhtml
	w !textutil -format html -convert rtf -stdin -stdout | pbcopy
	bdelete!
endfunction " }}}
```

便利！！！！！！！！！！！！！！！！！！！！！！！(以上です)
