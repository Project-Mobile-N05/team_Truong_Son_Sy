import 'package:flutter/material.dart';
import '../models/subject_appearance.dart';

class SubjectAppearancePicker extends StatelessWidget {
  final String colorKey;
  final String iconKey;
  final ValueChanged<String> onColorChanged;
  final ValueChanged<String> onIconChanged;

  const SubjectAppearancePicker({
    super.key,
    required this.colorKey,
    required this.iconKey,
    required this.onColorChanged,
    required this.onIconChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = subjectColor(colorKey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Màu đại diện',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 10,
          children: [
            for (final entry in subjectColors.entries)
              Tooltip(
                message: entry.key,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onColorChanged(entry.key),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorKey == entry.key
                            ? const Color(0xFF211B36)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: colorKey == entry.key
                        ? const Icon(Icons.check, size: 17, color: Colors.white)
                        : null,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Icon môn học',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in subjectIcons.entries)
              Tooltip(
                message: entry.key,
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => onIconChanged(entry.key),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconKey == entry.key
                          ? activeColor.withValues(alpha: 0.12)
                          : const Color(0xFFF5F4F8),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: iconKey == entry.key
                            ? activeColor
                            : const Color(0xFFE9E7EE),
                        width: iconKey == entry.key ? 1.5 : 1,
                      ),
                    ),
                    child: Icon(entry.value, color: activeColor, size: 21),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
