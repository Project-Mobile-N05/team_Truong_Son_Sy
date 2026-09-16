class Task {
  String title = "Nộp bài tập Flutter";
  String deadline = "16/09/2026";
  String description = "Tạo Lớp Quản lý công việc và commit lên GitHub";
  bool isCompleted = false;

  // Phương thức thiết lập thông tin công việc (Setter)
  void setTask(String title, String deadline, String description) {
    this.title = title;
    this.deadline = deadline;
    this.description = description;
  }

  // Phương thức lấy chuỗi tóm tắt công việc (Getter)
  String getTaskSummary() {
    return "$title | Deadline: $deadline";
  }

  // Phương thức cập nhật trạng thái
  void toggleStatus() {
    isCompleted = !isCompleted;
  }
}