import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_entity.dart';
import 'task_status.dart';
import 'task_type.dart';

DateTime _toDate(Object? v) {
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  return DateTime.now();
}

/// Class Task trong Class Diagram: một deadline/công việc của sinh viên.
/// id = id của Document trong collection `tasks`.
class Task extends BaseEntity {
  /// Chủ sở hữu (FK -> users).
  final String userId;

  /// Môn học liên quan (FK -> subjects), có thể không có.
  final String? subjectId;
  final String title;
  final TaskType? type;

  /// Hạn nộp / thời điểm diễn ra.
  final DateTime taskDatetime;
  final String? room;
  final String? notes;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    super.id,
    required this.userId,
    this.subjectId,
    required this.title,
    this.type,
    required this.taskDatetime,
    this.room,
    this.notes,
    this.status = TaskStatus.pending,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Document -> Object
  factory Task.fromMap(String id, Map<String, dynamic> m) => Task(
        id: id,
        userId: (m['userId'] as String?) ?? '',
        subjectId: m['subjectId'] as String?,
        title: (m['title'] as String?) ?? '',
        type: TaskType.fromName(m['type'] as String?),
        taskDatetime: _toDate(m['taskDatetime']),
        room: m['room'] as String?,
        notes: m['notes'] as String?,
        status: TaskStatus.fromName(m['status'] as String?),
        createdAt: _toDate(m['createdAt']),
        updatedAt: _toDate(m['updatedAt']),
      );

  /// Object -> Document
  @override
  Map<String, Object> toMap() => {
        'userId': userId,
        if (subjectId != null) 'subjectId': subjectId!,
        'title': title,
        if (type != null) 'type': type!.name,
        'taskDatetime': Timestamp.fromDate(taskDatetime),
        if (room != null) 'room': room!,
        if (notes != null) 'notes': notes!,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  /// Trả về bản sao có thay đổi. Muốn xóa môn học thì đặt [clearSubjectId].
  Task copyWith({
    String? id,
    String? subjectId,
    bool clearSubjectId = false,
    String? title,
    TaskType? type,
    DateTime? taskDatetime,
    String? room,
    String? notes,
    TaskStatus? status,
  }) =>
      Task(
        id: id ?? this.id,
        userId: userId,
        subjectId: clearSubjectId ? null : (subjectId ?? this.subjectId),
        title: title ?? this.title,
        type: type ?? this.type,
        taskDatetime: taskDatetime ?? this.taskDatetime,
        room: room ?? this.room,
        notes: notes ?? this.notes,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  /// Quá hạn: đã qua [taskDatetime] mà chưa hoàn thành.
  /// [now] chỉ dùng khi viết unit test.
  bool isOverdue({DateTime? now}) =>
      status != TaskStatus.completed &&
      taskDatetime.isBefore(now ?? DateTime.now());

  /// Trạng thái để hiển thị: tự chuyển thành [TaskStatus.overdue] khi quá hạn.
  TaskStatus displayStatus({DateTime? now}) =>
      isOverdue(now: now) ? TaskStatus.overdue : status;

  /// Số ngày còn lại tính theo ngày lịch (hôm nay = 0, quá hạn < 0).
  int daysLeft({DateTime? now}) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final due =
        DateTime(taskDatetime.year, taskDatetime.month, taskDatetime.day);
    return due.difference(today).inDays;
  }
}

/// Dữ liệu từ form thêm/sửa deadline (dto trong Class Diagram).
/// Các trường có thể null để [TaskService] báo lỗi thiếu dữ liệu.
class TaskDto {
  final String? title;
  final String? subjectId;
  final TaskType? type;
  final DateTime? taskDatetime;
  final String? room;
  final String? notes;

  /// null = giữ nguyên trạng thái hiện tại (khi sửa) hoặc [TaskStatus.pending] (khi tạo).
  final TaskStatus? status;

  const TaskDto({
    this.title,
    this.subjectId,
    this.type,
    this.taskDatetime,
    this.room,
    this.notes,
    this.status,
  });

  /// Tạo dto từ Task có sẵn, thường dùng để đổi trạng thái:
  /// `TaskDto.fromTask(task, status: TaskStatus.completed)`.
  factory TaskDto.fromTask(Task t, {TaskStatus? status}) => TaskDto(
        title: t.title,
        subjectId: t.subjectId,
        type: t.type,
        taskDatetime: t.taskDatetime,
        room: t.room,
        notes: t.notes,
        status: status ?? t.status,
      );
}