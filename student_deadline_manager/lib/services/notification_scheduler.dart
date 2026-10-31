import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/task.dart';
import 'auth_service.dart';
import 'device_notifier.dart';
import 'reminder_service.dart';
import 'task_service.dart';

/// Hai bộ hẹn giờ chạy khi ứng dụng đang mở:
/// - [runScan] mỗi 1 giờ: quét deadline sắp đến hạn và tạo nhắc nhở (Hình 3.3).
/// - [runSend] mỗi 5 phút: hiện thông báo cho nhắc nhở đã đến giờ (Hình 3.4).
class NotificationScheduler {
//   static const Duration scanEvery = Duration(hours: 1);
//   static const Duration sendEvery = Duration(minutes: 5);

  static const Duration scanEvery = Duration(seconds: 30);
static const Duration sendEvery = Duration(seconds: 15);

  final ReminderService _reminders;
  final DeviceNotifier _notifier;
  final String? Function() _currentUid;
  final Future<List<Task>> Function(String uid) _loadTasks;
  final Future<Task> Function(String uid, String taskId) _loadTask;

  Timer? _scanTimer;
  Timer? _sendTimer;
  bool _scanning = false;
  bool _sending = false;

  /// Các tham số chỉ truyền khi unit test.
  NotificationScheduler({
    ReminderService? reminders,
    DeviceNotifier? notifier,
    String? Function()? currentUid,
    Future<List<Task>> Function(String uid)? loadTasks,
    Future<Task> Function(String uid, String taskId)? loadTask,
  })  : _reminders = reminders ?? ReminderService(),
        _notifier = notifier ?? LocalDeviceNotifier(),
        _currentUid = currentUid ?? (() => AuthService().currentUid),
        _loadTasks = loadTasks ??
            ((uid) => TaskService().findAll(uid, forceRefresh: true)),
        _loadTask = loadTask ?? ((uid, id) => TaskService().findOne(uid, id));

  /// Chạy ngay một lượt quét + gửi, rồi đặt hẹn giờ định kỳ.
  Future<void> start() async {
    stop();
    try {
      await _notifier.init();
    } catch (e) {
      debugPrint('Khởi tạo thông báo lỗi: $e');
    }
    unawaited(runScan().then((_) => runSend()));
    _scanTimer = Timer.periodic(scanEvery, (_) => runScan());
    _sendTimer = Timer.periodic(sendEvery, (_) => runSend());
  }

  void stop() {
    _scanTimer?.cancel();
    _sendTimer?.cancel();
    _scanTimer = null;
    _sendTimer = null;
  }

  /// Quét deadline chưa xong có hạn trong 24 giờ tới, tạo nhắc nhở nếu chưa có.
  /// Trả về số nhắc nhở mới tạo.
  Future<int> runScan({DateTime? now}) async {
    final uid = _currentUid();
    if (uid == null || _scanning) return 0;
    _scanning = true;
    try {
      final tasks = await _loadTasks(uid);
      return await _reminders.scanUpcoming(tasks, now: now);
    } catch (e) {
      debugPrint('Quét nhắc nhở lỗi: $e');
      return 0;
    } finally {
      _scanning = false;
    }
  }

  /// Hiện thông báo cho các nhắc nhở đang bật đã đến giờ.
  /// Không tìm thấy Task hoặc hiện thông báo lỗi thì đánh dấu FAILED,
  /// thành công thì đánh dấu SENT kèm sentAt. Trả về số thông báo đã gửi.
  Future<int> runSend({DateTime? now}) async {
    final uid = _currentUid();
    if (uid == null || _sending || !_notifier.isSupported) return 0;
    _sending = true;
    var sent = 0;
    try {
      final due = await _reminders.findDue(now: now);
      for (final r in due) {
        try {
          final task = await _loadTask(uid, r.taskId);
          await _notifier.show(
            id: r.id.hashCode & 0x7fffffff,
            title: 'Sắp đến hạn deadline',
            body: '${task.title} · hạn ${_formatTime(task.taskDatetime)}',
          );
          await _reminders.markSent(r);
          sent++;
        } catch (e) {
          debugPrint('Gửi nhắc nhở lỗi: $e');
          await _reminders.markFailed(r);
        }
      }
    } catch (e) {
      debugPrint('Gửi nhắc nhở lỗi: $e');
    } finally {
      _sending = false;
    }
    return sent;
  }

  String _formatTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }
}