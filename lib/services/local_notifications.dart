import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// System (OS-level) notifications for matches and messages.
/// Local notifications work while the app process is alive; remote push requires
/// Firebase Messaging plus a backend that sends FCM/APNs messages.
class LocalNotifications {
  LocalNotifications._();

  static const String channelId = 'vinco_activity';

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Called with the notification payload when the user taps a notification.
  static void Function(String payload)? onTap;

  static Future<void> init() async {
    if (_initialized || kIsWeb) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) onTap?.call(payload);
      },
    );
    const channel = AndroidNotificationChannel(
      channelId,
      'Actividad de VINCÓ',
      description: 'Avisos de matches y mensajes',
      importance: Importance.high,
      playSound: true,
    );
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(channel);
    await android?.requestNotificationsPermission();
    _initialized = true;
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    if (kIsWeb || !_initialized) return;
    const androidDetails = AndroidNotificationDetails(
      channelId,
      'Actividad de VINCÓ',
      channelDescription: 'Avisos de matches y mensajes',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }
}
