import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/controllers/task_controller.dart';
import 'package:student_deadline_manager/models/task.dart';
import 'package:student_deadline_manager/models/task_status.dart';
import 'package:student_deadline_manager/services/task_repository.dart';
import 'package:student_deadline_manager/services/task_service.dart';

/// Unit test cho TaskController (trạng thái màn hình Lịch) với Firestore giả.
/// Cần thư viện dev: fake_cloud_firestore.
void main() {
  late FakeFirebaseFirestore fake;
  late TaskController c;

  TaskController makeController({
    String? Function()? uid,
    SubjectLoader? loader,
  }) =>
      TaskController(
        service: TaskService(repository: TaskRepository(firestore: fake)),
        currentUid: uid ?? () => 'u1',
        subjectLoader: loader,
      );

  TaskDto dto({String title = 'Bài tập 1', DateTime? at}) => TaskDto(
        title: title,
        taskDatetime: at ?? DateTime.now().add(const Duration(days: 3)),
      );

  setUp(() {
    fake = FakeFirebaseFirestore();
    c = makeController(
      loader: (uid) async => const [SubjectOption('M1', 'Lập trình')],
    );
  });

  group('load', () {
    test('tải xong: không lỗi, có môn học, báo cho giao diện cập nhật',
        () async {
      var notified = 0;
      c.addListener(() => notified++);

      await c.load();

      expect(c.loading, isFalse);
      expect(c.error, isNull);
      expect(c.tasks, isEmpty);
      expect(c.subjects.length, 1);
      expect(notified, greaterThan(0));
    });

    test('chưa đăng nhập thì báo lỗi', () async {
      final noUser = makeController(uid: () => null);
      await noUser.load();
      expect(noUser.error, 'Bạn chưa đăng nhập');
    });

    test('lỗi tải môn học không làm hỏng danh sách deadline', () async {
      final bad = makeController(
        loader: (uid) async => throw Exception('mất mạng'),
      );
      await bad.load();
      expect(bad.error, isNull);
      expect(bad.subjects, isEmpty);
    });

    test('subjectName tra tên môn học theo id', () async {
      await c.load();
      expect(c.subjectName('M1'), 'Lập trình');
      expect(c.subjectName('zz'), isNull);
      expect(c.subjectName(null), isNull);
    });
  });

  group('save, complete, remove', () {
    test('thêm thành công: trả về null, chọn đúng ngày, đánh dấu trên lịch',
        () async {
      final at = DateTime.now().add(const Duration(days: 3));
      final err = await c.save(dto: dto(at: at));

      expect(err, isNull);
      expect(c.tasks.length, 1);
      expect(c.selectedDay, TaskService.dayKey(at));
      expect(c.selectedTasks.length, 1);
      expect(c.markedDays.contains(TaskService.dayKey(at)), isTrue);
    });

    test('thêm thất bại: trả về thông báo lỗi, không thêm gì', () async {
      final err = await c.save(dto: dto(title: ''));
      expect(err, isNotNull);
      expect(c.tasks, isEmpty);
    });

    test('thêm trùng tiêu đề: báo lỗi', () async {
      await c.save(dto: dto());
      final err = await c.save(dto: dto());
      expect(err, isNotNull);
      expect(c.tasks.length, 1);
    });

    test('sửa deadline có sẵn', () async {
      await c.save(dto: dto());
      final old = c.tasks.first;
      final err = await c.save(
        existing: old,
        dto: TaskDto(title: 'Tên mới', taskDatetime: old.taskDatetime),
      );
      expect(err, isNull);
      expect(c.tasks.first.title, 'Tên mới');
    });

    test('complete đổi trạng thái thành hoàn thành', () async {
      await c.save(dto: dto());
      final err = await c.complete(c.tasks.first);
      expect(err, isNull);
      expect(c.tasks.first.status, TaskStatus.completed);
    });

    test('remove xóa deadline', () async {
      await c.save(dto: dto());
      final err = await c.remove(c.tasks.first);
      expect(err, isNull);
      expect(c.tasks, isEmpty);
    });

    test('chưa đăng nhập thì không thao tác được', () async {
      final noUser = makeController(uid: () => null);
      expect(await noUser.save(dto: dto()), 'Bạn chưa đăng nhập');
    });
  });

  group('lịch', () {
    test('overdueDays chứa ngày có deadline quá hạn', () async {
      final past = DateTime.now().subtract(const Duration(days: 4));
      await fake.collection('tasks').doc('old').set(
            Task(userId: 'u1', title: 'Cũ', taskDatetime: past).toMap(),
          );
      await c.load();
      expect(c.overdueDays.contains(TaskService.dayKey(past)), isTrue);
    });

    test('selectDay cập nhật ngày và tháng đang xem', () {
      c.selectDay(DateTime(2027, 3, 15, 10));
      expect(c.selectedDay, DateTime(2027, 3, 15));
      expect(c.visibleMonth, DateTime(2027, 3));
    });

    test('changeMonth chuyển tháng, qua năm đúng', () {
      c.selectDay(DateTime(2026, 12, 5));
      c.changeMonth(1);
      expect(c.visibleMonth, DateTime(2027, 1));
      c.changeMonth(-2);
      expect(c.visibleMonth, DateTime(2026, 11));
    });
  });
}