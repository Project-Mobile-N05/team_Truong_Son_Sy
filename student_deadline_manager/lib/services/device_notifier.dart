import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'web_notification_stub.dart'
    if (dart.library.js_interop) 'web_notification_web.dart';

final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

abstract class DeviceNotifier {
  bool get isSupported;
  Future<void> init();
  Future<void> show({
    required int id,
    required String title,
    required String body,
  });
}

class LocalDeviceNotifier implements DeviceNotifier {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  @override
  bool get isSupported => true;

  @override
  Future<void> init() async {
    if (_ready) return;
        if (kIsWeb) {
      await requestWebNotificationPermission();
      _ready = true;
      return;
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _ready = true;
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_ready) await init();
        if (kIsWeb) {
      if (!showWebNotification(title, body)) _showBanner(title, body);
      return;
    }
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'deadline_reminders',
        'Nhắc nhở deadline',
        channelDescription: 'Thông báo khi deadline sắp đến hạn',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  void _showBanner(String title, String body) {
    final messenger = appMessengerKey.currentState;
    if (messenger == null) {
      throw StateError('Chưa sẵn sàng hiển thị thông báo');
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 8),
          backgroundColor: const Color(0xFF3B2A7A),
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.white)),
                    Text(body, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          showCloseIcon: true,
          closeIconColor: Colors.white,
        ),
      );
  }
}