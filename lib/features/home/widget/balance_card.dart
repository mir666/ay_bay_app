import 'dart:convert';
import 'dart:ui';
import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:ay_bay_app/core/extension/transaction_category_localization.dart';
import 'package:ay_bay_app/core/localization/ui/widget/language_toggle_button.dart';
import 'package:ay_bay_app/core/profile/controllers/user_controller.dart';
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
  final userController = Get.find<UserController>();
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
      if (!controller.isSearching.value) {
        return const SizedBox();
      }

      return Positioned(
        top: 70,
        left: 12,
        right: 12,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Material(
            elevation: 18,
            borderRadius: BorderRadius.circular(20),
            shadowColor: Colors.black26,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              constraints: const BoxConstraints(
                maxHeight: 460,
              ),
              child: Column(
                children: [
                  _premiumSearchField(controller),

                  Expanded(
                    child: _buildSuggestionList(controller),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _premiumSearchField(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        autofocus: true,
        onChanged: controller.searchTransaction,
        decoration: InputDecoration(
          hintText: context.localization.searchHint,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: const Icon(
            Icons.search,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: controller.closeSearch,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding:
          const EdgeInsets.symmetric(
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionList(HomeController controller) {
    if (controller.searchText.isEmpty) {
      return _buildRecentSearches(controller);
    }

    if (controller.suggestions.isEmpty &&
        controller.monthSuggestions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      children: [
        if (controller.monthSuggestions.isNotEmpty)
          _buildMonthSection(controller),

        if (controller.suggestions.isNotEmpty)
          _buildTransactionSection(controller),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              context.localization.noResultsFound,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionTile(TransactionModel trx,HomeController controller) {
    final isIncome = trx.type == TransactionType.income;

    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: isIncome
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),

      /// Title
      title: searchHighlightText(
        trx.category.localizedName(),
        controller.searchText.value,
        highlightColor: isIncome ? Colors.green : Colors.red,
      ),

      /// Category + Date
      subtitle: Row(
        children: [
          /// Date
          Text(
            DateFormat(
              'dd MMM yyyy', Get.locale?.languageCode).format(trx.date),
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),

      /// Amount
      trailing: Text(
        "${settingsController.defaultCurrency.value} ${localizedNumber(trx.amount)}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),

      onTap: () {
        controller.selectSuggestion(trx);
        controller.closeSearch();
      },
    );
  }

  Widget _buildRecentSearches(HomeController controller) {
    if (controller.recentSearches.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Text(
            context.localization.recentSearches,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),

        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.recentSearches.length,
          itemBuilder: (context, index) {
            final query = controller.recentSearches[index];

            return ListTile(
              leading: Icon(Icons.history, color: Colors.grey),
              title: Text(query),

              trailing: IconButton(
                icon: Icon(Icons.close, size: 18,),
                onPressed: () {
                  controller.recentSearches.remove(query);
                },
              ),

              onTap: () {controller.searchTransaction(query);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMonthSection(HomeController controller) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Text(
            "${context.localization.month} "
                "(${controller.monthSuggestions.length})",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.monthSuggestions.length,
          itemBuilder: (context, index) {
            final m = controller.monthSuggestions[index];

            return ListTile(
              leading: const Icon(
                Icons.calendar_month,
                color: Colors.deepPurple,
              ),

              title: searchHighlightText(
                _localizedMonth(m['month'], DateTime.now()),
                controller.searchText.value,
                highlightColor:
                Colors.deepPurple,
              ),
              onTap: () => controller.selectMonthFromSearch(m),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionSection(HomeController controller) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Text(
            "${context.localization.transactions} "
                "(${controller.suggestions.length})",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.suggestions.length,

          itemBuilder: (context, index) {
            final trx = controller.suggestions[index];
            return _transactionTile(trx, controller);
          },
        ),
      ],
    );
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


          final safeSelectedMonth = controller.months.any(
                (m) => m['month'] == controller.selectedMonth.value)
              ? controller.selectedMonth.value : null;

          return DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: safeSelectedMonth,
              hint: Text(
                safeSelectedMonth == null ? context.localization.month
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
                          _localizedMonth(m['month'], today),
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          DateFormat(
                            'dd MMM', Get.locale?.languageCode ?? 'en',).format(today),
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

  Widget _buildHeaderProfileSection(BuildContext context, HomeController controller) {
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
                            child: _buildNotificationSection(
                              context,
                              notificationController,
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
              Obx(
                    () => GestureDetector(
                  onTap: () {
                    // Profile page এ navigate করবে
                    Get.toNamed(AppRoutes.appProfile);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white30,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 18, // ছোট, AppBar / header friendly
                      backgroundColor: Colors.blueGrey.withAlpha(200),
                      backgroundImage: userController.avatarBase64.value.isNotEmpty
                          ? MemoryImage(
                        base64Decode(userController.avatarBase64.value),
                      )
                          : null,
                      child: userController.avatarBase64.value.isEmpty
                          ? const Icon(
                        Icons.person,
                        size: 18,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ),
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

  Widget _buildNotificationSection(
    BuildContext context,
    NotificationController notificationController,
  ) {
    return Container(
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
              final list = notificationController.notifications;

              if (list.isEmpty) {
                return Center(
                  child: Text(
                    context.localization.noNotifications,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                );
              }

              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final notification = list[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          style: const TextStyle(fontSize: 14),
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
                backgroundColor: AppColors.loginTextButtonColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
