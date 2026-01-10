import 'package:ay_bay_app/core/settings/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());
    final size = MediaQuery.sizeOf(context);
    final isSmall = size.width < 360;

    return Scaffold(
      appBar: AppBar(
        title: const Text('সেটিংস'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// 🔹 Profile Info
              Obx(() => Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(
                    controller.name.value,
                    style: TextStyle(
                        fontSize: isSmall ? 14 : 16,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    controller.email.value,
                    style: TextStyle(fontSize: isSmall ? 12 : 14),
                  ),
                ),
              )),

              const SizedBox(height: 24),

              /// 🔹 Dark Mode Toggle
              Obx(() => SwitchListTile(
                value: controller.darkMode.value,
                title: const Text('Dark Mode'),
                secondary: const Icon(Icons.dark_mode),
                onChanged: controller.toggleDarkMode,
              )),

              /// 🔹 Notifications Toggle
              Obx(() => SwitchListTile(
                value: controller.notifications.value,
                title: const Text('Notifications'),
                secondary: const Icon(Icons.notifications_active),
                onChanged: controller.toggleNotifications,
              )),

              const SizedBox(height: 32),

              /// 🔹 Sign Out Button
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: TextStyle(
                      fontSize: isSmall ? 14 : 16,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Sign Out',
                    middleText: 'Are you sure you want to sign out?',
                    textConfirm: 'Yes',
                    textCancel: 'No',
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.red,
                    onConfirm: controller.signOut,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
