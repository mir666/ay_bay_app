import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpDialog {
  static void show() {
    Get.dialog(
      Builder(
        builder: (context) {
          final dialogLocalization = AppLocalizations.of(context)!;

          return Center(
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
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            Icons.help_outline_rounded,
                            size: 26,
                            color: AppColors.loginTextButtonColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            dialogLocalization.helpFaqTitle,
                            style: const TextStyle(
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
                          children: [
                            _FaqItem(
                              question: dialogLocalization.faqAddTransactionQ,
                              answer: dialogLocalization.faqAddTransactionA,
                            ),
                            _FaqItem(
                              question: dialogLocalization.faqMonthlyReportQ,
                              answer: dialogLocalization.faqMonthlyReportA,
                            ),
                            _FaqItem(
                              question: dialogLocalization.faqEditProfileQ,
                              answer: dialogLocalization.faqEditProfileA,
                            ),
                            _FaqItem(
                              question: dialogLocalization.faqDataSafeQ,
                              answer: dialogLocalization.faqDataSafeA,
                            ),
                            _FaqItem(
                              question: dialogLocalization.faqContactQ,
                              answer: dialogLocalization.faqContactA,
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
                        onPressed: Get.back,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColors.loginTextButtonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          dialogLocalization.close,
                          style: const TextStyle(
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
          );
        },
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
        color: highlight ? Theme.of(context).primaryColor.withValues(alpha: 0.08) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 6),
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
