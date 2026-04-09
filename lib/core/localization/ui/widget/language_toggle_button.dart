import 'dart:ui';
import 'package:ay_bay_app/core/localization/controllers/localization_controller.dart';
import 'package:flutter/material.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LocaleController.to;

    return GestureDetector(
      onTap: controller.toggleLanguage, // 👈 save + update
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language, size: 12),
                const SizedBox(width: 4),
                Text(
                  controller.isBangla ? 'EN' : 'BN',
                  style: TextStyle(fontWeight: FontWeight.w600,fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

