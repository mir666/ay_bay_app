import 'package:ay_bay_app/app/app.dart';
import 'package:ay_bay_app/core/services/notification_service.dart';
import 'package:ay_bay_app/features/home/controllers/notification_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/localization/controllers/localization_controller.dart';

// 🔹 Background FCM handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final title = message.notification?.title ?? 'নতুন নোটিফিকেশন';
  final body = message.notification?.body ?? '';

  await NotificationService.showNotification(
    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title: title,
    body: body,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  Get.put(LocaleController());

  // Initialize notification service
  await NotificationService.init();

  // Request iOS permissions
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Device FCM token
  String? token = await FirebaseMessaging.instance.getToken();
  if (kDebugMode) print('Device FCM Token: $token');

  // Initialize GetX notification controller
  final notificationController = Get.put(NotificationController());

  // Foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final title = message.notification?.title ?? 'নতুন নোটিফিকেশন';
    final body = message.notification?.body ?? '';

    notificationController.addNotification(title, body);

    await NotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
    );
  });

  // When notification opens the app from background/terminated
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    final title = message.notification?.title ?? 'নতুন নোটিফিকেশন';
    final body = message.notification?.body ?? '';

    notificationController.addNotification(title, body);

    await NotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
    );
  });

  // Background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Schedule daily expense reminder
  await NotificationService.scheduleDailyExpenseReminder();

  runApp(const AyBayApp());
}