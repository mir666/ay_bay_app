import 'package:ay_bay_app/app/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutAppDialog {
  static void show() {
    Get.dialog(
      AlertDialog(
        title: const Text('About AyBay App'),
        content: const Text(
          'AyBay App helps you manage your income, expenses, '
              'and monthly financial reports. You can view your profile, '
              'analyze transactions, and download monthly summaries.\n\n'
              'Version: ${AppConfig.currentAppVersion} (Build 1)\n© 2026 AyBay App. All rights reserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
