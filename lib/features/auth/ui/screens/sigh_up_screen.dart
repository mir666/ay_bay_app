import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          /// 🌈 Premium Gradient Background
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

          /// 🧊 Glass Card
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                child: Container(
                  width: size.width * 0.9,
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 38),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0.15),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 30,
                        spreadRadius: 4,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Title
                      const Text(
                        'নতুন একাউন্ট খুলুন',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'HindSiliguri',
                          color: AppColors.loginTextButtonColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'নতুন একাউন্ট খুলুন আর হিসাব রাখুন আপনার টাকার। থাকুন চিন্তা মুক্ত।',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 32),

                      _buildGlassField(
                        nameCtrl,
                        'নাম',
                        false,
                        Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      _buildGlassField(
                        phoneCtrl,
                        'মোবাইল নাম্বার',
                        false,
                        Icons.phone_outlined,
                      ),

                      const SizedBox(height: 16),

                      _buildGlassField(
                        passCtrl,
                        'পাসওয়ার্ড',
                        true,
                        Icons.lock_outline,
                      ),

                      const SizedBox(height: 36),

                      /// 🚀 Premium Button
                      Obx(
                            () => SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.signUp(
                              name: nameCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                              password: passCtrl.text.trim(),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 8,
                              backgroundColor:
                              AppColors.loginTextButtonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : const Text(
                              'একাউন্ট খুলুন',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'একাউন্ট আছে?',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          TextButton(
                            onPressed: () =>
                                Get.offAllNamed(AppRoutes.login),
                            child: Text(
                              'লগ ইন',
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
        fillColor: Colors.white.withOpacity(0.25),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.loginTextButtonColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.loginTextButtonColor,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}
