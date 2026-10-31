import 'base_entity.dart';

/// Lightweight reminder snapshot used by the generic manager example.
///
/// Firestore-backed reminders use `ReminderData`; this summary keeps the
/// manager's presentation fields separate from the persisted model.
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
