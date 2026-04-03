import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'dispatcherZ'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In ja, this message translates to:
  /// **'言語'**
  String get language;

  /// No description provided for @english.
  ///
  /// In ja, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @japanese.
  ///
  /// In ja, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @newDispatch.
  ///
  /// In ja, this message translates to:
  /// **'新規伝票を作成'**
  String get newDispatch;

  /// No description provided for @closeDispatch.
  ///
  /// In ja, this message translates to:
  /// **'伝票を閉じる'**
  String get closeDispatch;

  /// No description provided for @fileMenu.
  ///
  /// In ja, this message translates to:
  /// **'ファイル'**
  String get fileMenu;

  /// No description provided for @viewMenu.
  ///
  /// In ja, this message translates to:
  /// **'表示'**
  String get viewMenu;

  /// No description provided for @reservationList.
  ///
  /// In ja, this message translates to:
  /// **'予約リスト'**
  String get reservationList;

  /// No description provided for @dashboardGeneral.
  ///
  /// In ja, this message translates to:
  /// **'履歴・予約一覧 (一般)'**
  String get dashboardGeneral;

  /// No description provided for @dashboardAdmin.
  ///
  /// In ja, this message translates to:
  /// **'履歴・予約一覧 (管理者)'**
  String get dashboardAdmin;

  /// No description provided for @settingsMenu.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settingsMenu;

  /// No description provided for @modeChangeMenu.
  ///
  /// In ja, this message translates to:
  /// **'モード変更'**
  String get modeChangeMenu;

  /// No description provided for @lightMode.
  ///
  /// In ja, this message translates to:
  /// **'ライトモード'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In ja, this message translates to:
  /// **'ダークモード'**
  String get darkMode;

  /// No description provided for @colorMode.
  ///
  /// In ja, this message translates to:
  /// **'カラーモード'**
  String get colorMode;

  /// No description provided for @saveDeleteLayout.
  ///
  /// In ja, this message translates to:
  /// **'画面の保存／削除'**
  String get saveDeleteLayout;

  /// No description provided for @loadSavedLayout.
  ///
  /// In ja, this message translates to:
  /// **'保存した画面を読み込む'**
  String get loadSavedLayout;

  /// No description provided for @noSavedLayouts.
  ///
  /// In ja, this message translates to:
  /// **'保存された画面はありません'**
  String get noSavedLayouts;

  /// No description provided for @changeAdminPin.
  ///
  /// In ja, this message translates to:
  /// **'管理者PINの変更'**
  String get changeAdminPin;

  /// No description provided for @helpMenu.
  ///
  /// In ja, this message translates to:
  /// **'ヘルプ'**
  String get helpMenu;

  /// No description provided for @aboutApp.
  ///
  /// In ja, this message translates to:
  /// **'dispatcherZについて'**
  String get aboutApp;

  /// No description provided for @exitApp.
  ///
  /// In ja, this message translates to:
  /// **'配車業務の終了'**
  String get exitApp;

  /// No description provided for @customerNumberAuto.
  ///
  /// In ja, this message translates to:
  /// **'顧客番号 (自動生成)'**
  String get customerNumberAuto;

  /// No description provided for @customerName.
  ///
  /// In ja, this message translates to:
  /// **'顧客名'**
  String get customerName;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In ja, this message translates to:
  /// **'電話番号 (必須)'**
  String get phoneNumberRequired;

  /// No description provided for @phoneHint.
  ///
  /// In ja, this message translates to:
  /// **'ハイフンなしで入力し、Enterで顧客情報を検索'**
  String get phoneHint;

  /// No description provided for @pickupLocation1.
  ///
  /// In ja, this message translates to:
  /// **'配車場所１'**
  String get pickupLocation1;

  /// No description provided for @pickupLocation2.
  ///
  /// In ja, this message translates to:
  /// **'配車場所２'**
  String get pickupLocation2;

  /// No description provided for @pickupLocation3.
  ///
  /// In ja, this message translates to:
  /// **'配車場所３'**
  String get pickupLocation3;

  /// No description provided for @dispatchDateTime.
  ///
  /// In ja, this message translates to:
  /// **'配車日時'**
  String get dispatchDateTime;

  /// No description provided for @completionDateTime.
  ///
  /// In ja, this message translates to:
  /// **'配車完了日時'**
  String get completionDateTime;

  /// No description provided for @monthLabel.
  ///
  /// In ja, this message translates to:
  /// **'月'**
  String get monthLabel;

  /// No description provided for @dayLabel.
  ///
  /// In ja, this message translates to:
  /// **'日'**
  String get dayLabel;

  /// No description provided for @hourLabel.
  ///
  /// In ja, this message translates to:
  /// **'時'**
  String get hourLabel;

  /// No description provided for @minuteLabel.
  ///
  /// In ja, this message translates to:
  /// **'分'**
  String get minuteLabel;

  /// No description provided for @callArea.
  ///
  /// In ja, this message translates to:
  /// **'呼び出し (無線コールエリア)'**
  String get callArea;

  /// No description provided for @guidance.
  ///
  /// In ja, this message translates to:
  /// **'誘導先 (移動局への誘導案内)'**
  String get guidance;

  /// No description provided for @destination.
  ///
  /// In ja, this message translates to:
  /// **'配車先 (移動局の番号)'**
  String get destination;

  /// No description provided for @saveComplete.
  ///
  /// In ja, this message translates to:
  /// **'データ保存 / 完了'**
  String get saveComplete;

  /// No description provided for @resaveChanges.
  ///
  /// In ja, this message translates to:
  /// **'変更を再保存'**
  String get resaveChanges;

  /// No description provided for @closeButton.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get closeButton;

  /// No description provided for @saveButton.
  ///
  /// In ja, this message translates to:
  /// **'保存する'**
  String get saveButton;

  /// No description provided for @savedButton.
  ///
  /// In ja, this message translates to:
  /// **'保存済み'**
  String get savedButton;

  /// No description provided for @cancelButton.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancelButton;

  /// No description provided for @closeDispatchConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'伝票を閉じますか？'**
  String get closeDispatchConfirmTitle;

  /// No description provided for @closeDispatchConfirmContent.
  ///
  /// In ja, this message translates to:
  /// **'必要であれば保存してから閉じてください。'**
  String get closeDispatchConfirmContent;

  /// No description provided for @searchMapTooltip.
  ///
  /// In ja, this message translates to:
  /// **'地図を検索して座標を記憶'**
  String get searchMapTooltip;

  /// No description provided for @zoomIn.
  ///
  /// In ja, this message translates to:
  /// **'地図を拡大'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In ja, this message translates to:
  /// **'地図を縮小'**
  String get zoomOut;

  /// No description provided for @reservationListTitle.
  ///
  /// In ja, this message translates to:
  /// **'予約リスト (未手配)'**
  String get reservationListTitle;

  /// No description provided for @noWaitingReservations.
  ///
  /// In ja, this message translates to:
  /// **'待機中の予約はありません'**
  String get noWaitingReservations;

  /// No description provided for @dashboardTitleGeneral.
  ///
  /// In ja, this message translates to:
  /// **'履歴・予約 一元管理ダッシュボード'**
  String get dashboardTitleGeneral;

  /// No description provided for @dashboardTitleAdmin.
  ///
  /// In ja, this message translates to:
  /// **'履歴・予約 一元管理ダッシュボード (管理者)'**
  String get dashboardTitleAdmin;

  /// No description provided for @allFilters.
  ///
  /// In ja, this message translates to:
  /// **'すべて'**
  String get allFilters;

  /// No description provided for @reservedOnlyFilter.
  ///
  /// In ja, this message translates to:
  /// **'予約配車のみ'**
  String get reservedOnlyFilter;

  /// No description provided for @completedOnlyFilter.
  ///
  /// In ja, this message translates to:
  /// **'配車完了のみ'**
  String get completedOnlyFilter;

  /// No description provided for @cancelFilter.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancelFilter;

  /// No description provided for @searchHint.
  ///
  /// In ja, this message translates to:
  /// **'電話番号、名前で検索...'**
  String get searchHint;

  /// No description provided for @noDateLimit.
  ///
  /// In ja, this message translates to:
  /// **'期間指定なし (全件)'**
  String get noDateLimit;

  /// No description provided for @periodPrefix.
  ///
  /// In ja, this message translates to:
  /// **'期間:'**
  String get periodPrefix;

  /// No description provided for @colCustomerNo.
  ///
  /// In ja, this message translates to:
  /// **'顧客番号'**
  String get colCustomerNo;

  /// No description provided for @colDispatchId.
  ///
  /// In ja, this message translates to:
  /// **'伝票ID'**
  String get colDispatchId;

  /// No description provided for @colDispatchDate.
  ///
  /// In ja, this message translates to:
  /// **'配車日時'**
  String get colDispatchDate;

  /// No description provided for @colCompletionDate.
  ///
  /// In ja, this message translates to:
  /// **'配車完了日時'**
  String get colCompletionDate;

  /// No description provided for @colStatus.
  ///
  /// In ja, this message translates to:
  /// **'ステータス'**
  String get colStatus;

  /// No description provided for @colDestination.
  ///
  /// In ja, this message translates to:
  /// **'移動局'**
  String get colDestination;

  /// No description provided for @statusReserved.
  ///
  /// In ja, this message translates to:
  /// **'予約配車'**
  String get statusReserved;

  /// No description provided for @statusCompleted.
  ///
  /// In ja, this message translates to:
  /// **'配車完了'**
  String get statusCompleted;

  /// No description provided for @statusCanceled.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get statusCanceled;

  /// No description provided for @statusUnknown.
  ///
  /// In ja, this message translates to:
  /// **'不明'**
  String get statusUnknown;

  /// No description provided for @tooltipImportCsv.
  ///
  /// In ja, this message translates to:
  /// **'CSVファイルからデータを一括インポート'**
  String get tooltipImportCsv;

  /// No description provided for @tooltipExportCsv.
  ///
  /// In ja, this message translates to:
  /// **'表示中のデータをCSVで出力 (管理者のみ)'**
  String get tooltipExportCsv;

  /// No description provided for @tooltipRefresh.
  ///
  /// In ja, this message translates to:
  /// **'最新のデータをMySQLから取得'**
  String get tooltipRefresh;

  /// No description provided for @tooltipCloseTab.
  ///
  /// In ja, this message translates to:
  /// **'このダッシュボードタブを閉じる'**
  String get tooltipCloseTab;

  /// No description provided for @colPhone.
  ///
  /// In ja, this message translates to:
  /// **'電話番号'**
  String get colPhone;

  /// No description provided for @exitConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'本日もお疲れ様でした'**
  String get exitConfirmTitle;

  /// No description provided for @exitConfirmContent.
  ///
  /// In ja, this message translates to:
  /// **'配車業務を終了し、ウインドウを閉じますか？'**
  String get exitConfirmContent;

  /// No description provided for @exitButton.
  ///
  /// In ja, this message translates to:
  /// **'終了する'**
  String get exitButton;

  /// No description provided for @aboutTitle.
  ///
  /// In ja, this message translates to:
  /// **'dispatcherZ について'**
  String get aboutTitle;

  /// No description provided for @aboutAuthor.
  ///
  /// In ja, this message translates to:
  /// **'作者：利田盛宏'**
  String get aboutAuthor;

  /// No description provided for @aboutSource.
  ///
  /// In ja, this message translates to:
  /// **'ソースコード：'**
  String get aboutSource;

  /// No description provided for @aboutLicense.
  ///
  /// In ja, this message translates to:
  /// **'本ソフトウェアは、GPLライセンス 3.0に準拠します。'**
  String get aboutLicense;

  /// No description provided for @pinChangeTitle.
  ///
  /// In ja, this message translates to:
  /// **'管理者PINコードの変更'**
  String get pinChangeTitle;

  /// No description provided for @pinChangeInstruction.
  ///
  /// In ja, this message translates to:
  /// **'現在のPINコードと、新しいPINコードを入力してください。'**
  String get pinChangeInstruction;

  /// No description provided for @currentPin.
  ///
  /// In ja, this message translates to:
  /// **'現在のPINコード'**
  String get currentPin;

  /// No description provided for @newPin.
  ///
  /// In ja, this message translates to:
  /// **'新しいPINコード'**
  String get newPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In ja, this message translates to:
  /// **'新しいPINコード（確認用）'**
  String get confirmNewPin;

  /// No description provided for @pinMismatch.
  ///
  /// In ja, this message translates to:
  /// **'新しいPINコードが一致しません。'**
  String get pinMismatch;

  /// No description provided for @fillAllFields.
  ///
  /// In ja, this message translates to:
  /// **'すべての項目を入力してください。'**
  String get fillAllFields;

  /// No description provided for @pinChangeSuccess.
  ///
  /// In ja, this message translates to:
  /// **'管理者PINコードを変更しました。'**
  String get pinChangeSuccess;

  /// No description provided for @pinChangeFailed.
  ///
  /// In ja, this message translates to:
  /// **'現在のPINコードが間違っています。'**
  String get pinChangeFailed;

  /// No description provided for @commError.
  ///
  /// In ja, this message translates to:
  /// **'通信エラーが発生しました。'**
  String get commError;

  /// No description provided for @saveChangesButton.
  ///
  /// In ja, this message translates to:
  /// **'変更を保存'**
  String get saveChangesButton;

  /// No description provided for @tabNewDispatch.
  ///
  /// In ja, this message translates to:
  /// **'　新規伝票 (未入力)　'**
  String get tabNewDispatch;

  /// No description provided for @tabDashboardGeneral.
  ///
  /// In ja, this message translates to:
  /// **'　履歴・予約一覧 (一般)　'**
  String get tabDashboardGeneral;

  /// No description provided for @tabDashboardAdmin.
  ///
  /// In ja, this message translates to:
  /// **'　履歴・予約一覧 (管理者)　'**
  String get tabDashboardAdmin;

  /// No description provided for @layoutDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'画面の保存／削除'**
  String get layoutDialogTitle;

  /// No description provided for @layoutDialogContent.
  ///
  /// In ja, this message translates to:
  /// **'配車係の名前やシフト名（「山田用」「夜勤」など）を入力してください。'**
  String get layoutDialogContent;

  /// No description provided for @layoutNameLabel.
  ///
  /// In ja, this message translates to:
  /// **'レイアウト名'**
  String get layoutNameLabel;

  /// No description provided for @deleteLayoutBtn.
  ///
  /// In ja, this message translates to:
  /// **'画面の削除'**
  String get deleteLayoutBtn;

  /// No description provided for @saveLayoutBtn.
  ///
  /// In ja, this message translates to:
  /// **'画面の保存'**
  String get saveLayoutBtn;

  /// No description provided for @layoutDeletedMsg.
  ///
  /// In ja, this message translates to:
  /// **'レイアウト「{name}」を削除しました。'**
  String layoutDeletedMsg(String name);

  /// No description provided for @layoutSavedMsg.
  ///
  /// In ja, this message translates to:
  /// **'レイアウトを「{name}」として保存しました。'**
  String layoutSavedMsg(String name);

  /// No description provided for @tooltipTabList.
  ///
  /// In ja, this message translates to:
  /// **'開いているタブの一覧を表示'**
  String get tooltipTabList;

  /// No description provided for @tooltipSearchCustomer.
  ///
  /// In ja, this message translates to:
  /// **'電話番号から顧客を検索'**
  String get tooltipSearchCustomer;

  /// No description provided for @errorPhoneRequired.
  ///
  /// In ja, this message translates to:
  /// **'電話番号は必須項目です。数値を入力してください。'**
  String get errorPhoneRequired;

  /// No description provided for @layoutLoadedMsg.
  ///
  /// In ja, this message translates to:
  /// **'レイアウト「{profile}」を読み込みました。'**
  String layoutLoadedMsg(String profile);

  /// No description provided for @snackIncomingCall.
  ///
  /// In ja, this message translates to:
  /// **'📞 着信がありました！電話番号: {phone}'**
  String snackIncomingCall(String phone);

  /// No description provided for @snackCustomerFound.
  ///
  /// In ja, this message translates to:
  /// **'過去の履歴から顧客情報を読み込みました。'**
  String get snackCustomerFound;

  /// No description provided for @snackCustomerNotFound.
  ///
  /// In ja, this message translates to:
  /// **'新規のお客様です。該当する電話番号の履歴はありません。'**
  String get snackCustomerNotFound;

  /// No description provided for @snackAdminAuthError.
  ///
  /// In ja, this message translates to:
  /// **'エラー {statusCode}: {body}'**
  String snackAdminAuthError(String statusCode, String body);

  /// No description provided for @dialogAdminAuthTitle.
  ///
  /// In ja, this message translates to:
  /// **'🔐 管理者認証'**
  String get dialogAdminAuthTitle;

  /// No description provided for @dialogAdminAuthContent.
  ///
  /// In ja, this message translates to:
  /// **'管理者用ダッシュボードを開きます。\n管理者PINコードを入力してください。'**
  String get dialogAdminAuthContent;

  /// No description provided for @authButton.
  ///
  /// In ja, this message translates to:
  /// **'認証'**
  String get authButton;

  /// No description provided for @snackStatusChanged.
  ///
  /// In ja, this message translates to:
  /// **'伝票 #{id} を「{status}」に変更しました。'**
  String snackStatusChanged(String id, String status);

  /// No description provided for @snackStatusChangeFailed.
  ///
  /// In ja, this message translates to:
  /// **'ステータス変更に失敗しました。'**
  String get snackStatusChangeFailed;

  /// No description provided for @dialogStatusChangeTitle.
  ///
  /// In ja, this message translates to:
  /// **'ステータス変更: #{id}'**
  String dialogStatusChangeTitle(String id);

  /// No description provided for @dialogStatusChangeContent.
  ///
  /// In ja, this message translates to:
  /// **'伝票（{name} 様）の新しいステータスを選んでください。'**
  String dialogStatusChangeContent(String name);

  /// No description provided for @backButton.
  ///
  /// In ja, this message translates to:
  /// **'戻る'**
  String get backButton;

  /// No description provided for @revertReservationBtn.
  ///
  /// In ja, this message translates to:
  /// **'予約配車に戻す'**
  String get revertReservationBtn;

  /// No description provided for @snackCsvExportSuccess.
  ///
  /// In ja, this message translates to:
  /// **'CSVを出力しました:\n{path}'**
  String snackCsvExportSuccess(String path);

  /// No description provided for @snackCsvExportFailed.
  ///
  /// In ja, this message translates to:
  /// **'CSVの出力に失敗しました: {error}'**
  String snackCsvExportFailed(String error);

  /// No description provided for @snackCsvImportSuccess.
  ///
  /// In ja, this message translates to:
  /// **'CSVデータのインポートに成功しました！'**
  String get snackCsvImportSuccess;

  /// No description provided for @snackCsvImportFailed.
  ///
  /// In ja, this message translates to:
  /// **'インポートに失敗しました。ファイル形式を確認してください。'**
  String get snackCsvImportFailed;

  /// No description provided for @snackErrorOccurred.
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました: {error}'**
  String snackErrorOccurred(String error);

  /// No description provided for @snackDataRefreshed.
  ///
  /// In ja, this message translates to:
  /// **'MySQLからデータを最新に更新しました。'**
  String get snackDataRefreshed;

  /// No description provided for @snackDateRangeLimit.
  ///
  /// In ja, this message translates to:
  /// **'⚠️ データベース保護のため、一度に検索できる期間は最大{limit}までに制限されています。'**
  String snackDateRangeLimit(String limit);

  /// No description provided for @limitOneYear.
  ///
  /// In ja, this message translates to:
  /// **'1年間'**
  String get limitOneYear;

  /// No description provided for @limitThreeMonths.
  ///
  /// In ja, this message translates to:
  /// **'3ヶ月間'**
  String get limitThreeMonths;

  /// No description provided for @tabIncomingCall.
  ///
  /// In ja, this message translates to:
  /// **'　📞着信: {phone}　'**
  String tabIncomingCall(String phone);

  /// No description provided for @tabEditingCustomer.
  ///
  /// In ja, this message translates to:
  /// **'　{name} (入力中)　'**
  String tabEditingCustomer(String name);

  /// No description provided for @tabSavedDispatch.
  ///
  /// In ja, this message translates to:
  /// **'　{title} (保存済)　'**
  String tabSavedDispatch(String title);

  /// No description provided for @adminPinLabel.
  ///
  /// In ja, this message translates to:
  /// **'管理者PINコード'**
  String get adminPinLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
