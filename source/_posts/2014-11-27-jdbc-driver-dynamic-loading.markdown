---
layout: post
title: "JDBCドライバを動的にロードする"
date: 2014-11-27 21:40:03 +0900
comments: true
categories: 
---

古典的な話題だけど意外と日本語リソースなかった。

クラスパス外にあるJDBCドライバを使いたいというケース。

クラスパスにある場合は、以下のようなコードでドライバを使用できる。

```scala
// クラス名を指定して明示的にドライバクラスを初期化する。
// JDBC4対応のドライバは、ServiceLoaderの機構を使用して自動でロードされるため不要。
Class.forName("com.example.MySuperDBDriver")

// 登録されたドライバの中から自動で適合するものが使用される
DriverManager.getConnection("jdbc:mysuperdb:....")
```

クラスパス外のドライバを使いたい場合、追加で

* 外部のドライバクラスをロードするための`ClassLoader`を作成
* `DriverManager`はシステムクラスローダを使った`Driver`しか使ってくれないので、ラップする

という処理を行う必要がある。

[Scalaで書くとこうなった](https://github.com/todesking/jcon/blob/05391a4392b591eb273753aa489776d4dcaeb438/src/main/scala/driver_loader.scala)


主要部分はこんなかんじ。

```scala
// 外部jarを読むためのクラスローダ作成
val systemClassLoader = getClass.getClassLoader
val driverClassLoader = java.net.URLClassLoader.newInstance(config.driverJars.map(_.toURI.toURL).toArray, systemClassLoader)

// 必要に応じてドライバをラップしてDriverManagerに登録する処理
def register(driver:Driver) = DriverManager.registerDriver(DriverProxy.wrapIfNeeded(driver, systemClassLoader))


// JDBC4非対応のドライバは、クラス名を元に手動でロードする
val unmanagedDrivers = config.uninitializedDriverClasses.map { klass =>
  Class.forName(klass, true, driverClassLoader).newInstance.asInstanceOf[Driver]
}

// DriverManagerに登録済みのドライバをクリア
// 必須ではないが、ドライバ一覧を表示したいときに重複が発生するのを避けるため。
deregisterAllDrivers()

unmanagedDrivers.foreach { driver => register(driver) }

// JDBC4に対応したドライバの場合、ServiceLoaderを使用してDriverのインスタンスを取得できる
val serviceLoader = java.util.ServiceLoader.load(classOf[java.sql.Driver], driverClassLoader)
serviceLoader.iterator.asScala.foreach { driver => register(driver) }
```

ドライバがシステムクラスローダ以外を使っている場合は、`DriverManager`を騙すためにラップするためのクラス。

```scala
class DriverProxy(val original:java.sql.Driver) extends java.sql.Driver {
  def acceptsURL(x$1: String): Boolean = original.acceptsURL(x$1)
  def connect(x$1: String,x$2: java.util.Properties): java.sql.Connection = original.connect(x$1, x$2)
  def getMajorVersion(): Int = original.getMinorVersion()
  def getMinorVersion(): Int = original.getMinorVersion()
  def getParentLogger(): java.util.logging.Logger = original.getParentLogger()
  def getPropertyInfo(x$1: String,x$2: java.util.Properties): Array[java.sql.DriverPropertyInfo] = original.getPropertyInfo(x$1, x$2)
  def jdbcCompliant(): Boolean = original.jdbcCompliant()
}

object DriverProxy {
  import java.sql.Driver

  def wrapIfNeeded(driver:Driver, classloader:ClassLoader):Driver = driver match {
    case d if d.getClass != (try { Class.forName(d.getClass.getName, true, classloader) } catch { case e:ClassNotFoundException => null }) =>
      new DriverProxy(d)
    case d => d
  }
  def unwrap(driver:Driver):Driver = driver match {
    case d:DriverProxy => d.original
    case d => d
  }
}
```

## 参照

* http://www.ne.jp/asahi/hishidama/home/tech/java/DriverManager.html#h_connect
* http://www.kfu.com/~nsayer/Java/dyn-jdbc.html
* http://stackoverflow.com/questions/288828/how-to-use-a-jdbc-driver-from-an-arbitrary-location
