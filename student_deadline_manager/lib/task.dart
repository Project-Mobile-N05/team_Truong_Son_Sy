import './base_entity.dart';

/// Lớp Task mở rộng (extends) từ lớp Generic BaseEntity với ID kiểu String
class Task extends BaseEntity<String> {
  String title;
  String deadline;
  String description;
  bool isCompleted;

  Task({
    required String id,
    this.title = "Báo cáo Đồ án Flutter",
    this.deadline = "16/09/2026",
    this.description = "Xây dựng giao diện và lớp quản lý deadline",
    this.isCompleted = false,
    DateTime? createdAt,
  }) : super(id: id, createdAt: createdAt);

  void setTask(String title, String deadline, String description, bool isCompleted) {
    this.title = title;
    this.deadline = deadline;
    this.description = description;
    this.isCompleted = isCompleted;
  }

  String getTaskInfo() {
    return "$title\nHạn chót: $deadline ($description)";
  }

  String getTitle() => title;
  String getDeadline() => deadline;

  /// Chuyển đổi thành Map (Ghi đè phương thức từ BaseEntity)
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Sử dụng Object class để override chuỗi đại diện
  @override
  String toString() {
    return '${super.toString()} - Tiêu đề: $title [Hoàn thành: $isCompleted]';
  }
}