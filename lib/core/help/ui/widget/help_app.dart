import 'package:ay_bay_app/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpDialog {
  static void show() {
    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔹 HEADER
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(Get.context!)
                            .primaryColor
                            .withOpacity(0.12),
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 26,
                        color: AppColors.loginTextButtonColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Help & FAQ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// 🔹 FAQ LIST
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: const [
                        _FaqItem(
                          question: 'How do I add a budget?',
                          answer:
                          'Go to the Home screen and tap the + button.\n'
                              'After first sign up, start a new month and add a budget.',
                        ),
                        _FaqItem(
                          question: 'How do I add a new transaction?',
                          answer:
                          'From the Home screen, tap the + button to add income or expense.',
                        ),
                        _FaqItem(
                          question: 'How do I view monthly reports?',
                          answer:
                          'Select a month from the month list to view monthly summaries.',
                        ),
                        _FaqItem(
                          question: 'How do I edit my profile?',
                          answer:
                          'Go to the Profile screen and tap the Edit button.',
                        ),
                        _FaqItem(
                          question: 'Is my financial data safe?',
                          answer:
                          'Yes. Your data is securely stored in Firebase and only accessible by you.',
                        ),
                        _FaqItem(
                          question: 'How do I contact support?',
                          answer:
                          'Email us at:\nfarhanaakter10506264robi@gmail.com',
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔹 CLOSE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.loginTextButtonColor,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}

/// 🔹 FAQ ITEM CARD
class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool highlight;

  const _FaqItem({
    required this.question,
    required this.answer,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? Theme.of(context).primaryColor.withOpacity(0.08)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: highlight
                  ? Theme.of(context).primaryColor
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
