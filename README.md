# dispatcherZ
**dispatcherZ** は、直感的な操作と高い拡張性を備えた次世代タクシー配車・顧客管理システムです。
CTI（着信連動）による迅速な顧客検索や、OpenStreetMapを活用した地図連携により、配車業務の効率を劇的に向上させます。

## ✨ 主な機能 (Features)
- **CTI着信連動**: 電話着信と同時に新規伝票タブが自動で開き、過去の利用履歴を瞬時に検索・入力します。

- **柔軟なマルチタブUI**: 複数のお客様の伝票を並行して処理可能。ドラッグ＆ドロップでのタブ並び替えにも対応しています。

- **ダッシュボードとフィルター**: 「すべて」「予約のみ」「完了」「キャンセル」をワンクリックで切り替え。カレンダーによる期間指定検索も可能です。

- **地図システム統合**: 住所を入力するだけで、OpenStreetMap上でピンポイントに座標を特定し記録します。

- **高度な管理者機能**: 一般と管理者で権限を分離。管理者用ダッシュボードからはCSVデータのインポート/エクスポートが可能です。

- **完全多言語対応 (i18n)**: 日本語 (Japanese)、英語 (English)、韓国語 (Korean) に対応。

- **カスタムレイアウト**: 配車担当者の好みに合わせて、ライト/ダーク/カラーのテーマや画面幅を保存・復元できます。

## 🛠 技術スタック (Tech Stack)
- **Frontend**: Flutter (Linux Desktop App)

- **Backend API**: Laravel (PHP)

- **Database**: MySQL

- **CTI Integration**: Python 3

- **Map Service**: OpenStreetMap (nominatim)

## 🚀 インストールと起動 (Installation & Usage)
システムの詳細なセットアップおよび環境構築については、同梱の『dispatcherZ インストール ＆ 環境構築手引書（Zorin OS編）』をご参照ください。

### クイックスタート（Zorin OS）
専用の自動起動スクリプトとデスクトップショートカットを利用することで、ワンクリックで「Laravel API」「CTIサーバー」「Flutterアプリ本体」の3システムを全自動起動できます。

## 💻 開発者向けガイド (Getting Started)
This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)

- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)

- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 📄 ライセンス (License)
本ソフトウェアは **BSD-3-Clause License** のもとで公開されています。