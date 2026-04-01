# dispatcherZ Windows環境 セットアップガイド

本システムはLinux（Zorin OS）上で開発されましたが、クロスプラットフォーム技術（Flutter / Laravel / Python）を採用しているため、Windows環境でも完全に動作させることができます。

Windowsで本システムを稼働させる場合、以下の手順に従って環境を構築してください。

---

## 1. バックエンド（Laravel / データベース）の構築

Windowsでは、「XAMPP」などの統合開発環境を使うと簡単にPHPとMySQLを導入できます。

### ① 必須ソフトウェアのインストール
以下のツールを公式サイトからダウンロードし、インストールしてください。
* **XAMPP:** インストール後、コントロールパネルから「Apache」と「MySQL」をStart（起動）します。
* **Composer:** Windowsインストーラー（.exe）をダウンロードしてインストールします。
* **Git for Windows:** インストールしてGitを使えるようにします。

### ② データベースの作成
XAMPPのコントロールパネルからMySQLの「Admin」ボタンを押し、phpMyAdminを開きます。
「データベース」タブから、`dispatcherz_db` という名前のデータベースを新規作成してください（照合順序は `utf8mb4_unicode_ci` を推奨）。

### ③ Laravel APIのセットアップ
コマンドプロンプトを開き、`dispatcher-api` のフォルダ内で以下を実行します。

~~~cmd
# パッケージのインストール
composer install

# .envファイルの作成
copy .env.example .env
~~~

作成された `.env` ファイルをメモ帳等で開き、以下のように書き換えます。
~~~env
DB_DATABASE=dispatcherz_db
DB_USERNAME=root
DB_PASSWORD=
~~~
（※XAMPPの初期設定ではパスワードは空欄です）

保存後、以下のコマンドを続けて実行します。
~~~cmd
# アプリケーションキーの生成とマイグレーション
php artisan key:generate
php artisan migrate

# サーバーの起動
php artisan serve
~~~

---

## 2. フロントエンド（Flutter Windowsアプリ）の構築

WindowsでFlutterのデスクトップアプリをビルドするには、MicrosoftのC++ビルドツールが必要です。

### ① 必須ソフトウェアのインストール
* **Visual Studio 2022:** コミュニティ版をダウンロードし、インストール時に **「C++ によるデスクトップ開発」** に必ずチェックを入れてインストールしてください。（VS Codeとは別物です）
* **Flutter SDK:** Windows版のZIPをダウンロードし、`C:\src\flutter` 等に解凍して環境変数を通します。

### ② アプリのセットアップと【重要】Windows向けコードの変更
コマンドプロンプトで `dispatcherZ` のフォルダに移動します。

~~~cmd
# Windows向けビルドの有効化とパッケージ導入
flutter config --enable-windows-desktop
flutter pub get
~~~

**⚠️【超重要：ファイルパスの変更】⚠️**
Linux特有の `/tmp/` フォルダが存在しないため、Windows用にパスを変更します。
`C:\temp` というフォルダを事前に作成し、`lib/main.dart` の以下の部分を書き換えてください。

* 変更箇所（`_checkIncomingCall()` 関数内）:
  `final file = File('/tmp/dispatcherz_incoming.txt');`
  ↓
  `final file = File('C:\\temp\\dispatcherz_incoming.txt');`

### ③ アプリの起動・ビルド
~~~cmd
# 開発モードで起動
flutter run -d windows

# Windows用実行ファイル（.exe）の生成
flutter build windows
~~~

---

## 3. CTI連携（モデム監視モジュール）の構築

WindowsでアナログUSBモデムを使う場合、接続先が `/dev/ttyACM0` から `COM3` 等に変わります。

### ① Pythonとライブラリのインストール
* **Python 3:** 公式サイトからインストール（「Add Python to PATH」にチェックを入れる）。
* コマンドプロンプトで以下を実行します。

~~~cmd
pip install pyserial
~~~

### ② ポートの確認とスクリプトの修正
1. モデムをUSBに接続し、Windowsの「デバイスマネージャー」の「ポート (COM と LPT)」から、モデムのポート番号（例：`COM3`）を確認します。
2. `cti_monitor.py` を開き、2箇所を変更します。

**ポートの変更:**
~~~python
MODEM_PORT = 'COM3'  # デバイスマネージャーで確認した番号
~~~
**パスの変更:**
~~~python
file_path = 'C:\\temp\\dispatcherz_incoming.txt'
~~~

### ③ 監視の開始
コマンドプロンプトで以下を実行し、着信待機状態にします。
~~~cmd
python cti_monitor.py
~~~

以上で、Windows環境でもdispatcherZのシステムが利用可能になります！