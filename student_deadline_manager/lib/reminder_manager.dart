import 'base_manager.dart';

/// Dữ liệu nhắc nhở (kế thừa BaseEntity).
class ReminderData extends BaseEntity {
  final String title;
  final String dueDate;
  final String status;

  const ReminderData({
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

/// CÂU 2: ReminderManager extends BaseManager<ReminderData>
class ReminderManager extends BaseManager<ReminderData> {
  ReminderManager()
      : super(const ReminderData(
          title: "Nộp Bài tập thực hành Flutter",
          dueDate: "16/09/2026",
          status: "Đang thực hiện",
        ));

  String get title => data.title;
  String get dueDate => data.dueDate;
  String get status => data.status;

  void setReminder(String title, String dueDate, String status) {
    setData(ReminderData(title: title, dueDate: dueDate, status: status));
  }

  @override
  String describe() => "Nhắc nhở: $title - Hạn: $dueDate [$status]";

  String getReminderInfo() => describe();
}