
import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});


  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final phoneCtrl = TextEditingController();

  final controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('পাসওয়ার্ড পাঠান'),centerTitle: true,),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: Get.height * 0.2),
              Text(
                'পাসওয়ার্ড খুজে পান',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'AbuJMAkkas',
                ),
              ),
              SizedBox(height: 14),
              Text(
                'আপনার ইমেল একাউন্টে পাসওয়ার্ড পাঠান',
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: AppColors.accountTextColor
                ),
              ),
              SizedBox(height: 32),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'মোবাইল নাম্বার'),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => controller.resetPassword(phoneCtrl.text.trim()),
                child: Text(
                  'এগিয়ে যান',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
