import 'dart:ui';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/core/settings/controllers/change_password_contoller.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final controller = Get.find<ChangePasswordController>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          /// 🌈 Premium Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE3F2FD),
                  Color(0xFFF9FCFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                /// 🔝 Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black12,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.localization.changePassword,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.loginTextButtonColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔐 Glass Card
                Expanded(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 25,
                          sigmaY: 25,
                        ),
                        child: Container(
                          width: size.width * 0.9,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.35),
                                Colors.white.withValues(alpha: 0.15),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 25,
                                offset: Offset(0, 12),
                                color: Colors.black12,
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                /// 🔑 Icon
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors
                                        .loginTextButtonColor
                                        .withValues(alpha: 0.12),
                                  ),
                                  child: const Icon(
                                    Icons.lock_reset,
                                    size: 34,
                                    color: AppColors.loginTextButtonColor,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                _premiumField(
                                  label: context.localization.currentPassword,
                                  icon: Icons.lock_outline,
                                  obscureRx: controller.showCurrent,
                                  onChanged: (v) => controller
                                      .currentPassword.value = v,
                                ),

                                const SizedBox(height: 14),

                                _premiumField(
                                  label: context.localization.newPassword,
                                  icon: Icons.lock,
                                  obscureRx: controller.showNew,
                                  onChanged: (v) => controller
                                      .newPassword.value = v,
                                ),

                                const SizedBox(height: 14),

                                _premiumField(
                                  label: context.localization.confirmNewPassword,
                                  icon: Icons.lock,
                                  obscureRx: controller.showConfirm,
                                  onChanged: (v) => controller
                                      .confirmPassword.value = v,
                                ),

                                const SizedBox(height: 28),

                                /// 🚀 Premium Button
                                Obx(
                                      () => SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 8,
                                        backgroundColor:
                                        AppColors
                                            .loginTextButtonColor,
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(18),
                                        ),
                                      ),
                                      onPressed: controller
                                          .isLoading.value
                                          ? null
                                          : controller
                                          .changePassword,
                                      child: controller
                                          .isLoading.value
                                          ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                          : Text(
                                        context.localization.updatePassword,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight:
                                          FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 Premium TextField
  Widget _premiumField({
    required String label,
    required IconData icon,
    required RxBool obscureRx,
    required Function(String) onChanged,
  }) {
    return Obx(
          () => TextField(
        obscureText: obscureRx.value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(
              obscureRx.value
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () => obscureRx.toggle(),
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.6),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
