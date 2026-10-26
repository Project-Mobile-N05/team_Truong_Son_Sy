import 'package:flutter/material.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  const ScreenHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 14),
        child: Text(title,
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F1B2D))),
      );
}

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const SoftCard(
      {super.key, required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDDD8E8)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x141F1B2D), blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: child,
      );
}
