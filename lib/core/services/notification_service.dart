import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  /// ইনিশিয়ালাইজেশন
  static Future<void> init() async {
    tz.initializeTimeZones(); // টাইমজোন ইনিশিয়ালাইজ

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings: settings);

  }

  static Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local), // TimeZone conversion, adjust if needed
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'debt_channel',
          'Debt Notifications',
          channelDescription: 'Reminder for debts',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// সরাসরি নটিফিকেশন দেখানো
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const platformDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(id: id, title: title, body: body, notificationDetails: platformDetails);
  }

  /// শিডিউল করা নটিফিকেশন
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool repeatDaily = false, // প্রতিদিনের জন্য
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const _ = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local), // আপনার নির্ধারিত সময়
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default',
          channelDescription: 'Default notification channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // অ্যান্ড্রয়েডে idle মোডে ঠিক কাজ করবে
      matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null, // Daily হলে time match
    );
  }

  /// প্রতিদিনের নটিফিকেশন (যেমন রাত ৮টা)
  static Future<void> scheduleDailyNotification() async {
    final now = DateTime.now();
    final scheduledTime = DateTime(now.year, now.month, now.day, 20, 0); // রাত ৮টা

    await scheduleNotification(
      id: 1,
      title: "Daily Reminder",
      body: "আপনার দৈনিক আয়-ব্যয় চেক করুন",
      scheduledDate: scheduledTime,
      repeatDaily: true,
    );
  }

  /// মাসের শেষের নটিফিকেশন
  static Future<void> scheduleMonthlyNotification() async {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 20, 0); // মাসের শেষ রাত ৮টা

    await scheduleNotification(
      id: 2,
      title: "Monthly Reminder",
      body: "মাস শেষ! আপনার খরচের হিসাব চেক করুন",
      scheduledDate: lastDayOfMonth,
      repeatDaily: false,
    );
  }

  /// ইউজার ডিউ তারিখের জন্য নটিফিকেশন (যেমন ২ দিন আগে)
  static Future<void> scheduleDebtReminder(DateTime dueDate, int debtId) async {
    final reminderDate = dueDate.subtract(Duration(days: 2)); // দুই দিন আগে

    await scheduleNotification(
      id: debtId,
      title: "Debt Reminder",
      body: "আপনার payment দুই দিনের মধ্যে!",
      scheduledDate: reminderDate,
      repeatDaily: false,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }
}