import 'package:ay_bay_app/app/app.dart';
import 'package:ay_bay_app/core/services/notification_service.dart';
import 'package:ay_bay_app/features/home/controllers/notification_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/localization/controllers/localization_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize local storage
  await GetStorage.init();

  // Localization controller
  Get.put(LocaleController());

  await NotificationService.init();

  await requestNotificationPermission();

  // Start App
  runApp(const AyBayApp());
}

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isGranted) {
    print("Notification permission already granted");
  } else {
    var status = await Permission.notification.request();
    if (status.isGranted) {
      print("Notification permission granted");
    } else if (status.isDenied) {
      print("Notification permission denied");
    } else if (status.isPermanentlyDenied) {
      print("Notification permission permanently denied, open app settings");
      await openAppSettings();
    }
  }
}