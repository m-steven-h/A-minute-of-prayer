// services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'audio_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AudioService _audioService = AudioService();

  bool _initialized = false;

  static const String _egyptTimeZone = 'Africa/Cairo';
  static const int _notificationHour = 13;
  static const int _notificationMinute = 0;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_egyptTimeZone));

    // إعدادات Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // إعدادات iOS مع الصوت
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentSound: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  // دالة جدولة الإشعار اليومي
  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
    required String title,
    required String body,
    required int id,
  }) async {
    if (!_initialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('prayer_road_notifications_enabled') ?? true;
    if (!enabled) return;

    final egyptTimeZone = tz.getLocation(_egyptTimeZone);
    final now = tz.TZDateTime.now(egyptTimeZone);

    var scheduledTime = tz.TZDateTime(
      egyptTimeZone,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // إعدادات Android مع تحديد ملف الصوت notification.mp3
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'prayer_road_channel',
      'طريق الصلاة',
      channelDescription: 'تذكير يومي لإكمال مهام طريق الصلاة',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      // تحديد ملف الصوت notification.mp3
      // ملاحظة: يجب وضع الملف في android/app/src/main/res/raw/ بدون امتداد
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    // إعدادات iOS مع تحديد ملف الصوت notification.mp3
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentSound: true,
      sound: 'notification.mp3', // اسم ملف الصوت لنظام iOS
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> schedulePrayerRoadNotification({
    required String title,
    required String body,
  }) async {
    // تشغيل صوت الإشعار عند الجدولة
    await _audioService.playNotificationSound();

    await scheduleDailyNotification(
      hour: _notificationHour,
      minute: _notificationMinute,
      title: title,
      body: body,
      id: 1001,
    );
  }

  Future<void> updateDailyNotification(String title, String body) async {
    await cancelNotification(1001);
    await schedulePrayerRoadNotification(title: title, body: body);
  }

  Future<void> sendImmediateNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('prayer_road_notifications_enabled') ?? true;
    if (!enabled) return;

    // تشغيل صوت الإشعار الفوري
    await _audioService.playNotificationSound();

    // إعدادات Android للإشعار الفوري مع تحديد ملف الصوت notification.mp3
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'prayer_road_channel',
      'طريق الصلاة',
      channelDescription: 'تذكير يومي لإكمال مهام طريق الصلاة',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      // تحديد ملف الصوت notification.mp3 للإشعار الفوري
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    // إعدادات iOS للإشعار الفوري
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentSound: true,
      sound: 'notification.mp3',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1002,
      title,
      body,
      details,
    );
  }

  void dispose() {
    _audioService.dispose();
  }
}
