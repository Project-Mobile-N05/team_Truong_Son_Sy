import '../models/task.dart';
import '../models/task_status.dart';

class StatisticsService {
  static List<Task> filterByDateRange(
    Iterable<Task> tasks, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = _dayKey(startDate);
    final end = _dayKey(endDate);
    return tasks.where((task) {
      final date = _dayKey(task.taskDatetime);
      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  static int completedCount(Iterable<Task> tasks) =>
      tasks.where((task) => task.status == TaskStatus.completed).length;

  static int pendingCount(Iterable<Task> tasks) =>
      tasks.length - completedCount(tasks);

  static Map<String, int> deadlineCountBySubject(Iterable<Task> tasks) {
    final counts = <String, int>{};
    for (final task in tasks) {
      final subjectId = task.subjectId;
      if (subjectId != null) {
        counts.update(subjectId, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  static DateTime _dayKey(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
