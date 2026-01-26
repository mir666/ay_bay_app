import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ay_bay_app/core/profile/controllers/user_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final HomeController homeController = Get.find<HomeController>();
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('প্রোফাইল', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.loginTextButtonColor,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(size),

              SizedBox(height: size.height * 0.02),

              _buildMonthList(),

              SizedBox(height: size.height * 0.08),

              _buildIncomeBarChart(size),
            ],
          ),
        );
      }),
    );
  }

  /// 🔹 প্রোফাইল হেডার
  Widget _buildProfileHeader(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.035,
        horizontal: size.width * 0.04,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bannerBottomColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.categoryShadowColor,
            offset: Offset(0, 3),
            blurRadius: 24,
            blurStyle: BlurStyle.inner,
          ),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: size.width * 0.09,
            backgroundColor: Colors.blueGrey.withValues(alpha: 0.3),
            backgroundImage: userController.avatarUrl.value.isNotEmpty
                ? NetworkImage(userController.avatarUrl.value)
                : null,
            child: userController.avatarUrl.value.isEmpty
                ? Text(
                    userController.fullName.value.isNotEmpty
                        ? userController.fullName.value[0]
                        : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.085,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userController.fullName.value.isNotEmpty
                      ? userController.fullName.value
                      : 'Your Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: size.height * 0.007),
                Text(
                  userController.phoneNumber.value.isNotEmpty
                      ? userController.phoneNumber.value
                      : 'Phone Number',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: size.width * 0.040,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: () => _showEditProfileDialog(),
              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(
      text: userController.fullName.value,
    );
    final phoneController = TextEditingController(
      text: userController.phoneNumber.value,
    );

    RxBool hasChanged = false.obs;

    // Detect changes
    nameController.addListener(() {
      hasChanged.value =
          nameController.text.trim() != userController.fullName.value ||
          phoneController.text.trim() != userController.phoneNumber.value;
    });
    phoneController.addListener(() {
      hasChanged.value =
          nameController.text.trim() != userController.fullName.value ||
          phoneController.text.trim() != userController.phoneNumber.value;
    });

    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: Get.width * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Edit Profile',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blueAccent,
                        ),
                        labelText: 'Full Name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Colors.green,
                        ),
                        labelText: 'Phone Number',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.green,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Buttons
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Cancel
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Save
                        // Save Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: hasChanged.value
                                ? () async {
                                    final newName = nameController.text.trim();
                                    final newPhone = phoneController.text
                                        .trim();

                                    if (newName.isEmpty || newPhone.isEmpty) {
                                      Get.snackbar(
                                        'Error',
                                        'Name & Phone cannot be empty',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                      return;
                                    }

                                    try {
                                      await userController.updateProfile(
                                        name: newName,
                                        phone: newPhone,
                                      );
                                      if (Get.isDialogOpen!) Get.back();
                                    } catch (e) {
                                      Get.snackbar(
                                        'Error',
                                        e.toString(),
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // সবসময় সবুজ
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// 🔹 মাসের হরিজন্টাল লিস্ট
  Widget _buildMonthList() {
    return SizedBox(
      height: 50,
      child: Obx(() {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: homeController.months.length,
          itemBuilder: (context, index) {
            final month = homeController.months[index];
            final isSelected =
                month['id'] == homeController.selectedMonthId.value;

            return GestureDetector(
              onTap: () => homeController.selectMonth(month),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(
                  left: index == 0 ? 16 : 10, // প্রথম বাটনের জন্য বাম margin
                  right: 10, // বাকি বাটনের জন্য right margin
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade200, Colors.grey.shade300],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    month['month'] ?? '',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  /// 🔹 আয় (Income) বার চার্ট
  Widget _buildIncomeBarChart(Size size) {
    if (homeController.allTransactions.isEmpty) {
      return SizedBox(
        height: size.height * 0.4,
        child: const Center(
          child: Text(
            'এই মাসের কোনো লেনদেন নেই',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    // ===== Category-wise income
    final Map<String, double> categoryIncome = {};
    for (var trx in homeController.allTransactions) {
      if (trx.type == TransactionType.income) {
        categoryIncome[trx.category] =
            (categoryIncome[trx.category] ?? 0) + trx.amount;
      }
    }

    final categories = categoryIncome.keys.toList();
    final amounts = categoryIncome.values.toList();

    return SizedBox(
      height: size.height * 0.4,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        shadowColor: Colors.grey.withValues(alpha: 0.3),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: amounts.isEmpty
                  ? 0
                  : amounts.reduce((a, b) => a > b ? a : b),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.2),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < categories.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            categories[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              barGroups: categoryIncome.entries.toList().asMap().entries.map((
                e,
              ) {
                final index = e.key;
                final entry = e.value;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value,
                      width: 22,
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.greenAccent.shade100, Colors.green],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ],
                );
              }).toList(),
              barTouchData: BarTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final category = categories[group.x.toInt()];
                    final amount = categoryIncome[category]!.toInt();

                    return BarTooltipItem(
                      '$category\n+$amount ৳',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
