import 'base_entity.dart';

/// Dữ liệu nhắc nhở (kế thừa BaseEntity).
class ReminderData extends BaseEntity {
  final String title;
  final String dueDate;
  final String status;

  const ReminderData({
    super.id,
    required this.title,
    required this.dueDate,
    required this.status,
  });

  /// Document -> Object (ORM chiều đọc).
  factory ReminderData.fromMap(String id, Map<String, dynamic> m) =>
      ReminderData(
        id: id,
        title: (m['title'] as String?) ?? '',
        dueDate: (m['dueDate'] as String?) ?? '',
        status: (m['status'] as String?) ?? '',
      );

  @override
  Map<String, Object> toMap() => {
        'title': title,
        'dueDate': dueDate,
        'status': status,
      };
}
