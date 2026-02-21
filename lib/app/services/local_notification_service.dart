import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);
  }

  Future<void> sendNudge() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'quick_hit_nudge',
        'Quick Hit Nudge',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      1001,
      'Quick hit time',
      'Mở app 10 giây để gặp 1 từ mới',
      details,
    );
  }
}
