import 'base_entity.dart';
class ReminderSummary extends BaseEntity {
  final String title;
  final String dueDate;
  final String status;

  const ReminderSummary({
    super.id,
    required this.title,
    required this.dueDate,
    required this.status,
  });

  @override
  Map<String, Object> toMap() => {
        'title': title,
        'dueDate': dueDate,
        'status': status,
      };
}
