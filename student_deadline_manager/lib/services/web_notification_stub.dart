/// Không phải web: không có thông báo của trình duyệt.
Future<bool> requestWebNotificationPermission() async => false;

bool showWebNotification(String title, String body) => false;