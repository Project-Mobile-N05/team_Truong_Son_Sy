import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_deadline_manager/models/reminder_data.dart';
import 'package:student_deadline_manager/services/firestore_repository.dart';

void main() {
  late FakeFirebaseFirestore fs;
  late FirestoreRepository<ReminderData> repo;

  ReminderData make(String userId, String message) => ReminderData(
        userId: userId,
        taskId: 't1',
        message: message,
        scheduledAt: DateTime(2026, 11, 9, 9),
      );

  setUp(() {
    fs = FakeFirebaseFirestore();
    repo = FirestoreRepository<ReminderData>('reminders', ReminderData.fromMap,
        firestore: fs);
  });

  test('add trả về id và getById đọc lại đúng dữ liệu', () async {
    final id = await repo.add(make('u1', 'A'));
    final r = await repo.getById(id);
    expect(r, isNotNull);
    expect(r!.id, id);
    expect(r.userId, 'u1');
    expect(r.message, 'A');
  });

  test('getById với id không tồn tại trả về null', () async {
    expect(await repo.getById('khong-co'), isNull);
  });

  test('update ghi đè Document theo id', () async {
    final id = await repo.add(make('u1', 'cũ'));
    await repo.update(id, make('u1', 'mới'));
    expect((await repo.getById(id))!.message, 'mới');
  });

  test('update với id chỉ định tạo Document mới có đúng id đó', () async {
    await repo.update('abc', make('u1', 'X'));
    expect((await repo.getById('abc'))!.message, 'X');
  });

  test('delete xóa Document', () async {
    final id = await repo.add(make('u1', 'A'));
    await repo.delete(id);
    expect(await repo.getById(id), isNull);
  });

  test('getAll trả về tất cả Document', () async {
    await repo.add(make('u1', 'A'));
    await repo.add(make('u2', 'B'));
    expect((await repo.getAll()).length, 2);
  });

  test('findWhere chỉ trả về Document có trường khớp', () async {
    await repo.add(make('u1', 'A'));
    await repo.add(make('u1', 'B'));
    await repo.add(make('u2', 'C'));
    final list = await repo.findWhere('userId', 'u1');
    expect(list.length, 2);
    expect(list.every((r) => r.userId == 'u1'), isTrue);
  });
}
