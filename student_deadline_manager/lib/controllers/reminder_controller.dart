import 'package:flutter/foundation.dart';
import '../models/notification_status.dart';
import '../models/reminder_data.dart';
import '../services/reminder_service.dart';

class ReminderController extends ChangeNotifier {
  final ReminderService _service;

  ReminderController({ReminderService? service})
      : _service = service ?? ReminderService() {
    ReminderService.changes.addListener(_onExternalChange);
  }

  List<ReminderData> _items = [];
  bool _loading = false;
  bool _busy = false; // đang có một lượt tải
  bool _again = false; // có thay đổi trong lúc đang tải: tải thêm một lượt
  bool _disposed = false;
  String? _error;

  List<ReminderData> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  int get enabledCount => _items.where((r) => r.isEnabled).length;
  int get disabledCount =>
      _items.where((r) => r.status == NotificationStatus.cancelled).length;

  void _onExternalChange() {
    if (!_disposed) load(silent: true);
  }

  Future<void> load({bool silent = false}) async {
    if (_busy) {
      _again = true;
      return;
    }
    _busy = true;
    if (!silent) {
      _loading = true;
      _error = null;
      notifyListeners();
    }
    try {
      _items = await _service.findAll();
      _error = null;
    } on ReminderException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Có lỗi xảy ra: $e';
    } finally {
      _busy = false;
      _loading = false;
      if (!_disposed) notifyListeners();
    }
    if (_again && !_disposed) {
      _again = false;
      await load(silent: true);
    }
  }

  Future<String?> setEnabled(ReminderData r, bool enabled) =>
      _run(() => _service.setEnabled(r, enabled));

  Future<String?> remove(ReminderData r) => _run(() => _service.remove(r.id!));

  Future<String?> _run(Future<void> Function() action) async {
    try {
      await action();
    } on ReminderException catch (e) {
      return e.message;
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    }
    return null;
  }

  @override
  void dispose() {
    _disposed = true;
    ReminderService.changes.removeListener(_onExternalChange);
    super.dispose();
  }
}