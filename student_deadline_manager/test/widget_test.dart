import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/controllers/reminder_manager.dart';
import 'package:student_deadline_manager/main.dart';
import 'package:student_deadline_manager/widgets/login_success_screen.dart';

void main() {
  testWidgets('MyApp shows a startup error without opening Firebase', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MyApp(startupError: 'Firebase chưa sẵn sàng'),
    );

    expect(find.text('Firebase chưa sẵn sàng'), findsOneWidget);
  });

  testWidgets('AuthGate shows the signed-out screen', (tester) async {
    final authState = StreamController<User?>();
    final busy = ValueNotifier(false);
    addTearDown(authState.close);
    addTearDown(busy.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          authStateChanges: authState.stream,
          busy: busy,
          signedOutBuilder: (_) => const Text('Đăng nhập để tiếp tục'),
        ),
      ),
    );
    authState.add(null);
    await tester.pump();

    expect(find.text('Đăng nhập để tiếp tục'), findsOneWidget);
  });

  testWidgets('login success screen shows confirmation', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginSuccessScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập thành công'), findsOneWidget);
    expect(find.text('Đang mở không gian học tập của bạn…'), findsOneWidget);
  });

  test('ReminderManager keeps compatibility getters', () {
    final manager = ReminderManager();

    expect(manager.title, 'Nộp Bài tập thực hành Flutter');
    expect(manager.dueDate, '16/09/2026');
    expect(manager.status, 'Đang thực hiện');

    manager.setReminder('Bài tập mới', '20/10/2026', 'Đã hoàn thành');

    expect(manager.title, 'Bài tập mới');
    expect(manager.dueDate, '20/10/2026');
    expect(manager.status, 'Đã hoàn thành');
  });
}
