import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'navigation/main_navigation.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'widgets/app_loading_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? startupError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init lỗi: $e');
    startupError =
        'Không thể kết nối dịch vụ. Hãy kiểm tra mạng và mở lại ứng dụng.';
  }
  runApp(MyApp(startupError: startupError));
}

class MyApp extends StatelessWidget {
  final String? startupError;

  const MyApp({super.key, this.startupError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Bài Tập',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: startupError == null
          ? const AuthGate()
          : _FirebaseUnavailableScreen(message: startupError!),
    );
  }
}

class _FirebaseUnavailableScreen extends StatelessWidget {
  final String message;

  const _FirebaseUnavailableScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  final Stream<User?>? authStateChanges;
  final ValueListenable<bool>? busy;
  final WidgetBuilder? signedOutBuilder;

  const AuthGate({
    super.key,
    this.authStateChanges,
    this.busy,
    this.signedOutBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: busy ?? AuthService.busy,
      builder: (context, busy, _) {
        return StreamBuilder<User?>(
          stream: authStateChanges ?? FirebaseAuth.instance.authStateChanges(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const AppLoadingScreen(
                message: 'Đang kiểm tra phiên đăng nhập…',
              );
            }
            if (busy || snap.data == null) {
              return signedOutBuilder?.call(context) ?? const LoginScreen();
            }
            return const MainNavigation();
          },
        );
      },
    );
  }
}
