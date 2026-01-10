
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
        onPressed: () => Get.to(() => AddTransactionScreen()),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [

          /// 🔹 BALANCE CARD
          const SliverToBoxAdapter(
            child: BalanceCard(),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),

          /// 🔹 FILTER BUTTONS
          SliverToBoxAdapter(
            child: Container(
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
                    _filterButton('সব', isSmall),
                    const SizedBox(width: 10),
                    _filterButton('আয়', isSmall),
                    const SizedBox(width: 10),
                    _filterButton('ব্যয়', isSmall),
                    const SizedBox(width: 10),
                    _filterButton('মাসিক', isSmall),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 12),
          ),

          /// 🔹 MAIN CONTENT
          Obx(() {
            /// 🟢 MONTH LIST
            if (controller.filterCategory.value == 'মাসিক') {
              if (controller.months.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('কোনো মাস যোগ করা হয়নি')),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final m = controller.months[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMonthExpense(controller, m),
                            const SizedBox(width: 16),
                            _deleteIcon(() {
                              Get.defaultDialog(
                                title: 'Confirm Delete',
                                middleText: '${m['month']} মাস ডিলিট করতে চাচ্ছো?',
                                textConfirm: 'হ্যাঁ',
                                textCancel: 'না',
                                confirmTextColor: Colors.white,
                                buttonColor: Colors.red,
                                onConfirm: () {
                                  Get.back();
                                  controller.deleteMonth(m['id'], m['month']);
                                },
                              );
                            }),
                          ],
                        ),
                        onTap: () {
                          controller.selectMonth(m);
                          Get.to(() => MonthTransactionsScreen(
                            monthId: m['id'],
                            monthName: m['month'],
                          ));
                        },
                      ),
                    );
                  },
                  childCount: controller.months.length,
                ),
              );
            }

            /// 🟢 TRANSACTION LIST
            if (controller.transactions.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('কোনো ট্রানজাকশন নেই')),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final trx = controller.transactions[index];
                  final isIncome = trx.type == TransactionType.income;

                  return Card(
                    color: isIncome ? AppColors.ayCardColor : AppColors.bayCardColor,
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(trx.title, style: TextStyle(fontSize: isSmall ? 14 : 16)),
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

  Widget _filterButton(String text, bool isSmall) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final isSelected = controller.filterCategory.value == text;

      return ChoiceChip(
        label: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 13 : 14,
            color: isSelected
                ? AppColors.addButtonColor
                : AppColors.unSelectedColor,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => controller.setFilter(text),
        selectedColor: AppColors.categoryTitleBgColor,
        backgroundColor: Colors.white,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isSelected ? AppColors.categoryTitleBgColor : Colors.white,
          ),
        ),
      );
    });
  }

  Widget _deleteIcon(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
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
        Text(
          '${isIncome ? '+' : '-'} ৳ ${trx.amount}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 12 : 14,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.edit_note, color: Colors.blue),
          onPressed: () => controller.editTransaction(trx),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            Get.defaultDialog(
              title: 'Confirm Delete',
              middleText: 'এই ট্রানজেকশন ডিলিট করতে চাচ্ছো?',
              textConfirm: 'হ্যাঁ',
              textCancel: 'না',
              confirmTextColor: Colors.white,
              buttonColor: Colors.red,
              onConfirm: () {
                Get.back();
                controller.deleteTransaction(trx.id);
              },
            );
          },
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
        if (!snapshot.hasData) return const SizedBox(width: 40);

        final total = snapshot.data!.docs.fold<double>(
          0,
              (sum, doc) => sum + (doc['amount']?.toDouble() ?? 0),
        );

        return Text(
          '৳${total.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        );
      },
    );
  }
}

