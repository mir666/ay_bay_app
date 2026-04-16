
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin
  _notifications = FlutterLocalNotificationsPlugin();

  /// Initialize notification
  static Future<void> init() async {
    tz.initializeTimeZones();

    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    }

    const AndroidInitializationSettings android =
    AndroidInitializationSettings('@drawable/notification_icon');

    const InitializationSettings settings =
    InitializationSettings(android: android);

    await _notifications.initialize(settings: settings);
  }

  /// ==============================
  /// 1) Instant Notification
  /// ==============================

  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails =
    AndroidNotificationDetails(
      'instant_channel',
      'Instant Notification',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details =
    NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// ==============================
  /// 2) Specific Time Notification
  /// ==============================

  static Future<void> scheduleSpecificTimeNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(dateTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'specific_time_channel',
          'Specific Time Notification',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// ==============================
  /// 3) Daily Reminder Notification
  /// ==============================

  static Future<void> scheduleDaily9PMNotification({
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();

    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      21,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id: 100,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_9pm_channel',
          'Daily Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// ==============================
  /// 4) Task Reminder Notification
  /// ==============================

  static Future<void> scheduleUserNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(dateTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'debt_channel',
          'Debt Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// ==============================
  /// Cancel Specific Notification
  /// ==============================

  static Future<void> cancelNotification(
      int id) async {
    await _notifications.cancel(id: id);
  }

  /// Cancel All Notifications

  static Future<void> cancelAllNotifications()
  async {
    await _notifications.cancelAll();
  }
}