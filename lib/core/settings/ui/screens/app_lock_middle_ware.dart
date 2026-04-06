import 'package:ay_bay_app/core/settings/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppLockMiddleware extends GetMiddleware {
  late final SettingsController settingsController;

  AppLockMiddleware() {
    // যদি instance না থাকে তবে তৈরি করবে
    settingsController = Get.put(SettingsController(), permanent: true);
  }

  @override
  RouteSettings? redirect(String? route) {
    if (settingsController.isAppLockEnabled.value) {
      return const RouteSettings(name: '/app-lock');
    }
    return null;
  }
}