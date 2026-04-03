// ============================================================================
// dispatcherZ - Main Application / メインアプリケーション
// 
// This file contains the complete frontend logic for the dispatcherZ system.
// このファイルは、dispatcherZシステムの完全なフロントエンドロジックを含んでいます。
// ============================================================================

import 'dart:convert';
import 'dart:io'; 
import 'dart:ui'; 
import 'dart:async'; 
import 'dart:math'; 
import 'package:flutter/gestures.dart'; 
import 'package:flutter/services.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:file_picker/file_picker.dart'; 
import 'l10n/app_localizations.dart';

// ============================================================================
// Module: LayoutSettings
// Description: Manages application layout states, theme settings, and profiles.
// モジュール: LayoutSettings
// 説明: アプリケーションのレイアウト状態、テーマ設定、プロファイルを管理します。
// ============================================================================
class LayoutSettings {
  static bool showReservationList = true; 
  static ValueNotifier<double> reservationListRatioNotifier = ValueNotifier(1 / 6); 
  static ValueNotifier<double> leftFormRatioNotifier = ValueNotifier(1 / 3); 
  static ValueNotifier<String> themeModeNotifier = ValueNotifier('light'); 
  static String currentLanguage = 'ja'; // ★確認1：この変数はありますか？

  // ローカルのJSONファイルからレイアウトプロファイルを読み込む
  static Future<void> load([String profileName = 'default']) async {
    try {
      final file = File('dispatcherz_layout_$profileName.json');
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());
        showReservationList = data['showReservationList'] ?? true;
        reservationListRatioNotifier.value = data['reservationListRatio'] ?? (1 / 6); 
        leftFormRatioNotifier.value = data['leftFormRatio'] ?? (1 / 3); 
        
        if (data.containsKey('themeMode')) {
          themeModeNotifier.value = data['themeMode'];
        } else if (data.containsKey('isDarkMode')) {
          themeModeNotifier.value = data['isDarkMode'] == true ? 'dark' : 'light';
        }
        currentLanguage = data['language'] ?? 'ja'; // ★確認2：ここに入っていますか？
      }
    } catch (e) {}
  }

  // 現在のレイアウトとテーマをローカルのJSONファイルに保存する
  static Future<void> save(String profileName) async {
    try {
      final file = File('dispatcherz_layout_$profileName.json');
      final data = {
        'showReservationList': showReservationList,
        'reservationListRatio': reservationListRatioNotifier.value,
        'leftFormRatio': leftFormRatioNotifier.value,
        'themeMode': themeModeNotifier.value, 
        'language': currentLanguage, // ★確認3：保存するデータに言語が含まれていますか？
      };
      await file.writeAsString(jsonEncode(data));

      final lastFile = File('dispatcherz_last_profile.txt');
      await lastFile.writeAsString(profileName);
    } catch (e) {}
  }

  // Delete a specific layout profile
  // 特定のレイアウトプロファイルを削除する
  static Future<void> delete(String profileName) async {
    try {
      final file = File('dispatcherz_layout_$profileName.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {}
  }

  // Load the most recently used profile
  // 最後に使用したプロファイルを読み込む
  static Future<void> loadLastProfile() async {
    try {
      final lastFile = File('dispatcherz_last_profile.txt');
      if (await lastFile.exists()) {
        final profile = await lastFile.readAsString();
        await load(profile);
      } else {
        await load('default');
      }
    } catch (e) {
      await load('default');
    }
  }

  // Retrieve a list of all saved profiles
  // 保存されているすべてのプロファイルのリストを取得する
  static Future<List<String>> getSavedProfiles() async {
    List<String> profiles = [];
    try {
      final dir = Directory.current;
      final files = dir.listSync();
      for (var file in files) {
        if (file is File) {
          final name = file.path.split(Platform.pathSeparator).last;
          if (name.startsWith('dispatcherz_layout_') && name.endsWith('.json')) {
            final profile = name.replaceFirst('dispatcherz_layout_', '').replaceFirst('.json', '');
            if (profile != 'default') profiles.add(profile);
          }
        }
      }
    } catch (e) {}
    return profiles..sort(); 
  }
}

// ============================================================================
// Module: formatSafeTime (Utility)
// Description: Safely formats raw datetime strings from the database.
// モジュール: formatSafeTime (ユーティリティ)
// 説明: データベースからの生の日時文字列を安全にフォーマットします。
// ============================================================================
String formatSafeTime(String? rawTime) {
  if (rawTime == null || rawTime.isEmpty) return '';
  String safeTime = rawTime.replaceAll('Z', '').replaceFirst('T', ' ');
  if (safeTime.length > 16) safeTime = safeTime.substring(0, 16);
  try {
    DateTime dt = DateTime.parse(safeTime.replaceFirst(' ', 'T'));
    // 「月/日 時:分」という万国共通のフォーマットに変更
    return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  } catch (e) {
    return safeTime;
  }
}

// ============================================================================
// Main Application Entry Point
// アプリケーションのエントリポイント
// ============================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LayoutSettings.loadLastProfile(); 
  runApp(const DispatcherZApp());
}

// ============================================================================
// Module: DispatcherZApp
// Description: Root widget that configures themes and localization.
// モジュール: DispatcherZApp
// 説明: テーマとローカリゼーションを設定するルートウィジェット。
// ============================================================================
class DispatcherZApp extends StatefulWidget {
  const DispatcherZApp({Key? key}) : super(key: key);

  // どこからでも言語を切り替えられるようにするための静的メソッド
  static _DispatcherZAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_DispatcherZAppState>();

  @override
  State<DispatcherZApp> createState() => _DispatcherZAppState();
}

class _DispatcherZAppState extends State<DispatcherZApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    // ★保存されている言語設定を読み込んで起動する
    _locale = LayoutSettings.currentLanguage == 'en' ? const Locale('en', '') : const Locale('ja', 'JP');
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LayoutSettings.themeModeNotifier,
      builder: (context, mode, child) {
        bool isDark = mode == 'dark';
        return MaterialApp(
          title: 'dispatcherZ',
          debugShowCheckedModeBanner: false,
          
          // --- 多言語化設定 ---
          locale: _locale,
          localizationsDelegates: const [
            AppLocalizations.delegate, // 自動生成される辞書
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ja', 'JP'), 
            Locale('en', ''),
          ],
          // -------------------

          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.trackpad},
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light, 
          // Light Theme Configuration
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blueGrey,
            scaffoldBackgroundColor: Colors.white,
            menuTheme: const MenuThemeData(style: MenuStyle(shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.zero)))),
            popupMenuTheme: const PopupMenuThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          ),
          // Dark Theme Configuration
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blueGrey,
            scaffoldBackgroundColor: Colors.grey[900],
            menuTheme: const MenuThemeData(style: MenuStyle(shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.zero)))),
            popupMenuTheme: const PopupMenuThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
          ),
          home: const MainScreen(),
        );
      },
    );
  }
}

// ============================================================================
// Custom Notifications for inter-widget communication
// ウィジェット間通信用のカスタム通知クラス群
// ============================================================================
class CloseTabNotification extends Notification {}
class UpdateTabTitleNotification extends Notification {
  final String newTitle;
  UpdateTabTitleNotification(this.newTitle);
}
class RefreshDataNotification extends Notification {}

class OpenDispatchTabNotification extends Notification {
  final Map<String, dynamic> reservationData;
  OpenDispatchTabNotification(this.reservationData);
}

// ============================================================================
// Module: DispatchTab
// Description: Data model representing a single tab in the application.
// モジュール: DispatchTab
// 説明: アプリケーション内の単一タブを表現するデータモデル。
// ============================================================================
class DispatchTab {
  final String title;
  final Widget content;
  final bool isReservation;
  final bool isDashboard;
  final bool isAdminDashboard; 

  DispatchTab({
    required this.title,
    required this.content,
    this.isReservation = false,
    this.isDashboard = false, 
    this.isAdminDashboard = false,
  });
}

// ============================================================================
// Module: MainScreen
// Description: The primary screen containing the menu, tabs, and reservation list.
// モジュール: MainScreen
// 説明: メニュー、タブ、予約リストを含むメイン画面。
// ============================================================================
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  bool _showReservationList = LayoutSettings.showReservationList;
  int? _selectedReservationIndex; 
  final ScrollController _reservationScrollController = ScrollController(); 

  List<Map<String, dynamic>> _reservations = [];
  bool _isLoadingReservations = true;
  Timer? _reservationTimer; 
  Timer? _ctiTimer; 

  final List<DispatchTab> _tabs = [
    DispatchTab(title: '　新規伝票 (未入力)　', content: DispatchForm(key: UniqueKey())),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); 
    _initTabController(0); 
    _fetchReservations(); 

    // Auto-refresh reservation list every 30 seconds
    // 30秒ごとに予約リストを自動更新する
    _reservationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isLoadingReservations) {
        _fetchReservations();
      }
    });

    // CTI incoming call monitor (checks /tmp/ file every second)
    // CTI着信監視（毎秒 /tmp/ ファイルをチェックする）
    _ctiTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkIncomingCall();
    });
  }

  // Method to check for incoming calls passed via local file
  // ローカルファイル経由で渡された着信を確認するメソッド
  Future<void> _checkIncomingCall() async {
    try {
      final file = File('/tmp/dispatcherz_incoming.txt');
      if (await file.exists()) {
        String phone = await file.readAsString();
        await file.delete(); 

        phone = phone.trim().replaceAll(RegExp(r'[^0-9]'), ''); 

        if (phone.isNotEmpty && mounted) {
          _handleIncomingCall(phone);
        }
      }
    } catch (e) {
    }
  }

  // Handle opening a new tab when an incoming call is detected
  // 着信を検知した際に新しいタブを開く処理
  void _handleIncomingCall(String phone) {
    final l10n = AppLocalizations.of(context)!; // ★ここに追加！
    setState(() {
      final newTabIndex = _tabs.length;
      _tabs.insert(
        newTabIndex,
        DispatchTab(
          title: l10n.tabIncomingCall(phone),
          content: DispatchForm(
            key: UniqueKey(),
            initialData: {'phone': phone, 'isIncomingCall': true}, 
          ),
          isReservation: true,
        ),
      );
      _tabController.dispose();
      _initTabController(newTabIndex);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.snackIncomingCall(phone), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.pinkAccent,
        duration: const Duration(seconds: 5),
      )
    );
  }

  // Fetch pending reservations from the API
  // APIから未手配の予約を取得する
  Future<void> _fetchReservations() async {
    setState(() => _isLoadingReservations = true);
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/dispatches'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          _reservations = jsonData.where((item) {
            String dest = item['location_to']?.toString().trim() ?? '';
            return item['status'] == '未手配' && dest.isEmpty;
          }).map((item) {
            String rawTime = item['completion_time']?.toString() ?? '';
            String primaryText = item['primary_info']?.toString().trim() ?? '';
            
            return {
              'id': item['id'].toString(),
              'name': item['customer_name'] ?? '名称未設定',
              'phone': item['phone_number'] ?? '',
              'datetime': formatSafeTime(rawTime), 
              'primary': primaryText.isNotEmpty ? 'Primary: $primaryText' : '', 
              'raw_data': item, 
            };
          }).toList();
          _isLoadingReservations = false;
        });
      }
    } catch (e) {
      print('予約リスト取得エラー: $e');
      if (mounted) setState(() => _isLoadingReservations = false);
    }
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    final shouldExit = await _showAppExitConfirmationDialog();
    if (shouldExit == true) return AppExitResponse.exit; 
    return AppExitResponse.cancel; 
  }

  // Show dialog to confirm application exit
  // アプリケーション終了の確認ダイアログを表示する
  Future<bool?> _showAppExitConfirmationDialog() {
    final mode = LayoutSettings.themeModeNotifier.value;
    final isDark = mode == 'dark';
    final isColor = mode == 'color';
    
    final btnBg = isColor ? Colors.redAccent : (isDark ? Colors.white : Colors.black);
    final btnFg = isColor ? Colors.white : (isDark ? Colors.black : Colors.white);
    final textCol = isDark ? Colors.white : Colors.black;
    final l10n = AppLocalizations.of(context)!; // ★辞書を読み込み
    final existingIndex = _tabs.indexWhere((tab) => tab.isAdminDashboard);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.exitConfirmTitle, style: const TextStyle(fontWeight: FontWeight.bold)), // ★辞書
          content: Text(l10n.exitConfirmContent), // ★辞書
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancelButton, style: TextStyle(color: textCol)), // ★既存のcancelButtonを再利用
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: btnBg, foregroundColor: btnFg),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.exitButton), // ★辞書
            ),
          ],
        );
      },
    );
  }

  void _requestExitFromMenu() async {
    final shouldExit = await _showAppExitConfirmationDialog();
    if (shouldExit == true) exit(0);
  }

  // Show "About" dialog including GPL license
  // GPLライセンスを含む「このアプリについて」のダイアログを表示する
  void _showAboutDialog() {
    final mode = LayoutSettings.themeModeNotifier.value;
    final isDark = mode == 'dark';
    final btnBg = isDark ? Colors.white : Colors.black;
    final btnFg = isDark ? Colors.black : Colors.white;
    final l10n = AppLocalizations.of(context)!; // ★辞書を読み込み

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.aboutTitle, style: const TextStyle(fontWeight: FontWeight.bold)), // ★辞書
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(l10n.aboutAuthor), // ★辞書
              const SizedBox(height: 12),
              Text(l10n.aboutSource, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)), // ★辞書
              const SelectableText('https://github.com/morihirotoshida/', style: TextStyle(color: Colors.blueAccent)),
              const SizedBox(height: 12),
              Text(l10n.aboutLicense, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)), // ★辞書
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: btnBg, foregroundColor: btnFg),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.closeButton), // ★既存のcloseButtonを再利用
            ),
          ],
        );
      },
    );
  }

  // Show dialog to change the admin PIN code
  // 管理者PINコードを変更するためのダイアログを表示する
  void _showChangePinDialog() {
    final TextEditingController currentPinController = TextEditingController();
    final TextEditingController newPinController = TextEditingController();
    final TextEditingController confirmPinController = TextEditingController();
    bool isProcessing = false;
    final l10n = AppLocalizations.of(context)!; // ★辞書を読み込み

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.pinChangeTitle, style: const TextStyle(fontWeight: FontWeight.bold)), // ★辞書
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.pinChangeInstruction), // ★辞書
                    const SizedBox(height: 16),
                    TextField(
                      controller: currentPinController,
                      obscureText: true,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))],
                      decoration: InputDecoration(labelText: l10n.currentPin, border: const OutlineInputBorder()), // ★辞書
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: newPinController,
                      obscureText: true,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))],
                      decoration: InputDecoration(labelText: l10n.newPin, border: const OutlineInputBorder()), // ★辞書
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: confirmPinController,
                      obscureText: true,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))],
                      decoration: InputDecoration(labelText: l10n.confirmNewPin, border: const OutlineInputBorder()), // ★辞書
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isProcessing ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancelButton), // ★既存辞書
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  onPressed: isProcessing ? null : () async {
                    if (newPinController.text != confirmPinController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pinMismatch), backgroundColor: Colors.redAccent)); // ★辞書
                      return;
                    }
                    if (newPinController.text.isEmpty || currentPinController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.fillAllFields), backgroundColor: Colors.redAccent)); // ★辞書
                      return;
                    }

                    setState(() => isProcessing = true);
                    try {
                      final response = await http.post(
                        Uri.parse('http://127.0.0.1:8000/api/update-pin'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode({
                          'current_pin': currentPinController.text,
                          'new_pin': newPinController.text,
                        }),
                      );

                      if (response.statusCode == 200) {
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pinChangeSuccess), backgroundColor: Colors.green)); // ★辞書
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pinChangeFailed), backgroundColor: Colors.redAccent)); // ★辞書
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commError), backgroundColor: Colors.redAccent)); // ★辞書
                    } finally {
                      setState(() => isProcessing = false);
                    }
                  },
                  child: isProcessing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(l10n.saveChangesButton), // ★辞書
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _initTabController(int initialIndex) {
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (LayoutSettings.leftFormRatioNotifier.value == 0.0 || LayoutSettings.reservationListRatioNotifier.value == 0.0) {
      LayoutSettings.leftFormRatioNotifier.value = 1 / 3; 
      LayoutSettings.reservationListRatioNotifier.value = 1 / 6; 
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); 
    _reservationTimer?.cancel(); 
    _ctiTimer?.cancel(); 
    _tabController.dispose();
    _reservationScrollController.dispose();
    super.dispose();
  }

  // Create a new blank dispatch tab
  // 空の新規伝票タブを作成する
  void _addNewTab() {
    setState(() {
      final newTabIndex = _tabs.length; 
      _tabs.insert(
        newTabIndex,
        DispatchTab(
          title: '　新規伝票 (未入力)　', 
          content: DispatchForm(key: UniqueKey()), 
        ),
      );
      _tabController.dispose();
      _initTabController(newTabIndex);
    });
  }

  // Toggle general dashboard view
  // 一般ダッシュボードの表示を切り替える
  void _toggleDispatcherViewTab() {
    final existingIndex = _tabs.indexWhere((tab) => tab.isDashboard && !tab.isAdminDashboard);
    
    if (existingIndex != -1) {
      setState(() {
        _tabs.removeAt(existingIndex);
        if (_tabs.isEmpty) {
          _tabs.insert(0, DispatchTab(title: '　新規伝票 (未入力)　', content: DispatchForm(key: UniqueKey())));
        }
        _tabController.dispose();
        int newIndex = _tabController.index;
        if (newIndex >= _tabs.length) newIndex = _tabs.length - 1;
        if (newIndex < 0) newIndex = 0;
        _initTabController(newIndex);
      });
    } else {
      setState(() {
        final newTabIndex = _tabs.length; 
        _tabs.insert(
          newTabIndex,
          DispatchTab(
            title: '　履歴・予約一覧 (一般)　', 
            content: const DispatcherViewContent(isAdmin: false), 
            isDashboard: true, 
          ),
        );
        _tabController.dispose();
        _initTabController(newTabIndex);
      });
    }
  }

  // Toggle admin dashboard view (requires PIN)
  // 管理者ダッシュボードの表示を切り替える（PINが必要）
  Future<void> _toggleAdminDispatcherViewTab() async {
    final existingIndex = _tabs.indexWhere((tab) => tab.isAdminDashboard);
    
    if (existingIndex != -1) {
      setState(() {
        _tabs.removeAt(existingIndex);
        if (_tabs.isEmpty) {
          _tabs.insert(0, DispatchTab(title: '　新規伝票 (未入力)　', content: DispatchForm(key: UniqueKey())));
        }
        _tabController.dispose();
        int newIndex = _tabController.index;
        if (newIndex >= _tabs.length) newIndex = _tabs.length - 1;
        if (newIndex < 0) newIndex = 0;
        _initTabController(newIndex);
      });
      return;
    }

    // =========================================================
    // ★ここです！ダイアログを作る前に、辞書（l10n）を読み込みます！
    final l10n = AppLocalizations.of(context)!; 
    // =========================================================

    final TextEditingController pinController = TextEditingController();
    bool isVerifying = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.dialogAdminAuthTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.dialogAdminAuthContent),
                    const SizedBox(height: 16),
                    TextField(
                      controller: pinController,
                      obscureText: true,
                      autofocus: true,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))],
                      decoration: InputDecoration(labelText: l10n.adminPinLabel, border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  onPressed: isVerifying ? null : () async {
                    if (pinController.text.isEmpty) return;

                    setDialogState(() => isVerifying = true);
                    try {
                      final verifyRes = await http.post(
                        Uri.parse('http://127.0.0.1:8000/api/verify-pin'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode({'pin': pinController.text}),
                      );

                      if (verifyRes.statusCode == 200) {
                        Navigator.of(dialogContext).pop(); 
                        
                        setState(() {
                          final newTabIndex = _tabs.length; 
                          _tabs.insert(
                            newTabIndex,
                            DispatchTab(
                              title: '　履歴・予約一覧 (管理者)　', 
                              content: const DispatcherViewContent(isAdmin: true), 
                              isDashboard: true,
                              isAdminDashboard: true, 
                            ),
                          );
                          _tabController.dispose();
                          _initTabController(newTabIndex);
                        });
                        
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(l10n.snackAdminAuthError(verifyRes.statusCode.toString(), verifyRes.body)), 
                          backgroundColor: Colors.red
                        ));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commError), backgroundColor: Colors.red));
                    } finally {
                      if (mounted) setDialogState(() => isVerifying = false);
                    }
                  },
                  child: isVerifying ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(l10n.authButton),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // Open an existing reservation data in a new tab
  // 既存の予約データを新しいタブで開く
  void _openReservationTab(Map<String, dynamic> reservationData) {
    final name = reservationData['name'] ?? '名称未設定';
    final existingIndex = _tabs.indexWhere((tab) => tab.title.contains(name));
    
    if (existingIndex != -1) {
      setState(() {
        _tabController.animateTo(existingIndex);
      });
      return; 
    }

    setState(() {
      final newTabIndex = _tabs.length; 
      _tabs.insert(
        newTabIndex,
        DispatchTab(
          title: '　$name 様　', 
          content: DispatchForm(key: UniqueKey(), initialData: reservationData), 
          isReservation: true, 
        ),
      );
      _tabController.dispose();
      _initTabController(newTabIndex);
    });
  }

  // Close the currently active tab
  // 現在アクティブなタブを閉じる
  void _closeCurrentTab() {
    if (_tabs.isEmpty) return;
    final currentIndex = _tabController.index;

    setState(() {
      _tabs.removeAt(currentIndex);
      if (_tabs.isEmpty) {
        _tabs.insert(0, DispatchTab(
          title: '　新規伝票 (未入力)　', 
          content: DispatchForm(key: UniqueKey()), 
        ));
      }
      _tabController.dispose();
      int newIndex = currentIndex;
      if (newIndex >= _tabs.length) newIndex = _tabs.length - 1;
      if (newIndex < 0) newIndex = 0;
      _initTabController(newIndex);
    });
  }

  // Update title of current tab dynamically
  // 現在のタブのタイトルを動的に更新する
  void _updateCurrentTabTitle(String newTitle) {
    final currentIndex = _tabController.index;
    setState(() {
      final cur = _tabs[currentIndex];
      _tabs[currentIndex] = DispatchTab(
        title: newTitle,
        content: cur.content,
        isReservation: cur.isReservation,
        isDashboard: cur.isDashboard,
        isAdminDashboard: cur.isAdminDashboard,
      );
    });
  }

  void _toggleReservationList() {
    setState(() {
      _showReservationList = !_showReservationList;
      LayoutSettings.showReservationList = _showReservationList; 
      if (!_showReservationList) {
        _selectedReservationIndex = null; 
      }
    });
  }

  // Save or delete the UI layout profile
  // UIレイアウトプロファイルを保存または削除する
  Future<bool> _saveOrDeleteLayout() async {
    TextEditingController nameCtrl = TextEditingController();
    bool isChanged = false; 
    final mode = LayoutSettings.themeModeNotifier.value;
    final isDark = mode == 'dark';
    final isColor = mode == 'color';
    final l10n = AppLocalizations.of(context)!; // ★辞書を読み込み

    final saveBtnBg = isColor ? Colors.blueAccent : (isDark ? Colors.white : Colors.black);
    final delBtnBg = isColor ? Colors.redAccent : (isDark ? Colors.white : Colors.black);
    final btnFg = isColor ? Colors.white : (isDark ? Colors.black : Colors.white);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.layoutDialogTitle, style: const TextStyle(fontWeight: FontWeight.bold)), // ★辞書
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.layoutDialogContent), // ★辞書
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: l10n.layoutNameLabel, border: const OutlineInputBorder()), // ★辞書
              autofocus: true,
            ),
          ]
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text(l10n.cancelButton, style: TextStyle(color: isDark ? Colors.white : Colors.black)) // ★既存の「キャンセル」を再利用
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: delBtnBg, foregroundColor: btnFg),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                await LayoutSettings.delete(name);
                isChanged = true;
                Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.layoutDeletedMsg(name), style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: delBtnBg) // ★変数（name）を渡して翻訳！
                  );
                }
              }
            },
            child: Text(l10n.deleteLayoutBtn), // ★辞書
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: saveBtnBg, foregroundColor: btnFg),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                LayoutSettings.showReservationList = _showReservationList;
                await LayoutSettings.save(name);
                isChanged = true;
                Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.layoutSavedMsg(name), style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: saveBtnBg) // ★変数（name）を渡して翻訳！
                  );
                }
              }
            },
            child: Text(l10n.saveLayoutBtn), // ★辞書
          ),
        ],
      )
    );
    return isChanged; 
  }

  void _onLayoutLoaded() {
    setState(() {
      _showReservationList = LayoutSettings.showReservationList;
    });
    // ★確認：レイアウト読み込み時に、言語も強制的に切り替える指示が入っていますか？
    if (LayoutSettings.currentLanguage == 'en') {
      DispatcherZApp.of(context)?.setLocale(const Locale('en', ''));
    } else {
      DispatcherZApp.of(context)?.setLocale(const Locale('ja', 'JP'));
    }
  }

  // --- ★ここから追加：タブのタイトルを多言語化するヘルパーメソッド ---
  String _getLocalizedTabTitle(DispatchTab tab, AppLocalizations l10n) {
    if (tab.isDashboard) {
      return tab.isAdminDashboard ? l10n.tabDashboardAdmin : l10n.tabDashboardGeneral;
    } else if (!tab.isReservation && tab.title.contains('新規伝票')) {
      return l10n.tabNewDispatch;
    }
    return tab.title; // 「山田 様 (入力中)」などの動的なタイトルはそのまま表示
  }

  // Build the reservation list sidebar
  // サイドバーの予約リストを構築する
  Widget _buildReservationList(String mode) {
    final isDark = mode == 'dark';
    final isColor = mode == 'color';
    final l10n = AppLocalizations.of(context)!; // ★辞書を追加

    Color headerBg = isColor ? Colors.redAccent : (isDark ? Colors.grey[800]! : Colors.grey[200]!);
    Color headerText = isColor ? Colors.white : (isDark ? Colors.white : Colors.black);
    Color dateText = isColor ? Colors.blueAccent : (isDark ? Colors.white : Colors.black);

    return Container(
      color: isDark ? Colors.grey[900] : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: headerBg, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.reservationListTitle, // ★辞書に変更
                    style: TextStyle(color: headerText, fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: headerText, size: 20),
                  onPressed: _fetchReservations,
                  tooltip: l10n.tooltipRefresh, // ★辞書に変更
                )
              ],
            ),
          ),
          Expanded(
            child: _isLoadingReservations && _reservations.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _reservations.isEmpty
                ? Center(child: Text(l10n.noWaitingReservations, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))) // ★辞書に変更
                : Scrollbar(
                    controller: _reservationScrollController,
                    thumbVisibility: true, 
                    child: ListView.separated(
                      controller: _reservationScrollController,
                      itemCount: _reservations.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? Colors.white24 : Colors.black12),
                      itemBuilder: (context, index) {
                        final res = _reservations[index];
                        final isSelected = _selectedReservationIndex == index;

                        return Material(
                          color: isSelected 
                              ? (isDark ? Colors.grey[700] : Colors.grey[300]) 
                              : Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() { _selectedReservationIndex = index; });
                              _openReservationTab({
                                'id': res['id'], 
                                'customer_number': res['raw_data']['customer_number'], 
                                'name': res['name'],
                                'phone': res['phone'],
                                'loc1': res['raw_data']['location_from_1'] ?? '',
                                'lat1': res['raw_data']['lat_1'],
                                'lng1': res['raw_data']['lng_1'],
                                'loc2': res['raw_data']['location_from_2'] ?? '',
                                'lat2': res['raw_data']['lat_2'],
                                'lng2': res['raw_data']['lng_2'],
                                'loc3': res['raw_data']['location_from_3'] ?? '',
                                'lat3': res['raw_data']['lat_3'],
                                'lng3': res['raw_data']['lng_3'],
                                'destination': res['raw_data']['location_to'] ?? '',
                                'dispatch_time': res['raw_data']['dispatch_time'],
                                'completion_time': res['raw_data']['completion_time'],
                                'call_area': res['raw_data']['call_area'] ?? '',
                                'guidance': res['raw_data']['guidance'] ?? '',
                                'primary': res['raw_data']['primary_info'] ?? '',
                              });
                            },
                            hoverColor: isDark ? Colors.grey[800] : Colors.blue[50],
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('📅 ${res['datetime']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: dateText)),
                                  const SizedBox(height: 4),
                                  Text('${res['name']} 様', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                                  Row(
                                    children: [
                                      Icon(Icons.phone, size: 16, color: isDark ? Colors.white : Colors.black),
                                      const SizedBox(width: 4),
                                      Text('${res['phone']}', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                                    ],
                                  ),
                                  if (res['primary'].toString().isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text('${res['primary']}', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                                  ]
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isDashboardOpen = _tabs.any((tab) => tab.isDashboard && !tab.isAdminDashboard);
    bool isAdminDashboardOpen = _tabs.any((tab) => tab.isAdminDashboard);
    
    bool isCurrentTabDashboard = false;
    if (_tabController.index >= 0 && _tabController.index < _tabs.length) {
      isCurrentTabDashboard = _tabs[_tabController.index].isDashboard;
    }

    final l10n = AppLocalizations.of(context)!; // ★ここにこの1行を追加！

    return ValueListenableBuilder<String>(
      valueListenable: LayoutSettings.themeModeNotifier,
      builder: (context, mode, child) {
        bool isDark = mode == 'dark';
        bool isColor = mode == 'color';

        return Scaffold(
          body: NotificationListener<Notification>(
            onNotification: (notification) {
              if (notification is CloseTabNotification) {
                _closeCurrentTab();
                return true;
              } else if (notification is UpdateTabTitleNotification) {
                _updateCurrentTabTitle(notification.newTitle);
                return true;
              } else if (notification is RefreshDataNotification) {
                _fetchReservations();
                return false; 
              } else if (notification is OpenDispatchTabNotification) {
                _openReservationTab(notification.reservationData);
                return true;
              }
              return false;
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppMenuBar(
                  onNewPressed: _addNewTab, 
                  onClosePressed: _closeCurrentTab, 
                  onToggleReservationList: _toggleReservationList, 
                  onToggleDispatcherView: _toggleDispatcherViewTab, 
                  onToggleAdminDispatcherView: _toggleAdminDispatcherViewTab, 
                  onSaveOrDeleteLayoutPressed: _saveOrDeleteLayout, 
                  onLayoutLoaded: _onLayoutLoaded, 
                  onShowAboutDialog: _showAboutDialog, 
                  onRequestExit: _requestExitFromMenu, 
                  onChangePinPressed: _showChangePinDialog, 
                  isCurrentTabDashboard: isCurrentTabDashboard, 
                  isReservationListVisible: _showReservationList, 
                  isDashboardOpen: isDashboardOpen,                
                  isAdminDashboardOpen: isAdminDashboardOpen, 
                ),
                Container(
                  height: 46,
                  width: double.infinity,
                  color: isDark ? Colors.grey[900] : Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
                          child: ReorderableListView.builder(
                            scrollDirection: Axis.horizontal,
                            buildDefaultDragHandles: false, 
                            itemCount: _tabs.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (oldIndex < newIndex) newIndex -= 1;
                                final tab = _tabs.removeAt(oldIndex);
                                _tabs.insert(newIndex, tab);
                                int currentSelectedIndex = _tabController.index;
                                int nextSelectedIndex = currentSelectedIndex;
                                if (currentSelectedIndex == oldIndex) {
                                   nextSelectedIndex = newIndex;
                                } else if (currentSelectedIndex > oldIndex && currentSelectedIndex <= newIndex) {
                                   nextSelectedIndex--;
                                } else if (currentSelectedIndex < oldIndex && currentSelectedIndex >= newIndex) {
                                   nextSelectedIndex++;
                                }
                                _tabController.dispose();
                                _initTabController(nextSelectedIndex);
                              });
                            },
                            itemBuilder: (context, index) {
                              final tab = _tabs[index];
                              final isSelected = _tabController.index == index;
                              Color bgColor;
                              Color textColor;
                              if (isSelected) {
                                if (isColor) {
                                  bgColor = tab.isReservation ? Colors.redAccent : (tab.isDashboard ? Colors.indigo : Colors.blueAccent);
                                  textColor = Colors.white;
                                } else {
                                  bgColor = isDark ? Colors.white : Colors.black;
                                  textColor = isDark ? Colors.black : Colors.white;
                                }
                              } else {
                                if (isColor) {
                                  bgColor = tab.isReservation ? Colors.red[50]! : (tab.isDashboard ? Colors.indigo[50]! : Colors.transparent);
                                  textColor = Colors.black87;
                                } else {
                                  bgColor = (tab.isReservation || tab.isDashboard) ? (isDark ? Colors.grey[700]! : Colors.grey[300]!) : Colors.transparent;
                                  textColor = isDark ? Colors.white : Colors.black;
                                }
                              }

                              return ReorderableDragStartListener(
                                key: ValueKey(tab.content.key), 
                                index: index,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      _tabController.animateTo(index);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        border: Border(right: BorderSide(color: isColor ? Colors.white : (isDark ? Colors.grey[800]! : Colors.white), width: 1.0)),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _getLocalizedTabTitle(tab, l10n), // ★ここを書き換え
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: (tab.isReservation || tab.isDashboard) ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          ),
                        ),
                      ),
                      Container(
                        width: 44,
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey, width: 0.5)),
                        ),
                        alignment: Alignment.center,
                        child: PopupMenuButton<int>(
                          tooltip: l10n.tooltipTabList, // ★辞書に変更！
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.format_list_bulleted, color: isDark ? Colors.white54 : Colors.grey, size: 22),
                          offset: const Offset(0, 40),
                          onSelected: (int index) {
                            _tabController.animateTo(index);
                          },
                          itemBuilder: (BuildContext context) {
                            return _tabs.asMap().entries.map((entry) {
                              bool isSelected = _tabController.index == entry.key;
                              IconData iconData = Icons.edit_document;
                              if (entry.value.isDashboard) iconData = Icons.dashboard;
                              if (entry.value.isReservation) iconData = Icons.book;

                              Color iconColor = isSelected ? (isColor ? Colors.blueAccent : (isDark ? Colors.white : Colors.black)) : Colors.grey;

                              return PopupMenuItem<int>(
                                value: entry.key,
                                child: Row(
                                  children: [
                                        Icon(iconData, size: 16, color: iconColor),
                                        const SizedBox(width: 8),
                                        Text(
                                          _getLocalizedTabTitle(entry.value, l10n).trim(), // ★ここを書き換え
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected ? (isColor ? Colors.blueAccent : (isDark ? Colors.white : Colors.black)) : (isDark ? Colors.white70 : Colors.black87),
                                          ),
                                        ),
                                      ],
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      InkWell(
                        onTap: _addNewTab,
                        child: Container(
                          width: 50,
                          decoration: BoxDecoration(
                            border: Border(left: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey, width: 0.5)),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.add, color: isDark ? Colors.white54 : Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 2, color: isDark ? Colors.white : Colors.black),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch, 
                    children: [
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          physics: const NeverScrollableScrollPhysics(), 
                          children: _tabs.map((tab) => tab.content).toList(),
                        ),
                      ),
                      if (_showReservationList)
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onHorizontalDragUpdate: (details) {
                            double newRatio = LayoutSettings.reservationListRatioNotifier.value - (details.delta.dx / screenWidth);
                            if (newRatio * screenWidth < 200) newRatio = 200 / screenWidth; 
                            if (newRatio > 0.5) newRatio = 0.5; 
                            LayoutSettings.reservationListRatioNotifier.value = newRatio;
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.resizeLeftRight, 
                            child: Container(
                              width: 8.0,
                              color: isDark ? Colors.grey[800] : Colors.grey[300],
                              child: Center(
                                child: Icon(Icons.drag_indicator, size: 16, color: isDark ? Colors.white54 : Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      if (_showReservationList)
                        ValueListenableBuilder<double>(
                          valueListenable: LayoutSettings.reservationListRatioNotifier,
                          builder: (context, ratio, child) {
                            return SizedBox(
                              width: screenWidth * ratio,
                              child: _buildReservationList(mode),
                            );
                          }
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

// ============================================================================
// Module: AppMenuBar
// Description: The top menu bar widget providing access to system settings, UI toggles, and help.
// モジュール: AppMenuBar
// 説明: システム設定、UI切り替え、ヘルプへのアクセスを提供する上部メニューバーウィジェット。
// ============================================================================
class AppMenuBar extends StatefulWidget {
  final VoidCallback onNewPressed;
  final VoidCallback onClosePressed;
  final VoidCallback onToggleReservationList; 
  final VoidCallback onToggleDispatcherView; 
  final VoidCallback onToggleAdminDispatcherView; 
  final Future<bool> Function() onSaveOrDeleteLayoutPressed; 
  final VoidCallback onLayoutLoaded; 
  final VoidCallback onShowAboutDialog; 
  final VoidCallback onRequestExit;     
  final VoidCallback onChangePinPressed; 
  final bool isCurrentTabDashboard; 
  final bool isReservationListVisible; 
  final bool isDashboardOpen;          
  final bool isAdminDashboardOpen; 

  const AppMenuBar({
    Key? key,
    required this.onNewPressed,
    required this.onClosePressed,
    required this.onToggleReservationList,
    required this.onToggleDispatcherView,
    required this.onToggleAdminDispatcherView, 
    required this.onSaveOrDeleteLayoutPressed, 
    required this.onLayoutLoaded,
    required this.onShowAboutDialog, 
    required this.onRequestExit,     
    required this.onChangePinPressed, 
    required this.isCurrentTabDashboard, 
    required this.isReservationListVisible,
    required this.isDashboardOpen,
    required this.isAdminDashboardOpen, 
  }) : super(key: key);

  @override
  State<AppMenuBar> createState() => _AppMenuBarState();
}

class _AppMenuBarState extends State<AppMenuBar> {
  List<String> _savedProfiles = [];

  @override
  void initState() {
    super.initState();
    _refreshProfiles();
  }

  Future<void> _refreshProfiles() async {
    final profiles = await LayoutSettings.getSavedProfiles();
    setState(() {
      _savedProfiles = profiles;
    });
  }

@override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ★この1行を追加！

    return ValueListenableBuilder<String>(
      valueListenable: LayoutSettings.themeModeNotifier,
      builder: (context, mode, child) {
        final isDark = mode == 'dark';
        final menuTextColor = isDark ? Colors.white : Colors.black87;

        return Container(
          color: isDark ? Colors.grey[850] : Colors.grey[200],
          width: double.infinity,
          child: MenuBar(
            style: const MenuStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.transparent),
              elevation: MaterialStatePropertyAll(0),
              padding: MaterialStatePropertyAll(EdgeInsets.zero),
            ),
            children: [
              // --- ファイルメニュー ---
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    onPressed: widget.onNewPressed,
                    child: Text(l10n.newDispatch), // 辞書から呼び出し
                  ),
                  MenuItemButton(
                    onPressed: () {
                      if (widget.isCurrentTabDashboard) {
                        widget.onClosePressed();
                      } else {
                        CloseTabNotification().dispatch(context);
                      }
                    },
                    child: Text(l10n.closeDispatch), // 辞書から呼び出し
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(l10n.fileMenu, style: TextStyle(color: menuTextColor)), // 辞書から呼び出し
                ),
              ),

              // --- 表示メニュー ---
              SubmenuButton(
                menuChildren: [
                  CheckboxMenuButton(
                    value: widget.isReservationListVisible,
                    onChanged: (bool? value) {
                      widget.onToggleReservationList();
                    },
                    child: Text(l10n.reservationList), // 辞書から呼び出し
                  ),
                  CheckboxMenuButton(
                    value: widget.isDashboardOpen,
                    onChanged: (bool? value) {
                      widget.onToggleDispatcherView();
                    },
                    child: Text(l10n.dashboardGeneral), // 辞書から呼び出し
                  ),
                  const PopupMenuDivider(),
                  CheckboxMenuButton(
                    value: widget.isAdminDashboardOpen,
                    onChanged: (bool? value) {
                      widget.onToggleAdminDispatcherView();
                    },
                    child: Text(l10n.dashboardAdmin, style: const TextStyle(fontWeight: FontWeight.bold)), // 辞書から呼び出し
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(l10n.viewMenu, style: TextStyle(color: menuTextColor)), // 辞書から呼び出し
                ),
              ),

              // --- 設定メニュー ---
              SubmenuButton(
                menuChildren: [
                  SubmenuButton(
                    menuChildren: [
                      RadioMenuButton<String>(
                        value: 'light',
                        groupValue: LayoutSettings.themeModeNotifier.value,
                        onChanged: (String? value) {
                          if (value != null) {
                            LayoutSettings.themeModeNotifier.value = value;
                            LayoutSettings.save('default'); 
                          }
                        },
                        child: Text(l10n.lightMode), // 辞書から呼び出し
                      ),
                      RadioMenuButton<String>(
                        value: 'dark',
                        groupValue: LayoutSettings.themeModeNotifier.value,
                        onChanged: (String? value) {
                          if (value != null) {
                            LayoutSettings.themeModeNotifier.value = value;
                            LayoutSettings.save('default'); 
                          }
                        },
                        child: Text(l10n.darkMode), // 辞書から呼び出し
                      ),
                      RadioMenuButton<String>(
                        value: 'color',
                        groupValue: LayoutSettings.themeModeNotifier.value,
                        onChanged: (String? value) {
                          if (value != null) {
                            LayoutSettings.themeModeNotifier.value = value;
                            LayoutSettings.save('default'); 
                          }
                        },
                        child: Text(l10n.colorMode), // 辞書から呼び出し
                      ),
                    ],
                    child: Text(l10n.modeChangeMenu), // 辞書から呼び出し
                  ),
                  const PopupMenuDivider(),
                  MenuItemButton(
                    onPressed: () async {
                      bool changed = await widget.onSaveOrDeleteLayoutPressed();
                      if (changed) {
                        _refreshProfiles(); 
                      }
                    },
                    child: Text(l10n.saveDeleteLayout), // 辞書から呼び出し
                  ),
                  SubmenuButton(
                    menuChildren: _savedProfiles.isEmpty
                        ? [MenuItemButton(child: Text(l10n.noSavedLayouts, style: const TextStyle(color: Colors.grey)))] // 辞書から呼び出し
                        : _savedProfiles.map((profile) => MenuItemButton(
                              onPressed: () async {
                                await LayoutSettings.load(profile);
                                widget.onLayoutLoaded(); 
                                if (context.mounted) {
                                  // ※スナックバーの多言語化を行いました
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(l10n.layoutLoadedMsg(profile), style: const TextStyle(fontWeight: FontWeight.bold)), // ★辞書に変更し、変数profileを渡す！
                                    backgroundColor: isDark ? Colors.white : Colors.black,
                                    behavior: SnackBarBehavior.floating,
                                  ));
                                }
                              },
                              child: Text(profile),
                            )).toList(),
                    child: Text(l10n.loadSavedLayout), // 辞書から呼び出し
                  ),
                  const PopupMenuDivider(),
                  MenuItemButton(
                    onPressed: widget.onChangePinPressed,
                    child: Text(l10n.changeAdminPin), // 辞書から呼び出し
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(l10n.settingsMenu, style: TextStyle(color: menuTextColor)), // 辞書から呼び出し
                ),
              ),

              // --- ヘルプメニュー ---
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    onPressed: widget.onShowAboutDialog, 
                    child: Text(l10n.aboutApp) // 辞書から呼び出し
                  ),
                  MenuItemButton(
                    onPressed: widget.onRequestExit, 
                    child: Text(l10n.exitApp), // 辞書から呼び出し
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(l10n.helpMenu, style: TextStyle(color: menuTextColor)), // 辞書から呼び出し
                ),
              ),

              // --- Language メニュー ---
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    onPressed: () {
                      LayoutSettings.currentLanguage = 'ja'; // ★裏側のシステムに「日本語」を記憶
                      LayoutSettings.save('default'); // ★設定を保存
                      DispatcherZApp.of(context)?.setLocale(const Locale('ja', 'JP'));
                    },
                    child: const Text('Japanese (日本語)'), 
                  ),
                  MenuItemButton(
                    onPressed: () {
                      LayoutSettings.currentLanguage = 'en'; // ★裏側のシステムに「英語」を記憶
                      LayoutSettings.save('default'); // ★設定を保存
                      DispatcherZApp.of(context)?.setLocale(const Locale('en', ''));
                    },
                    child: const Text('English (英語)'), 
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Language', style: TextStyle(color: menuTextColor)), // 万国共通の固定テキスト
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
// ============================================================================
// Module: DispatchForm
// Description: The primary input form for creating and updating dispatch records.
//              Includes map integration, CTI handling, and API saving mechanisms.
// モジュール: DispatchForm
// 説明: 配車記録を作成・更新するための主要な入力フォーム。
//      マップ連携、CTI処理、およびAPI保存メカニズムを含みます。
// ============================================================================
class DispatchForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const DispatchForm({Key? key, this.initialData}) : super(key: key);

  @override
  State<DispatchForm> createState() => _DispatchFormState();
}

class _DispatchFormState extends State<DispatchForm> with AutomaticKeepAliveClientMixin {
  final MapController _mapController = MapController();

  late TextEditingController _customerNumberController;

  late TextEditingController _loc1Controller;
  final TextEditingController _loc2Controller = TextEditingController();
  final TextEditingController _loc3Controller = TextEditingController();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _primaryController;
  late TextEditingController _destinationController;
  late TextEditingController _callAreaController;
  late TextEditingController _guidanceController;

  LatLng? _loc1LatLng;
  LatLng? _loc2LatLng;
  LatLng? _loc3LatLng;

  LatLng _currentCenter = const LatLng(34.6793, 135.6012);
  String? _loadingField; 
  
  String? _currentRecordId;
  bool _isSaving = false; 

  final List<String> _months = List.generate(12, (i) => (i + 1).toString());
  final List<String> _days = List.generate(31, (i) => (i + 1).toString());
  final List<String> _hours = List.generate(24, (i) => i.toString());
  final List<String> _minutes = List.generate(12, (i) => (i * 5).toString().padLeft(2, '0'));

  String? _selectedMonth;
  String? _selectedDay;
  String? _selectedHour;
  String? _selectedMinute;

  String? _completedMonth;
  String? _completedDay;
  String? _completedHour;
  String? _completedMinute;

  @override
  bool get wantKeepAlive => true; 

  // Generate a random 8-digit customer number
  // 8桁のランダムな顧客番号を生成する
  String _generateRandomCustomerNumber() {
    final random = Random();
    return (random.nextInt(90000000) + 10000000).toString(); 
  }

  @override
  void initState() {
    super.initState();
    _currentRecordId = widget.initialData?['id']?.toString();
    _initializeDateTime(); 
    
    _customerNumberController = TextEditingController(text: widget.initialData?['customer_number'] ?? _generateRandomCustomerNumber());

    _nameController = TextEditingController(text: widget.initialData?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.initialData?['phone'] ?? '');
    
    _loc1Controller = TextEditingController(text: widget.initialData?['loc1'] ?? '');
    _loc2Controller.text = widget.initialData?['loc2'] ?? '';
    _loc3Controller.text = widget.initialData?['loc3'] ?? '';

    if (widget.initialData?['lat1'] != null && widget.initialData?['lng1'] != null) {
      _loc1LatLng = LatLng(double.parse(widget.initialData!['lat1'].toString()), double.parse(widget.initialData!['lng1'].toString()));
      _currentCenter = _loc1LatLng!; 
    }
    if (widget.initialData?['lat2'] != null && widget.initialData?['lng2'] != null) {
      _loc2LatLng = LatLng(double.parse(widget.initialData!['lat2'].toString()), double.parse(widget.initialData!['lng2'].toString()));
    }
    if (widget.initialData?['lat3'] != null && widget.initialData?['lng3'] != null) {
      _loc3LatLng = LatLng(double.parse(widget.initialData!['lat3'].toString()), double.parse(widget.initialData!['lng3'].toString()));
    }

    _destinationController = TextEditingController(text: widget.initialData?['destination'] ?? '');
    _primaryController = TextEditingController(text: widget.initialData?['primary'] ?? '');
    _callAreaController = TextEditingController(text: widget.initialData?['call_area'] ?? '');
    _guidanceController = TextEditingController(text: widget.initialData?['guidance'] ?? '');

    // Handle CTI auto-search if marked as an incoming call
    // 着信フラグがある場合は自動で顧客検索を実行する
    if (widget.initialData?['isIncomingCall'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchCustomerByPhone();
      });
    }
  }

  // Initialize and round datetime dropdowns
  // 日時のドロップダウンを初期化し、丸める
  void _initializeDateTime() {
    DateTime dispatchTime;
    DateTime completionTime;

    DateTime now = DateTime.now();
    int rem = now.minute % 5;
    DateTime roundedTime = now.add(Duration(minutes: rem >= 3 ? 5 - rem : -rem));
    dispatchTime = roundedTime;
    completionTime = roundedTime;

    if (widget.initialData != null) {
      if (widget.initialData!['dispatch_time'] != null && widget.initialData!['dispatch_time'].toString().isNotEmpty) {
        try {
          String safeTime = widget.initialData!['dispatch_time'].toString().replaceAll('Z', '').replaceFirst('T', ' ');
          DateTime parsed = DateTime.parse(safeTime.replaceFirst(' ', 'T'));
          int mRem = parsed.minute % 5;
          dispatchTime = parsed.add(Duration(minutes: mRem >= 3 ? 5 - mRem : -mRem));
        } catch (e) {}
      }
      
      if (widget.initialData!['completion_time'] != null && widget.initialData!['completion_time'].toString().isNotEmpty) {
        try {
          String safeTime = widget.initialData!['completion_time'].toString().replaceAll('Z', '').replaceFirst('T', ' ');
          DateTime parsed = DateTime.parse(safeTime.replaceFirst(' ', 'T'));
          int mRem = parsed.minute % 5;
          completionTime = parsed.add(Duration(minutes: mRem >= 3 ? 5 - mRem : -mRem));
        } catch (e) {}
      } else {
        completionTime = dispatchTime; 
      }
    }

    _selectedMonth = dispatchTime.month.toString();
    _selectedDay = dispatchTime.day.toString();
    _selectedHour = dispatchTime.hour.toString();
    _selectedMinute = dispatchTime.minute.toString().padLeft(2, '0');

    _completedMonth = completionTime.month.toString();
    _completedDay = completionTime.day.toString();
    _completedHour = completionTime.hour.toString();
    _completedMinute = completionTime.minute.toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    _customerNumberController.dispose();
    _loc1Controller.dispose();
    _loc2Controller.dispose();
    _loc3Controller.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _primaryController.dispose();
    _destinationController.dispose();
    _callAreaController.dispose();
    _guidanceController.dispose();
    super.dispose();
  }

  // Search address coordinates using OpenStreetMap API
  // OpenStreetMap APIを使用して住所の座標を検索する
  Future<void> _searchAddress(TextEditingController controller, String fieldKey) async {
    final address = controller.text;
    if (address.isEmpty) return;

    setState(() {
      _loadingField = fieldKey; 
    });

    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1');
      
      final response = await http.get(url, headers: {
        'User-Agent': 'biz.webflame.dispatcherz/1.0', 
      });

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        
        if (data.isNotEmpty) {
          final double lat = double.parse(data[0]['lat']);
          final double lon = double.parse(data[0]['lon']);
          final newLocation = LatLng(lat, lon);

          setState(() {
            _currentCenter = newLocation;
            if (fieldKey == 'loc1') _loc1LatLng = newLocation;
            if (fieldKey == 'loc2') _loc2LatLng = newLocation;
            if (fieldKey == 'loc3') _loc3LatLng = newLocation;
          });
          
          _mapController.move(newLocation, 18.0);
        } else {
          _showErrorDialog('住所が見つかりませんでした。');
        }
      }
    } catch (e) {
      _showErrorDialog('通信エラーが発生しました。');
    } finally {
      setState(() {
        _loadingField = null; 
      });
    }
  }

  // Search customer history in MySQL via Laravel API based on phone number
  // 電話番号を基にLaravel API経由でMySQL内の顧客履歴を検索する
  Future<void> _searchCustomerByPhone() async {
    // ==========================================
    // ★ここです！この部屋（関数）にも辞書を持ち込む！
    final l10n = AppLocalizations.of(context)!;
    // ==========================================
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/customers/search?phone=$phone');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        setState(() {
          _customerNumberController.text = data['customer_number'] ?? _customerNumberController.text;
          _nameController.text = data['customer_name'] ?? '';
          _loc1Controller.text = data['location_from_1'] ?? '';
          _loc2Controller.text = data['location_from_2'] ?? '';
          _loc3Controller.text = data['location_from_3'] ?? '';
          _callAreaController.text = data['call_area'] ?? '';
          _guidanceController.text = data['guidance'] ?? '';
          
          if (data['lat_1'] != null && data['lng_1'] != null) {
            _loc1LatLng = LatLng(double.parse(data['lat_1'].toString()), double.parse(data['lng_1'].toString()));
            _currentCenter = _loc1LatLng!;
            _mapController.move(_currentCenter, 18.0);
          }
          if (data['lat_2'] != null && data['lng_2'] != null) {
            _loc2LatLng = LatLng(double.parse(data['lat_2'].toString()), double.parse(data['lng_2'].toString()));
          }
          if (data['lat_3'] != null && data['lng_3'] != null) {
            _loc3LatLng = LatLng(double.parse(data['lat_3'].toString()), double.parse(data['lng_3'].toString()));
          }
        });

        UpdateTabTitleNotification(l10n.tabEditingCustomer(data['customer_name'].toString())).dispatch(context);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.snackCustomerFound, style: TextStyle(fontWeight: FontWeight.bold)), 
              backgroundColor: Colors.blueAccent
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.snackCustomerNotFound)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commError), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Submit form data to Laravel API (Create or Update)
  // フォームのデータをLaravel APIに送信する（作成または更新）
  Future<bool> _submitDataAndSync(BuildContext ctx) async {
    final l10n = AppLocalizations.of(ctx)!; 

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar( 
        content: Text(l10n.errorPhoneRequired, style: const TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.redAccent
      ));
      return false; 
    }

    setState(() => _isSaving = true);
    
    // =================================================================
    // ★追加：保存直前に「電話番号のサイレント重複チェック」を行う
    // =================================================================
    try {
      final phone = _phoneController.text.trim();
      final searchUrl = Uri.parse('http://127.0.0.1:8000/api/customers/search?phone=$phone');
      final searchRes = await http.get(searchUrl);

      if (searchRes.statusCode == 200) {
        final searchData = json.decode(searchRes.body);
        if (searchData['customer_number'] != null) {
          // データベースに同じ電話番号が存在する場合、
          // ランダム生成された仮のIDを破棄して、既存の顧客番号に書き換える！
          _customerNumberController.text = searchData['customer_number'].toString();
        }
      }
    } catch (e) {
      // APIに繋がらない等の通信エラー時は無視して、そのまま保存処理へ進む
    }
    // =================================================================

    String dM = _selectedMonth?.padLeft(2, '0') ?? '01';
    String dD = _selectedDay?.padLeft(2, '0') ?? '01';
    String dH = _selectedHour?.padLeft(2, '0') ?? '00';
    String dMin = _selectedMinute?.padLeft(2, '0') ?? '00';
    String dispatchTimeStr = '${DateTime.now().year}-$dM-$dD $dH:$dMin:00';

    String cM = _completedMonth?.padLeft(2, '0') ?? '01';
    String cD = _completedDay?.padLeft(2, '0') ?? '01';
    String cH = _completedHour?.padLeft(2, '0') ?? '00';
    String cMin = _completedMinute?.padLeft(2, '0') ?? '00';
    String completionTimeStr = '${DateTime.now().year}-$cM-$cD $cH:$cMin:00';

    String destStatus = _destinationController.text.trim().isNotEmpty ? '配車完了' : '未手配';

    final bodyData = json.encode({
      'customer_number': _customerNumberController.text.trim(),
      'customer_name': _nameController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'location_from_1': _loc1Controller.text.trim(),
      'lat_1': _loc1LatLng?.latitude,
      'lng_1': _loc1LatLng?.longitude,
      'location_from_2': _loc2Controller.text.trim(),
      'lat_2': _loc2LatLng?.latitude,
      'lng_2': _loc2LatLng?.longitude,
      'location_from_3': _loc3Controller.text.trim(),
      'lat_3': _loc3LatLng?.latitude,
      'lng_3': _loc3LatLng?.longitude,
      'location_to': _destinationController.text.trim(),
      'dispatch_time': dispatchTimeStr, 
      'completion_time': completionTimeStr, 
      'call_area': _callAreaController.text.trim(),
      'guidance': _guidanceController.text.trim(),
      'primary_info': _primaryController.text.trim(),
      'status': destStatus, 
    });

    try {
      if (_currentRecordId == null) {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/api/dispatches'),
          headers: {'Content-Type': 'application/json'},
          body: bodyData,
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final resData = json.decode(response.body);
          if (resData['id'] != null) {
            _currentRecordId = resData['id'].toString(); 
          }
        } else {
           setState(() => _isSaving = false);
           return false;
        }
      } else {
        await http.put(
          Uri.parse('http://127.0.0.1:8000/api/dispatches/$_currentRecordId'),
          headers: {'Content-Type': 'application/json'},
          body: bodyData,
        );
      }
    } catch (e) {
      print('送信エラー: $e');
      setState(() => _isSaving = false);
      return false;
    }

    RefreshDataNotification().dispatch(ctx); 
    
    String displayName = _nameController.text.trim();
    String tabTitle = displayName.isNotEmpty ? displayName : '伝票 (#$_currentRecordId)';
    UpdateTabTitleNotification(l10n.tabSavedDispatch(tabTitle)).dispatch(ctx);
    
    setState(() => _isSaving = false);
    return true; 
  }


  Widget _buildSearchableLocationField(String label, TextEditingController controller, String fieldKey, bool isDark, bool isColor) {
    final bool isThisLoading = _loadingField == fieldKey;
    Color iconColor = isColor ? Colors.redAccent : (isDark ? Colors.white70 : Colors.black87);
    final l10n = AppLocalizations.of(context)!; // 辞書を読み込み

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            inputFormatters: [LengthLimitingTextInputFormatter(255)],
            decoration: InputDecoration(labelText: label),
            onFieldSubmitted: (_) => _searchAddress(controller, fieldKey),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: isThisLoading 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(Icons.location_on, color: iconColor),
          tooltip: l10n.searchMapTooltip, // ★辞書から呼び出し
          onPressed: _loadingField != null ? null : () => _searchAddress(controller, fieldKey),
        ),
      ],
    );
  }

@override
  Widget build(BuildContext context) {
    super.build(context); 
    final formContext = context; 
    final screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!; // ★辞書を読み込み

    return ValueListenableBuilder<String>(
      valueListenable: LayoutSettings.themeModeNotifier,
      builder: (context, mode, child) {
        final isDark = mode == 'dark';
        final isColor = mode == 'color';

        bool isSaved = _currentRecordId != null;

        Color btnBg, btnFg, closeBtnBg;
        if (isColor) {
          btnBg = isSaved ? Colors.indigo : Colors.blueAccent;
          btnFg = Colors.white;
          closeBtnBg = Colors.white;
        } else {
          btnBg = isSaved ? (isDark ? Colors.grey[700]! : Colors.grey[300]!) : (isDark ? Colors.white : Colors.black);
          btnFg = isSaved ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.black : Colors.white);
          closeBtnBg = isDark ? Colors.white : Colors.black;
        }

        final subTextCol = isDark ? Colors.white54 : Colors.black54;
        Color searchIconColor = isColor ? Colors.blueAccent : (isDark ? Colors.white70 : Colors.black87);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: [
            ValueListenableBuilder<double>(
              valueListenable: LayoutSettings.leftFormRatioNotifier,
              builder: (context, ratio, child) {
                return SizedBox(
                  width: screenWidth * ratio,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: isDark ? Colors.grey[850] : Colors.grey[50], 
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _customerNumberController,
                            readOnly: true, 
                            decoration: InputDecoration(
                              labelText: l10n.customerNumberAuto, // ★辞書
                              filled: false, 
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black, 
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(l10n.customerName, controller: _nameController, maxLength: 64), // ★辞書
                          const SizedBox(height: 8),
                          
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(20),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: l10n.phoneNumberRequired, // ★辞書
                                    hintText: l10n.phoneHint, // ★辞書
                                  ),
                                  onFieldSubmitted: (_) => _searchCustomerByPhone(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.search, color: searchIconColor),
                                tooltip: l10n.tooltipSearchCustomer, // ★辞書に変更！
                                onPressed: _searchCustomerByPhone,
                              ),
                            ],
                          ),
                          
                          const Divider(height: 20),
                          
                          _buildSearchableLocationField(l10n.pickupLocation1, _loc1Controller, 'loc1', isDark, isColor), // ★辞書
                          const SizedBox(height: 8),
                          _buildSearchableLocationField(l10n.pickupLocation2, _loc2Controller, 'loc2', isDark, isColor), // ★辞書
                          const SizedBox(height: 8),
                          _buildSearchableLocationField(l10n.pickupLocation3, _loc3Controller, 'loc3', isDark, isColor), // ★辞書
                          
                          const Divider(height: 20),

                          Text(l10n.dispatchDateTime, style: TextStyle(fontSize: 12, color: subTextCol)), // ★辞書
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildStatefulDropdown(_months, _selectedMonth, (val) => setState(() => _selectedMonth = val)),
                              const SizedBox(width: 4),
                              Text(l10n.monthLabel, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                              const SizedBox(width: 8),
                              _buildStatefulDropdown(_days, _selectedDay, (val) => setState(() => _selectedDay = val)),
                              const SizedBox(width: 4),
                              Text(l10n.dayLabel, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                              const SizedBox(width: 8),
                              _buildStatefulDropdown(_hours, _selectedHour, (val) => setState(() => _selectedHour = val)),
                              const SizedBox(width: 4),
                              Text(l10n.hourLabel, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                              const SizedBox(width: 8),
                              _buildStatefulDropdown(_minutes, _selectedMinute, (val) => setState(() => _selectedMinute = val)),
                              const SizedBox(width: 4),
                              Text(l10n.minuteLabel, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          Text(l10n.completionDateTime, style: TextStyle(fontSize: 12, color: subTextCol)), // ★辞書
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildStatefulDropdown(_months, _completedMonth, (val) => setState(() => _completedMonth = val)),
                              const SizedBox(width: 4),
                              Text(l10n.monthLabel, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                              const SizedBox(width: 8),
                              _buildStatefulDropdown(_days, _completedDay, (val) => setState(() => _completedDay = val)),
                              const SizedBox(width: 4),
                              Text(l10n.dayLabel, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                              const SizedBox(width: 8),
                              _buildStatefulDropdown(_hours, _completedHour, (val) => setState(() => _completedHour = val)),
                              const SizedBox(width: 4),
                              Text(l10n.hourLabel, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                              const SizedBox(width: 8),
                              _buildStatefulDropdown(_minutes, _completedMinute, (val) => setState(() => _completedMinute = val)),
                              const SizedBox(width: 4),
                              Text(l10n.minuteLabel, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                            ],
                          ),
                          const Divider(height: 20),

                          _buildTextField(l10n.callArea, maxLines: 2, controller: _callAreaController, maxLength: 128), // ★辞書
                          const SizedBox(height: 8),
                          _buildTextField(l10n.guidance, maxLines: 4, controller: _guidanceController, maxLength: 512), // ★辞書
                          const SizedBox(height: 8),
                          
                          _buildTextField(l10n.destination, maxLines: 2, controller: _destinationController, maxLength: 128), // ★辞書
                          const SizedBox(height: 8),
                          _buildTextField('Primary', maxLines: 3, controller: _primaryController, maxLength: 256), // 固有名詞なのでそのまま
                          
                          const SizedBox(height: 10),
                          Wrap(
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16.0, 
                            runSpacing: 8.0, 
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: btnBg,
                                  foregroundColor: btnFg,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                ),
                                onPressed: _isSaving ? null : () async { 
                                  await _submitDataAndSync(formContext);
                                },
                                child: _isSaving 
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text(isSaved ? l10n.resaveChanges : l10n.saveComplete, style: const TextStyle(fontWeight: FontWeight.bold)), // ★辞書
                              ),
                              
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isColor ? Colors.black : (isDark ? Colors.white : Colors.black), 
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext dialogContext) {
                                      bool isDialogSaving = false;
                                      bool isDialogSaved = false;

                                      return StatefulBuilder(
                                        builder: (context, setDialogState) {
                                          return AlertDialog(
                                            title: Text(l10n.closeDispatchConfirmTitle, style: const TextStyle(fontWeight: FontWeight.bold)), // ★辞書
                                            content: Text(l10n.closeDispatchConfirmContent), // ★辞書
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(dialogContext).pop(),
                                                child: Text(l10n.cancelButton, style: TextStyle(color: isDark ? Colors.white : Colors.black)), // ★辞書
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isColor ? Colors.blueAccent : closeBtnBg, 
                                                  foregroundColor: isColor ? Colors.white : (isDark ? Colors.black : Colors.white),
                                                  disabledBackgroundColor: Colors.grey, 
                                                ),
                                                onPressed: (isDialogSaving || isDialogSaved || _isSaving) ? null : () async { 
                                                  setDialogState(() => isDialogSaving = true);
                                                  bool success = await _submitDataAndSync(formContext);
                                                  if (mounted) {
                                                    setDialogState(() {
                                                      isDialogSaving = false;
                                                      if (success) isDialogSaved = true; 
                                                    });
                                                  }
                                                },
                                                child: isDialogSaving 
                                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                                                    : (isDialogSaved ? Text(l10n.savedButton) : Text(l10n.saveButton)), // ★辞書
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isColor ? Colors.redAccent : closeBtnBg, 
                                                  foregroundColor: isColor ? Colors.white : (isDark ? Colors.black : Colors.white)
                                                ),
                                                onPressed: () {
                                                  Navigator.of(dialogContext).pop();
                                                  CloseTabNotification().dispatch(formContext); 
                                                },
                                                child: Text(l10n.closeButton), // ★辞書
                                              ),
                                            ],
                                          );
                                        }
                                      );
                                    },
                                  );
                                },
                                child: Text(l10n.closeButton), // ★辞書
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
            
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                double newRatio = LayoutSettings.leftFormRatioNotifier.value + (details.delta.dx / screenWidth);
                if (newRatio * screenWidth < 300) newRatio = 300 / screenWidth; 
                if (newRatio > 0.5) newRatio = 0.5; 
                LayoutSettings.leftFormRatioNotifier.value = newRatio;
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight, 
                child: Container(
                  width: 8.0,
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.drag_indicator, size: 16, color: isDark ? Colors.white54 : Colors.grey),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentCenter,
                        initialZoom: 18.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'biz.webflame.dispatcherz',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentCenter,
                              width: 40,
                              height: 40,
                              child: Icon(Icons.location_on, color: isColor ? Colors.redAccent : Colors.black87, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Container(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 17.0), 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                          ),
                          onPressed: () {
                            _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1.0);
                          },
                          icon: const Icon(Icons.zoom_in),
                          label: Text(l10n.zoomIn, style: const TextStyle(fontWeight: FontWeight.bold)), // ★constを外し、辞書に変更！
                        ),
                        const SizedBox(width: 32),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                          ),
                          onPressed: () {
                            _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1.0);
                          },
                          icon: const Icon(Icons.zoom_out),
                          label: Text(l10n.zoomOut, style: const TextStyle(fontWeight: FontWeight.bold)), // ★constを外し、辞書に変更！
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildTextField(String label, {int maxLines = 1, TextEditingController? controller, int? maxLength}) {
    return TextFormField(
      controller: controller, 
      maxLines: maxLines,
      inputFormatters: maxLength != null ? [LengthLimitingTextInputFormatter(maxLength)] : null,
      decoration: InputDecoration(labelText: label, alignLabelWithHint: maxLines > 1),
    );
  }

  Widget _buildStatefulDropdown(
      List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        isExpanded: true, 
        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8)),
        value: value, 
        items: items.map((String val) => DropdownMenuItem<String>(value: val, child: Text(val))).toList(),
        onChanged: onChanged, 
      ),
    );
  }
}

// ============================================================================
// Module: DispatcherViewContent
// Description: The dashboard interface for visualizing, filtering, and managing 
//              dispatch histories. Includes admin privileges and CSV export/import.
// モジュール: DispatcherViewContent
// 説明: 配車履歴の表示、フィルタリング、管理を行うダッシュボードインターフェース。
//      管理者権限やCSVのエクスポート/インポート機能を含みます。
// ============================================================================
class DispatcherViewContent extends StatefulWidget {
  final bool isAdmin;

  const DispatcherViewContent({Key? key, this.isAdmin = false}) : super(key: key);

  @override
  State<DispatcherViewContent> createState() => _DispatcherViewContentState();
}

class _DispatcherViewContentState extends State<DispatcherViewContent> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  
  DateTimeRange? _dateRange;

  String _selectedFilter = 'all'; // ★内部判定用のキーワード（英語）に変更

  String? _sortColumn;
  bool _sortAscending = true;

  double _wCustomerNum = 120;
  double _wId = 80;
  double _wDate = 150;
  double _wCompDate = 150;
  double _wStatus = 120;
  double _wName = 160;
  double _wPhone = 140;
  double _wDest = 250;
  double _wPrimary = 200; 

  @override
  bool get wantKeepAlive => true; 

  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;
  Timer? _dashboardTimer; 

  @override
  void initState() {
    super.initState();
    
    DateTime now = DateTime.now();
    _dateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 3)),
      end: now.add(const Duration(days: 3)),
    );

    _fetchData(); 
    
    _dashboardTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isLoading) {
        _fetchData();
      }
    });
  }

  // Fetch filtered dispatch data from the API
  // フィルタリングされた配車データをAPIから取得する
  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      String urlStr = 'http://127.0.0.1:8000/api/dispatches';
      if (_dateRange != null) {
        String startStr = '${_dateRange!.start.year}-${_dateRange!.start.month.toString().padLeft(2, '0')}-${_dateRange!.start.day.toString().padLeft(2, '0')}';
        String endStr = '${_dateRange!.end.year}-${_dateRange!.end.month.toString().padLeft(2, '0')}-${_dateRange!.end.day.toString().padLeft(2, '0')}';
        urlStr += '?start=$startStr&end=$endStr';
      }

      final response = await http.get(Uri.parse(urlStr));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        if (!mounted) return;

        setState(() {
          _allData = jsonData.map((item) {
            String dest = item['location_to']?.toString().trim() ?? '';
            String dbStatus = item['status']?.toString() ?? '';
            
            int statusCode = 0;
            if (dbStatus == 'キャンセル') {
              statusCode = 2;
            } else if (dbStatus == '配車完了') {
              statusCode = 1;
            } else if (dbStatus == '未手配') {
              statusCode = 0; 
            } else if (dest.isNotEmpty) {
              statusCode = 1; 
            }

            return {
              'id': item['id'].toString(),
              'customer_number': item['customer_number']?.toString() ?? '',
              'datetime': formatSafeTime(item['dispatch_time']?.toString()),
              'comp_datetime': formatSafeTime(item['completion_time']?.toString()),
              'status': statusCode,
              'name': item['customer_name'] ?? '名称未設定',
              'phone': item['phone_number'] ?? '',
              'destination': item['location_to'] ?? '',
              'primary': item['primary_info'] ?? '', 
              'raw_data': item, 
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('通信エラー: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _dashboardTimer?.cancel(); 
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  // Update the status of a specific dispatch record via API
  // 特定の配車記録のステータスをAPI経由で更新する
  Future<void> _updateDispatchStatus(String id, String newStatus) async {
    // ==========================================
    // ★ここです！この部屋（関数）にも辞書を持ち込む！
    final l10n = AppLocalizations.of(context)!;
    // ==========================================
    try {
      await http.put(
        Uri.parse('http://127.0.0.1:8000/api/dispatches/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );
      
      _fetchData(); 
      RefreshDataNotification().dispatch(context); 
      
      if (mounted) {
        Color msgColor = Colors.blueGrey;
        String localizedStatus = newStatus;
        if (newStatus == '未手配') localizedStatus = l10n.statusReserved;
        if (newStatus == '配車完了') localizedStatus = l10n.statusCompleted;
        if (newStatus == 'キャンセル') localizedStatus = l10n.statusCanceled;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.snackStatusChanged(id, localizedStatus)), backgroundColor: msgColor));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.snackStatusChangeFailed), backgroundColor: Colors.red));
    }
  }

  // Show dialog for administrators to manually change status
  // 管理者がステータスを手動変更するためのダイアログを表示する
  void _showAdminActionDialog(Map<String, dynamic> row) {
    if (!widget.isAdmin) return;
    final l10n = AppLocalizations.of(context)!; // ★ここに追加！

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.dialogStatusChangeTitle(row['id'].toString()), style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(l10n.dialogStatusChangeContent(row['name'].toString())),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.backButton),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(dialogContext);
                
                await _updateDispatchStatus(row['id'], '未手配');
                
                OpenDispatchTabNotification({
                  'id': row['id'], 
                  'name': row['name'],
                  'phone': row['phone'],
                  'loc1': row['raw_data']['location_from_1'] ?? '',
                  'lat1': row['raw_data']['lat_1'],
                  'lng1': row['raw_data']['lng_1'],
                  'loc2': row['raw_data']['location_from_2'] ?? '',
                  'lat2': row['raw_data']['lat_2'],
                  'lng2': row['raw_data']['lng_2'],
                  'loc3': row['raw_data']['location_from_3'] ?? '',
                  'lat3': row['raw_data']['lat_3'],
                  'lng3': row['raw_data']['lng_3'],
                  'destination': row['raw_data']['location_to'] ?? '', 
                  'dispatch_time': row['raw_data']['dispatch_time'],
                  'completion_time': row['raw_data']['completion_time'],
                  'call_area': row['raw_data']['call_area'] ?? '',
                  'guidance': row['raw_data']['guidance'] ?? '',
                  'primary': row['raw_data']['primary_info'] ?? '',
                  'raw_data': row['raw_data'],
                }).dispatch(context);
              },
              child: Text(l10n.revertReservationBtn),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(dialogContext);
                _updateDispatchStatus(row['id'], '配車完了');
              },
              child: Text(l10n.statusCompleted), //既存辞書再利用
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(dialogContext);
                _updateDispatchStatus(row['id'], 'キャンセル');
              },
              child: Text(l10n.cancelButton), //既存辞書再利用
            ),
          ],
        );
      },
    );
  }

  // Export current dashboard view to a local CSV file
  // 現在のダッシュボード表示をローカルのCSVファイルにエクスポートする
  Future<void> _exportCsv(List<Map<String, dynamic>> filteredData) async {
    final l10n = AppLocalizations.of(context)!; // ★ここに追加！
    try {
      StringBuffer sb = StringBuffer();
      sb.write('\uFEFF');
      
      sb.writeln('伝票ID,配車日時,配車完了日時,ステータス,顧客番号,顧客名,電話番号,配車場所1,緯度1,経度1,配車場所2,緯度2,経度2,配車場所3,緯度3,経度3,配車先(移動局),呼び出し,誘導先,Primary');

      for (var row in filteredData) {
        final r = row['raw_data'];
        List<String> fields = [
          r['id']?.toString() ?? '',
          r['dispatch_time']?.toString() ?? '',
          r['completion_time']?.toString() ?? '',
          r['status']?.toString() ?? '',
          r['customer_number']?.toString() ?? '',
          r['customer_name']?.toString() ?? '',
          r['phone_number']?.toString() ?? '',
          r['location_from_1']?.toString() ?? '',
          r['lat_1']?.toString() ?? '',
          r['lng_1']?.toString() ?? '',
          r['location_from_2']?.toString() ?? '',
          r['lat_2']?.toString() ?? '',
          r['lng_2']?.toString() ?? '',
          r['location_from_3']?.toString() ?? '',
          r['lat_3']?.toString() ?? '',
          r['lng_3']?.toString() ?? '',
          r['location_to']?.toString() ?? '',
          r['call_area']?.toString() ?? '',
          r['guidance']?.toString() ?? '',
          r['primary_info']?.toString() ?? '',
        ];

        String rowString = fields.map((f) {
          String escaped = f.replaceAll('"', '""');
          return '"$escaped"';
        }).join(',');
        
        sb.writeln(rowString);
      }

      final now = DateTime.now();
      final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final fileName = 'dispatcherz_export_$timestamp.csv';
      
      final file = File(fileName);
      await file.writeAsString(sb.toString(), encoding: utf8);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.snackCsvExportSuccess(file.absolute.path), style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.snackCsvExportFailed(e.toString())),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  // Import local CSV file and send to Laravel API for processing (Upsert)
  // ローカルのCSVファイルをインポートし、Laravel APIに送信して処理（アップサート）する
  Future<void> _importCsv() async {
    // ==========================================
    // ★ここです！この部屋（関数）にも辞書を持ち込む！
    final l10n = AppLocalizations.of(context)!;
    // ==========================================
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);

        setState(() => _isLoading = true);

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://127.0.0.1:8000/api/dispatches/import'),
        );
        request.files.add(
          await http.MultipartFile.fromPath('csv_file', file.path),
        );

        var response = await request.send();

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l10n.snackCsvImportSuccess, style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.green,
            ));
          }
          _fetchData(); 
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l10n.snackCsvImportFailed),
              backgroundColor: Colors.redAccent,
            ));
          }
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.snackErrorOccurred(e.toString())),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  // Sort dashboard data based on column selection
  // 選択された列に基づいてダッシュボードのデータをソートする
  void _sortData(String columnKey) {
    setState(() {
      if (_sortColumn == columnKey) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = columnKey;
        _sortAscending = true;
      }
    });
  }

  // Generate visual badge based on dispatch status
  // 配車ステータスに基づいた視覚的なバッジを生成する
  Widget _buildStatusBadge(int status, String mode) {
    bool isDark = mode == 'dark';
    bool isColor = mode == 'color';
    final l10n = AppLocalizations.of(context)!; // ★辞書を追加

    Color baseColor;
    String label;
    switch (status) {
      case 0:
        baseColor = isColor ? Colors.blueAccent : (isDark ? Colors.white70 : Colors.black87);
        label = l10n.statusReserved; // ★辞書に変更
        break;
      case 1:
        baseColor = isColor ? Colors.green : (isDark ? Colors.white : Colors.black);
        label = l10n.statusCompleted; // ★辞書に変更
        break;
      case 2:
        baseColor = isColor ? Colors.redAccent : (isDark ? Colors.white54 : Colors.black54);
        label = l10n.statusCanceled; // ★辞書に変更
        break;
      default:
        baseColor = Colors.grey;
        label = l10n.statusUnknown; // ★辞書に変更
    }

    bool isCompleted = status == 1;
    Color textColor;
    if (isColor) {
      textColor = isCompleted ? Colors.white : baseColor;
    } else {
      textColor = isCompleted ? (isDark ? Colors.black : Colors.white) : baseColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? baseColor : Colors.transparent,
        border: Border.all(color: baseColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
        softWrap: false, 
        overflow: TextOverflow.visible,
      ),
    );
  }

  // Generate resizable table headers for the dashboard
  // ダッシュボード用のサイズ変更可能なテーブルヘッダーを生成する
  Widget _buildResizableHeader(String title, String columnKey, double width, ValueChanged<double> onWidthChanged, bool isDark) {
    return SizedBox(
      width: width,
      child: Stack(
        children: [
          Container(
            width: width,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!)), 
            ),
            child: InkWell(
              onTap: () => _sortData(columnKey),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    if (_sortColumn == columnKey)
                      Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: isDark ? Colors.white : Colors.black),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight, 
              child: GestureDetector(
                behavior: HitTestBehavior.translucent, 
                onPanUpdate: (details) {
                  double newWidth = width + details.delta.dx;
                  if (newWidth < 50) newWidth = 50; 
                  onWidthChanged(newWidth);
                },
                child: Container(
                  width: 16.0, 
                  color: Colors.transparent, 
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Generate a standard table cell
  // 標準的なテーブルセルを生成する
  Widget _buildCell(Widget child, double width, bool isDark) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!)),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return NotificationListener<RefreshDataNotification>(
      onNotification: (notification) {
        _fetchData(); 
        return false;
      },
      child: ValueListenableBuilder<String>(
        valueListenable: LayoutSettings.themeModeNotifier,
        builder: (context, mode, child) {
          bool isDark = mode == 'dark';
          bool isColor = mode == 'color';

          String searchText = _searchController.text.trim();

          List<Map<String, dynamic>> filteredData = _allData.where((data) {
            // ★内部キーワード（英語）で判定するように変更
            if (_selectedFilter == 'reserved' && data['status'] != 0) return false; 
            if (_selectedFilter == 'completed' && data['status'] != 1) return false;
            if (_selectedFilter == 'canceled' && data['status'] != 2) return false;

            if (searchText.isNotEmpty) {
              String name = data['name'].toString();
              String phone = data['phone'].toString();
              if (!name.contains(searchText) && !phone.contains(searchText)) {
                return false; 
              }
            }

            return true;
          }).toList();

          if (_sortColumn != null) {
            filteredData.sort((a, b) {
              var valA = a[_sortColumn];
              var valB = b[_sortColumn];

              if (_sortColumn == 'datetime') {
                valA = a['raw_data']['dispatch_time']?.toString() ?? '';
                valB = b['raw_data']['dispatch_time']?.toString() ?? '';
              } else if (_sortColumn == 'comp_datetime') {
                valA = a['raw_data']['completion_time']?.toString() ?? '';
                valB = b['raw_data']['completion_time']?.toString() ?? '';
              }

              if (valA == valB) return 0;
              
              if (valA == null || valA.toString().isEmpty) return _sortAscending ? 1 : -1;
              if (valB == null || valB.toString().isEmpty) return _sortAscending ? -1 : 1;

              int comp;
              if (_sortColumn == 'id' || _sortColumn == 'customer_number') {
                String strA = valA.toString().replaceAll(RegExp(r'[^0-9]'), '');
                String strB = valB.toString().replaceAll(RegExp(r'[^0-9]'), '');
                int numA = int.tryParse(strA) ?? 0;
                int numB = int.tryParse(strB) ?? 0;
                comp = numA.compareTo(numB);
              } 
              else if (valA is num && valB is num) {
                comp = valA.compareTo(valB);
              } else {
                comp = valA.toString().compareTo(valB.toString());
              }
              return _sortAscending ? comp : -comp;
            });
          }

          double totalTableWidth = _wCustomerNum + _wId + _wDate + _wCompDate + _wStatus + 16 + _wName + _wPhone + _wDest + _wPrimary;
          
          final l10n = AppLocalizations.of(context)!; // ★辞書を追加

          String rangeText = l10n.noDateLimit; // ★辞書に変更
          if (_dateRange != null) {
            rangeText = '${l10n.periodPrefix} ${_dateRange!.start.month}/${_dateRange!.start.day} - ${_dateRange!.end.month}/${_dateRange!.end.day}'; // ★辞書に変更
          }

          return Container(
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.dashboard, color: isColor ? Colors.indigo : (isDark ? Colors.white : Colors.black), size: 28),
                      const SizedBox(width: 12),
                      Text(widget.isAdmin ? l10n.dashboardTitleAdmin : l10n.dashboardTitleGeneral, // ★辞書に変更
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      const Spacer(),
                      
                      if (widget.isAdmin) ...[
                        IconButton(
                          icon: Icon(Icons.upload_file, color: isColor ? Colors.orange : (isDark ? Colors.white : Colors.black)),
                          tooltip: l10n.tooltipImportCsv, // ★辞書に変更
                          onPressed: _importCsv,
                        ),
                        const SizedBox(width: 8),

                        IconButton(
                          icon: Icon(Icons.download, color: isColor ? Colors.green : (isDark ? Colors.white : Colors.black)),
                          tooltip: l10n.tooltipExportCsv, // ★辞書に変更
                          onPressed: () {
                            _exportCsv(filteredData);
                          },
                        ),
                      ],
                      const SizedBox(width: 8),

                      IconButton(
                          icon: Icon(Icons.refresh, color: isColor ? Colors.blueAccent : (isDark ? Colors.white : Colors.black)),
                          tooltip: l10n.tooltipRefresh, 
                          onPressed: () {
                            _fetchData(); 
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.snackDataRefreshed)), // ★スッキリ直す！
                            );
                          },
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.close, color: isColor ? Colors.redAccent : (isDark ? Colors.red[300] : Colors.red)),
                        tooltip: l10n.tooltipCloseTab, // ★辞書に変更
                        onPressed: () {
                          CloseTabNotification().dispatch(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(foregroundColor: isDark ? Colors.white : Colors.black),
                            icon: const Icon(Icons.calendar_month),
                            label: Text(rangeText),
                            onPressed: () async {
                              // ... (カレンダー選択処理の中身はそのまま) ...
                              DateTimeRange? picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2024),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                initialDateRange: _dateRange,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: isDark ? const ColorScheme.dark(primary: Colors.blueAccent) : const ColorScheme.light(primary: Colors.blueAccent),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              
                              if (picked != null) {
                                int days = picked.end.difference(picked.start).inDays;
                                int maxDays = widget.isAdmin ? 366 : 93; 

                                if (days > maxDays) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(l10n.snackDateRangeLimit(widget.isAdmin ? l10n.limitOneYear : l10n.limitThreeMonths), style: const TextStyle(fontWeight: FontWeight.bold)),
                                      backgroundColor: Colors.redAccent,
                                      duration: const Duration(seconds: 4),
                                    ));
                                  }
                                  return; 
                                }

                                setState(() {
                                  _dateRange = picked;
                                });
                                _fetchData(); 
                              }
                            },
                          ),
                          SegmentedButton<String>(
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor: isColor ? Colors.blueAccent : (isDark ? Colors.white : Colors.black),
                              selectedForegroundColor: isColor ? Colors.white : (isDark ? Colors.black : Colors.white),
                            ),
                            segments: [
                              // ★ valueは裏側用の英語、labelは表示用の辞書（l10n）に分離！
                              ButtonSegment(value: 'all', label: SizedBox(width: 110, child: Center(child: Text(l10n.allFilters)))), 
                              ButtonSegment(value: 'reserved', label: SizedBox(width: 110, child: Center(child: Text(l10n.reservedOnlyFilter)))), 
                              ButtonSegment(value: 'completed', label: SizedBox(width: 110, child: Center(child: Text(l10n.completedOnlyFilter)))),
                              ButtonSegment(value: 'canceled', label: SizedBox(width: 110, child: Center(child: Text(l10n.cancelFilter)))),
                            ],
                            selected: {_selectedFilter},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() {
                                _selectedFilter = newSelection.first;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {}); 
                          },
                          decoration: InputDecoration(
                            hintText: l10n.searchHint, // ★辞書に変更
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Scrollbar(
                      controller: _horizontalScrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : Colors.grey[200],
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
                                border: Border(bottom: BorderSide(color: isDark ? Colors.white54 : Colors.grey, width: 1)),
                              ),
                              child: Row(
                                children: [
                                  // ★見出しを辞書に変更
                                  _buildResizableHeader(l10n.colCustomerNo, 'customer_number', _wCustomerNum, (w) => setState(() => _wCustomerNum = w), isDark),
                                  _buildResizableHeader(l10n.colDispatchId, 'id', _wId, (w) => setState(() => _wId = w), isDark),
                                  _buildResizableHeader(l10n.colDispatchDate, 'datetime', _wDate, (w) => setState(() => _wDate = w), isDark),
                                  _buildResizableHeader(l10n.colCompletionDate, 'comp_datetime', _wCompDate, (w) => setState(() => _wCompDate = w), isDark),
                                  _buildResizableHeader(l10n.colStatus, 'status', _wStatus, (w) => setState(() => _wStatus = w), isDark),
                                  const SizedBox(width: 16), 
                                  _buildResizableHeader(l10n.customerName, 'name', _wName, (w) => setState(() => _wName = w), isDark),
                                  _buildResizableHeader(l10n.colPhone, 'phone', _wPhone, (w) => setState(() => _wPhone = w), isDark),
                                  _buildResizableHeader(l10n.colDestination, 'destination', _wDest, (w) => setState(() => _wDest = w), isDark),
                                  _buildResizableHeader('Primary', 'primary', _wPrimary, (w) => setState(() => _wPrimary = w), isDark),
                                ],
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                width: totalTableWidth,
                                child: _isLoading 
                                    ? const Center(child: CircularProgressIndicator()) 
                                    : Scrollbar(
                                  controller: _verticalScrollController,
                                  thumbVisibility: true,
                                  child: ListView.builder(
                                    controller: _verticalScrollController,
                                    itemCount: filteredData.length,
                                    itemBuilder: (context, index) {
                                      final row = filteredData[index];
                                      
                                      bool isFuture = false;
                                      try {
                                        String dateStr = row['comp_datetime'].toString().replaceAll('/', '-');
                                        DateTime compTime = DateTime.parse('$dateStr:00');
                                        isFuture = compTime.isAfter(DateTime.now());
                                      } catch (e) {}

                                      bool isDestinationEmpty = row['destination'] == null || row['destination'].toString().trim().isEmpty;
                                      
                                      FontWeight compDateFontWeight = FontWeight.normal; 
                                      if (isFuture && isDestinationEmpty) {
                                        compDateFontWeight = FontWeight.bold;
                                      }

                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: widget.isAdmin ? () => _showAdminActionDialog(row) : null,
                                            hoverColor: widget.isAdmin ? (isDark ? Colors.white10 : Colors.black12) : Colors.transparent,
                                            mouseCursor: widget.isAdmin ? SystemMouseCursors.click : SystemMouseCursors.basic,
                                            child: Padding(
                                              padding: EdgeInsets.zero,
                                              child: Row(
                                                children: [
                                                  _buildCell(Text(row['customer_number'], style: TextStyle(color: isDark ? Colors.white : Colors.black)), _wCustomerNum, isDark),
                                                  _buildCell(Text('#${row['id']}', style: TextStyle(color: isDark ? Colors.white : Colors.black)), _wId, isDark),
                                                  _buildCell(Text(row['datetime']), _wDate, isDark),
                                                  _buildCell(Text(row['comp_datetime'], style: TextStyle(fontWeight: compDateFontWeight, color: isDark ? Colors.white : Colors.black)), _wCompDate, isDark),
                                                  _buildCell(_buildStatusBadge(row['status'], mode), _wStatus, isDark),
                                                  const SizedBox(width: 16), 
                                                  _buildCell(Text(row['name'], overflow: TextOverflow.ellipsis), _wName, isDark),
                                                  _buildCell(Text(row['phone']), _wPhone, isDark),
                                                  _buildCell(Text(row['destination'], overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white : Colors.black)), _wDest, isDark),
                                                  _buildCell(Text(row['primary'], overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white : Colors.black)), _wPrimary, isDark),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}