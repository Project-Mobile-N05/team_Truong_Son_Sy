import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/models/notification_status.dart';
import 'package:student_deadline_manager/models/reminder_data.dart';
import 'package:student_deadline_manager/models/task.dart';
import 'package:student_deadline_manager/models/task_status.dart';
import 'package:student_deadline_manager/services/device_notifier.dart';
import 'package:student_deadline_manager/services/firestore_repository.dart';
import 'package:student_deadline_manager/services/notification_scheduler.dart';
import 'package:student_deadline_manager/services/reminder_service.dart';
import 'package:student_deadline_manager/services/task_service.dart';

class FakeNotifier implements DeviceNotifier {
  final shown = <String>[];
  bool fail = false;
  @override
  bool get isSupported => true;
  @override
  Future<void> init() async {}
  @override
  Future<void> show(
      {required int id, required String title, required String body}) async {
    if (fail) throw Exception('thiết bị từ chối');
    shown.add(body);
  }
}

void main() {
  final now = DateTime(2026, 11, 9, 8);
  late FirestoreRepository<ReminderData> repo;
  late ReminderService reminders;
  late FakeNotifier notifier;
  late List<Task> tasks;
  late NotificationScheduler scheduler;

  Task task(String id, DateTime due, {TaskStatus status = TaskStatus.pending}) =>
      Task(id: id, userId: 'u1', title: 'Bài $id', taskDatetime: due, status: status);

  setUp(() {
    repo = FirestoreRepository<ReminderData>(
        'reminders', ReminderData.fromMap,
        firestore: FakeFirebaseFirestore());
    reminders =
        ReminderService(repository: repo, currentUid: () => 'u1', clock: () => now);
    notifier = FakeNotifier();
    tasks = [];
    scheduler = NotificationScheduler(
      reminders: reminders,
      notifier: notifier,
      currentUid: () => 'u1',
      loadTasks: (_) async => tasks,
      loadTask: (_, id) async {
        final found = tasks.where((t) => t.id == id);
        if (found.isEmpty) throw const TaskException('Không tìm thấy deadline');
        return found.first;
      },
    );
  });

  group('runScan', () {
    test('chỉ tạo nhắc nhở cho deadline chưa xong có hạn trong 24 giờ tới', () async {
      tasks = [
        task('gan', DateTime(2026, 11, 10, 7)),
        task('xa', DateTime(2026, 11, 12, 7)),
        task('xong', DateTime(2026, 11, 10, 6), status: TaskStatus.completed),
        task('quahan', DateTime(2026, 11, 8, 7)),
      ];
      expect(await scheduler.runScan(), 1);
      final list = await reminders.findAll();
      expect(list.length, 1);
      expect(list.first.taskId, 'gan');
      expect(list.first.scheduledAt, now); // hạn còn dưới 24 giờ: nhắc ngay
    });

    test('quét lần hai không tạo trùng, kể cả khi nhắc nhở đã gửi', () async {
      tasks = [task('gan', DateTime(2026, 11, 10, 7))];
      await scheduler.runScan();
      await scheduler.runSend();
      expect(await scheduler.runScan(), 0);
      expect((await reminders.findAll()).length, 1);
    });
  });

  group('runSend', () {
    test('hiện thông báo và đánh dấu SENT kèm sentAt', () async {
      tasks = [task('gan', DateTime(2026, 11, 10, 7))];
      await scheduler.runScan();
      expect(await scheduler.runSend(), 1);
      expect(notifier.shown.single, contains('Bài gan'));
      final r = (await reminders.findAll()).first;
      expect(r.status, NotificationStatus.sent);
      expect(r.sentAt, now);
    });

    test('nhắc nhở chưa đến giờ thì không gửi', () async {
      await repo.add(ReminderData(
          userId: 'u1',
          taskId: 'a',
          message: 'x',
          scheduledAt: DateTime(2026, 11, 9, 20)));
      expect(await scheduler.runSend(), 0);
      expect(notifier.shown, isEmpty);
    });

    test('thiết bị từ chối thông báo thì đánh dấu FAILED', () async {
      tasks = [task('gan', DateTime(2026, 11, 10, 7))];
      await scheduler.runScan();
      notifier.fail = true;
      expect(await scheduler.runSend(), 0);
      expect((await reminders.findAll()).first.status, NotificationStatus.failed);
    });

    test('không tìm thấy Task của nhắc nhở thì đánh dấu FAILED', () async {
      await repo.add(ReminderData(
          userId: 'u1', taskId: 'mat', message: 'x', scheduledAt: now));
      expect(await scheduler.runSend(), 0);
      expect((await reminders.findAll()).first.status, NotificationStatus.failed);
    });

    test('bật lại nhắc nhở đã gửi thì được gửi lần nữa', () async {
      tasks = [task('gan', DateTime(2026, 11, 10, 7))];
      await scheduler.runScan();
      await scheduler.runSend();
      final r = (await reminders.findAll()).first;
      await reminders.setEnabled(r, true);
      expect(await scheduler.runSend(), 1);
      expect(notifier.shown.length, 2);
    });
  });
}