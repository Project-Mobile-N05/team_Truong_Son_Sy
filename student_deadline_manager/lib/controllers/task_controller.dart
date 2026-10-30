import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/task_status.dart';
import '../services/auth_service.dart';
import '../services/reminder_service.dart';
import '../services/task_service.dart';

/// Một môn học để hiển thị tên và chọn trong form.
/// Nối với module Môn học (Sơn) qua [SubjectLoader].
class SubjectOption {
  final String id;
  final String name;
  const SubjectOption(this.id, this.name);
}

/// Hàm lấy danh sách môn học của user. Chưa truyền thì danh sách môn học rỗng.
typedef SubjectLoader = Future<List<SubjectOption>> Function(String userId);

/// Cầu nối giữa màn hình (Lịch, thêm/sửa deadline) và [TaskService].
/// Giữ trạng thái màn hình: danh sách deadline, ngày đang chọn, tháng đang xem.
class TaskController extends ChangeNotifier {
  final TaskService _service;
  final String? Function() _currentUid;
  final SubjectLoader? _subjectLoader;

  /// [service], [currentUid] chỉ truyền khi unit test.
  TaskController({
    TaskService? service,
    String? Function()? currentUid,
    SubjectLoader? subjectLoader,
  })  : _service = service ??
            TaskService(
              // Nối module Nhắc nhở (Trường): thêm/sửa/xóa deadline sẽ
              // tự tạo/hủy nhắc nhở.
              scheduleReminder: ReminderService().schedule,
              cancelReminders: ReminderService().cancelForTask,
            ),
        _currentUid = currentUid ?? _authUid,
        _subjectLoader = subjectLoader;

  static String? _authUid() => AuthService().currentUid;

  List<Task> _tasks = [];
  List<SubjectOption> _subjects = [];
  bool _loading = false;
  String? _error;
  DateTime _selectedDay = TaskService.dayKey(DateTime.now());
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<Task> get tasks => _tasks;
  List<SubjectOption> get subjects => _subjects;
  bool get loading => _loading;
  String? get error => _error;
  DateTime get selectedDay => _selectedDay;
  DateTime get visibleMonth => _visibleMonth;

  /// Tên môn học theo id, null nếu không có.
  String? subjectName(String? id) {
    if (id == null) return null;
    for (final s in _subjects) {
      if (s.id == id) return s.name;
    }
    return null;
  }

  /// Các ngày có deadline (để đánh dấu chấm trên lịch).
  Set<DateTime> get markedDays => TaskService.groupByDay(_tasks).keys.toSet();

  /// Các ngày có deadline quá hạn (chấm đỏ).
  Set<DateTime> get overdueDays => {
        for (final t in _tasks)
          if (t.isOverdue()) TaskService.dayKey(t.taskDatetime),
      };

  /// Deadline của ngày đang chọn, sắp xếp theo giờ.
  List<Task> get selectedTasks =>
      TaskService.tasksOfDay(_tasks, _selectedDay);

  void selectDay(DateTime d) {
    _selectedDay = TaskService.dayKey(d);
    _visibleMonth = DateTime(d.year, d.month);
    notifyListeners();
  }

  /// Chuyển tháng: [delta] = -1 là tháng trước, 1 là tháng sau.
  void changeMonth(int delta) {
    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    notifyListeners();
  }

  /// Tải lại danh sách deadline và môn học.
  Future<void> load() async {
    final uid = _currentUid();
    if (uid == null) {
      _error = 'Bạn chưa đăng nhập';
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _tasks = await _service.findAll(uid);
      await _loadSubjects(uid);
    } on TaskException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Có lỗi xảy ra: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSubjects(String uid) async {
    final loader = _subjectLoader;
    if (loader == null) return;
    try {
      _subjects = await loader(uid);
    } catch (_) {
      _subjects = []; // lỗi môn học không làm hỏng danh sách deadline
    }
  }

  /// Thêm mới ([existing] = null) hoặc cập nhật deadline.
  /// Trả về null nếu thành công, ngược lại là thông báo lỗi tiếng Việt.
  Future<String?> save({Task? existing, required TaskDto dto}) async {
    final err = await _run((uid) async {
      if (existing == null) {
        await _service.create(uid, dto);
      } else {
        await _service.update(uid, existing.id!, dto);
      }
    });
    final at = dto.taskDatetime;
    if (err == null && at != null) selectDay(at);
    return err;
  }

  /// Đánh dấu hoàn thành (nút "Xong").
  Future<String?> complete(Task t) => _run((uid) async {
        await _service.update(
          uid,
          t.id!,
          TaskDto.fromTask(t, status: TaskStatus.completed),
        );
      });

  /// Xóa deadline.
  Future<String?> remove(Task t) =>
      _run((uid) => _service.remove(uid, t.id!));

  /// Chạy một thao tác rồi tải lại dữ liệu. Trả về thông báo lỗi hoặc null.
  Future<String?> _run(Future<void> Function(String uid) action) async {
    final uid = _currentUid();
    if (uid == null) return 'Bạn chưa đăng nhập';
    try {
      await action(uid);
    } on TaskException catch (e) {
      return e.message;
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    }
    await load();
    return null;
  }
}