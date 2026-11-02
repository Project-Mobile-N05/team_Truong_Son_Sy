import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_entity.dart';
import 'notification_status.dart';

DateTime _toDate(Object? v) {
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  return DateTime.now();
}

class ReminderData extends BaseEntity {
  final String userId;

  final String taskId;
  final String message;

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

  bool get isEnabled => status == NotificationStatus.pending;

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