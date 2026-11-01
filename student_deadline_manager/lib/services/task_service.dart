import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/task_status.dart';
import 'task_repository.dart';

/// Lỗi nghiệp vụ của Task, [message] là câu tiếng Việt hiển thị cho người dùng.
class TaskException implements Exception {
  final String message;
  const TaskException(this.message);
  @override
  String toString() => message;
}

/// Kiểm tra môn học có tồn tại và thuộc về user không.
/// Nối với `Subject.findOne(id, userId)` của module môn học khi ghép code.
typedef SubjectChecker = Future<bool> Function(String subjectId, String userId);

/// Xử lý nghiệp vụ Task (deadline) theo Class Diagram:
/// create, findAll, findOne, update, remove.
///
/// Mọi hàm nhận [userId] (lấy từ `AuthService().currentUid`) và chỉ thao tác
/// trên Task của chính user đó.
class TaskService {
  final TaskRepository _repo;
  final SubjectChecker? _subjectExists;
  final Future<void> Function(Task task)? _scheduleReminder;
  final Future<void> Function(String taskId)? _cancelReminders;

  /// Báo thay đổi deadline để cập nhật các màn hình còn được giữ trong navigation.
  static final ValueNotifier<int> taskChanges = ValueNotifier<int>(0);
  static const Duration _cacheTtl = Duration(seconds: 20);
  static final Map<_TaskCacheKey, _TaskCacheEntry> _taskCache = {};
  static final Map<_TaskCacheKey, Future<List<Task>>> _pendingLoads = {};
  static final Map<_TaskCacheKey, int> _cacheGeneration = {};

  /// [repository]: truyền repository dùng FakeFirebaseFirestore khi unit test.
  /// [subjectExists], [scheduleReminder], [cancelReminders]: điểm nối với
  /// module Môn học (Sơn) và Nhắc nhở (Trường); null thì bỏ qua bước đó.
  TaskService({
    TaskRepository? repository,
    SubjectChecker? subjectExists,
    Future<void> Function(Task task)? scheduleReminder,
    Future<void> Function(String taskId)? cancelReminders,
  }) : _repo = repository ?? TaskRepository(),
       _subjectExists = subjectExists,
       _scheduleReminder = scheduleReminder,
       _cancelReminders = cancelReminders;

  // ---------- Kiểm tra dữ liệu (dùng được cho form và unit test) ----------

  static String? validateTitle(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Vui lòng nhập tiêu đề';
    if (s.length > 100) return 'Tiêu đề tối đa 100 ký tự';
    return null;
  }

  /// [allowPast] = true khi sửa deadline đã quá hạn.
  static String? validateDateTime(
    DateTime? v, {
    DateTime? now,
    bool allowPast = false,
  }) {
    if (v == null) return 'Vui lòng chọn ngày giờ';
    if (!allowPast && v.isBefore(now ?? DateTime.now())) {
      return 'Hạn nộp không được ở trong quá khứ';
    }
    return null;
  }

  // ---------- Nghiệp vụ ----------

  /// Thêm deadline mới. Trạng thái mặc định là [TaskStatus.pending].
  /// Ném [TaskException] khi: chưa đăng nhập, thiếu/sai dữ liệu, môn học
  /// không tồn tại, trùng tiêu đề, lỗi Firestore.
  Future<Task> create(String userId, TaskDto dto) async {
    _requireUser(userId);
    final err = validateTitle(dto.title) ?? validateDateTime(dto.taskDatetime);
    if (err != null) throw TaskException(err);

    await _checkSubject(dto.subjectId, userId);
    await _ensureUniqueTitle(userId, dto.title!);

    final task = Task(
      userId: userId,
      subjectId: dto.subjectId,
      title: dto.title!.trim(),
      type: dto.type,
      taskDatetime: dto.taskDatetime!,
      room: _blankToNull(dto.room),
      notes: _blankToNull(dto.notes),
      status: dto.status ?? TaskStatus.pending,
    );
    final id = await _guard(() => _repo.add(task));
    final saved = task.copyWith(id: id);
    _notifyTaskChanges(userId);
    if (saved.status != TaskStatus.completed) {
      unawaited(_safeReminder(() => _scheduleReminder?.call(saved)));
    }
    return saved;
  }

  /// Danh sách deadline của user, sắp xếp theo hạn nộp tăng dần.
  Future<List<Task>> findAll(
    String userId, {
    bool forceRefresh = false,
  }) async {
    _requireUser(userId);
    final key = _TaskCacheKey(_repo.cacheScope, userId);
    final cached = _taskCache[key];
    if (!forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.loadedAt) < _cacheTtl) {
      return cached.tasks;
    }
    final pending = _pendingLoads[key];
    if (pending != null) return pending;

    final generation = _cacheGeneration[key] ?? 0;
    final request = _loadAndCache(key, userId, generation);
    _pendingLoads[key] = request;
    try {
      return await request;
    } finally {
      if (identical(_pendingLoads[key], request)) {
        _pendingLoads.remove(key);
      }
    }
  }

  Future<List<Task>> _loadAndCache(
    _TaskCacheKey key,
    String userId,
    int generation,
  ) async {
    final list = await _guard(() => _repo.getByUser(userId));
    final tasks = List<Task>.unmodifiable(list);
    if ((_cacheGeneration[key] ?? 0) == generation) {
      _taskCache[key] = _TaskCacheEntry(tasks, DateTime.now());
    }
    return tasks;
  }

  /// Một deadline theo id. Không có hoặc không thuộc user thì ném lỗi.
  Future<Task> findOne(String userId, String id) async {
    _requireUser(userId);
    final task = await _guard(() => _repo.getById(id));
    if (task == null || task.userId != userId) {
      throw const TaskException('Không tìm thấy deadline');
    }
    return task;
  }

  /// Cập nhật deadline (kể cả đổi trạng thái qua [TaskDto.status]).
  /// Kiểm tra trùng tiêu đề, trừ chính nó. Cho phép sửa deadline đã quá hạn.
  Future<Task> update(String userId, String id, TaskDto dto) async {
    final old = await findOne(userId, id);
    final err =
        validateTitle(dto.title) ??
        validateDateTime(dto.taskDatetime, allowPast: true);
    if (err != null) throw TaskException(err);

    await _checkSubject(dto.subjectId, userId);
    await _ensureUniqueTitle(userId, dto.title!, excludeId: id);

    final updated = Task(
      id: id,
      userId: userId,
      subjectId: dto.subjectId,
      title: dto.title!.trim(),
      type: dto.type,
      taskDatetime: dto.taskDatetime!,
      room: _blankToNull(dto.room),
      notes: _blankToNull(dto.notes),
      status: dto.status ?? old.status,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
    );
    await _guard(() => _repo.update(id, updated));
    _notifyTaskChanges(userId);

    final changed =
        updated.taskDatetime != old.taskDatetime ||
        updated.title != old.title ||
        updated.status != old.status;
    if (changed) {
      unawaited(_syncReminder(updated, id));
    }
    return updated;
  }

  /// Xóa deadline và hủy các nhắc nhở đang chờ của nó.
  Future<void> remove(String userId, String id) async {
    await findOne(userId, id);
    await _guard(() => _repo.delete(id));
    _notifyTaskChanges(userId);
    unawaited(_safeReminder(() => _cancelReminders?.call(id)));
  }

  // ---------- Hỗ trợ màn hình Lịch ----------

  /// Bỏ phần giờ để dùng làm khóa theo ngày.
  static DateTime dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Nhóm deadline theo ngày, mỗi ngày sắp xếp theo giờ.
  static Map<DateTime, List<Task>> groupByDay(Iterable<Task> tasks) {
    final map = <DateTime, List<Task>>{};
    for (final t in tasks) {
      map.putIfAbsent(dayKey(t.taskDatetime), () => []).add(t);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.taskDatetime.compareTo(b.taskDatetime));
    }
    return map;
  }

  /// Các deadline rơi vào đúng ngày [day].
  static List<Task> tasksOfDay(Iterable<Task> tasks, DateTime day) {
    final key = dayKey(day);
    return tasks.where((t) => dayKey(t.taskDatetime) == key).toList()
      ..sort((a, b) => a.taskDatetime.compareTo(b.taskDatetime));
  }

  /// Deadline đến hạn trong tuần lịch hiện tại, từ thứ Hai đến Chủ nhật.
  static List<Task> tasksThisWeek(Iterable<Task> tasks, {DateTime? now}) {
    final today = dayKey(now ?? DateTime.now());
    final monday = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );
    final sundayExclusive = monday.add(const Duration(days: 7));
    return tasks.where((task) {
      final dueDate = dayKey(task.taskDatetime);
      return !dueDate.isBefore(monday) && dueDate.isBefore(sundayExclusive);
    }).toList()..sort((a, b) => a.taskDatetime.compareTo(b.taskDatetime));
  }

  /// Deadline đến hạn trong [days] ngày lịch tới, kể cả hôm nay.
  /// Bao gồm deadline hoàn thành để Trang chủ vẫn thể hiện trạng thái của chúng.
  static List<Task> upcoming(
    Iterable<Task> tasks, {
    DateTime? now,
    int days = 7,
  }) {
    final today = dayKey(now ?? DateTime.now());
    final end = today.add(Duration(days: days));
    return tasks.where((task) {
      final dueDate = dayKey(task.taskDatetime);
      return !dueDate.isBefore(today) && dueDate.isBefore(end);
    }).toList()..sort((a, b) => a.taskDatetime.compareTo(b.taskDatetime));
  }

  void _notifyTaskChanges(String userId) {
    final key = _TaskCacheKey(_repo.cacheScope, userId);
    _taskCache.remove(key);
    _cacheGeneration[key] = (_cacheGeneration[key] ?? 0) + 1;
    _pendingLoads.remove(key);
    taskChanges.value++;
  }

  // ---------- Nội bộ ----------

  void _requireUser(String userId) {
    if (userId.isEmpty) throw const TaskException('Bạn chưa đăng nhập');
  }

  /// Đổi [TaskRepositoryException] thành [TaskException].
  Future<R> _guard<R>(Future<R> Function() action) async {
    try {
      return await action();
    } on TaskRepositoryException catch (e) {
      throw TaskException(e.message);
    }
  }

  Future<void> _checkSubject(String? subjectId, String userId) async {
    final check = _subjectExists;
    if (subjectId == null || check == null) return;
    final ok = await check(subjectId, userId);
    if (!ok) throw const TaskException('Môn học không tồn tại');
  }

  Future<void> _ensureUniqueTitle(
    String userId,
    String title, {
    String? excludeId,
  }) async {
    final key = title.trim().toLowerCase();
    // Reuse the same short-lived, per-user snapshot shown by the app instead
    // of issuing another full collection read for each save.
    final list = await findAll(userId);
    final dup = list.any(
      (t) => t.id != excludeId && t.title.trim().toLowerCase() == key,
    );
    if (dup) throw const TaskException('Tiêu đề deadline đã tồn tại');
  }

  /// Lỗi ở bước nhắc nhở không làm hỏng việc đã lưu deadline.
  Future<void> _safeReminder(Future<void>? Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint('Nhắc nhở lỗi: $e');
    }
  }

  Future<void> _syncReminder(Task task, String taskId) async {
    await _safeReminder(() => _cancelReminders?.call(taskId));
    if (task.status != TaskStatus.completed) {
      await _safeReminder(() => _scheduleReminder?.call(task));
    }
  }

  String? _blankToNull(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}

class _TaskCacheEntry {
  final List<Task> tasks;
  final DateTime loadedAt;

  const _TaskCacheEntry(this.tasks, this.loadedAt);
}

class _TaskCacheKey {
  final Object scope;
  final String userId;

  const _TaskCacheKey(this.scope, this.userId);

  @override
  bool operator ==(Object other) =>
      other is _TaskCacheKey &&
      identical(other.scope, scope) &&
      other.userId == userId;

  @override
  int get hashCode => Object.hash(identityHashCode(scope), userId);
}
