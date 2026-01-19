import 'package:ay_bay_app/core/settings/controllers/user_controller.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final UserController userController = Get.put(UserController());
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.00),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ✅ Profile Header
              Obx(() => Container(
                color: Colors.blue,
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.03,
                  horizontal: size.width * 0.04,
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
                            fontWeight: FontWeight.bold),
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
                                fontWeight: FontWeight.bold),
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
              )),

              SizedBox(height: size.height * 0.15),

              // ✅ BarChart Section
              Obx(() {
                final incomeTransactions = homeController.transactions
                    .where((trx) => trx.type.name == 'income')
                    .toList();

                if (incomeTransactions.isEmpty) {
                  return const Center(child: Text('কোনো আয় পাওয়া যায়নি'));
                }

                // BarGroups
                List<BarChartGroupData> barGroups = [];
                for (int i = 0; i < incomeTransactions.length; i++) {
                  final trx = incomeTransactions[i];
                  barGroups.add(
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: trx.amount.toDouble(),
                          width: size.width * 0.02,
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: [Colors.greenAccent, Colors.green],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                  );
                }

                double maxY = incomeTransactions
                    .map((e) => e.amount)
                    .reduce((a, b) => a > b ? a : b)
                    .toDouble() +
                    500;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: (incomeTransactions.length * size.width * 0.15)
                        .clamp(size.width, double.infinity),
                    child: AspectRatio(
                      aspectRatio: 1.2, // Height auto-adjust
                      child: BarChart(
                        BarChartData(
                          maxY: maxY,
                          barGroups: barGroups,
                          alignment: BarChartAlignment.spaceAround,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index < 0 ||
                                      index >= incomeTransactions.length) {
                                    return const SizedBox();
                                  }
                                  final trx = incomeTransactions[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      trx.category,
                                      style: TextStyle(
                                        fontSize: size.width * 0.025,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: maxY / 5,
                                reservedSize: 40,
                              ),
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: maxY / 5,
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final trx = incomeTransactions[group.x.toInt()];
                                return BarTooltipItem(
                                  '${trx.category}\n+${trx.amount.toInt()}৳',
                                  const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
