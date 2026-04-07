import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:ay_bay_app/core/profile/ui/screens/profile_screen.dart';
import 'package:ay_bay_app/core/settings/controllers/settings_controller.dart';
import 'package:ay_bay_app/core/profile/controllers/user_controller.dart';
import 'package:ay_bay_app/core/settings/ui/screens/change_password_screen.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController controller = Get.find<SettingsController>();
  final HomeController homeController = Get.find<HomeController>();
  final userController = Get.put(UserController());

  SettingsScreen({super.key});

  final List<Color> colorOptions = [
    AppColors.loginTextButtonColor,
    Colors.teal,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.localization.setting,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.loginTextButtonColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        children: [
          _buildSectionTitle('Account'),
          _premiumCard(
            child: ListTile(
              leading: Obx(
                () => CircleAvatar(
                  radius: 26,
                  backgroundImage: userController.avatarUrl.value.isNotEmpty
                      ? NetworkImage(userController.avatarUrl.value)
                      : null,
                  child: userController.avatarUrl.value.isEmpty
                      ? const Icon(Icons.person, size: 28)
                      : null,
                ),
              ),
              title: Obx(
                () => Text(
                  userController.fullName.value.isNotEmpty
                      ? userController.fullName.value
                      : 'Your Name',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              subtitle: Obx(
                () => Text(
                  userController.phoneNumber.value.isNotEmpty
                      ? userController.phoneNumber.value
                      : 'Phone Number',
                ),
              ),
              onTap: () => Get.to(() => ProfileScreen()),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            ),
          ),
          _premiumCard(
            child: ListTile(
              leading: const Icon(Icons.lock, color: Colors.orangeAccent),
              title: Text(context.localization.changePassword),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => Get.to(() => ChangePasswordScreen()),
            ),
          ),

          _buildSectionTitle(context.localization.dataAndBackup),
          _premiumCard(
            child: ListTile(
              leading: const Icon(Icons.backup, color: Colors.blueAccent),
              title: Text(context.localization.backUpData),
              onTap: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  Get.snackbar(
                    context.localization.error,
                    context.localization.pleaseLogInFirst,
                  );
                  return;
                }
                String userId = user.uid;
                await controller.backupData(userId);
              },
            ),
          ),
          _premiumCard(
            child: ListTile(
              leading: const Icon(Icons.restore, color: Colors.greenAccent),
              title: Text(context.localization.restoreData),
              onTap: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  Get.snackbar(
                    context.localization.error,
                    context.localization.pleaseLogInFirst,
                  );
                  return;
                }
                String userId = user.uid;
                await controller.restoreData(userId);
              },
            ),
          ),
          _premiumCard(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(context.localization.clearAllData),
              onTap: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  Get.snackbar(
                    context.localization.error,
                    context.localization.pleaseLogInFirst,
                  );
                  return;
                }
                String _ = user.uid;
                await controller.clearLocalData();
              },
            ),
          ),

          _buildSectionTitle(context.localization.currencyAndBudget),
          Obx(
            () => _premiumCard(
              child: ListTile(
                leading: const Icon(Icons.attach_money, color: Colors.green),
                title: Text(context.localization.defaultCurrency),
                trailing: DropdownButton<String>(
                  value: controller.defaultCurrency.value,
                  items: ['৳', '\$', '€', '₹']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      controller.defaultCurrency.value = val;
                      controller.saveSettings(); // save locally
                    }
                  },
                ),
              ),
            ),
          ),

          _buildSectionTitle(context.localization.notifications),
          Obx(
            () => _premiumCard(
              child: SwitchListTile(
                title: Text(context.localization.enableNotification),
                value: controller.notificationsEnabled.value,
                onChanged: (val) {
                  controller.notificationsEnabled.value = val;
                  controller.saveSettings();
                },
              ),
            ),
          ),

          _buildSectionTitle(context.localization.security),
          Obx(
            () => _premiumCard(
              child: SwitchListTile(
                title: Text(context.localization.enableAppLock),
                value: controller.isAppLockEnabled.value,
                onChanged: (val) {
                  controller.isAppLockEnabled.value = val;
                  if (val) {
                    // পাসওয়ার্ড সেট করার জন্য ডায়ালগ
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 10,
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Set App Lock Password',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                obscureText: true,
                                onChanged: (text) =>
                                    controller.appLockPassword.value = text,
                                decoration: InputDecoration(
                                  hintText: 'Enter password',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF2575FC),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    controller.saveSettings();
                                    Get.back();
                                    Get.snackbar(
                                      'Success',
                                      'App Lock password set',
                                      barBlur: 0,
                                      backgroundColor: Colors.transparent,
                                      snackPosition: SnackPosition.BOTTOM,
                                      titleText: Text(
                                        context.localization.success,
                                        textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                          fontSize: 16,
                                        ),
                                      ),
                                      messageText: Text(
                                        context.localization.appLockPasswordSet,
                                        textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600, // বোল্ড
                                          color: Colors.green, // টেক্স কালার
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: const Color(0xFF2575FC),
                                    elevation: 6,
                                  ),
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    controller.saveSettings();
                    Get.snackbar(
                      context.localization.appLock,
                      context.localization.appLockIsDisabled,
                      barBlur: 0,
                      backgroundColor: Colors.transparent,
                      snackPosition: SnackPosition.BOTTOM,
                      titleText: Text(
                        context.localization.appLock,
                        textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                      messageText: Text(
                        context.localization.appLockIsDisabled,
                        textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
                        style: TextStyle(
                          fontWeight: FontWeight.w600, // বোল্ড
                          color: Colors.green, // টেক্স কালার
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          _buildSectionTitle(context.localization.support),
          _premiumCard(
            child: ListTile(
              leading: const Icon(Icons.feedback, color: Colors.deepPurple),
              title: Text(context.localization.sendFeedback),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {},
            ),
          ),
          _premiumCard(
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blueAccent),
              title: Text(context.localization.appVersion),
              trailing: Text(
                context.localization.versionNumber,
                style: const TextStyle(fontSize: 16),
              ),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _premiumCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
