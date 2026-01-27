import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:ay_bay_app/core/localization/ui/widget/language_toggle_button.dart';
import 'package:ay_bay_app/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          /// 🌈 Premium Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFEAF3FF),
                  Color(0xFFF7FAFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),


          /// 🌐 Language Toggle
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: LanguageToggleButton(),
          ),

          /// 🧊 Premium Glass Card
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                child: Container(
                  width: size.width * 0.9,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 26, vertical: 38),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.45),
                        Colors.white.withValues(alpha: 0.18),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 32,
                        spreadRadius: 6,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Title
                      Text(
                        context.localization.logIn,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'HindSiliguri',
                          color: AppColors.loginTextButtonColor,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        context.localization.logIntoYourAccount,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 34),

                      _buildGlassField(
                        phoneCtrl,
                        context.localization.mobileNumber,
                        false,
                        Icons.phone_outlined,
                      ),

                      const SizedBox(height: 16),

                      _buildGlassField(
                        passCtrl,
                        context.localization.password,
                        true,
                        Icons.lock_outline,
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.forget),
                          child: Text(
                            context.localization.forgetPassword,
                            style: TextStyle(
                              color: AppColors.loginTextButtonColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      /// 🚀 Premium Button
                      Obx(
                            () => SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.login(
                              phone: phoneCtrl.text.trim(),
                              password: passCtrl.text.trim(),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 10,
                              backgroundColor:
                              AppColors.loginTextButtonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : Text(
                              context.localization.submit,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.localization.wantToOpenNewAccount,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          TextButton(
                            onPressed: () =>
                                Get.offAllNamed(AppRoutes.signup),
                            child: Text(
                              context.localization.signUp,
                              style: TextStyle(
                                color: AppColors.loginTextButtonColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🧊 Premium Glass TextField
  Widget _buildGlassField(
      TextEditingController ctrl,
      String label,
      bool obscure,
      IconData icon,
      ) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        labelText: label,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.4),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.loginTextButtonColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.loginTextButtonColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
