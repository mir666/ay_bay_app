import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:ay_bay_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutAppDialog {
  static void show() {
    Get.dialog(
      Builder(
        builder: (context) {
          final dialogLocalization = AppLocalizations.of(context)!;

          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Get.isDarkMode
                      ? Colors.grey.shade900
                      : Colors.white,
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
                    /// 🔹 ICON
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 40,
                        color: AppColors.loginTextButtonColor,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// 🔹 TITLE
                    Text(
                      dialogLocalization.aboutAppTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// 🔹 VERSION
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${dialogLocalization.version} ${context.localization.versionNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// 🔹 DESCRIPTION
                    Text(
                      dialogLocalization.aboutAppDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔹 COPYRIGHT
                    Text(
                      dialogLocalization.readCopyright,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black38,
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
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
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
    );
  }
}

