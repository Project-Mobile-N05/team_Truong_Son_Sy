import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_status.dart';

String _two(int n) => n.toString().padLeft(2, '0');

/// dd/MM/yyyy
String formatDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

/// dd/MM
String formatDayMonth(DateTime d) => '${_two(d.day)}/${_two(d.month)}';

/// HH:mm
String formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

/// Thẻ một deadline trong danh sách (theo wireframe màn Lịch):
/// tiêu đề, "Môn học · Trạng thái · Giờ" và nút "Xong".
/// Deadline quá hạn hiển thị màu đỏ.
class TaskCard extends StatelessWidget {
  final Task task;
  final String? subjectName;
  final VoidCallback? onTap;

  /// null thì không hiện nút "Xong".
  final VoidCallback? onComplete;

  const TaskCard({
    super.key,
    required this.task,
    this.subjectName,
    this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = task.displayStatus();
    final done = status == TaskStatus.completed;
    final overdue = status == TaskStatus.overdue;
    final accent = overdue ? Colors.red.shade700 : scheme.onSurfaceVariant;

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: overdue ? Colors.red.shade200 : scheme.outlineVariant),
      ),
      child: InkWell(
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${subjectName ?? 'Chưa có môn học'} · ${status.label} · ${formatTime(task.taskDatetime)}',
                      style: TextStyle(color: accent),
                    ),
                  ],
                ),
              ),
              if (onComplete != null && !done) ...[
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: onComplete,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: scheme.primary, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Xong',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ] else if (done)
                Icon(Icons.check_circle, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}