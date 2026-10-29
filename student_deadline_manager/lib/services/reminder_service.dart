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
    final list = await _guard(() => _repo.findWhere('userId', uid));
    list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return list;
  }

  /// Tạo nhắc nhở cho deadline. Đã có nhắc nhở đang bật cho deadline này thì bỏ qua.
  Future<void> schedule(Task task) async {
    final taskId = task.id;
    if (taskId == null) return;
    final uid = _requireUid();
    final all = await findAll();
    final exists = all.any(
        (r) => r.taskId == taskId && r.status == NotificationStatus.pending);
    if (exists) return;
    await _guard(() => _repo.add(ReminderData(
          userId: uid,
          taskId: taskId,
          message: 'Sắp đến hạn: ${task.title}',
          scheduledAt: task.taskDatetime.subtract(remindBefore),
        )));
  }

  /// Hủy (tắt) các nhắc nhở đang chờ của một deadline.
  Future<void> cancelForTask(String taskId) async {
    for (final r in await findAll()) {
      if (r.taskId == taskId && r.status == NotificationStatus.pending) {
        await _guard(() => _repo.update(
            r.id!, r.copyWith(status: NotificationStatus.cancelled)));
      }
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