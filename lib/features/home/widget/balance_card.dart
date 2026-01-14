import 'dart:ui';
import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:ay_bay_app/features/home/widget/app_drawer.dart';
import 'package:ay_bay_app/features/home/widget/search_highlite_text.dart';
import 'package:ay_bay_app/features/home/widget/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:side_sheet/side_sheet.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final size = MediaQuery.sizeOf(context);

    return Obx(() {
      return Stack(
        children: [
          /// 🔹 MAIN CARD
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: size.height * 0.03,
              bottom: size.height * 0.015,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2C59), Color(0xFF1E4FA1)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.bannerShadowColor,
                  blurRadius: 12,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                /// 🔹 Top Row (Menu + Search)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 🔹 Profile Button
                      CircleAvatar(
                        backgroundColor: AppColors.monthAddButtonColor,
                        child: IconButton(
                          onPressed: () async {
                            await SideSheet.left(
                              context: context,
                              body: SafeArea(
                                child: AppDrawer(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.person_2_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // 🔹 Search Button
                      IconButton(
                        icon: Icon(
                          controller.isSearching.value
                              ? Icons.close
                              : Icons.search_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          controller.isSearching.value
                              ? controller.closeSearch()
                              : controller.isSearching.value = true;
                        },
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 12),

                /// 🔹 Month Selector Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous Month
                      ElevatedButton(
                        onPressed: controller.goToPreviousMonth,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          backgroundColor: AppColors.categoryTitleBgColor
                              .withValues(alpha: 0.2),
                          elevation: 2,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),

                      // Month Dropdown
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppColors.categoryTitleBgColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Obx(() {
                            final today = controller.todayDate.value;

                            // ✅ Check: selectedMonth must exist in months list
                            final safeSelectedMonth =
                                controller.months.any(
                                  (m) =>
                                      m['month'] ==
                                      controller.selectedMonth.value,
                                )
                                ? controller.selectedMonth.value
                                : null;

                            return DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: safeSelectedMonth,
                                hint: Text(
                                  safeSelectedMonth == null
                                      ? 'মাস'
                                      : '$safeSelectedMonth (${DateFormat('dd MMM').format(today)})',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                icon: Obx(
                                  () => Icon(
                                    controller.isMonthDropdownOpen.value
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                ),
                                dropdownColor: const Color(0xFF0F2C59),
                                items: [
                                  ...controller.months.map((m) {
                                    return DropdownMenuItem<String>(
                                      value: m['month'],
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            m['month'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('dd MMM').format(today),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const DropdownMenuItem<String>(
                                    enabled: false,
                                    child: Divider(color: Colors.white),
                                  ),
                                  DropdownMenuItem<String>(
                                    enabled: false,
                                    child: TextButton.icon(
                                      onPressed: () async {
                                        final result = await Get.toNamed(
                                          AppRoutes.addMonth,
                                        );
                                        if (result != null &&
                                            result is Map<String, dynamic>) {
                                          controller.selectMonth(result);

                                          // 🔹 নতুন মাস add করার পরে dropdown close
                                          controller.isMonthDropdownOpen.value =
                                              false;
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'নতুন মাস খুলুন',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (monthName) {
                                  if (monthName == null) return;
                                  final month = controller.months.firstWhere(
                                    (m) => m['month'] == monthName,
                                  );
                                  controller.selectMonth(month);

                                  // 🔹 মাস select করার পরে dropdown close
                                  controller.isMonthDropdownOpen.value = false;
                                },
                                onTap: () {
                                  // 🔹 tap করলে dropdown toggle হবে
                                  controller.isMonthDropdownOpen.value =
                                      !controller.isMonthDropdownOpen.value;
                                },
                              ),
                            );
                          }),
                        ),
                      ),

                      // Next Month
                      ElevatedButton(
                        onPressed: controller.goToNextMonth,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          backgroundColor: AppColors.categoryTitleBgColor
                              .withValues(alpha: 0.2),
                          elevation: 2,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Dashboard Summary
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.monthAddButtonColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.bannerBottomColor,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      /// 🟢 LEFT SIDE — মোট বাজেট
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.addMonth,
                              arguments: 'UPDATE_BUDGET',
                            );
                          },
                          child: Column(
                            children: [
                              const Text(
                                'মোট বাজেট',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  '${controller.totalBalance.value.toInt()} ৳',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// 🔹 DIVIDER
                      Container(
                        height: 50,
                        width: 1,
                        color: AppColors.addButtonColor.withValues(alpha: 0.3),
                      ),

                      /// 🟢 RIGHT SIDE — ব্যালেন্স
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'ব্যালেন্স',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Obx(
                              () => Text(
                                '${controller.balance.value.toInt()} ৳',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SummaryCard(),
              ],
            ),
          ),

          /// 🌫️ BLUR + DIM
          if (controller.isSearching.value)
            Positioned.fill(
              child: GestureDetector(
                onTap: controller.closeSearch,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(color: Colors.black.withValues(alpha: 0.35)),
                ),
              ),
            ),

          /// 🔍 FLOATING SEARCH PANEL
          Obx(() {
            if (!controller.isSearching.value) return SizedBox();

            return Positioned(
              top: 80,
              left: 12,
              right: 12,
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 400, // পুরো suggestions area scrollable
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Search Bar
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            autofocus: true,
                            onChanged: controller.searchTransaction,
                            decoration: const InputDecoration(
                              hintText: 'মাস, লেনদেন বা তারিখ খুঁজুন...',
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        /// Month Suggestions
                        if (controller.monthSuggestions.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                child: Text(
                                  'মাস',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.monthSuggestions.length,
                                itemBuilder: (context, index) {
                                  final m = controller.monthSuggestions[index];
                                  return ListTile(
                                    leading: const Icon(Icons.calendar_month),
                                    title: searchHighlightText(
                                      m['month'],
                                      controller.searchText.value,
                                      highlightColor: Colors.deepPurple,
                                    ),
                                    onTap: () =>
                                        controller.selectMonthFromSearch(m),
                                  );
                                },
                              ),
                              const Divider(height: 1),
                            ],
                          ),

                        /// Transaction Suggestions
                        if (controller.suggestions.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: controller.suggestions.length,
                            itemBuilder: (context, index) {
                              final trx = controller.suggestions[index];
                              return ListTile(
                                leading: Icon(
                                  trx.type == TransactionType.income
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: trx.type == TransactionType.income
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                title: searchHighlightText(
                                  trx.title,
                                  controller.searchText.value,
                                  highlightColor:
                                      trx.type == TransactionType.income
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                subtitle: Text(
                                  DateFormat('dd MMM yyyy').format(trx.date),
                                ),
                                trailing: Text('৳ ${trx.amount}'),
                                onTap: () {
                                  controller.selectSuggestion(trx);
                                  controller.closeSearch();
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}
