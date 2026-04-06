// notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        print("Notification clicked: ${details.payload}");
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Android channel
    const androidChannel = AndroidNotificationChannel(
      'scheduled_channel',
      'Scheduled Notifications',
      description: 'Scheduled debt notifications',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    int? id,
  }) async {
    final int safeId = id ?? DateTime.now().millisecondsSinceEpoch.remainder(2147483647);

    final androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Scheduled debt notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      id: safeId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: body,
    );
  }

  static Future<void> showScheduledNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    int? id,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    final int safeId = id ?? DateTime.now().millisecondsSinceEpoch.remainder(2147483647);

    final androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Scheduled debt notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await _notifications.zonedSchedule(
      id: safeId,
      title: title,
      body: body,
      scheduledDate: tzDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchDateTimeComponents,
      payload: body,
    );
  }

  static Future<void> printPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();

    for (var n in pending) {
      print("Pending ID: ${n.id} Title: ${n.title}");
    }
  }

  static Future<void> scheduleDailyExpenseReminder() async {
    final now = DateTime.now();

    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      20,
      0,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(
        const Duration(days: 1),
      );
    }

    await showScheduledNotification(
      id: 5000,
      title: 'Daily Expense Reminder',
      body: 'আজ কি আপনার সব খরচ যোগ হয়েছে?',
      scheduledDate: scheduledTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  print('Background notification clicked: ${response.payload}');
}