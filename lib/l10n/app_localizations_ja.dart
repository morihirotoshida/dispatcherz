// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'dispatcherZ';

  @override
  String get language => '言語';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get newDispatch => '新規伝票を作成';

  @override
  String get closeDispatch => '伝票を閉じる';

  @override
  String get fileMenu => 'ファイル';

  @override
  String get viewMenu => '表示';

  @override
  String get reservationList => '予約リスト';

  @override
  String get dashboardGeneral => '履歴・予約一覧 (一般)';

  @override
  String get dashboardAdmin => '履歴・予約一覧 (管理者)';

  @override
  String get settingsMenu => '設定';

  @override
  String get modeChangeMenu => 'モード変更';

  @override
  String get lightMode => 'ライトモード';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get colorMode => 'カラーモード';

  @override
  String get saveDeleteLayout => '画面の保存／削除';

  @override
  String get loadSavedLayout => '保存した画面を読み込む';

  @override
  String get noSavedLayouts => '保存された画面はありません';

  @override
  String get changeAdminPin => '管理者PINの変更';

  @override
  String get helpMenu => 'ヘルプ';

  @override
  String get aboutApp => 'dispatcherZについて';

  @override
  String get exitApp => '配車業務の終了';

  @override
  String get customerNumberAuto => '顧客番号 (自動生成)';

  @override
  String get customerName => '顧客名';

  @override
  String get phoneNumberRequired => '電話番号 (必須)';

  @override
  String get phoneHint => 'ハイフンなしで入力し、Enterで顧客情報を検索';

  @override
  String get pickupLocation1 => '配車場所１';

  @override
  String get pickupLocation2 => '配車場所２';

  @override
  String get pickupLocation3 => '配車場所３';

  @override
  String get dispatchDateTime => '配車日時';

  @override
  String get completionDateTime => '配車完了日時';

  @override
  String get monthLabel => '月';

  @override
  String get dayLabel => '日';

  @override
  String get hourLabel => '時';

  @override
  String get minuteLabel => '分';

  @override
  String get callArea => '呼び出し (無線コールエリア)';

  @override
  String get guidance => '誘導先 (移動局への誘導案内)';

  @override
  String get destination => '配車先 (移動局の番号)';

  @override
  String get saveComplete => 'データ保存 / 完了';

  @override
  String get resaveChanges => '変更を再保存';

  @override
  String get closeButton => '閉じる';

  @override
  String get saveButton => '保存する';

  @override
  String get savedButton => '保存済み';

  @override
  String get cancelButton => 'キャンセル';

  @override
  String get closeDispatchConfirmTitle => '伝票を閉じますか？';

  @override
  String get closeDispatchConfirmContent => '必要であれば保存してから閉じてください。';

  @override
  String get searchMapTooltip => '地図を検索して座標を記憶';

  @override
  String get zoomIn => '地図を拡大';

  @override
  String get zoomOut => '地図を縮小';

  @override
  String get reservationListTitle => '予約リスト (未手配)';

  @override
  String get noWaitingReservations => '待機中の予約はありません';

  @override
  String get dashboardTitleGeneral => '履歴・予約 一元管理ダッシュボード';

  @override
  String get dashboardTitleAdmin => '履歴・予約 一元管理ダッシュボード (管理者)';

  @override
  String get allFilters => 'すべて';

  @override
  String get reservedOnlyFilter => '予約配車のみ';

  @override
  String get completedOnlyFilter => '配車完了のみ';

  @override
  String get cancelFilter => 'キャンセル';

  @override
  String get searchHint => '電話番号、名前で検索...';

  @override
  String get noDateLimit => '期間指定なし (全件)';

  @override
  String get periodPrefix => '期間:';

  @override
  String get colCustomerNo => '顧客番号';

  @override
  String get colDispatchId => '伝票ID';

  @override
  String get colDispatchDate => '配車日時';

  @override
  String get colCompletionDate => '配車完了日時';

  @override
  String get colStatus => 'ステータス';

  @override
  String get colDestination => '移動局';

  @override
  String get statusReserved => '予約配車';

  @override
  String get statusCompleted => '配車完了';

  @override
  String get statusCanceled => 'キャンセル';

  @override
  String get statusUnknown => '不明';

  @override
  String get tooltipImportCsv => 'CSVファイルからデータを一括インポート';

  @override
  String get tooltipExportCsv => '表示中のデータをCSVで出力 (管理者のみ)';

  @override
  String get tooltipRefresh => '最新のデータをMySQLから取得';

  @override
  String get tooltipCloseTab => 'このダッシュボードタブを閉じる';

  @override
  String get colPhone => '電話番号';

  @override
  String get exitConfirmTitle => '本日もお疲れ様でした';

  @override
  String get exitConfirmContent => '配車業務を終了し、ウインドウを閉じますか？';

  @override
  String get exitButton => '終了する';

  @override
  String get aboutTitle => 'dispatcherZ について';

  @override
  String get aboutAuthor => '作者：利田盛宏';

  @override
  String get aboutSource => 'ソースコード：';

  @override
  String get aboutLicense => '本ソフトウェアは、GPLライセンス 3.0に準拠します。';

  @override
  String get pinChangeTitle => '管理者PINコードの変更';

  @override
  String get pinChangeInstruction => '現在のPINコードと、新しいPINコードを入力してください。';

  @override
  String get currentPin => '現在のPINコード';

  @override
  String get newPin => '新しいPINコード';

  @override
  String get confirmNewPin => '新しいPINコード（確認用）';

  @override
  String get pinMismatch => '新しいPINコードが一致しません。';

  @override
  String get fillAllFields => 'すべての項目を入力してください。';

  @override
  String get pinChangeSuccess => '管理者PINコードを変更しました。';

  @override
  String get pinChangeFailed => '現在のPINコードが間違っています。';

  @override
  String get commError => '通信エラーが発生しました。';

  @override
  String get saveChangesButton => '変更を保存';

  @override
  String get tabNewDispatch => '　新規伝票 (未入力)　';

  @override
  String get tabDashboardGeneral => '　履歴・予約一覧 (一般)　';

  @override
  String get tabDashboardAdmin => '　履歴・予約一覧 (管理者)　';

  @override
  String get layoutDialogTitle => '画面の保存／削除';

  @override
  String get layoutDialogContent => '配車係の名前やシフト名（「山田用」「夜勤」など）を入力してください。';

  @override
  String get layoutNameLabel => 'レイアウト名';

  @override
  String get deleteLayoutBtn => '画面の削除';

  @override
  String get saveLayoutBtn => '画面の保存';

  @override
  String layoutDeletedMsg(String name) {
    return 'レイアウト「$name」を削除しました。';
  }

  @override
  String layoutSavedMsg(String name) {
    return 'レイアウトを「$name」として保存しました。';
  }

  @override
  String get tooltipTabList => '開いているタブの一覧を表示';

  @override
  String get tooltipSearchCustomer => '電話番号から顧客を検索';

  @override
  String get errorPhoneRequired => '電話番号は必須項目です。数値を入力してください。';

  @override
  String layoutLoadedMsg(String profile) {
    return 'レイアウト「$profile」を読み込みました。';
  }

  @override
  String snackIncomingCall(String phone) {
    return '📞 着信がありました！電話番号: $phone';
  }

  @override
  String get snackCustomerFound => '過去の履歴から顧客情報を読み込みました。';

  @override
  String get snackCustomerNotFound => '新規のお客様です。該当する電話番号の履歴はありません。';

  @override
  String snackAdminAuthError(String statusCode, String body) {
    return 'エラー $statusCode: $body';
  }

  @override
  String get dialogAdminAuthTitle => '🔐 管理者認証';

  @override
  String get dialogAdminAuthContent => '管理者用ダッシュボードを開きます。\n管理者PINコードを入力してください。';

  @override
  String get authButton => '認証';

  @override
  String snackStatusChanged(String id, String status) {
    return '伝票 #$id を「$status」に変更しました。';
  }

  @override
  String get snackStatusChangeFailed => 'ステータス変更に失敗しました。';

  @override
  String dialogStatusChangeTitle(String id) {
    return 'ステータス変更: #$id';
  }

  @override
  String dialogStatusChangeContent(String name) {
    return '伝票（$name 様）の新しいステータスを選んでください。';
  }

  @override
  String get backButton => '戻る';

  @override
  String get revertReservationBtn => '予約配車に戻す';

  @override
  String snackCsvExportSuccess(String path) {
    return 'CSVを出力しました:\n$path';
  }

  @override
  String snackCsvExportFailed(String error) {
    return 'CSVの出力に失敗しました: $error';
  }

  @override
  String get snackCsvImportSuccess => 'CSVデータのインポートに成功しました！';

  @override
  String get snackCsvImportFailed => 'インポートに失敗しました。ファイル形式を確認してください。';

  @override
  String snackErrorOccurred(String error) {
    return 'エラーが発生しました: $error';
  }

  @override
  String get snackDataRefreshed => 'MySQLからデータを最新に更新しました。';

  @override
  String snackDateRangeLimit(String limit) {
    return '⚠️ データベース保護のため、一度に検索できる期間は最大$limitまでに制限されています。';
  }

  @override
  String get limitOneYear => '1年間';

  @override
  String get limitThreeMonths => '3ヶ月間';

  @override
  String tabIncomingCall(String phone) {
    return '　📞着信: $phone　';
  }

  @override
  String tabEditingCustomer(String name) {
    return '　$name (入力中)　';
  }

  @override
  String tabSavedDispatch(String title) {
    return '　$title (保存済)　';
  }

  @override
  String get adminPinLabel => '管理者PINコード';

  @override
  String get unnamedCustomer => '名称未設定';

  @override
  String tabCustomerName(String name) {
    return '　$name 様　';
  }

  @override
  String listCustomerName(String name) {
    return '$name 様';
  }
}
