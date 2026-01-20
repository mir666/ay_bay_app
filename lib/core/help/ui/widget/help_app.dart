import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpDialog {
  static void show() {
    Get.dialog(
      AlertDialog(
        title: const Text('Help / FAQ'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Q1: How do I add a budget?\n'
                'A1: Go to the Home screen and tap the + button to add budget.\n'
                '[After first sign Up and start new month add budget]',
              ),
              SizedBox(height: 10),
              Text(
                'Q1: How do I add a new transaction?\n'
                'A1: Go to the Home screen and tap the + button to add income or expense.',
              ),
              SizedBox(height: 10),
              Text(
                'Q2: How do I view monthly reports?\n'
                'A2: Select a month from the top horizontal list to view monthly summaries.',
              ),
              SizedBox(height: 10),
              Text(
                'Q3: How do I edit my profile?\n'
                'A3: Go to Profile screen and tap the Edit button to update your name or avatar.',
              ),
              SizedBox(height: 10),
              Text(
                'Q4: Is my financial data safe?\n'
                'A4: Yes, all data is securely stored in Firebase and only accessible by you.',
              ),
              SizedBox(height: 10),
              Text(
                'Q5: How do I contact support?\n'
                'A5: You can contact via email: farhanaakter10506264robi@gmail.com',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
