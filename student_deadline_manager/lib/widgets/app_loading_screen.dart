import 'package:flutter/material.dart';

/// Branded loading state used while Firebase restores or verifies a session.
class AppLoadingScreen extends StatelessWidget {
  final String message;

  const AppLoadingScreen({super.key, this.message = 'Đang tải ứng dụng…'});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF5B43C2);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EDFF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: purple,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Deadline',
                  style: TextStyle(
                    color: Color(0xFF211B36),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: purple,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6F6A7D),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
