import 'package:flutter/material.dart';

class LoginSuccessScreen extends StatefulWidget {
  const LoginSuccessScreen({super.key});

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _checkScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _checkScale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.28, 1, curve: Curves.easeOut),
    );
    _textOffset = Tween<Offset>(
      begin: const Offset(0, 0.16),
      end: Offset.zero,
    ).animate(_textOpacity);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _checkScale,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE8FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF5B43C2),
                    size: 52,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              FadeTransition(
                opacity: _textOpacity,
                child: SlideTransition(
                  position: _textOffset,
                  child: const Column(
                    children: [
                      Text(
                        'Đăng nhập thành công',
                        style: TextStyle(
                          color: Color(0xFF211B36),
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Đang mở không gian học tập của bạn…',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF777286),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
