# 🛠 dispatcherZ 再構築ガイド (Zorin OS / 非Snap完全版)

このドキュメントは、Zorin OS上に「Snap」を使用せず、安定した開発環境（Laravel + Flutter + CTI）を構築するための公式手順書です。日本語入力（Mozc）との相性や権限エラーを回避した、実戦的な構成になっています。

---

## 1. システムの基本更新
OSインストール直後のパッケージリストを最新の状態にします。

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. バックエンド環境 (PHP / MySQL)
Snap版のMySQLで発生しがちな「パスワードポリシー」や「ソケットエラー」を避けるため、標準のAPTパッケージを使用します。
PHP & 拡張機能のインストール

```bash
sudo apt install -y php php-curl php-xml php-mbstring php-mysql php-zip php-bcmath php-gd php-intl unzip
```

Composer (PHPパッケージ管理)

```bash
curl -sS [https://getcomposer.org/installer](https://getcomposer.org/installer) | php
sudo mv composer.phar /usr/local/bin/composer
```

MySQL 8.0 サーバーの構築

```bash
sudo apt install -y mysql-server

# データベースとユーザーの作成
# ※パスワードは英大文字・小文字・数字・記号を混ぜる必要があります
sudo mysql -u root -e "CREATE DATABASE dispatcherz_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -u root -e "CREATE USER 'dispatcher'@'localhost' IDENTIFIED BY 'DispatcherZ-2026#';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON dispatcherz_db.* TO 'dispatcher'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"
```
---

## 3. フロントエンド環境 (Flutter / Dart)
Snap版のFlutterは日本語入力（Mozc）で不具合が出やすいため、公式バイナリによる手動インストールを推奨します。
Flutter SDKの配置
Flutter公式からSDKをダウンロード。
~/development/flutter 等に展開。
~/.bashrc にパスを追記：
export PATH="$PATH:$HOME/development/flutter/bin"
Linux開発用依存パッケージ

```bash
sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
```

Linuxデスクトップ開発を有効化

```bash
flutter config --enable-linux-desktop
```

## 4. 開発ツール (Visual Studio Code)
Snap版ではなく、日本語入力が安定する 公式 .deb 版 をインストールします。

```bash
wget -O vscode.deb '[https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64](https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64)'
sudo apt install -y ./vscode.deb
rm vscode.deb
```

## 5. CTI連携環境 (Python / Serial)
アナログモデム通信（CTI）に必要なPythonライブラリをインストールします。

```bash
sudo apt install -y python3-serial
# 実行確認: python3 cti_monitor.py
```

## 🎉 構築完了！
以上でdispatcherZの実行環境が完全に整いました。
アナログモデムに着信が入ると、`/tmp/dispatcherz_incoming.txt` が生成され、Flutterアプリがそれを1秒以内に検知して画面を自動展開します。

**素晴らしい配車業務を！**