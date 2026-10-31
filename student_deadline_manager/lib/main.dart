import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'navigation/main_navigation.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'widgets/app_loading_screen.dart';
import 'widgets/login_success_screen.dart';

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

class AuthGate extends StatefulWidget {
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
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<User?>? _authSubscription;
  User? _user;
  bool _authResolved = false;
  bool _showLoginSuccess = false;
  Timer? _successTimer;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        (widget.authStateChanges ?? FirebaseAuth.instance.authStateChanges())
            .listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    if (!mounted) return;
    final firstAuthEvent = !_authResolved;
    final signedInNow = _authResolved && _user == null && user != null;
    _successTimer?.cancel();
    setState(() {
      _authResolved = true;
      _user = user;
      // Don't animate a session restored on app startup.
      _showLoginSuccess = !firstAuthEvent && signedInNow;
    });
    if (signedInNow) {
      _successTimer = Timer(const Duration(milliseconds: 1050), () {
        if (!mounted) return;
        setState(() => _showLoginSuccess = false);
      });
    }
  }

  @override
  void dispose() {
    _successTimer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.busy ?? AuthService.busy,
      builder: (context, busy, _) {
        if (!_authResolved) {
          return const AppLoadingScreen(
            message: 'Đang kiểm tra phiên đăng nhập…',
          );
        }
        if (_user != null && _showLoginSuccess) {
          return const LoginSuccessScreen();
        }
        if (busy || _user == null) {
          return widget.signedOutBuilder?.call(context) ?? const LoginScreen();
        }
        return const MainNavigation();
      },
    );
  }
}
