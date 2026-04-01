# dispatcherZ インストール ＆ 環境構築手順書（Zorin OS編）

**次世代タクシー配車・顧客管理システム**
Version: 1.0
OS: Zorin OS (Ubuntu/Debian系 Linux)

---

## はじめに
本手順書は、まっさらなZorin OS環境に「dispatcherZ」の動作に必要なすべてのインフラ（データベース、バックエンド、フロントエンド、CTI監視プログラム）を構築し、システムを実稼働させるための完全なガイドです。

ターミナル（端末）を開き、以下のステップを順番に実行してください。

---

## 1. システムの最新化と必須ツールの導入

まずはZorin OSのパッケージを最新の状態にし、開発に必要な基本ツールをインストールします。

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl unzip zip software-properties-common
```

---

## 2. データベース（MySQL）の構築

dispatcherZの心臓部となるMySQLをインストールし、専用のデータベースを作成します。

### ① MySQLのインストール
```bash
sudo apt install -y mysql-server
```

### ② データベースとユーザーの作成
MySQLのコマンドラインに入ります。
```bash
sudo mysql
```
以下のSQLコマンドを1行ずつ実行し、データベース（`dispatcherz_db`）とユーザーを作成します。（※パスワードの `your_password` は任意の強力な文字列に変更してください）

```sql
CREATE DATABASE dispatcherz_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'dispatcher'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON dispatcherz_db.* TO 'dispatcher'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

## 3. バックエンド（Laravel / PHP）の構築

APIの窓口となるPHPとLaravel環境をセットアップします。

### ① PHPと拡張モジュールのインストール
```bash
sudo apt install -y php php-cli php-fpm php-mysql php-xml php-mbstring php-curl php-zip
```

### ② Composer（PHPパッケージ管理ツール）の導入
```bash
curl -sS [https://getcomposer.org/installer](https://getcomposer.org/installer) | php
sudo mv composer.phar /usr/local/bin/composer
```

### ③ Laravelプロジェクトのセットアップ
dispatcherZのバックエンドのソースコードを任意のフォルダに配置し、そのディレクトリ内で以下のコマンドを実行します。

```bash
# パッケージのインストール
composer install

# .envファイルの作成と編集（データベース接続情報を記述）
cp .env.example .env
nano .env  # DB_DATABASE, DB_USERNAME, DB_PASSWORDを先ほどの情報に書き換えて保存

# アプリケーションキーの生成
php artisan key:generate

# データベースのテーブル作成（マイグレーション）
php artisan migrate

# サーバーの起動（※実運用の場合は、ApacheやNginx等のWebサーバーを使用してください）
php artisan serve
```

---

## 4. フロントエンド（Flutter）の構築

配車係が操作する美しいUI（Linuxデスクトップアプリ版）をビルドします。

### ① Flutter SDKのインストール
Zorin OSでは、`snap` コマンドを使うと一瞬で安全にインストールできます。
```bash
sudo snap install flutter --classic
```

### ② Linuxデスクトップ開発の有効化とパッケージ導入
Flutterプロジェクトのディレクトリに移動し、以下のコマンドを実行します。
```bash
# Linux向けビルドの有効化
flutter config --enable-linux-desktop

# 必要なライブラリのインストール
flutter pub get
```

### ③ アプリの起動（またはビルド）
```bash
# 開発モードでの起動
flutter run -d linux

# リリース用アプリ（実行ファイル）の作成
flutter build linux
```

---

## 5. CTI連携（モデム監視モジュール）の構築

アナログモデムとZorin OSを連動させ、電話着信時にシステムを自動展開させる設定です。

### ① Python通信ライブラリのインストール
```bash
sudo apt install -y python3-serial
```

### ② モデムへの恒久的なアクセス権限の付与
毎回の `sudo chmod` を不要にするため、現在のユーザーを `dialout` グループ（モデムを自由に使えるグループ）に追加します。
```bash
sudo usermod -a -G dialout $USER
```
※設定を反映させるため、**ここで一度Zorin OSを再起動（またはログアウト）**してください。

### ③ 監視スクリプトのバックグラウンド実行
再起動後、モデムを接続して監視スクリプトを起動します。
```bash
python3 cti_monitor.py
```
（※実運用時は、このPythonスクリプトがOS起動時に自動で立ち上がるように `systemd` サービス化することをおすすめします。）

---

## 🎉 構築完了！
以上でdispatcherZの実行環境が完全に整いました。
アナログモデムに着信が入ると、`/tmp/dispatcherz_incoming.txt` が生成され、Flutterアプリがそれを1秒以内に検知して画面を自動展開します。

**素晴らしい配車業務を！**