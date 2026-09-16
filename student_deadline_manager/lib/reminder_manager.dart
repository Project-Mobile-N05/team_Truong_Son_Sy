class ReminderManager {
  String title = "Nộp Bài tập thực hành Flutter";
  String dueDate = "16/09/2026";
  String status = "Đang thực hiện";

  void setReminder(String title, String dueDate, String status) {
    this.title = title;
    this.dueDate = dueDate;
    this.status = status;
  }

  String getReminderInfo() {
    return "Nhắc nhở: $title - Hạn: $dueDate [$status]";
  }
}