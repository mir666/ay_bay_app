import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:ay_bay_app/core/extension/transaction_category_localization.dart';
import 'package:ay_bay_app/core/utils/number_util.dart';
import 'package:ay_bay_app/features/common/data/category_data.dart';
import 'package:ay_bay_app/features/common/models/category_model.dart';
import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ay_bay_app/core/profile/controllers/user_controller.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final HomeController homeController = Get.find<HomeController>();
  final UserController userController = Get.find<UserController>();

  String localizedMonthName(String? monthName) {
    if (monthName == null || monthName.isEmpty) return '';

    try {
      // English month → month number
      final monthNumber =
          DateFormat('MMMM', 'en').parse(monthName).month;

      // Create date using current year
      final date = DateTime(DateTime.now().year, monthNumber);

      // Return localized month name
      return DateFormat.MMMM(
        Get.locale?.languageCode ?? 'en',
      ).format(date);
    } catch (e) {
      return monthName; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final _ =
        MediaQuery.of(context).orientation == Orientation.landscape;


    return Scaffold(
      appBar: AppBar(
        title: Text(context.localization.profile, style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.loginTextButtonColor,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(context,size),

              SizedBox(height: size.height * 0.02),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: context.localization.transactions,
                        value: localizedNumber(homeController.allTransactions.length),
                        icon: Icons.swap_horiz,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: context.localization.income,
                        value: localizedNumber(homeController.income.value),
                        icon: Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: context.localization.expense,
                        value: localizedNumber(homeController.expense.value),
                        icon: Icons.trending_down,
                      ),
                    ),
                  ],
                ),
              ),


              SizedBox(height: size.height * 0.035),
              _buildCategoryColorLegend(),

              SizedBox(height: size.height * 0.04),

              _buildMonthList(),

              SizedBox(height: size.height * 0.08),

              _buildIncomeBarChart(context,size),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(BuildContext context,Size size) {
    DateTime? firstTransactionDate;
    if (homeController.allTransactions.isNotEmpty) {
      firstTransactionDate = homeController.allTransactions
          .map((e) => e.date) // ধরছি transaction এ date ফিল্ড আছে
          .reduce((a, b) => a.isBefore(b) ? a : b);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.035,
        horizontal: size.width * 0.04,
      ),
      decoration: const BoxDecoration(
        color: AppColors.loginTextButtonColor,
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
          // Avatar
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

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
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

                // Phone
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

                SizedBox(height: size.height * 0.007),

                // Member Since (সব ইউজারের জন্য)
                if (userController.createdAt.value != null)
                  Text(
                    '${context.localization.accountOpen} ${localizedNumber(userController.createdAt.value!.day)}/${localizedNumber(userController.createdAt.value!.month)}/${localizedNumber(userController.createdAt.value!.year)}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: size.width * 0.035,
                    ),
                  ),

                // Transactions Since (শুধু প্রিমিয়ামের জন্য)
                if (userController.isPremium.value && firstTransactionDate != null)
                  Text(
                    'Transactions since: ${firstTransactionDate.day}/${firstTransactionDate.month}/${firstTransactionDate.year}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: size.width * 0.035,
                    ),
                  ),
              ],
            ),
          ),

          // Edit Button
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
                      color: Colors.blueAccent.withValues(alpha: 0.4),
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
                    localizedMonthName(month['month']),
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
  Widget _buildIncomeBarChart(BuildContext context, Size size) {
    if (homeController.allTransactions.isEmpty) {
      return SizedBox(
        height: size.height * 0.4,
        child: Center(
          child: Text(
            context.localization.noTransactionThisMonth,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    /// 🔹 Category-wise Income
    final Map<String, double> categoryIncome = {};

    for (var trx in homeController.allTransactions) {
      if (trx.type == TransactionType.income) {
        categoryIncome[trx.category] =
            (categoryIncome[trx.category] ?? 0) + trx.amount;
      }
    }

    if (categoryIncome.isEmpty) {
      return const SizedBox.shrink();
    }

    final categories = categoryIncome.keys.toList();
    final amounts = categoryIncome.values.toList();
    final maxY = amounts.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: size.height * 0.4,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        shadowColor: Colors.grey.withValues(alpha: 0.3),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              maxY: maxY * 1.2,
              alignment: BarChartAlignment.spaceAround,
              borderData: FlBorderData(show: false),

              /// 🔹 Grid
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.2),
                  strokeWidth: 1,
                ),
              ),

              /// 🔹 Titles
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: maxY / 4,
                  ),
                ),
                rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),

                /// 🔻 Bottom: ONLY COLOR DOT
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= categories.length) {
                        return const SizedBox.shrink();
                      }

                      final category = categories[value.toInt()];
                      final color = getCategoryColor(category);

                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              /// 🔹 Bars
              barGroups: categoryIncome.entries
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final data = entry.value;
                final barColor = getCategoryColor(data.key);

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data.value,
                      width: 22,
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          barColor.withValues(alpha: 0.4),
                          barColor,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ],
                );
              }).toList(),

              /// 🔹 Tooltip (name থাকবে)
              barTouchData: BarTouchData(
                enabled: true,
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

  Color getCategoryColor(String name) {
    final allCategories = [...incomeCategories, ...expenseCategories];
    return allCategories
        .firstWhere(
          (cat) => cat.name == name,
      orElse: () =>
          CategoryModel(name: name, iconId: 0, color: Colors.grey),
    )
        .color;
  }

  Widget _buildCategoryColorLegend() {
    final allCategories = [...incomeCategories];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = allCategories[index];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: category.color.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔵 Color Dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: category.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),

                // 📝 Category Name
                Text(
                  category.name.localizedName(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: category.color,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isPressed = false.obs;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Responsive sizing
        final iconSize = width * 0.22; // ~28–32
        final valueSize = width * 0.18; // ~16–18
        final titleSize = width * 0.13; // ~12–14

        return Obx(() {
          return GestureDetector(
            onTapDown: (_) => isPressed.value = true,
            onTapUp: (_) => isPressed.value = false,
            onTapCancel: () => isPressed.value = false,
            child: AnimatedScale(
              scale: isPressed.value ? 0.96 : 1,
              duration: const Duration(milliseconds: 120),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: isPressed.value ? 8 : 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(width * 0.08),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: iconSize),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      value,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: valueSize,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: titleSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }




}