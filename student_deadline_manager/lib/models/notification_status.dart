/// Trạng thái của một nhắc nhở (NotificationStatus trong Class Diagram).
///
/// Bật = [pending], tắt = [cancelled]. Giá trị lưu trên Firestore là [name].
enum NotificationStatus {
  pending('Đang bật'),
  sent('Đã gửi'),
  failed('Gửi lỗi'),
  cancelled('Đã tắt');

  /// Nhãn tiếng Việt hiển thị trên giao diện.
  final String label;
  const NotificationStatus(this.label);

  /// Đọc từ Firestore. Giá trị lạ hoặc null thì coi là [pending].
  static NotificationStatus fromName(String? name) =>
      NotificationStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => NotificationStatus.pending,
      );
}