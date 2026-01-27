import 'package:ay_bay_app/core/settings/controllers/change_password_contoller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ay_bay_app/app/app_colors.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final controller = Get.find<ChangePasswordController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Change Password',style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.loginTextButtonColor,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// 🔐 Premium Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _premiumField(
                        label: 'Current Password',
                        icon: Icons.lock_outline,
                        obscureRx: controller.showCurrent,
                        onChanged: (v) =>
                        controller.currentPassword.value = v,
                      ),
                      SizedBox(height: 8),

                      _premiumField(
                        label: 'New Password',
                        icon: Icons.lock,
                        obscureRx: controller.showNew,
                        onChanged: (v) =>
                        controller.newPassword.value = v,
                      ),
                      SizedBox(height: 8),

                      _premiumField(
                        label: 'Confirm New Password',
                        icon: Icons.lock,
                        obscureRx: controller.showConfirm,
                        onChanged: (v) =>
                        controller.confirmPassword.value = v,
                      ),
                      const SizedBox(height: 30),

                      /// 🔘 Premium Button
                      Obx(
                            () => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              backgroundColor:
                              AppColors.loginTextButtonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.changePassword,
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : const Text(
                              'Update Password',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
          prefixIcon: Icon(icon,color: Colors.grey,),
          suffixIcon: IconButton(
            icon: Icon(
              obscureRx.value ? Icons.visibility_off : Icons.visibility, color: Colors.grey,
            ),
            onPressed: () => obscureRx.toggle(),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
