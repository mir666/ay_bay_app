
import 'package:ay_bay_app/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.only(top: 5),
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.monthAddButtonColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.bannerBottomColor,
                  style: BorderStyle.solid,
                ),
              ),
              child: _item(
                'আয়',
                controller.income.value,
                Colors.greenAccent,
                Icons.trending_up, // 📈 like icon
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.only(top: 5),
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.monthAddButtonColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.bannerBottomColor,
                  style: BorderStyle.solid,
                ),
              ),
              child: _item(
                'ব্যয়',
                controller.expense.value,
                Colors.redAccent,
                Icons.trending_down, // 📉 like icon
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _item(String title, double value, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(0)} ৳',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
