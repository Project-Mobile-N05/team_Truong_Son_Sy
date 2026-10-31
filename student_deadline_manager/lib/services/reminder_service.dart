import '../models/notification_status.dart';
import '../models/reminder_data.dart';
import '../models/task.dart';
import 'auth_service.dart';
import 'firestore_repository.dart';

/// Lỗi nghiệp vụ của Nhắc nhở, [message] là câu tiếng Việt hiển thị cho người dùng.
class ReminderException implements Exception {
  final String message;
  const ReminderException(this.message);
  @override
  String toString() => message;
}

/// Nghiệp vụ Nhắc nhở. Hai hàm [schedule] và [cancelForTask] là điểm nối
/// với TaskService (module của Sỹ): TaskService gọi khi thêm/sửa/xóa deadline.
class ReminderService {
  /// Nhắc trước hạn bao lâu.
  static const Duration remindBefore = Duration(hours: 24);

  final FirestoreRepository<ReminderData> _repo;
  final String? Function() _currentUid;

  /// [repository], [currentUid] chỉ truyền khi unit test.
  ReminderService({
    FirestoreRepository<ReminderData>? repository,
    String? Function()? currentUid,
  })  : _repo = repository ??
            FirestoreRepository<ReminderData>(
                'reminders', ReminderData.fromMap),
        _currentUid = currentUid ?? (() => AuthService().currentUid);

  /// Nhắc nhở của người đăng nhập, sắp xếp theo thời điểm nhắc.
  Future<List<ReminderData>> findAll() async {
    final uid = _requireUid();
    // Filter by owner (single-field index) and sort locally. The composite
    // userId + scheduledAt index is optional for this small per-user list, and
    // may not yet be deployed to existing Firebase projects.
    final reminders = await _guard(() => _repo.findWhere('userId', uid));
    reminders.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return reminders;
  }

  /// Tạo nhắc nhở cho deadline. Đã có nhắc nhở đang bật cho deadline này thì bỏ qua.
  Future<void> schedule(Task task) async {
    final taskId = task.id;
    if (taskId == null) return;
    final uid = _requireUid();
    if (await _hasPendingForTask(uid, taskId)) return;
    await _guard(() => _repo.add(ReminderData(
          userId: uid,
          taskId: taskId,
          message: 'Sắp đến hạn: ${task.title}',
          scheduledAt: task.taskDatetime.subtract(remindBefore),
        )));
  }

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

      // Keep reminder creation/cancellation working before the composite index
      // is deployed. This fallback reads only the signed-in user's reminders.
      final reminders = await _guard(() => _repo.findWhere('userId', uid));
      return reminders
          .where((r) =>
              r.taskId == taskId &&
              r.status == NotificationStatus.pending)
          .toList();
    }
  }

  /// Bật/tắt một nhắc nhở. Nhắc nhở đã gửi thì không đổi được.
  Future<void> setEnabled(ReminderData r, bool enabled) async {
    if (!r.canToggle) {
      throw const ReminderException('Nhắc nhở này đã gửi, không thể bật/tắt');
    }
    final status =
        enabled ? NotificationStatus.pending : NotificationStatus.cancelled;
    await _guard(() => _repo.update(r.id!, r.copyWith(status: status)));
  }

  Future<void> remove(String id) => _guard(() => _repo.delete(id));

  // ---------- Nội bộ ----------

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
