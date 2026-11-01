import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/models/task.dart';
import 'package:student_deadline_manager/models/task_status.dart';
import 'package:student_deadline_manager/models/task_type.dart';
import 'package:student_deadline_manager/services/task_service.dart';

/// Unit test cho model Task, enum và các hàm kiểm tra dữ liệu.
/// Không cần Firebase và không cần thư viện test nào thêm.
void main() {
  final now = DateTime(2026, 10, 27, 12);

  Task makeTask({
    String id = 't1',
    String title = 'Bài tập',
    DateTime? at,
    TaskStatus status = TaskStatus.pending,
  }) =>
      Task(
        id: id,
        userId: 'u1',
        title: title,
        taskDatetime: at ?? DateTime(2026, 11, 2, 9),
        status: status,
      );

  group('TaskStatus và TaskType', () {
    test('TaskStatus.fromName đọc đúng giá trị', () {
      expect(TaskStatus.fromName('inProgress'), TaskStatus.inProgress);
      expect(TaskStatus.fromName('completed'), TaskStatus.completed);
    });

    test('TaskStatus.fromName: giá trị lạ hoặc null thì là pending', () {
      expect(TaskStatus.fromName('abc'), TaskStatus.pending);
      expect(TaskStatus.fromName(null), TaskStatus.pending);
    });

    test('TaskType.fromName', () {
      expect(TaskType.fromName('exam'), TaskType.exam);
      expect(TaskType.fromName('classSession'), TaskType.classSession);
      expect(TaskType.fromName('zzz'), isNull);
      expect(TaskType.fromName(null), isNull);
    });

    test('có nhãn tiếng Việt', () {
      expect(TaskStatus.completed.label, 'Hoàn thành');
      expect(TaskType.assignment.label, 'Bài tập');
    });
  });

  group('Task', () {
    test('isOverdue: quá hạn khi chưa hoàn thành', () {
      final t = makeTask(at: now.subtract(const Duration(hours: 1)));
      expect(t.isOverdue(now: now), isTrue);
      expect(t.displayStatus(now: now), TaskStatus.overdue);
    });

    test('isOverdue: chưa đến hạn thì không quá hạn', () {
      final t = makeTask(at: now.add(const Duration(hours: 1)));
      expect(t.isOverdue(now: now), isFalse);
      expect(t.displayStatus(now: now), TaskStatus.pending);
    });

    test('isOverdue: đã hoàn thành thì không quá hạn', () {
      final t = makeTask(
        at: now.subtract(const Duration(days: 3)),
        status: TaskStatus.completed,
      );
      expect(t.isOverdue(now: now), isFalse);
      expect(t.displayStatus(now: now), TaskStatus.completed);
    });

    test('daysLeft tính theo ngày lịch', () {
      expect(makeTask(at: DateTime(2026, 10, 30, 8)).daysLeft(now: now), 3);
      expect(makeTask(at: DateTime(2026, 10, 27, 23)).daysLeft(now: now), 0);
      expect(makeTask(at: DateTime(2026, 10, 25, 8)).daysLeft(now: now), -2);
    });

    test('toMap rồi fromMap giữ nguyên dữ liệu', () {
      final t = Task(
        userId: 'u1',
        subjectId: 's1',
        title: 'Nộp báo cáo',
        type: TaskType.project,
        taskDatetime: DateTime(2026, 11, 2, 23, 59),
        room: 'A9-2310',
        notes: 'In 2 bản',
        status: TaskStatus.inProgress,
      );
      final back = Task.fromMap('id1', t.toMap());
      expect(back.id, 'id1');
      expect(back.userId, 'u1');
      expect(back.subjectId, 's1');
      expect(back.title, 'Nộp báo cáo');
      expect(back.type, TaskType.project);
      expect(back.taskDatetime.isAtSameMomentAs(t.taskDatetime), isTrue);
      expect(back.room, 'A9-2310');
      expect(back.notes, 'In 2 bản');
      expect(back.status, TaskStatus.inProgress);
    });

    test('toMap bỏ qua các trường tùy chọn đang trống', () {
      final map = makeTask().toMap();
      expect(map.containsKey('subjectId'), isFalse);
      expect(map.containsKey('room'), isFalse);
      expect(map.containsKey('notes'), isFalse);
      expect(map.containsKey('type'), isFalse);
      expect(map['status'], 'pending');
      expect(map['userId'], 'u1');
    });

    test('fromMap: dữ liệu thiếu hoặc lạ vẫn không lỗi', () {
      final back = Task.fromMap('x', {'status': 'abc', 'type': 'zzz'});
      expect(back.title, '');
      expect(back.userId, '');
      expect(back.status, TaskStatus.pending);
      expect(back.type, isNull);
    });

    test('copyWith đổi đúng trường và giữ id, createdAt', () {
      final t = Task(
        id: 't1',
        userId: 'u1',
        subjectId: 's1',
        title: 'A',
        taskDatetime: DateTime(2026, 11, 2, 9),
      );
      final c = t.copyWith(title: 'B', status: TaskStatus.completed);
      expect(c.title, 'B');
      expect(c.status, TaskStatus.completed);
      expect(c.id, 't1');
      expect(c.subjectId, 's1');
      expect(c.createdAt, t.createdAt);
    });

    test('copyWith: clearSubjectId xóa môn học', () {
      final t = Task(
        userId: 'u1',
        subjectId: 's1',
        title: 'A',
        taskDatetime: DateTime(2026, 11, 2),
      );
      expect(t.copyWith(clearSubjectId: true).subjectId, isNull);
    });

    test('TaskDto.fromTask sao chép dữ liệu và cho đổi trạng thái', () {
      final t = makeTask(title: 'A');
      final dto = TaskDto.fromTask(t, status: TaskStatus.completed);
      expect(dto.title, 'A');
      expect(dto.taskDatetime, t.taskDatetime);
      expect(dto.status, TaskStatus.completed);
      expect(TaskDto.fromTask(t).status, TaskStatus.pending);
    });
  });

  group('TaskService (kiểm tra dữ liệu)', () {
    test('validateTitle', () {
      expect(TaskService.validateTitle(null), isNotNull);
      expect(TaskService.validateTitle(''), isNotNull);
      expect(TaskService.validateTitle('   '), isNotNull);
      expect(TaskService.validateTitle('a' * 101), isNotNull);
      expect(TaskService.validateTitle('a' * 100), isNull);
      expect(TaskService.validateTitle('Nộp bài'), isNull);
    });

    test('validateDateTime', () {
      final base = DateTime(2026, 10, 27);
      final yesterday = base.subtract(const Duration(days: 1));
      final tomorrow = base.add(const Duration(days: 1));
      expect(TaskService.validateDateTime(null), isNotNull);
      expect(TaskService.validateDateTime(yesterday, now: base), isNotNull);
      expect(
        TaskService.validateDateTime(yesterday, now: base, allowPast: true),
        isNull,
      );
      expect(TaskService.validateDateTime(tomorrow, now: base), isNull);
    });
  });

  group('TaskService (Lịch và sắp tới)', () {
    test('groupByDay nhóm theo ngày và sắp xếp theo giờ', () {
      final tasks = [
        makeTask(id: '2', at: DateTime(2026, 11, 2, 18)),
        makeTask(id: '1', at: DateTime(2026, 11, 2, 9)),
        makeTask(id: '3', at: DateTime(2026, 11, 4, 8)),
      ];
      final grouped = TaskService.groupByDay(tasks);
      expect(grouped.length, 2);
      expect(grouped[DateTime(2026, 11, 2)]!.map((t) => t.id), ['1', '2']);
      expect(grouped[DateTime(2026, 11, 4)]!.length, 1);
    });

    test('tasksOfDay chỉ lấy đúng ngày', () {
      final tasks = [
        makeTask(id: '1', at: DateTime(2026, 11, 2, 9)),
        makeTask(id: '2', at: DateTime(2026, 11, 4, 8)),
      ];
      expect(TaskService.tasksOfDay(tasks, DateTime(2026, 11, 4)).length, 1);
      expect(TaskService.tasksOfDay(tasks, DateTime(2026, 11, 3)), isEmpty);
    });

    test('dayKey bỏ phần giờ', () {
      expect(
        TaskService.dayKey(DateTime(2026, 11, 2, 23, 59)),
        DateTime(2026, 11, 2),
      );
    });

    test('upcoming: gồm deadline đã hoàn thành trong 7 ngày lịch tới', () {
      final tasks = [
        makeTask(id: 'in', at: DateTime(2026, 10, 28, 9)),
        makeTask(id: 'edge', at: DateTime(2026, 11, 3, 11, 59)),
        makeTask(id: 'over', at: DateTime(2026, 11, 3, 12)),
        makeTask(id: 'far', at: DateTime(2026, 11, 20)),
        makeTask(id: 'past', at: DateTime(2026, 10, 26)),
        makeTask(
          id: 'done',
          at: DateTime(2026, 10, 29),
          status: TaskStatus.completed,
        ),
      ];
      final result = TaskService.upcoming(tasks, now: now);
      expect(result.map((t) => t.id), ['in', 'done']);
    });
  });
}