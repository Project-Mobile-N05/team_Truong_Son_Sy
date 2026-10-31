import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_entity.dart';
import 'notification_status.dart';

DateTime _toDate(Object? v) {
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  return DateTime.now();
}

/// Class NotificationLog trong Class Diagram: một nhắc nhở gắn với một deadline.
/// id = id của Document trong collection `reminders`.
class ReminderData extends BaseEntity {
  /// Chủ sở hữu (FK -> users).
  final String userId;

  /// Deadline được nhắc (FK -> tasks).
  final String taskId;
  final String message;

  /// Thời điểm cần nhắc.
  final DateTime scheduledAt;
  final NotificationStatus status;
  final DateTime? sentAt;
  final DateTime createdAt;

  ReminderData({
    super.id,
    required this.userId,
    required this.taskId,
    required this.message,
    required this.scheduledAt,
    this.status = NotificationStatus.pending,
    this.sentAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Document -> Object
  factory ReminderData.fromMap(String id, Map<String, dynamic> m) =>
      ReminderData(
        id: id,
        userId: (m['userId'] as String?) ?? '',
        taskId: (m['taskId'] as String?) ?? '',
        message: (m['message'] as String?) ?? '',
        scheduledAt: _toDate(m['scheduledAt']),
        status: NotificationStatus.fromName(m['status'] as String?),
        sentAt: m['sentAt'] == null ? null : _toDate(m['sentAt']),
        createdAt: _toDate(m['createdAt']),
      );

  /// Object -> Document
  @override
  Map<String, Object> toMap() => {
        'userId': userId,
        'taskId': taskId,
        'message': message,
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'status': status.name,
        if (sentAt != null) 'sentAt': Timestamp.fromDate(sentAt!),
        'createdAt': Timestamp.fromDate(createdAt),
      };

  /// Đang bật (chờ nhắc).
  bool get isEnabled => status == NotificationStatus.pending;

  /// Mọi trạng thái đều bật/tắt lại được: bật lại nhắc nhở đã gửi sẽ gửi lần nữa.
  bool get canToggle => true;

  ReminderData copyWith({
    NotificationStatus? status,
    DateTime? sentAt,
    DateTime? scheduledAt,
    bool clearSentAt = false,
  }) =>
      ReminderData(
        id: id,
        userId: userId,
        taskId: taskId,
        message: message,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        status: status ?? this.status,
        sentAt: clearSentAt ? null : (sentAt ?? this.sentAt),
        createdAt: createdAt,
      );
}