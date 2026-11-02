import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/models/task.dart';
import 'package:student_deadline_manager/models/task_status.dart';
import 'package:student_deadline_manager/services/statistics_service.dart';

Task _task(
  String title,
  DateTime dueDate, {
  String? subjectId,
  TaskStatus status = TaskStatus.pending,
}) => Task(
  userId: 'user-1',
  title: title,
  taskDatetime: dueDate,
  subjectId: subjectId,
  status: status,
);

void main() {
  group('StatisticsService.filterByDateRange', () {
    test('lọc bao gồm cả hai ngày biên và bỏ qua giờ trong ngày', () {
      final tasks = [
        _task('Trước khoảng', DateTime(2026, 10, 29, 23, 59)),
        _task('Đầu ngày', DateTime(2026, 10, 30)),
        _task('Cuối ngày', DateTime(2026, 10, 31, 23, 59)),
        _task('Sau khoảng', DateTime(2026, 11, 1)),
      ];

      final result = StatisticsService.filterByDateRange(
        tasks,
        startDate: DateTime(2026, 10, 30, 18),
        endDate: DateTime(2026, 10, 31, 9),
      );

      expect(result.map((task) => task.title), ['Đầu ngày', 'Cuối ngày']);
    });

    test('trả về danh sách rỗng khi không có deadline trong khoảng', () {
      final result = StatisticsService.filterByDateRange(
        [_task('Ngoài khoảng', DateTime(2026, 11, 1))],
        startDate: DateTime(2026, 10, 30),
        endDate: DateTime(2026, 10, 31),
      );

      expect(result, isEmpty);
    });
  });

  group('StatisticsService summaries', () {
    test('đếm deadline hoàn thành và chưa hoàn thành', () {
      final tasks = [
        _task('Chưa làm', DateTime(2026, 10, 30)),
        _task('Đã xong', DateTime(2026, 10, 30), status: TaskStatus.completed),
        _task(
          'Đang làm',
          DateTime(2026, 10, 30),
          status: TaskStatus.inProgress,
        ),
      ];

      expect(StatisticsService.completedCount(tasks), 1);
      expect(StatisticsService.pendingCount(tasks), 2);
    });

    test('đếm deadline theo môn và bỏ qua deadline không gắn môn', () {
      final tasks = [
        _task('Bài 1', DateTime(2026, 10, 30), subjectId: 'CS101'),
        _task('Bài 2', DateTime(2026, 10, 31), subjectId: 'CS101'),
        _task('Bài 3', DateTime(2026, 11, 1), subjectId: 'MA102'),
        _task('Không có môn', DateTime(2026, 11, 2)),
      ];

      expect(StatisticsService.deadlineCountBySubject(tasks), {
        'CS101': 2,
        'MA102': 1,
      });
    });
  });
}
