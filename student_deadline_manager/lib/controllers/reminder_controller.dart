import 'package:flutter/foundation.dart';
import '../models/notification_status.dart';
import '../models/reminder_data.dart';
import '../services/reminder_service.dart';

/// Cầu nối giữa ReminderScreen và [ReminderService].
/// Giữ trạng thái màn hình: danh sách nhắc nhở, đang tải, lỗi.
class ReminderController extends ChangeNotifier {
  final ReminderService _service;

  /// [service] chỉ truyền khi unit test.
  ReminderController({ReminderService? service})
      : _service = service ?? ReminderService();

  List<ReminderData> _items = [];
  bool _loading = false;
  String? _error;

  List<ReminderData> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  int get enabledCount => _items.where((r) => r.isEnabled).length;
  int get disabledCount =>
      _items.where((r) => r.status == NotificationStatus.cancelled).length;

  /// Tải lại danh sách nhắc nhở.
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _service.findAll();
    } on ReminderException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Có lỗi xảy ra: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Bật/tắt. Trả về null nếu thành công, ngược lại là thông báo lỗi.
  Future<String?> setEnabled(ReminderData r, bool enabled) =>
      _run(() => _service.setEnabled(r, enabled));

  Future<String?> remove(ReminderData r) => _run(() => _service.remove(r.id!));

  /// Chạy một thao tác rồi tải lại dữ liệu.
  Future<String?> _run(Future<void> Function() action) async {
    try {
      await action();
    } on ReminderException catch (e) {
      return e.message;
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    }
    await load();
    return null;
  }
}