class Task {
  String title;
  String deadline;
  String description;
  bool isCompleted;

  Task({
    this.title = "Báo cáo Đồ án Flutter",
    this.deadline = "16/09/2026",
    this.description = "Xây dựng giao diện và lớp quản lý deadline",
    this.isCompleted = false,
  });

  void setTask(String title, String deadline, String description, bool isCompleted) {
    this.title = title;
    this.deadline = deadline;
    this.description = description;
    this.isCompleted = isCompleted;
  }

  String getTaskInfo() {
    return "$title - Hạn chót: $deadline ($description)";
  }

  String getTitle() => title;
  String getDeadline() => deadline;
}