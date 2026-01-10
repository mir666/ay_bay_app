import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/core/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    final size = MediaQuery.sizeOf(context);
    final isSmall = size.width < 360;

    final nameController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔹 Profile Photo
            Obx(() => Stack(
              children: [
                CircleAvatar(
                  radius: isSmall ? 50 : 70,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: controller.photoUrl.value.isNotEmpty
                      ? NetworkImage(controller.photoUrl.value)
                      : null,
                  child: controller.photoUrl.value.isEmpty
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: controller.changeProfilePhoto,
                    borderRadius: BorderRadius.circular(30),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.loginTextButtonColor,
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )),

            const SizedBox(height: 20),

            /// 🔹 Name
            Obx(() {
              nameController.text = controller.name.value;
              return TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'নাম',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: controller.updateName,
              );
            }),

            const SizedBox(height: 16),

            /// 🔹 Email (read-only)
            Obx(() => TextField(
              controller: TextEditingController(text: controller.email.value),
              decoration: const InputDecoration(
                labelText: 'মোবাইল নাম্বার',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            )),

            const SizedBox(height: 16),

            /// 🔹 Change Password
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'নতুন পাসওয়ার্ড',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (passwordController.text.isNotEmpty) {
                    controller.changePassword(passwordController.text);
                    passwordController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.loginTextButtonColor,
                  padding:  EdgeInsets.symmetric(horizontal: 40,vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child:  Text('পাসওয়ার্ড পরিবর্তন করুন'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
