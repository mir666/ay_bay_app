
import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:ay_bay_app/features/home/ui/screens/add_transaction_screen.dart';
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.loginTextButtonColor,
        onPressed: () {
          Get.to(() => AddTransactionScreen());
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          const BalanceCard(),
          const SizedBox(height: 16),

          /// Filter Buttons
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.dateIconBgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.categoryShadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  filterButton('সব', isSmall),
                  SizedBox(width: 10),
                  filterButton('আয়', isSmall),
                  SizedBox(width: 10),
                  filterButton('ব্যয়', isSmall),
                  SizedBox(width: 10),
                  filterButton('মাসিক', isSmall),
                ],
              ),
            ),
          ),

          Expanded(
            child: Obx(() {
              // 🔹 মাসিক ফিল্টার হলে মাসের লিস্ট দেখাবে
              if (controller.filterCategory.value == 'মাসিক') {
                if (controller.months.isEmpty) {
                  return const Center(child: Text('কোনো মাস যোগ করা হয়নি'));
                }

                return ListView.builder(
                  itemCount: controller.months.length,
                  itemBuilder: (context, index) {
                    final m = controller.months[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          m['month'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isSmall ? 14 : 16,
                          ),
                        ),

                        // Trailing section: Expense + Delete Icon
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // মাসের Expense দেখাবে
                            _buildMonthExpense(controller, m),
                            const SizedBox(width: 18),

                            // Delete Icon
                            InkWell(
                              onTap: () {
                                // ✅ কনফার্ম ডায়ালগ
                                Get.defaultDialog(
                                  title: 'Confirm Delete',
                                  middleText: '${m['month']} মাস ডিলিট করতে চাচ্ছো?',
                                  textConfirm: 'হ্যাঁ',
                                  textCancel: 'না',
                                  confirmTextColor: Colors.white,
                                  buttonColor: Colors.red,
                                  onConfirm: () {
                                    Get.back(); // ডায়ালগ বন্ধ
                                    controller.deleteMonth(m['id'], m['month']); // ডিলিট কল
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                              ),
                            ),
                          ],
                        ),

                        onTap: () {
                          controller.selectMonth(m);
                          Get.to(
                                () => MonthTransactionsScreen(
                              monthId: m['id'],
                              monthName: m['month'],
                            ),
                          );
                        },
                      ),
                    );

                  },
                );
              }

              // 🔹 অন্য ফিল্টার / হোম লিস্ট দেখাবে (last active month)
              if (controller.transactions.isEmpty) {
                return const Center(child: Text('কোনো ট্রানজাকশন নেই'));
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 80),
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final trx = controller.transactions[index];
                  final isIncome = trx.type == TransactionType.income;

                  return Card(
                    color: isIncome
                        ? AppColors.ayCardColor
                        : AppColors.bayCardColor,
                    elevation: 6,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        trx.title,
                        style: TextStyle(fontSize: isSmall ? 14 : 16),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy').format(trx.date),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: _buildTransactionAction(
                        isIncome,
                        trx,
                        isSmall,
                        controller,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }


  Widget _buildTransactionAction(
      bool isIncome,
      TransactionModel trx,
      bool isSmall,
      HomeController controller,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Amount
        Text(
          '${isIncome ? '+' : '-'} ৳ ${trx.amount}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 12 : 14,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 16),

        // Edit Icon
        InkWell(
          onTap: () => controller.editTransaction(trx),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.edit_note, color: Colors.blue, size: 22),
          ),
        ),

        const SizedBox(width: 14),

        // Delete Icon with confirmation dialog
        InkWell(
          onTap: () {
            // ✅ Confirmation Dialog
            Get.defaultDialog(
              title: 'Confirm Delete',
              middleText: 'এই ট্রানজেকশন ডিলিট করতে চাচ্ছো?',
              textConfirm: 'হ্যাঁ',
              textCancel: 'না',
              confirmTextColor: Colors.white,
              buttonColor: Colors.red,
              onConfirm: () {
                Get.back(); // Close dialog
                controller.deleteTransaction(trx.id); // Call delete
              },
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
          ),
        ),
      ],
    );
  }


  Widget _buildMonthExpense(HomeController controller, Map m) {
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
        if (!snapshot.hasData) {
          return const SizedBox(width: 40);
        }

        final totalExpense = snapshot.data!.docs.fold<double>(
          0,
          (double sum, doc) => sum + (doc['amount']?.toDouble() ?? 0),
        );

        return Text(
          '৳${totalExpense.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.red,
          ),
        );
      },
    );
  }

  Widget filterButton(String text, bool isSmall) {
    final HomeController controller = Get.find<HomeController>();

    return Obx(() {
      final bool isSelected = controller.filterCategory.value == text;

      return ChoiceChip(
        label: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected
                ? AppColors.addButtonColor
                : AppColors.unSelectedColor,
            fontSize: isSelected ? 16 : 14,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => controller.setFilter(text),

        // 🔥 Selected & Unselected Color
        selectedColor: AppColors.categoryTitleBgColor,
        backgroundColor: Colors.white,

        // 🔥 Border
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isSelected ? AppColors.categoryTitleBgColor : Colors.white,
            width: 1,
          ),
        ),
        showCheckmark: false,

        // 🔥 Padding
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

        // 🔥 Shadow
        elevation: isSelected ? 6 : 6,
        pressElevation: 8,
      );
    });
  }
}
