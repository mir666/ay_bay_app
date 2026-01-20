
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ay_bay_app/core/settings/controllers/user_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final HomeController homeController = Get.find<HomeController>();
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('প্রোফাইল'), centerTitle: true),
      body: Obx(() {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ======================
              // 🔹 হেডার: নাম + ফোন
              // ======================
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.03,
                  horizontal: size.width * 0.04,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: size.width * 0.12,
                      backgroundImage: userController.avatarUrl.value.isNotEmpty
                          ? NetworkImage(userController.avatarUrl.value)
                          : null,
                      child: userController.avatarUrl.value.isEmpty
                          ? Text(
                              userController.fullName.value.isNotEmpty
                                  ? userController.fullName.value[0]
                                  : '?',
                              style: TextStyle(
                                fontSize: size.width * 0.12,
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
                              fontSize: size.width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: size.height * 0.008),
                          Text(
                            userController.phoneNumber.value.isNotEmpty
                                ? userController.phoneNumber.value
                                : 'Phone Number',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: size.width * 0.035,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // ======================
              // 🔹 মাসের হরিজন্টাল লিস্ট
              // ======================
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: homeController.months.length,
                  itemBuilder: (context, index) {
                    final month = homeController.months[index];
                    final isSelected =
                        month['id'] == homeController.selectedMonthId.value;

                    return GestureDetector(
                      onTap: () => homeController.selectMonth(month),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blueAccent
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            month['month'] ?? '',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: size.height * 0.03),

              // ======================
              // 🔹 আয় (Income) বার চার্ট
              // ======================
              SizedBox(
                height: size.height * 0.4,
                child: homeController.allTransactions.isEmpty
                    ? const Center(
                        child: Text(
                          'এই মাসের কোনো লেনদেন নেই',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        shadowColor: Colors.grey.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: BarChart(
                            BarChartData(
                              maxY: (homeController.income.value + 500),
                              alignment: BarChartAlignment.spaceAround,
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                          if (value.toInt() == 0) {
                                            return const Padding(
                                              padding: EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                'আয়',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
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
                              ),
                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                      toY: homeController.income.value,
                                      width: 40,
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.greenAccent.shade100,
                                          Colors.green,
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.withOpacity(0.2),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              barTouchData: BarTouchData(
                                enabled: true,
                                handleBuiltInTouches: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                        return BarTooltipItem(
                                          '+${homeController.income.value.toInt()}৳',
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
              ),
            ],
          ),
        );
      }),
    );
  }
}
