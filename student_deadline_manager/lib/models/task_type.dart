/// Loại deadline (TaskType trong Class Diagram).
///
/// Lưu ý: giá trị CLASS trong Class Diagram được đặt tên [classSession]
/// vì `class` là từ khóa của Dart.
enum TaskType {
  assignment('Bài tập'),
  exam('Thi'),
  project('Đồ án'),
  classSession('Buổi học'),
  other('Khác');

  /// Nhãn tiếng Việt hiển thị trên giao diện.
  final String label;
  const TaskType(this.label);

  /// Đọc từ Firestore. Giá trị lạ hoặc null thì trả về null (không có loại).
  static TaskType? fromName(String? name) {
    for (final t in TaskType.values) {
      if (t.name == name) return t;
    }
    return null;
  }
}