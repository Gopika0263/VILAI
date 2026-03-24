// ─────────────────────────────────────────────────────────────────────────────
//  services/notification_service.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ── Call once in main() ───────────────────────────────────────────────────
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);

    // Request permission (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ── Show a notification ───────────────────────────────────────────────────
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'price_alert_channel', // channel id
      'Price Alerts', // channel name
      channelDescription: 'Crop price alerts for farmers',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details);
  }

  // ── Price alert check + notify ────────────────────────────────────────────
  static Future<bool> checkAndNotify({
    required String crop,
    required double currentPrice,
    required double targetPrice,
    required String marketName,
  }) async {
    if (currentPrice >= targetPrice) {
      await showNotification(
        id: crop.hashCode,
        title: '🔔 ${_emoji(crop)} $crop Price Alert!',
        body: '$marketName-ல் இப்போ ₹${currentPrice.toInt()}/kg — '
            'Target ₹${targetPrice.toInt()} reach ஆச்சு! '
            'இப்போவே விக்கலாம்! 🌾',
      );
      return true; // triggered
    }
    return false; // not triggered
  }

  static String _emoji(String crop) {
    const map = {
      'Tomato': '🍅',
      'Onion': '🧅',
      'Potato': '🥔',
      'Rice': '🌾',
    };
    return map[crop] ?? '🌾';
  }
}
