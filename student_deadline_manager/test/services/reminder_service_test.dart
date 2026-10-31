import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/models/notification_status.dart';
import 'package:student_deadline_manager/models/reminder_data.dart';
import 'package:student_deadline_manager/models/task.dart';
import 'package:student_deadline_manager/services/firestore_repository.dart';
import 'package:student_deadline_manager/services/reminder_service.dart';

void main() {
  late FakeFirebaseFirestore fs;
  late FirestoreRepository<ReminderData> repo;
  late ReminderService service;

  final due = DateTime(2026, 11, 10, 9);

  Task makeTask({String? id = 't1', String title = 'Nộp bài'}) => Task(
        id: id,
        userId: 'u1',
        title: title,
        taskDatetime: due,
      );

  setUp(() {
    fs = FakeFirebaseFirestore();
    repo = FirestoreRepository<ReminderData>('reminders', ReminderData.fromMap,
        firestore: fs);
    service = ReminderService(repository: repo, currentUid: () => 'u1', clock: () => DateTime(2026, 10, 1));
  });

  group('schedule', () {
    test('tạo nhắc nhở trước hạn 24 giờ, đang bật, đúng chủ sở hữu', () async {
      await service.schedule(makeTask());
      final list = await service.findAll();
      expect(list.length, 1);
      expect(list.first.userId, 'u1');
      expect(list.first.taskId, 't1');
      expect(list.first.message, 'Sắp đến hạn: Nộp bài');
      expect(list.first.status, NotificationStatus.pending);
      expect(list.first.scheduledAt, due.subtract(ReminderService.remindBefore));
    });

    test('gọi hai lần cho cùng deadline chỉ tạo một nhắc nhở', () async {
      await service.schedule(makeTask());
      await service.schedule(makeTask());
      expect((await service.findAll()).length, 1);
    });

    test('deadline chưa có id thì bỏ qua', () async {
      await service.schedule(makeTask(id: null));
      expect(await service.findAll(), isEmpty);
    });

    test('hai deadline khác nhau tạo hai nhắc nhở', () async {
      await service.schedule(makeTask(id: 't1'));
      await service.schedule(makeTask(id: 't2', title: 'Thi giữa kỳ'));
      expect((await service.findAll()).length, 2);
    });
  });

  group('cancelForTask', () {
    test('tắt nhắc nhở đang bật của đúng deadline, không đụng deadline khác',
        () async {
      await service.schedule(makeTask(id: 't1'));
      await service.schedule(makeTask(id: 't2', title: 'Thi giữa kỳ'));
      await service.cancelForTask('t1');

      final list = await service.findAll();
      final r1 = list.firstWhere((r) => r.taskId == 't1');
      final r2 = list.firstWhere((r) => r.taskId == 't2');
      expect(r1.status, NotificationStatus.cancelled);
      expect(r2.status, NotificationStatus.pending);
    });
  });

  group('setEnabled', () {
    test('tắt rồi bật lại đổi trạng thái cancelled <-> pending', () async {
      await service.schedule(makeTask());
      var r = (await service.findAll()).first;

      await service.setEnabled(r, false);
      r = (await service.findAll()).first;
      expect(r.status, NotificationStatus.cancelled);

      await service.setEnabled(r, true);
      r = (await service.findAll()).first;
      expect(r.status, NotificationStatus.pending);
    });

    test('hạn còn dưới 24 giờ thì nhắc ngay bây giờ', () async {
      final soon = ReminderService(
          repository: repo,
          currentUid: () => 'u1',
          clock: () => DateTime(2026, 11, 10, 3)); // còn 6 giờ tới hạn 9:00
      await soon.schedule(makeTask());
      expect((await soon.findAll()).first.scheduledAt, DateTime(2026, 11, 10, 3));
    });

    test('deadline đã quá hạn thì không tạo nhắc nhở', () async {
      final late = ReminderService(
          repository: repo,
          currentUid: () => 'u1',
          clock: () => DateTime(2026, 11, 11));
      await late.schedule(makeTask());
      expect(await late.findAll(), isEmpty);
    });

    test('bật lại nhắc nhở đã gửi: về đang bật, xóa sentAt, nhắc từ bây giờ',
        () async {
      final id = await repo.add(ReminderData(
        userId: 'u1',
        taskId: 't1',
        message: 'x',
        scheduledAt: DateTime(2026, 9, 1), // trước đồng hồ giả 1/10/2026
        status: NotificationStatus.sent,
        sentAt: DateTime(2026, 9, 1),
      ));
      await service.setEnabled((await repo.getById(id))!, true);
      final r = (await repo.getById(id))!;
      expect(r.status, NotificationStatus.pending);
      expect(r.sentAt, isNull);
      expect(r.scheduledAt, DateTime(2026, 10, 1));
    });
  });

  group('remove và findAll', () {
    test('remove xóa nhắc nhở', () async {
      await service.schedule(makeTask());
      final r = (await service.findAll()).first;
      await service.remove(r.id!);
      expect(await service.findAll(), isEmpty);
    });

    test('findAll chỉ trả về nhắc nhở của người dùng hiện tại', () async {
      await service.schedule(makeTask());
      await repo.add(ReminderData(
          userId: 'u2', taskId: 't9', message: 'của người khác', scheduledAt: due));
      final list = await service.findAll();
      expect(list.length, 1);
      expect(list.first.userId, 'u1');
    });

    test('findAll sắp xếp theo thời điểm nhắc tăng dần', () async {
      await repo.add(ReminderData(
          userId: 'u1', taskId: 'a', message: 'muộn',
          scheduledAt: DateTime(2026, 12, 1)));
      await repo.add(ReminderData(
          userId: 'u1', taskId: 'b', message: 'sớm',
          scheduledAt: DateTime(2026, 11, 1)));
      final list = await service.findAll();
      expect(list.map((r) => r.message).toList(), ['sớm', 'muộn']);
    });

    test('chưa đăng nhập thì ném ReminderException', () async {
      final guest = ReminderService(repository: repo, currentUid: () => null);
      await expectLater(
        guest.findAll(),
        throwsA(isA<ReminderException>().having(
            (e) => e.message, 'message', 'Bạn chưa đăng nhập')),
      );
    });
  });
}
