---
layout: post
title: "SSL接続時にHandshakeに失敗する場合はSNIが原因かもしれない"
date: 2017-02-11 20:23:46 +0900
comments: true
categories: 
---

発端としてはCloudFrontなHostにJsoupでHTTPS接続しようとしたところ
```
javax.net.ssl.SSLHandshakeException: Received fatal alert: handshake_failure
```
というエラーになり、原因調査のためにOpenSSLで当該ホストに繋いでも同様に

```
$ openssl s_client -connect d1lto7any9tcj3.cloudfront.net:443 -debug
CONNECTED(00000003)
write to 0x7fad93d087e0 [0x7fad94007000] (130 bytes => 130 (0x82))
0000 - 80 80 01 03 01 00 57 00-00 00 20 00 00 39 00 00   ......W... ..9..
0010 - 38 00 00 35 00 00 16 00-00 13 00 00 0a 07 00 c0   8..5............
0020 - 00 00 33 00 00 32 00 00-2f 00 00 9a 00 00 99 00   ..3..2../.......
0030 - 00 96 03 00 80 00 00 05-00 00 04 01 00 80 00 00   ................
0040 - 15 00 00 12 00 00 09 06-00 40 00 00 14 00 00 11   .........@......
0050 - 00 00 08 00 00 06 04 00-80 00 00 03 02 00 80 00   ................
0060 - 00 ff a5 a9 c7 ed 47 05-40 24 f7 e7 d1 fd 33 62   ......G.@$....3b
0070 - 6c 36 0a 90 ca ee 7c 55-d9 41 b1 1b 90 7e 91 ad   l6....|U.A...~..
0080 - d3 8b                                             ..
read from 0x7fad93d087e0 [0x7fad9400c600] (7 bytes => 7 (0x7))
0000 - 15 03 01 00 02 02 28                              ......(
26360:error:14077410:SSL routines:SSL23_GET_SERVER_HELLO:sslv3 alert handshake failure:/BuildRoot/Library/Caches/com.apple.xbs/Sources/OpenSSL098/OpenSSL098-59.60.1/src/ssl/s23_clnt.c:593:
```

このようなことになってしまった。なおcurlやChromeでは普通につながる。

Server Helloの段階で拒否されてるので証明書の検証エラーではなさそう。


いろいろ調べたところ、[SNIが原因だった](http://stackoverflow.com/questions/22776032/handshake-failure-in-centos-release-5-9-final-with-openssl-1-0-1e)(検証に使用したドメインはこのページより)。
SNI対応サーバに対しては、`-servername`を指定してやらないと拒絶されるんですね。

```
$ openssl s_client -connect d1lto7any9tcj3.cloudfront.net:443 -servername d1lto7any9tcj3.cloudfront.net < /dev/null
CONNECTED(00000003)
depth=1 /C=US/O=Symantec Corporation/OU=Symantec Trust Network/CN=Symantec Class 3 Secure Server CA - G4
verify error:num=20:unable to get local issuer certificate
verify return:0
(以下略)
```

[Java7以降では標準でSNI有効](http://www.oracle.com/technetwork/jp/articles/java/enhancements7-435563-ja.html)になってるらしいんですが、
Jsoupで証明書の検証を無効にしようと`Connection#validateTLSCertificates(true)`したところ巻き添えで無効になってしまった模様。
