import '../models/notification_status.dart';
import '../models/reminder_data.dart';
import '../models/task.dart';
import '../models/task_status.dart';
import 'auth_service.dart';
import 'firestore_repository.dart';

/// Lỗi nghiệp vụ của Nhắc nhở, [message] là câu tiếng Việt hiển thị cho người dùng.
class ReminderException implements Exception {
  final String message;
  const ReminderException(this.message);
  @override
  String toString() => message;
}

/// Nghiệp vụ Nhắc nhở. [schedule] và [cancelForTask] là điểm nối với
/// TaskService (module của Sỹ); [scanUpcoming], [findDue], [markSent],
/// [markFailed] phục vụ NotificationScheduler.
class ReminderService {
  /// Nhắc trước hạn bao lâu.
  static const Duration remindBefore = Duration(hours: 24);

  final FirestoreRepository<ReminderData> _repo;
  final String? Function() _currentUid;
  final DateTime Function() _clock;

  /// [repository], [currentUid], [clock] chỉ truyền khi unit test.
  ReminderService({
    FirestoreRepository<ReminderData>? repository,
    String? Function()? currentUid,
    DateTime Function()? clock,
  })  : _repo = repository ??
            FirestoreRepository<ReminderData>(
                'reminders', ReminderData.fromMap),
        _currentUid = currentUid ?? (() => AuthService().currentUid),
        _clock = clock ?? DateTime.now;

  /// Nhắc nhở của người đăng nhập, sắp xếp theo thời điểm nhắc.
  Future<List<ReminderData>> findAll() async {
    final uid = _requireUid();
    // Lọc theo chủ sở hữu (index một trường) rồi sắp xếp trong ứng dụng,
    // tránh phụ thuộc composite index chưa được triển khai.
    final reminders = await _guard(() => _repo.findWhere('userId', uid));
    reminders.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return reminders;
  }

  /// Tạo nhắc nhở cho deadline. Bỏ qua nếu deadline đã quá hạn hoặc đã có
  /// nhắc nhở đang bật.
  Future<void> schedule(Task task) async {
    final taskId = task.id;
    if (taskId == null) return;
    final now = _clock();
    if (!task.taskDatetime.isAfter(now)) return;
    final uid = _requireUid();
    if (await _hasPendingForTask(uid, taskId)) return;
    await _guard(() => _repo.add(_newReminder(uid, task, now)));
  }

  /// Bộ quét (Hình 3.3): với các deadline chưa xong có hạn trong 24 giờ tới,
  /// tạo nhắc nhở nếu deadline đó chưa từng có nhắc nhở nào (mọi trạng thái;
  /// nhắc nhở đã gửi hoặc đã tắt thì không tạo lại). Trả về số nhắc nhở mới tạo.
  Future<int> scanUpcoming(Iterable<Task> tasks, {DateTime? now}) async {
    final uid = _requireUid();
    final t0 = now ?? _clock();
    final limit = t0.add(remindBefore);
    final upcoming = tasks.where((t) =>
        t.id != null &&
        t.status == TaskStatus.pending &&
        !t.taskDatetime.isBefore(t0) &&
        !t.taskDatetime.isAfter(limit));
    if (upcoming.isEmpty) return 0;

    final logged = (await _guard(() => _repo.findWhere('userId', uid)))
        .map((r) => r.taskId)
        .toSet();
    var created = 0;
    for (final task in upcoming) {
      if (logged.contains(task.id)) continue;
      await _guard(() => _repo.add(_newReminder(uid, task, t0)));
      created++;
    }
    return created;
  }

  /// Nhắc nhở đang bật đã đến giờ gửi (Hình 3.4), cũ nhất trước.
  Future<List<ReminderData>> findDue({DateTime? now}) async {
    final uid = _requireUid();
    final t0 = now ?? _clock();
    final list = await _guard(() => _repo.findWhereAll({
          'userId': uid,
          'status': NotificationStatus.pending.name,
        }));
    return list.where((r) => !r.scheduledAt.isAfter(t0)).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// Đánh dấu đã gửi thành công, ghi thời điểm gửi.
  Future<void> markSent(ReminderData r, {DateTime? at}) => _guard(() =>
      _repo.update(
          r.id!,
          r.copyWith(
              status: NotificationStatus.sent, sentAt: at ?? _clock())));

  /// Đánh dấu gửi thất bại.
  Future<void> markFailed(ReminderData r) => _guard(() => _repo.update(
      r.id!, r.copyWith(status: NotificationStatus.failed)));

  /// Hủy (tắt) các nhắc nhở đang chờ của một deadline.
  Future<void> cancelForTask(String taskId) async {
    final uid = _requireUid();
    final pending = await _pendingForTask(uid, taskId);
    for (final reminder in pending) {
      await _guard(() => _repo.update(
          reminder.id!,
          reminder.copyWith(status: NotificationStatus.cancelled)));
    }
  }

  Future<bool> _hasPendingForTask(String uid, String taskId) async =>
      (await _pendingForTask(uid, taskId)).isNotEmpty;

  Future<List<ReminderData>> _pendingForTask(String uid, String taskId) async {
    try {
      return await _guard(() => _repo.findWhereAll({
            'userId': uid,
            'taskId': taskId,
            'status': NotificationStatus.pending.name,
          }));
    } on ReminderException catch (e) {
      if (!e.message.contains('failed-precondition')) rethrow;

      // Giữ cho việc tạo/hủy nhắc nhở hoạt động khi chưa tạo composite index:
      // đọc các nhắc nhở của người dùng rồi lọc trong ứng dụng.
      final reminders = await _guard(() => _repo.findWhere('userId', uid));
      return reminders
          .where((r) =>
              r.taskId == taskId && r.status == NotificationStatus.pending)
          .toList();
    }
  }

  /// Bật/tắt một nhắc nhở. Bật lại nhắc nhở đã gửi (hoặc gửi lỗi) thì đưa về
  /// đang bật, xóa thời điểm gửi cũ; nếu mốc nhắc đã qua thì nhắc ngay.
  Future<void> setEnabled(ReminderData r, bool enabled) async {
    final now = _clock();
    final updated = enabled
        ? r.copyWith(
            status: NotificationStatus.pending,
            clearSentAt: true,
            scheduledAt: r.scheduledAt.isBefore(now) ? now : r.scheduledAt,
          )
        : r.copyWith(status: NotificationStatus.cancelled);
    await _guard(() => _repo.update(r.id!, updated));
  }

  Future<void> remove(String id) => _guard(() => _repo.delete(id));

  // ---------- Nội bộ ----------

  /// Nhắc trước hạn 24 giờ; hạn còn dưới 24 giờ thì nhắc ngay bây giờ.
  ReminderData _newReminder(String uid, Task task, DateTime now) {
    final at = task.taskDatetime.subtract(remindBefore);
    return ReminderData(
      userId: uid,
      taskId: task.id!,
      message: 'Sắp đến hạn: ${task.title}',
      scheduledAt: at.isBefore(now) ? now : at,
    );
  }

  String _requireUid() {
    final uid = _currentUid();
    if (uid == null || uid.isEmpty) {
      throw const ReminderException('Bạn chưa đăng nhập');
    }
    return uid;
  }

  /// Đổi [RepositoryException] thành [ReminderException].
  Future<R> _guard<R>(Future<R> Function() action) async {
    try {
      return await action();
    } on RepositoryException catch (e) {
      throw ReminderException(e.message);
    }
  }
}