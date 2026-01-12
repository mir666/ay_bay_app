import 'package:ay_bay_app/core/analysis/controllers/analysis_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnalysisScreen extends StatelessWidget {
  AnalysisScreen({super.key});

  final AnalysisController controller = Get.put(AnalysisController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Analysis')),
      body: SafeArea(
        child: Obx(
              () => controller.monthsList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              // 🔹 Bar Chart for all months
              SizedBox(
                height: height * 0.25,
                child: Obx(() {
                  if (controller.monthsList.isEmpty) return const SizedBox.shrink();

                  double maxY = controller.monthsList
                      .map((m) => (m['totalBalance'] ?? 0).toDouble())
                      .fold(0.0, (prev, e) => e > prev ? e : prev);

                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY * 1.2,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              int index = value.toInt();
                              if (index < 0 || index >= controller.monthsList.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  controller.monthsList[index]['month'],
                                  style: TextStyle(
                                    fontSize: width * 0.025,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 42,
                          ),
                        ),

                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(controller.monthsList.length, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: (controller.monthsList[index]['totalBalance'] ?? 0).toDouble(),
                              color: Colors.redAccent,
                              width: width * 0.02,
                            ),
                          ],
                        );
                      }),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // 🔹 Months Horizontal List
              SizedBox(
                height: height * 0.1,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.monthsList.length,
                  itemBuilder: (context, index) {
                    final month = controller.monthsList[index];
                    final isSelected = controller.selectedMonthId.value == month['id'];
                    return GestureDetector(
                      onTap: () => controller.selectMonth(month['id']),
                      child: Container(
                        margin: EdgeInsets.all(width * 0.02),
                        padding: EdgeInsets.symmetric(
                            vertical: height * 0.015, horizontal: width * 0.05),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            month['month'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: width * 0.04,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Analysis Section
              Expanded(
                child: controller.selectedMonthId.value.isEmpty
                    ? const Center(
                    child: Text('মাস নির্বাচন করুন', style: TextStyle(fontSize: 18)))
                    : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 0.05, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Selected Month Name
                      Text(
                        controller.selectedMonthName.value,
                        style: TextStyle(
                            fontSize: width * 0.06, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: height * 0.03),

                      // 🔹 Cards Row: Income, Expense, Balance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCard('Income', controller.income.value, Colors.green,
                              width, height),
                          _buildCard('Expense', controller.expense.value, Colors.red,
                              width, height),
                          _buildCard('Balance', controller.balance.value, Colors.blue,
                              width, height),
                        ],
                      ),

                      SizedBox(height: height * 0.03),

                      // 🔹 Pie Chart for category-wise analysis
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category-wise Analysis',
                            style: TextStyle(
                                fontSize: width * 0.045, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: height * 0.02),
                          Obx(() {
                            if (controller.categoryData.isEmpty) {
                              return const Center(
                                  child: Text('এই মাসে কোন লেনদেন নেই'));
                            }

                            List<PieChartSectionData> sections = [];

                            for (var cat in controller.categoryData) {
                              if ((cat['income'] ?? 0) > 0) {
                                sections.add(PieChartSectionData(
                                  value: cat['income'].toDouble(),
                                  title: cat['name'],
                                  color: Colors.green,
                                  radius: width * 0.15,
                                  titleStyle: TextStyle(
                                      fontSize: width * 0.03,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ));
                              }
                              if ((cat['expense'] ?? 0) > 0) {
                                sections.add(PieChartSectionData(
                                  value: cat['expense'].toDouble(),
                                  title: cat['name'],
                                  color: Colors.red,
                                  radius: width * 0.15,
                                  titleStyle: TextStyle(
                                      fontSize: width * 0.03,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ));
                              }
                            }

                            return SizedBox(
                              height: height * 0.35,
                              child: PieChart(
                                PieChartData(
                                  sections: sections,
                                  centerSpaceRadius: width * 0.08,
                                  sectionsSpace: 2,
                                ),
                              ),
                            );
                          }),
                        ],
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

  Widget _buildCard(String title, double amount, Color color, double w, double h) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(w * 0.04),
        width: w * 0.27,
        height: h * 0.15,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: w * 0.035)),
            SizedBox(height: h * 0.015),
            Text('$amount', style: TextStyle(fontSize: w * 0.04)),
          ],
        ),
      ),
    );
  }
}
