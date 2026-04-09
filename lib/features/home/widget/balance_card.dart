import 'dart:ui';
import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:ay_bay_app/core/localization/ui/widget/language_toggle_button.dart';
import 'package:ay_bay_app/core/settings/controllers/settings_controller.dart';
import 'package:ay_bay_app/core/utils/number_util.dart';
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
  final controller = Get.find<HomeController>();
  late String locale;

  @override
  void initState() {
    super.initState();
    locale = Get.locale?.languageCode ?? 'en'; // init once
  }

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
                SizedBox(height: 48),
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
            constraints: BoxConstraints(
              maxHeight: 400, // পুরো suggestions area scrollable
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Search Bar
                  Padding(
                    padding: EdgeInsets.all(12),
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
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Text(
                            context.localization.month,
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
                            DateFormat(
                              'dd MMM yyyy',
                              Get.locale?.languageCode,
                            ).format(trx.date),
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
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 2),
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
                  /// 🔹 BALANCE (auto expand)
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.localization.balance,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'HindSiliguri',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.localization.balanceAmount.trParams({
                            'balance': localizedNumber(
                              controller.balance.value,
                            ),
                            'defaultCurrency':
                                settingsController.defaultCurrency.value,
                          }),
                          style: const TextStyle(
                            fontSize: 20,
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
          SizedBox(height: 6),
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
                      context.localization.income,
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
                      context.localization.expense,
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'HindSiliguri',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${settingsController.defaultCurrency.value} ${localizedNumber(value)}',
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
            onPressed: () => controller.goToPreviousMonth(context),
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
            onPressed: () => controller.goToNextMonth(context),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
              backgroundColor: AppColors.categoryTitleBgColor.withValues(
                alpha: 0.2,
              ),
              elevation: 2,
            ),
            child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDropdownMenu(HomeController controller) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
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
                    ? context.localization.month
                    : _localizedMonth(safeSelectedMonth, today),
                // <-- লোকালাইজড
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
                          _localizedMonth(m['month'], today), // <-- লোকালাইজড
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          DateFormat(
                            'dd MMM',
                            Get.locale?.languageCode ?? 'en',
                          ).format(today),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (monthName) {
                if (monthName == null) return;
                final month = controller.months.firstWhere(
                  (m) => m['month'] == monthName,
                );
                controller.selectMonth(month);
                controller.isMonthDropdownOpen.value = false;
              },
              onTap: () {
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
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
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
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.categoryTitleBgColor.withValues(
                    alpha: 0.2,
                  ),
                ),
                onPressed: () {
                  controller.isSearching.value
                      ? controller.closeSearch()
                      : controller.isSearching.value = true;
                },
              ),

              // 🔹 Notification Button with Badge
              Obx(
                () => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 🔹 Notification Icon
                    IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.categoryTitleBgColor
                            .withValues(alpha: 0.2),
                      ),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Colors.white,
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 400),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 🔹 Title
                                  Text(
                                    context.localization.notifications,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // 🔹 Notification List
                                  Expanded(
                                    child: Obx(() {
                                      final list =
                                          notificationController.notifications;

                                      if (list.isEmpty) {
                                        return Center(
                                          child: Text(
                                            context
                                                .localization
                                                .noNotifications,
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        );
                                      }

                                      return ListView.separated(
                                        itemCount: list.length,
                                        separatorBuilder: (_, _) =>
                                            const Divider(height: 1),
                                        itemBuilder: (_, index) {
                                          final notification = list[index];
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  notification.title,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  notification.body,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 16),

                                  // 🔹 Action Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.loginTextButtonColor,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        elevation: 4,
                                      ),
                                      onPressed: () {
                                        notificationController.markAllRead();
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        context.localization.makeAllAsRead,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // 🔴 Unread dot
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
                          child: Obx(
                            () => Text(
                              '${notificationController.unreadCount.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // 🔹 Language Toggle Button
              const LanguageToggleButton(),
            ],
          ),
        ],
      ),
    );
  }

  String _localizedMonth(String monthName, DateTime date) {
    try {
      final monthNumber = DateFormat('MMMM', 'en').parse(monthName).month;
      final localizedDate = DateTime(date.year, monthNumber);
      return DateFormat.yMMMM(
        Get.locale?.languageCode ?? 'en',
      ).format(localizedDate);
    } catch (_) {
      return monthName; // fallback
    }
  }
}
