import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:ay_bay_app/core/settings/controllers/settings_controller.dart';
import 'package:ay_bay_app/core/utils/number_util.dart';
import 'package:ay_bay_app/features/common/models/category_icon.dart';
import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
import 'package:ay_bay_app/core/extension/transaction_category_localization.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:ay_bay_app/features/common/transaction/ui/screens/add_transaction_screen.dart';
import 'package:ay_bay_app/features/home/widget/balance_card.dart';
import 'package:ay_bay_app/features/months/ui/screens/month_transactions_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    controller.saveLastScreen(AppRoutes.home);

    final size = MediaQuery.sizeOf(context);
    final isSmall = size.width < 360;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.loginTextButtonColor,
        elevation: 8,
        onPressed: () {
          Get.to(() => const AddTransactionScreen());
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          /// 🔹 BALANCE CARD
          SliverPersistentHeader(
            pinned: true, // 🔹 fixed on top
            delegate: _BalanceCardHeaderDelegate(
              child: BalanceCard(),
              minExtent: 336, // মিনিমাম হাইট
              maxExtent: 336, // ম্যাক্সিমাম হাইট
            ),
          ),

          /// 🔹 FILTER BUTTONS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Obx(() {
                final filterCategory = controller.filterCategory.value;

                // 🔹 লোকালাইজড লেবেল ম্যাপ
                final filterMap = {
                  'সব': context.localization.all,
                  'আয়': context.localization.income,
                  'ব্যয়': context.localization.expense,
                  'মাসিক': context.localization.monthly,
                };

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filterMap.entries.map((entry) {
                      final originalValue = entry.key;       // মূল ডাটা ('সব', 'আয়', ...)
                      final displayValue = entry.value;      // লোকালাইজড মান ('All', 'Income', ...)
                      final isSelected = filterCategory == originalValue;

                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(
                            displayValue,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'HindSiliguri',
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.withValues(alpha: 0.65),
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) => controller.setFilter(originalValue),
                          selectedColor: AppColors.loginTextButtonColor,
                          backgroundColor: Colors.white,
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.loginTextButtonColor
                                  : Colors.grey.shade200,
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ),
          ),




          /// 🔹 MONTH LIST / TRANSACTION LIST
          Obx(() {
            // মূল filterCategory ব্যবহার
            final filterCategory = controller.filterCategory.value;

            // মূল ডাটার সাথে লোকালাইজড মান ম্যাপ
            final _ = {
              'সব': context.localization.all,
              'আয়': context.localization.income,
              'ব্যয়': context.localization.expense,
              'মাসিক': context.localization.monthly,
            };

            // মাসিক ফিল্টার চেক
            if (filterCategory == 'মাসিক') {
              if (controller.months.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(context.localization.noMonthAdded)), // 'কোনো মাস যোগ করা হয়নি'
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final m = controller.months[index];

                    // 🔹 লোকালাইজড মাস + বছর
                    final today = DateTime.now();
                    final monthText = localizedMonthYear(m['month'], today);

                    return GestureDetector(
                      onTap: () {
                        controller.selectMonth(m);
                        Get.to(() => MonthTransactionsScreen(
                          monthId: m['id'],
                          monthName: m['month'],
                        ));
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E88E5), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 🔹 মাস + বছর
                            Text(
                              monthText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                _buildMonthExpense(controller, m),
                                const SizedBox(width: 12),
                                _deleteIcon(() {
                                  Get.defaultDialog(
                                    title: '',
                                    backgroundColor: Colors.transparent, // Transparent background for card effect
                                    barrierDismissible: false,
                                    content: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 12,
                                            offset: Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // 🔹 Title
                                          Text(
                                            context.localization.confirmDelete,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // 🔹 Message
                                          Text(
                                            '${m['month']} ${context.localization.wantToDeleteMonth}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 24),

                                          // 🔹 Buttons
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () => Get.back(),
                                                  style: OutlinedButton.styleFrom(
                                                    side: const BorderSide(color: Colors.grey),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                  ),
                                                  child: Text(
                                                    context.localization.no,
                                                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Get.back();
                                                    controller.deleteMonth(m['id'], m['month'], m['deleteMonth']);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.redAccent,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    elevation: 6,
                                                  ),
                                                  child: Text(
                                                    context.localization.yes,
                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: controller.months.length,
                ),
              );

            }

            /// TRANSACTIONS LIST
            if (controller.transactions.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text(context.localization.noTransactions)), // 'কোনো ট্রানজাকশন নেই'
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final trx = controller.transactions[index];
                  final isIncome = trx.type == TransactionType.income;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CategoryIcons.fromId(trx.categoryIcon),
                          color: isIncome ? Colors.green : Colors.red,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        trx.category.localizedName(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy', Get.locale?.languageCode ?? 'en').format(trx.date),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      trailing: _buildTransactionAction(context, isIncome, trx, isSmall, controller),
                    ),
                  );
                },
                childCount: controller.transactions.length,
              ),
            );
          }),


          const SliverToBoxAdapter(
            child: SizedBox(height: 80), // FAB space
          ),
        ],
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _deleteIcon(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
      ),
    );
  }

  Widget _buildTransactionAction(BuildContext context, bool isIncome, trx, bool isSmall, HomeController controller) {
    final SettingsController settingsController = Get.find<SettingsController>();
    final currency = settingsController.defaultCurrency.value;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${isIncome ? '+ $currency' : '- $currency'} ${localizedNumber(trx.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green : Colors.red,
            fontSize: 17,
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: () => controller.editTransaction(trx),
          child: const Icon(Icons.edit_note, color: Colors.blue),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () {
            Get.defaultDialog(
              title: '',
              backgroundColor: Colors.transparent, // Transparent for card effect
              barrierDismissible: true,
              content: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Title
                    Text(
                      context.localization.confirmDelete,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🔹 Message
                    Text(
                      context.localization.wantToDeleteTransaction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🔹 Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              context.localization.no,
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              controller.deleteTransaction(context,trx.id);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 6,
                            ),
                            child: Text(
                              context.localization.yes,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );

          },
          child: const Icon(Icons.delete_outline, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildMonthExpense(HomeController controller, Map m) {
    final SettingsController settingsController = Get.find<SettingsController>();
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(controller.uid)
          .collection('months')
          .doc(m['id'])
          .collection('transactions')
          .where('type', isEqualTo: 'expense')
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(width: 40);

        final total = snapshot.data!.docs.fold<double>(
          0,
              (double sum, doc) => sum + (doc['amount']?.toDouble() ?? 0),
        );

        return Text(
          '${settingsController.defaultCurrency.value} ${localizedNumber(total)}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
        );
      },
    );
  }

  String localizedMonthYear(String monthName, DateTime date) {
    try {
      // English month থেকে month number বের কর
      final monthNumber = DateFormat('MMMM', 'en').parse(monthName).month;

      // ঐ মাস + current year এর DateTime তৈরি কর
      final localizedDate = DateTime(date.year, monthNumber);

      // locale অনুযায়ী দেখাও (যেমন 'bn' -> বাংলা)
      return DateFormat.yMMMM(Get.locale?.languageCode ?? 'en').format(localizedDate);
    } catch (_) {
      return monthName; // fallback
    }
  }

  String localizedAmount(double amount) {
    // NumberFormat.locale ব্যবহার করে সংখ্যা লোকালাইজ করা
    final f = NumberFormat.currency(
      locale: Get.locale?.languageCode ?? 'en',
      symbol: '', // currency symbol আমরা settings থেকে ব্যবহার করব
      decimalDigits: 0,
    );
    return f.format(amount);
  }


}

class _BalanceCardHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  @override
  final double minExtent;
  @override
  final double maxExtent;

  _BalanceCardHeaderDelegate({
    required this.child,
    required this.minExtent,
    required this.maxExtent,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _BalanceCardHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.minExtent != minExtent ||
        oldDelegate.maxExtent != maxExtent;
  }
}

