import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/models/task.dart';
import 'package:student_deadline_manager/models/task_status.dart';
import 'package:student_deadline_manager/services/task_service.dart';

Task _task(
  String title,
  DateTime dueDate, {
  TaskStatus status = TaskStatus.pending,
}) {
  return Task(
    userId: 'user',
    title: title,
    taskDatetime: dueDate,
    status: status,
  );
}

void main() {
  group('TaskService.tasksOfDay', () {
    test('returns every deadline for the selected date in time order', () {
      final day = DateTime(2026, 10, 30);
      final tasks = [
        _task('Later', DateTime(2026, 10, 30, 18)),
        _task('Other day', DateTime(2026, 10, 31, 10)),
        _task('Earlier', DateTime(2026, 10, 30, 9)),
      ];

      final result = TaskService.tasksOfDay(tasks, day);

      expect(result.map((task) => task.title), ['Earlier', 'Later']);
    });
  });

  group('TaskService.upcoming', () {
    test('includes completed and incomplete deadlines in the date range', () {
      final now = DateTime(2026, 10, 30, 15);
      final tasks = [
        _task('Today at midnight', DateTime(2026, 10, 30)),
        _task('Tomorrow', DateTime(2026, 10, 31, 9)),
        _task(
          'Completed tomorrow',
          DateTime(2026, 10, 31, 10),
          status: TaskStatus.completed,
        ),
        _task('Sunday', DateTime(2026, 11, 1, 12)),
        _task('Wednesday', DateTime(2026, 11, 4, 12)),
        _task(
          'Completed today',
          DateTime(2026, 10, 30, 17),
          status: TaskStatus.completed,
        ),
        _task('Yesterday', DateTime(2026, 10, 29, 23)),
        _task('Outside seven days', DateTime(2026, 11, 6)),
      ];

      final result = TaskService.upcoming(tasks, now: now);

      expect(result.map((task) => task.title), [
        'Today at midnight',
        'Completed today',
        'Tomorrow',
        'Completed tomorrow',
        'Sunday',
        'Wednesday',
      ]);
      expect(result[3].displayStatus(), TaskStatus.completed);
    });
  });

  group('TaskService.tasksThisWeek', () {
    test('counts deadlines from Monday through Sunday', () {
      final tasks = [
        _task('Monday', DateTime(2026, 10, 26)),
        _task('Sunday', DateTime(2026, 11, 1, 23, 59)),
        _task(
          'Completed this week',
          DateTime(2026, 10, 28, 12),
          status: TaskStatus.completed,
        ),
        _task('Previous week', DateTime(2026, 10, 25, 23, 59)),
        _task('Next week', DateTime(2026, 11, 2)),
      ];

      final result = TaskService.tasksThisWeek(
        tasks,
        now: DateTime(2026, 10, 30, 15),
      );

      expect(result.map((task) => task.title), [
        'Monday',
        'Completed this week',
        'Sunday',
      ]);
    });
  });
}
