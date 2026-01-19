import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/app/app_theme.dart';
import 'package:ay_bay_app/core/controllers/theme_controller.dart';
import 'package:ay_bay_app/core/settings/controllers/settings_controller.dart';
import 'package:ay_bay_app/features/common/controller/controller_binding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AyBayApp extends StatefulWidget {
  const AyBayApp({super.key});

  @override
  State<AyBayApp> createState() => _AyBayAppState();
}

class _AyBayAppState extends State<AyBayApp> {
  final ThemeController themeController = Get.put(ThemeController());
  final SettingsController settingsController = Get.put(SettingsController());

  @override
  void initState() {
    super.initState();

    // 🔹 Foreground messages with toggle
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (settingsController.notificationsEnabled.value) {
        // check switch
        if (message.notification != null) {
          Get.snackbar(
            message.notification!.title ?? '',
            message.notification!.body ?? '',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.black87,
            colorText: Colors.white,
            duration: const Duration(seconds: 1),
          );
        }
      }
    });

    // 🔹 Notification opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (settingsController.notificationsEnabled.value) {
        // Example navigation if needed
      }
    });

    // 🔹 Token refresh listener (optional)
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fcmToken': newToken,
        }, SetOptions(merge: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        getPages: AppRoutes.pages,
        initialBinding: ControllerBinding(),

        // ⚡ Light theme
        theme: AppTheme.lightTheme.copyWith(
          primaryColor: themeController.primaryColor.value,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeController.primaryColor.value,
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: themeController.primaryColor.value,
            foregroundColor: ThemeData.estimateBrightnessForColor(
                themeController.primaryColor.value) ==
                Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),

        // ⚡ Dark theme
        darkTheme: AppTheme.darkTheme.copyWith(
          primaryColor: themeController.primaryColor.value,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeController.primaryColor.value,
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: themeController.primaryColor.value,
            foregroundColor: ThemeData.estimateBrightnessForColor(
                themeController.primaryColor.value) ==
                Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),

        themeMode: themeController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
      );
    });
  }

}
