
import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: Get.height * 0.2),
              Text(
                'লগ ইন',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'AbuJMAkkas',
                ),
              ),
              SizedBox(height: 14),
              Text(
                'আপনার একাউন্টে ঢুকুন আর হিসাব রাখুন আপনার টাকার, থাকুন চিন্তা মুক্ত ।',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: AppColors.accountTextColor
                ),
              ),
              SizedBox(height: 32),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'মোবাইল নাম্বার'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: 'পাসওয়ার্ড'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.forget),
                    child: Text(
                      'পাসওয়ার্ড ভুলে গেছেন?',
                      style: TextStyle(color: AppColors.loginTextButtonColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.login(
                          phone: phoneCtrl.text.trim(),
                          password: passCtrl.text.trim(),
                        ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : Text(
                          'এগিয়ে যান',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'নতুন একাউন্ট খুলতে চান?',
                    style: TextStyle(color: AppColors.accountTextColor),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.signup);
                    },
                    child: Text(
                      'সাইন আপ',
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
    );
  }
}
