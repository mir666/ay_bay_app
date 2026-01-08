
import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: Get.height * 0.2),
              Text(
                'নতুন একাউন্ট খুলুন',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'AbuJMAkkas',
                ),
              ),
              SizedBox(height: 18),
              Text(
                'নতুন একাউন্ট খুলুন আর হিসাব রাখুন আপনার টাকার ।থাকুন চিন্তা মুক্ত ।',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: AppColors.accountTextColor,
                ),
              ),
              SizedBox(height: 32),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'নাম'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'মোবাইল নাম্বার'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'পাসওয়ার্ড'),
              ),
              const SizedBox(height: 48),

              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.signUp(
                          name: nameCtrl.text.trim(),
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

              SizedBox(height: 48),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'একাউন্ট আছে?',
                    style: TextStyle(color: AppColors.accountTextColor),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.login);
                    },
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
    );
  }
}
