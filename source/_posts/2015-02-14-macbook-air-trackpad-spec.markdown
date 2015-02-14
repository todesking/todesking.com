---
layout: post
title: "MacBook Airのトラックパッド買った。とりあえず詳細を書く"
date: 2015-02-14 16:39:16 +0900
comments: true
categories: 
---

Mac用の小型外付けトラックパッドがほしくて、しかし市販品が2種類(Apple Magic Trackpad, Logicool t651)しかなくてどちらもクソでかいという現状があり、MacBookの部品で自作できたらいいなというのがモチベーションです。


とりあえずebayで[GENUINE APPLE MACBOOK AIR A1465 11" MID 2013 TRACK PAD 923-0429](http://www.ebay.com/itm/400830899750)買った。


MacBookの部品を使用した外付けトラックパッド自作には前例があり、以下のページで紹介されてます。

* [Macbook pro trackpad conversion - bounav.free.fr](http://bounav.free.fr/wp/?p=176)
* [MacBook TrackPad USB化計画 - Gm7add9](https://gm7add9.wordpress.com/2014/06/08/macbook-trackpad-usb-mod/)

これらの資料によれば2008年くらいまでのモデルのトラックパッドはUSBインタフェースを内蔵しているため改造が容易、それ以降の物は本体側に移動しているので難しいだろうとのことなのですが、今回手に入れたトラックパッドにはUSBインタフェース内蔵マイコンが搭載されており、最近のモデルでふたたび改造可能になった可能性があります。


## 全体像

![全体像](http://gyazo.todesking.com/7a6445043bb45a9cb058ab7f453139c2.png)

写真が暗い、だがこれは序章にすぎない。

## 基板部分

![基板部分の拡大](http://gyazo.todesking.com/6f653044a9901ad759fa8467aef52b76.png)


## 搭載部品

### ML25L2006E

![](http://gyazo.todesking.com/21f6e798360130b63a79b7340fe55674.png)

基板写真いちばん右のチップ。

```
MXIC
X133580-12G
MX25L2006EZNI
3L974600
```

[Macronix のメモリIC ML25L2006Eシリーズ](http://www.macronix.com/en-us/Product/Pages/ProductDetail.aspx?PartNo=MX25L2006E)らしい。

動作電圧は2.7V - 3.6Vっぽい。データシートの見方がいまいち自信なし。

### STM32F103VB

![](http://gyazo.todesking.com/e9fc6fdd0a187df50d410c78c0971b71.png)

```
STM32F
103VBI6
HPAFB 9U
KOR 329
```

[ST STM32シリーズ STM32F103VB](http://www.st.com/web/catalog/mmc/FM141/SC1169/SS1031/LN1565/PF164493)

<blockquote>
Mainstream Performance line, ARM Cortex-M3 MCU with 128 Kbytes Flash, 72 MHz CPU, motor control, USB and CAN
</blockquote>

USBインタフェース内臓のCPU、これは期待が持てる。

動作電圧は2.0 - 3.6V とのこと。


### 謎の小さいやつら

![](http://gyazo.todesking.com/4f9495a14476e1d1e103f3cf8089807b.png)

```
JXM
B3G
  A
```

謎です。

![](http://gyazo.todesking.com/4696e734d962cd95068bb64da9856d10.png)

```
EEW
3NAA
```

謎です。

下のやつは実際は鏡面になってて(チップスケールパッケージというものだと思う)、表面の印刷を読み取るのが困難すぎる。

iFixtによるとBroadcom BCM5976A0KUB2G trackpad controllerとのこと。

## 参考情報

[iFixitのMacBook Air分解記事](https://www.ifixit.com/Teardown/MacBook+Air+11-Inch+Mid+2013+Teardown/15078)

* [トラックパッドが接続された状態の高解像度写真](https://d3nevzfk7ii3be.cloudfront.net/igi/icPZLRe2XESMmITn)
* [メインボードとの接続状態の高解像度写真](https://d3nevzfk7ii3be.cloudfront.net/igi/nnarBwdd1ElJ5sxh)

## 所感

とりあえず電源電圧として何ボルト用意すればいいのか知りたいですね。
基板上にレギュレータがあって適当に5V突っ込めば動いてくれるのか、3.3V用意しないといけないのかが不明。


フレキケーブルのコネクタが4個並んでいて、左右のコネクタはトラックパッドのセンサと接続されている模様。

おそらくはこの基板がキーボードとのインタフェースを兼ねていて、中央のコネクタのうち大きいほうがキーボードとの接続、もう一方が本体に続いている。

銀色のシールが貼られているようにみえるのは、トラックパッドのセンサ面にGNDを接続するためのものだと思われる。

その反対にある「いかにもコネクタ(8ピン)がつきそうな空きパターン」が気になる。iFixitの写真を見ると、フレキケーブル用と思われるコネクタが実装されている(未接続)。
これがテスト端子だとすると、USB信号線を楽に引き出せる可能性があるのだが。
