---
layout: post
title: "GCCでCarbonを使用したObjective-Cのコードをコンパイルする"
date: 2014-06-08 16:11:38 +0900
comments: true
categories: 
---
自由を大切にしている老人なのでエックスコードとかいう難しいやつ使いたくないんですよ……。

結論としては以下のコマンドでいけました。

```
gcc \
  objc_code.m \
  -o output_file_name \
  -lobjc \
  -mmacosx-version-min=10.9 \
  --sysroot=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/ \
  -Wl,-framework,Carbon
```

- `-lobjc`で言語を指定する
- `-mmacosx-version-min`でOSXのバージョン指定する(どういう意味があるのか分かってません)
- `-sysroot`でOSX SDKの場所を指定する
- `-Wl`でリンカオプションを渡し、使用するフレームワーク名を指定する

良かったですね。
