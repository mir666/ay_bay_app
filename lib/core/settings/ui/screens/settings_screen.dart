import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_config.dart';
import 'package:ay_bay_app/core/controllers/theme_controller.dart';
import 'package:ay_bay_app/core/profile/ui/screens/profile_screen.dart';
import 'package:ay_bay_app/core/settings/controllers/settings_controller.dart';
import 'package:ay_bay_app/core/profile/controllers/user_controller.dart';
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
      appBar: AppBar(title: Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildSectionTitle('Account'),
          ListTile(
            leading: Obx(() => CircleAvatar(
              backgroundImage: userController.avatarUrl.value.isNotEmpty
                  ? NetworkImage(userController.avatarUrl.value)
                  : null,
              child: userController.avatarUrl.value.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            )),
            title: Obx(() => Text(
              userController.fullName.value.isNotEmpty
                  ? userController.fullName.value
                  : 'Your Name',
            )),
            subtitle: Obx(() => Text(
              userController.phoneNumber.value.isNotEmpty
                  ? userController.phoneNumber.value
                  : 'Phone Number',
            )),
            onTap: () {
              Get.to(() =>  ProfileScreen());
            },
          ),

          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              homeController.logout();
            },
          ),

          _buildSectionTitle('Data & Backup'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            onTap: () async {
              // userId আসলে Firebase Auth থেকে নিতে হবে
              String userId = 'USER_ID'; // FirebaseAuth.instance.currentUser!.uid;
              await controller.backupData(userId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Data'),
            onTap: () async {
              String userId = 'USER_ID'; // FirebaseAuth.instance.currentUser!.uid;
              await controller.restoreData(userId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Clear All Data'),
            onTap: () async {
              await controller.clearLocalData();
            },
          ),

          _buildSectionTitle('Currency & Budget'),
          Obx(
            () => ListTile(
              leading: const Icon(Icons.attach_money),
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
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Month Start Date'),
            onTap: () {},
          ),

          _buildSectionTitle('Notifications'),
          Obx(
            () => SwitchListTile(
              title: const Text('Enable Notifications'),
              value: controller.notificationsEnabled.value,
              onChanged: (val) {
                controller.notificationsEnabled.value = val;
                controller.saveSettings();
              },
            ),
          ),

          _buildSectionTitle('Appearance'),
          Obx(() => SwitchListTile(
              title: const Text('Dark Mode'),
              value: themeController.isDarkMode.value,
              onChanged: (val) async {
                await themeController.toggleTheme();
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildSectionTitle('Accent Color'),
          Obx(
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

          _buildSectionTitle('Security'),
          Obx(() => SwitchListTile(
            title: const Text('Enable App Lock'),
            value: controller.isAppLockEnabled.value,
            onChanged: (val) {
              controller.isAppLockEnabled.value = val;
              controller.saveSettings();

              if (val) {
                Get.snackbar('App Lock', 'App Lock is enabled');
              } else {
                Get.snackbar('App Lock', 'App Lock is disabled');
              }
            },
          )),


          _buildSectionTitle('Support'),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Send Feedback'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Version'),
            trailing: Text(AppConfig.currentAppVersion,style: TextStyle(fontSize: 16),),
            onTap: () {},
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
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
