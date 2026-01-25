import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_config.dart';
import 'package:ay_bay_app/core/controllers/theme_controller.dart';
import 'package:ay_bay_app/core/profile/ui/screens/profile_screen.dart';
import 'package:ay_bay_app/core/settings/controllers/settings_controller.dart';
import 'package:ay_bay_app/core/profile/controllers/user_controller.dart';
import 'package:ay_bay_app/core/settings/ui/screens/change_password_screen.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());
  final ThemeController themeController = Get.put(ThemeController());
  final HomeController homeController = Get.put(HomeController());
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
      backgroundColor: themeController.isDarkMode.value
          ? Colors.grey.shade900
          : Colors.grey.shade200,
      appBar: AppBar(
        title: const Text('Settings'),
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
              leading: Obx(() => CircleAvatar(
                radius: 26,
                backgroundImage: userController.avatarUrl.value.isNotEmpty
                    ? NetworkImage(userController.avatarUrl.value)
                    : null,
                child: userController.avatarUrl.value.isEmpty
                    ? const Icon(Icons.person, size: 28)
                    : null,
              )),
              title: Obx(() => Text(
                userController.fullName.value.isNotEmpty
                    ? userController.fullName.value
                    : 'Your Name',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
              subtitle: Obx(() => Text(
                userController.phoneNumber.value.isNotEmpty
                    ? userController.phoneNumber.value
                    : 'Phone Number',
              )),
              onTap: () => Get.to(() => ProfileScreen()),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            ),
          ),
          _premiumCard(
            child: ListTile(
              leading: const Icon(Icons.lock, color: Colors.orangeAccent),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => Get.to(() => ChangePasswordScreen()),
            ),
          ),
          _premiumCard(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => homeController.logout(),
            ),
          ),

          _buildSectionTitle('Data & Backup'),
          _premiumCard(
            child: ListTile(
              leading: const Icon(Icons.backup, color: Colors.blueAccent),
              title: const Text('Backup Data'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () async {
                String userId = 'USER_ID';
                await controller.backupData(userId);
              },
            ),
          ),
          _premiumCard(
            child: ListTile(
              leading: const Icon(Icons.restore, color: Colors.greenAccent),
              title: const Text('Restore Data'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () async {
                String userId = 'USER_ID';
                await controller.restoreData(userId);
              },
            ),
          ),
          _premiumCard(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Clear All Data'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () async => await controller.clearLocalData(),
            ),
          ),

          _buildSectionTitle('Currency & Budget'),
          Obx(
                () => _premiumCard(
              child: ListTile(
                leading: const Icon(Icons.attach_money, color: Colors.green),
                title: const Text('Default Currency'),
                trailing: DropdownButton<String>(
                  value: controller.defaultCurrency.value,
                  items: ['৳', '\$', '€', '₹']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    controller.defaultCurrency.value = val!;
                    controller.saveSettings();
                  },
                ),
              ),
            ),
          ),
          _premiumCard(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.orange),
              title: const Text('Month Start Date'),
              onTap: () {},
            ),
          ),

          _buildSectionTitle('Notifications'),
          Obx(
                () => _premiumCard(
              child: SwitchListTile(
                title: const Text('Enable Notifications'),
                value: controller.notificationsEnabled.value,
                onChanged: (val) {
                  controller.notificationsEnabled.value = val;
                  controller.saveSettings();
                },
              ),
            ),
          ),

          _buildSectionTitle('Appearance'),
          Obx(
                () => _premiumCard(
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                value: themeController.isDarkMode.value,
                onChanged: (val) => themeController.toggleTheme(),
              ),
            ),
          ),

          _buildSectionTitle('Accent Color'),
          _premiumCard(
            child: Obx(
                  () => Wrap(
                spacing: 12,
                children: colorOptions
                    .map(
                      (color) => GestureDetector(
                    onTap: () => themeController.changePrimaryColor(color),
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 20,
                      child: themeController.primaryColor.value == color
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
          ),

          _buildSectionTitle('Security'),
          Obx(
                () => _premiumCard(
              child: SwitchListTile(
                title: const Text('Enable App Lock'),
                value: controller.isAppLockEnabled.value,
                onChanged: (val) {
                  controller.isAppLockEnabled.value = val;
                  controller.saveSettings();
                  Get.snackbar(
                    'App Lock',
                    val ? 'App Lock is enabled' : 'App Lock is disabled',
                  );
                },
              ),
            ),
          ),

          _buildSectionTitle('Support'),
          _premiumCard(
            child: ListTile(
              leading: const Icon(Icons.feedback, color: Colors.deepPurple),
              title: const Text('Send Feedback'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {},
            ),
          ),
          _premiumCard(
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blueAccent),
              title: const Text('App Version'),
              trailing: Text(AppConfig.currentAppVersion,
                  style: const TextStyle(fontSize: 16)),
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
            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
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
          )
        ],
      ),
      child: child,
    );
  }
}
