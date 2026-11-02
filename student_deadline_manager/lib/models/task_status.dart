/// Trạng thái của một deadline (TaskStatus trong Class Diagram).
///
/// Giá trị lưu trên Firestore là [name] (vd: 'inProgress').
enum TaskStatus {
  pending('Chưa làm'),
  inProgress('Đang làm'),
  completed('Hoàn thành'),
  overdue('Quá hạn');

  /// Nhãn tiếng Việt hiển thị trên giao diện.
  final String label;
  const TaskStatus(this.label);

  /// Đọc từ Firestore. Giá trị lạ hoặc null thì coi là [pending].
  static TaskStatus fromName(String? name) => TaskStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => TaskStatus.pending,
      );
}