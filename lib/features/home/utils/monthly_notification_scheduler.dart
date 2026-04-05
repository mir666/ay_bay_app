import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:ay_bay_app/features/home/controllers/notification_controller.dart';
import 'package:ay_bay_app/core/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class MonthlyNotificationScheduler {
  static final _db = FirebaseFirestore.instance;

  /// Schedule monthly notification at month end
  static Future<void> schedule(String uid) async {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59);
    final duration = lastDay.difference(now);

    await AndroidAlarmManager.oneShot(
      duration,
      1000 + now.month, // unique id for each month
      sendNotification,
      exact: true,
      wakeup: true,
      params: {'uid': uid},
    );
  }

  /// Send monthly expense notification
  static Future<void> sendNotification(Map<String, dynamic> params) async {
    final uid = params['uid'] as String;

    // Notification service init
    await NotificationService.init();
    final notificationController = Get.put(NotificationController());

    // 🔹 Fetch transactions from Firebase
    final now = DateTime.now();
    final currentMonthRef = _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .doc('${now.year}-${now.month.toString().padLeft(2, '0')}')
        .collection('transactions');

    final previousMonth = DateTime(now.year, now.month - 1, 1);
    final previousMonthRef = _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .doc('${previousMonth.year}-${previousMonth.month.toString().padLeft(2, '0')}')
        .collection('transactions');

    // Current month expense
    final currentSnap = await currentMonthRef.get();
    double currentExpense = currentSnap.docs.fold(
      0.0,
          (sum, doc) => doc['type'] == 'expense' ? sum + (doc['amount'] ?? 0).toDouble() : sum,
    );

    // Previous month expense
    final previousSnap = await previousMonthRef.get();
    double previousExpense = previousSnap.docs.fold(
      0.0,
          (sum, doc) => doc['type'] == 'expense' ? sum + (doc['amount'] ?? 0).toDouble() : sum,
    );

    // Decide message
    String title = 'মাসিক খরচ সংক্ষিপ্তসার';
    String body = 'এই মাসে মোট খরচ: ৳${currentExpense.toInt()}';

    if (currentExpense > previousExpense) {
      body += '\n⚠️ আগের মাসের তুলনায় বেড়েছে ৳${(currentExpense - previousExpense).toInt()}';
    } else if (currentExpense < previousExpense) {
      body += '\n✅ আগের মাসের তুলনায় কমেছে ৳${(previousExpense - currentExpense).toInt()}';
    } else {
      body += '\nℹ️ আগের মাসের মতোই খরচ হয়েছে';
    }

    notificationController.addNotification(title, body);
    await NotificationService.showNotification(
      id: 2000 + now.month, // monthly unique id
      title: title,
      body: body,
    );

    // Schedule next month automatically
    await schedule(uid);
  }
}