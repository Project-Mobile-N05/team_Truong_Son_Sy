import 'package:flutter/material.dart';

/// Lịch tháng theo wireframe: tiêu đề "Tháng 10, 2026", hàng T2..CN,
/// ngày đang chọn tô màu chính, ngày có deadline có chấm nhỏ (đỏ nếu quá hạn).
/// Không dùng thư viện ngoài nên không cần thêm dependency.
class MonthCalendar extends StatelessWidget {
  /// Tháng đang hiển thị (chỉ dùng năm và tháng).
  final DateTime month;

  /// Ngày đang chọn.
  final DateTime selected;

  /// Các ngày (đã bỏ giờ) có deadline.
  final Set<DateTime> markedDays;

  /// Các ngày (đã bỏ giờ) có deadline quá hạn.
  final Set<DateTime> overdueDays;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const MonthCalendar({
    super.key,
    required this.month,
    required this.selected,
    required this.onSelect,
    required this.onPrev,
    required this.onNext,
    this.markedDays = const {},
    this.overdueDays = const {},
  });

  static const _weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1; // T2 = 0 ... CN = 6

    final cells = <DateTime?>[
      for (var i = 0; i < leading; i++) null,
      for (var d = 1; d <= daysInMonth; d++)
        DateTime(month.year, month.month, d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sel = DateTime(selected.year, selected.month, selected.day);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Tháng trước',
                icon: const Icon(Icons.chevron_left),
                onPressed: onPrev,
              ),
              Expanded(
                child: Text(
                  'Tháng ${month.month}, ${month.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
              IconButton(
                tooltip: 'Tháng sau',
                icon: const Icon(Icons.chevron_right),
                onPressed: onNext,
              ),
            ],
          ),
          Row(
            children: [
              for (final w in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(w,
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (var r = 0; r < cells.length; r += 7)
            Row(
              children: [
                for (final day in cells.sublist(r, r + 7))
                  Expanded(
                    child: day == null
                        ? const SizedBox(height: 48)
                        : _DayCell(
                            day: day,
                            isSelected: day == sel,
                            isToday: day == today,
                            hasDeadline: markedDays.contains(day),
                            hasOverdue: overdueDays.contains(day),
                            onTap: () => onSelect(day),
                          ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool hasDeadline;
  final bool hasOverdue;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasDeadline,
    required this.hasOverdue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textColor = isSelected ? scheme.onPrimary : scheme.onSurface;
    final dotColor = isSelected
        ? scheme.onPrimary
        : (hasOverdue ? Colors.red.shade600 : scheme.primary);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? scheme.primary : null,
            borderRadius: BorderRadius.circular(16),
            border: (isToday && !isSelected)
                ? Border.all(color: scheme.primary)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 5,
                child: hasDeadline
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox(width: 5, height: 5),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}