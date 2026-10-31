import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Xin quyền hiện thông báo của trình duyệt. Trả về true nếu đã được cấp.
Future<bool> requestWebNotificationPermission() async {
  final current = web.Notification.permission;
  if (current == 'granted') return true;
  if (current == 'denied') return false;
  final result = await web.Notification.requestPermission().toDart;
  return result.toDart == 'granted';
}

/// Hiện thông báo của trình duyệt. Trả về false nếu chưa được cấp quyền.
bool showWebNotification(String title, String body) {
  if (web.Notification.permission != 'granted') return false;
  web.Notification(title, web.NotificationOptions(body: body));
  return true;
}