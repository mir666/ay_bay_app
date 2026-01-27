import 'package:ay_bay_app/app/app.dart';
import 'package:ay_bay_app/features/home/controllers/notification_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// 🔹 Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Background message: ${message.messageId}');
    print('Background notification title: ${message.notification?.title}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();

  // 🔹 iOS notification permission
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // 🔹 Device FCM token (optional: save to your backend)
  String? token = await FirebaseMessaging.instance.getToken();
  if (kDebugMode) {
    print('Device FCM Token: $token');
  }

  // 🔹 Initialize NotificationController
  final notificationController = Get.put(NotificationController());

  // 🔹 Foreground message listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final title = message.notification?.title ?? 'নতুন নোটিফিকেশন';
    if (kDebugMode) {
      print('Foreground notification title: $title');
    }
    notificationController.addNotification(title);
  });

  // 🔹 Background message listener
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔹 Notification opened from terminated/background state
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final title = message.notification?.title ?? 'নতুন নোটিফিকেশন';
    if (kDebugMode) {
      print('Notification clicked: $title');
    }
    notificationController.addNotification(title);
    // এখানে চাইলে Get.toNamed('/your_route') করে screen navigate করতে পারেন
  });

  runApp(const AyBayApp());
}
