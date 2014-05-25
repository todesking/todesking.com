---
layout: post
title: "Rubyで高速にパターンマッチするgemを作った"
date: 2014-05-26 00:35:42 +0900
comments: true
categories: 
---
[Ripperの出力](http://www.ruby-doc.org/stdlib-2.1.2/libdoc/ripper/rdoc/Ripper.html#method-c-sexp)とか[Parseletの解析結果](http://kschiess.github.io/parslet/get-started.html)などを扱うのに､ArrayやHashでパターンマッチして中身を取り出す処理を多用する必要があったのでパターンマッチライブラリを作りました｡

[GitHub: todesking/patm](https://github.com/todesking/patm)

同様のライブラリとしては[pattern-match](https://github.com/k-tsj/pattern-match)があります｡
機能面ではpattern-matchのほうが豊富ですが､PATMは高速なのが売りです(DSLによるメソッド定義を使用した場合､ネイティブRubyコードにコンパイルされるため50倍くらい速い｡case式内で使用した場合でも7倍程度)｡ベンチマークについてはこの記事の下のほう参照｡

## 主な機能

### DSLによるメソッド定義

`extend Patm::DSL` することで `define_matcher`を使ったメソッド定義が可能です｡

```ruby
require 'patm'

class Matcher
  extend Patm::DSL

  P = Patm
  _ = P._any
  _1, _2, _3 = P._1, P._2, P._3
  _xs = P._xs

  define_matcher :match do|r|
    # ルールオブジェクトrが引数に渡ってくるので､ on および else を使ってパターンを定義する｡
    # - on(pattern) {|match, _self| }
    #    patternにマッチした場合ブロックが呼ばれる｡
    #    match: マッチオブジェクト｡キャプチャした値にアクセスできる｡
    #    _self: 他のメソッドを呼ぶ場合､この引数を経由して呼ぶ
    # - else {|value, _self| }
    #    onで指定されたどのパターンにもマッチしなかった場合にブロックが呼ばれる｡
    #    (elseを指定しない場合はMatchError例外となる)
    #    value: マッチしなかった値
    #    _self: 上述

    r.on(value: {key: _1, value: _2}) {|m| "KV: #{m._1}, #{m._2}" }
    r.on([:assign, [:v, _1, [_2, _3]]]) {|m| "AS: #{m._1}, #{m._2}, #{m._3}" }
    r.on([:container, _1]) {|m, _self| _self.match(m._1) }
    r.else {|obj| "Unknown: #{obj.inspect}" }
  end
end

m = Matcher.new

m.match(1)
#=> Unknown: 1

m.match({value: {key: 10, value: 999}})
#=> "KV: 10, 999"

m.match([:assign, [:v, 10, [20, 30]]])
#=> "AS: 10, 20, 30"

m.match([:container, [:assign, [:v, 10, [20, 30]]]])
#=> "AS: 10, 20, 30"
```

### case式内での使用

`Patm.match(pattern)`を使用することで､case式内でパターンマッチできます｡

手軽だけど､毎回パターンオブジェクトを構築する必要があるのでDSLを使用するよりは重い｡

```ruby
case value
when m = Patm.match([1, 2, Patm._1])
  m._1
# ...
end
```

### パターン: 値によるマッチ

`1`, `"foo"`, `:symbol`, `/regex.*/`, 等｡

case式と同様､`===`による比較を行います｡

### パターン: 任意の値

`Patm._any`で任意の値にマッチします｡

### パターン: キャプチャ

`Patm._1, Patm._2, ...` は､任意の値にマッチし､その結果を対応する数字でキャプチャします｡
キャプチャした結果は､マッチオブジェクトから`m._1, m._2, ...`を使用してアクセス可能です｡

また､パターンの後ろに`[]`をつけることにより､任意の名前でキャプチャ可能です｡`Patm._any[:x]`は､マッチオブジェクトから`m[:x]`として参照可能です｡

### パターン: 配列

配列内の要素を元にマッチします｡

配列には特殊なパターン `Patm._xs` を一個だけ含めることができます｡
パターン`[1, 2, Patm._xs[:xs], 3, 4]`は､`[1, 2]`で始まり`[3, 4]`で終わる任意の配列にマッチし､中間の配列が`:xs`という名前でキャプチャされます｡

### パターン: ハッシュ

ハッシュ内の要素を元にマッチします｡今のところキーは定数のみで､パターンは使えません(需要が思いつかなかったので)｡

特殊なオブジェクト `Patm.exact`をキーに含めることで､パターンに含まれないキーを許容するかどうか指定できます｡初期設定では､パターンに含まれないキーも許容します｡

また､`Patm.opt(...)`やパターンの`.opt`メソッドを使用することで､キーが必須かどうかを指定できます｡

```ruby
# 1
{a: Patm._1, b: Patm._2.opt, Patm.exact => true}

# 2
{a: Patm._1, b: Patm._2.opt}
```
 1のパターンは､`{a: 1, b: 2}`, `{a: 1}` にはマッチしますが `{a: 1, c: 3}`にはマッチしません｡

 2のパターンは `{a: 1, b: 2}`, `{a: 1}`, `{a: 1, c: 3}` すべてにマッチします｡

### パターン: Struct

これは需要は特になかったけど､勢い余って作った｡ 構造体をScalaのcase classみたいに使える｡

`Patm[struct_class].(...pattern...)` で､`struct_class`用のパターンが作成できます｡

```ruby
Name = Struct.new(:first, :last)

case Name.new('todes', 'king')
when m = Patm.match(Patm[Name].('todes', Patm._1))
  # ...
when m = Patm.match(Patm[Name].(last: 'king')) # ハッシュで個別の属性のみ指定できる
  # ...
end
```

### パターン: 合成

`&`を使用して複数のパターンのANDを指定できます｡`_1&String` で､任意の文字列を`_1`にキャプチャできます｡

`Patm.or(...)`を使用してOR条件を指定できます｡

## コンパイル処理について

`Patm::DSL`のメソッド定義の実体は`Patm::Rule`で､下記のようにすればコンパイル後のコードが確認できます｡

```ruby
rule = Patm::Rule.new(false) {|r|
  r.on([Patm._any, 1]) { 1 }
  r.on(a: [String, Patm._xs], b: Patm._1.opt) {|m| m._1}
  r.else {|value| value }
}.compile

puts rule.src
```

```ruby
        def apply(_obj, _self = nil)
          _ctx = @context
          _match = ::Patm::Match.new
if ((_obj.is_a?(::Array)) &&
(_obj.size == 2) &&
((_obj_elm = _obj[1]; 1 === _obj_elm)))
_ctx[0].call()
elsif (_obj.is_a?(::Hash) &&
_obj.size >= 1 &&
(_obj.has_key?(:a) && (_obj_elm = _obj[:a]; (_obj_elm.is_a?(::Array)) &&
(_obj_elm.size >= 1) &&
((_obj_elm_elm = _obj_elm[0]; _ctx[2] === _obj_elm_elm)))) &&
(!_obj.has_key?(:b) || (_obj_elm = _obj[:b]; _match[1] = _obj_elm; true)))
_ctx[3].call(_match)
else
_ctx[4].call(_obj)
end
        end
```

同様の処理を手書きするのに比べると4〜5倍程度遅いようです｡マッチオブジェクトの生成と､マッチ時のproc呼び出しが原因だと思われます｡まあ実用上は全く問題ない速度が出てる｡

## ベンチマーク結果

[詳細はコード参照](https://github.com/todesking/patm/blob/e138606d8fea1f6f01bbe05976478d7bae902f60/benchmark/comparison.rb)

```
RUBY_VERSION: 2.0.0 p247

Benchmark: Empty(x10000)
                    user     system      total        real
manual          0.010000   0.000000   0.010000 (  0.012840)
patm            0.040000   0.000000   0.040000 (  0.044294)
pattern_match   2.230000   0.040000   2.270000 (  2.304750)

Benchmark: SimpleConst(x10000)
                    user     system      total        real
manual          0.010000   0.000000   0.010000 (  0.014267)
patm            0.040000   0.000000   0.040000 (  0.040269)
patm_case       0.190000   0.000000   0.190000 (  0.193041)
pattern_match   2.260000   0.020000   2.280000 (  2.321225)

Benchmark: ArrayDecomposition(x10000)
                    user     system      total        real
manual          0.050000   0.000000   0.050000 (  0.056363)
patm            0.240000   0.000000   0.240000 (  0.269492)
patm_case       2.050000   0.010000   2.060000 (  2.105357)
pattern_match  16.520000   0.100000  16.620000 ( 17.116351)

Benchmark: VarArray(x10000)
                    user     system      total        real
manual          0.050000   0.000000   0.050000 (  0.059690)
patm            0.220000   0.000000   0.220000 (  0.219058)
patm_case       1.710000   0.010000   1.720000 (  1.727676)
pattern_match  13.280000   0.090000  13.370000 ( 14.916347)
```


## 実世界における使用例

- ruby_hl_lvar.vim: [Ripperの出力解析](https://github.com/todesking/ruby_hl_lvar.vim/blob/f6f53fdf5738a17a4ac3f5398f349fcd4da3c784/autoload/ruby_hl_lvar.vim.rb#L42)
- typedocs: [Parsletの出力変換](https://github.com/todesking/typedocs/blob/27208aadf3faaf682030ae3d28b47b1fbcbc161e/lib/typedocs/parser/object_builder.rb#L39)
