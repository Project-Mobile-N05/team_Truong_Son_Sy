import 'package:flutter/material.dart';

class HomeTile extends StatelessWidget {
  final String title;
  final Color color;
  final List<Color> gradient;
  final IconData icon;
  final double fontSize;
  final VoidCallback onTap;

  const HomeTile({
    super.key,
    required this.title,
    required this.color,
    required this.gradient,
    required this.icon,
    required this.onTap,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 103,
          child: Stack(
            children: [
              Positioned(
                right: -12,
                bottom: -40,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: gradient,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 12,
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              Positioned(
                left: 13,
                top: 12,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F1B2D),
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