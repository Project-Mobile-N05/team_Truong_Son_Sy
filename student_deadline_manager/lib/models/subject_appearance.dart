import 'package:flutter/material.dart';

const Map<String, Color> subjectColors = {
  'violet': Color(0xFF7155D9),
  'blue': Color(0xFF3682D8),
  'teal': Color(0xFF149D9A),
  'green': Color(0xFF3B9B68),
  'orange': Color(0xFFE58A32),
  'rose': Color(0xFFD85C7A),
};

const Map<String, IconData> subjectIcons = {
  'book': Icons.menu_book_rounded,
  'science': Icons.science_rounded,
  'computer': Icons.computer_rounded,
  'calculate': Icons.calculate_rounded,
  'language': Icons.translate_rounded,
  'history': Icons.account_balance_rounded,
  'palette': Icons.palette_rounded,
  'biology': Icons.biotech_rounded,
  'business': Icons.business_center_rounded,
  'psychology': Icons.psychology_rounded,
};

Color subjectColor(String key) =>
    subjectColors[key] ?? subjectColors['violet']!;

IconData subjectIcon(String key) => subjectIcons[key] ?? subjectIcons['book']!;
