enum NotificationStatus {
  pending('Đang bật'),
  sent('Đã gửi'),
  failed('Gửi lỗi'),
  cancelled('Đã tắt');

  final String label;
  const NotificationStatus(this.label);

  static NotificationStatus fromName(String? name) =>
      NotificationStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => NotificationStatus.pending,
      );
}