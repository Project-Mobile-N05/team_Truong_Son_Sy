class Task {
  String title = "Báo cáo Đồ án Flutter";
  String deadline = "16/09/2026";
  String description = "Xây dựng giao diện và lớp quản lý deadline";
  bool isCompleted = false;

  // Setter cập nhật thông tin công việc
  void setTask(String title, String deadline, String description, bool isCompleted) {
    this.title = title;
    this.deadline = deadline;
    this.description = description;
    this.isCompleted = isCompleted;
  }

  // Getter lấy thông tin tổng quan
  String getTaskInfo() {
    return "$title - Deadline: $deadline ($description)";
  }

  // Getter lấy tiêu đề
  String getTitle() {
    return title;
  }

  // Getter lấy hạn chót
  String getDeadline() {
    return deadline;
  }
}