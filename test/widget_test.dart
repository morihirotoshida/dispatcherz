import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dispatcherz/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // 完全に新しくなった dispatcherZ のアプリを起動するテスト
    // ★修正: DispatcherApp() -> DispatcherZApp()
    await tester.pumpWidget(const DispatcherZApp());

    // MaterialAppが1つ画面に存在していればOK（起動成功）とする
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}