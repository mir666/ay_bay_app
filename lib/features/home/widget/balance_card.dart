import 'dart:ui';
import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/core/settings/controllers/settings_controller.dart';
import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:ay_bay_app/features/home/controllers/notification_controller.dart';
import 'package:ay_bay_app/features/home/widget/app_drawer.dart';
import 'package:ay_bay_app/features/home/widget/search_highlite_text.dart';
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

  final settingsController = Get.find<SettingsController>();
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
              top: size.height * 0.01,
              bottom: size.height * 0.010,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              gradient: const LinearGradient(
                colors: [AppColors.bannerTopColor, AppColors.bannerBottomColor],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.bannerShadowColor,
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeaderProfileSection(context, controller),

                const SizedBox(height: 6),

                _buildHomeMonthMenuSection(controller),

                const SizedBox(height: 12),

                // Dashboard Summary
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.monthAddButtonColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.bannerBottomColor,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(children: [_buildCurrentBalance(controller)]),
                ),
              ],
            ),
          ),

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

          _buildSearchBar(controller),
        ],
      );
    });
  }

  Widget _buildSearchBar(HomeController controller) {
    return Obx(() {
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
                              onTap: () => controller.selectMonthFromSearch(m),
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
                            highlightColor: trx.type == TransactionType.income
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
    });
  }

  Widget _buildCurrentBalance(HomeController controller) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.bannerBottomColor,
                style: BorderStyle.solid,
              ),
            ),
            child: Obx(
                  () => Row(
                children: [
                  /// 🔹 TOTAL BUDGET (conditional)
                  if (controller.showTotalBudget.value)
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'মোট বাজেট',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'HindSiliguri',
                                ),
                              ),
                              const SizedBox(width: 6),

                              /// 👁 Toggle Button
                              GestureDetector(
                                onTap: () =>
                                    controller.showTotalBudget.toggle(),
                                child: const Icon(
                                  Icons.visibility_off,
                                  size: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${controller.balance.value.toInt()} ${settingsController.defaultCurrency.value}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                  /// Divider only when budget visible
                  if (controller.showTotalBudget.value)
                    Container(
                      height: 50,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: AppColors.addButtonColor.withValues(alpha: 0.3),
                    ),

                  /// 🔹 BALANCE (auto expand)
                  Expanded(
                    flex: controller.showTotalBudget.value ? 1 : 2,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'ব্যালেন্স',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'HindSiliguri',
                              ),
                            ),

                            /// 👁 Show button when hidden
                            if (!controller.showTotalBudget.value) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () =>
                                    controller.showTotalBudget.toggle(),
                                child: Icon(
                                  Icons.visibility,
                                  size: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${controller.balance.value.toInt()} ${settingsController.defaultCurrency.value}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          ),
          SizedBox(height: 10),
          Obx(() {
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
          }),
        ],
      ),
    );
  }

  Widget _item(String title, double value, Color color, IconData icon) {
    final settingsController = Get.find<SettingsController>();
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'HindSiliguri',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(0)} ${settingsController.defaultCurrency.value}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHomeMonthMenuSection(HomeController controller) {
    return Padding(
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
              backgroundColor: AppColors.categoryTitleBgColor.withValues(
                alpha: 0.2,
              ),
              elevation: 2,
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 16,
            ),
          ),

          // Month Dropdown
          _buildMonthDropdownMenu(controller),

          // Next Month
          ElevatedButton(
            onPressed: controller.goToNextMonth,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
              backgroundColor: AppColors.categoryTitleBgColor.withValues(
                alpha: 0.2,
              ),
              elevation: 2,
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDropdownMenu(HomeController controller) {
    return Expanded(
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
                (m) => m['month'] == controller.selectedMonth.value,
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
                  fontSize: 14,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          m['month'],
                          style: const TextStyle(color: Colors.white),
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
                      final result = await Get.toNamed(AppRoutes.addMonth);
                      if (result != null && result is Map<String, dynamic>) {
                        controller.selectMonth(result);

                        // 🔹 নতুন মাস add করার পরে dropdown close
                        controller.isMonthDropdownOpen.value = false;
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
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
    );
  }

  Widget _buildHeaderProfileSection(
      BuildContext context,
      HomeController controller,
      ) {
    final notificationController = Get.put(NotificationController());

    return Padding(
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
                  body: SafeArea(child: AppDrawer()),
                );
              },
              icon: const Icon(Icons.person_2_outlined, color: Colors.white),
            ),
          ),

          Row(
            children: [
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

              // 🔹 Notification Button with Badge
              Obx(() => Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                    onPressed: () async {
                      // Show notification dialog or screen
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Notifications'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: Obx(() => ListView.builder(
                              shrinkWrap: true,
                              itemCount:
                              notificationController.notifications.length,
                              itemBuilder: (_, index) => ListTile(
                                title: Text(notificationController
                                    .notifications[index]),
                              ),
                            )),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  notificationController.markAllRead();
                                  Navigator.pop(context);
                                },
                                child: const Text('Mark all as read')),
                          ],
                        ),
                      );
                    },
                  ),
                  if (notificationController.unreadCount.value > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Obx(() => Text(
                          '${notificationController.unreadCount.value}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        )),
                      ),
                    )
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }
}
