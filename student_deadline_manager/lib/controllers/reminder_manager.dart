import '../models/reminder_summary.dart';
import 'base_manager.dart';

class ReminderManager extends BaseManager<ReminderSummary> {
  ReminderManager()
      : super(const ReminderSummary(
          title: "Nộp Bài tập thực hành Flutter",
          dueDate: "16/09/2026",
          status: "Đang thực hiện",
        ));

  String get title => data.title;
  String get dueDate => data.dueDate;
  String get status => data.status;

  void setReminder(String title, String dueDate, String status) {
    setData(ReminderSummary(
        id: data.id, title: title, dueDate: dueDate, status: status));
  }

  @override
  String describe() => "Nhắc nhở: $title - Hạn: $dueDate [$status]";

  String getReminderInfo() => describe();
}
