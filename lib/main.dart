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

// =============================================================
//  Background FCM Handler
// =============================================================

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  String title = 'নতুন নোটিফিকেশন';
  String body = '';

  if (message.notification != null) {
    title = message.notification!.title ?? title;
    body = message.notification!.body ?? body;
  }

  if (message.data.isNotEmpty) {
    title = message.data['title'] ?? title;
    body = message.data['body'] ?? body;
  }
}

// =============================================================
//  Main Entry Point
// =============================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize local storage
  await GetStorage.init();

  // Localization controller
  Get.put(LocaleController());

  // Initialize notification service
  await NotificationService.init();

  // Request notification permissions (Android 13+ & iOS)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Register background handler (must be before runApp)
  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  // Get FCM token (for testing / backend registration)
  String? token = await FirebaseMessaging.instance.getToken();
  if (kDebugMode) {
    print('Device FCM Token: $token');
  }

  // Initialize notification controller
  final notificationController = Get.put(
    NotificationController(),
  );

  // =============================================================
  //  Foreground Message Listener
  // =============================================================

  FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) async {
      String title = 'নতুন নোটিফিকেশন';
      String body = '';

      // Notification payload
      if (message.notification != null) {
        title = message.notification!.title ?? title;
        body = message.notification!.body ?? body;
      }

      // Data payload
      if (message.data.isNotEmpty) {
        title = message.data['title'] ?? title;
        body = message.data['body'] ?? body;
      }

      // Save notification locally
      notificationController.addNotification(
        title,
        body,
      );

      // Show local notification
    },
  );

  // =============================================================
  //  When Notification Opens the App
  // =============================================================

  FirebaseMessaging.onMessageOpenedApp.listen(
        (RemoteMessage message) async {
      String title = 'নতুন নোটিফিকেশন';
      String body = '';

      if (message.notification != null) {
        title = message.notification!.title ?? title;
        body = message.notification!.body ?? body;
      }

      if (message.data.isNotEmpty) {
        title = message.data['title'] ?? title;
        body = message.data['body'] ?? body;
      }

      notificationController.addNotification(
        title,
        body,
      );
    },
  );

  // Start App
  runApp(const AyBayApp());
}