import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:ay_bay_app/features/common/models/category_icon.dart';
import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
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
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            /// 🔹 BALANCE CARD
            const SliverToBoxAdapter(child: BalanceCard()),

            /// 🔹 FILTER BUTTONS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Obx(() {
                  final filterCategory = controller.filterCategory.value;
                  final filters = ['সব', 'আয়', 'ব্যয়', 'মাসিক'];

                  return Wrap(
                    children: filters.map((f) {
                      final isSelected = filterCategory == f;
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(
                            f,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'HindSiliguri',
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.withValues(alpha: 0.65),
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) => controller.setFilter(f),
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
                  );
                }),
              ),
            ),

            /// 🔹 MONTH LIST / TRANSACTION LIST
            Obx(() {
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
                              Text(
                                m['month'],
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
                                      title: 'Confirm Delete',
                                      backgroundColor: Colors.transparent, // Transparent background for card effect
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
                                              offset: Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // 🔹 Title
                                            Text(
                                              'Confirm Delete',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            // 🔹 Message
                                            Text(
                                              '${m['month']} মাস ডিলিট করতে চাচ্ছো?',
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
                                                    child: const Text(
                                                      'না',
                                                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Get.back();
                                                      controller.deleteMonth(m['id'], m['month']);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.redAccent,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                                      elevation: 6,
                                                    ),
                                                    child: const Text(
                                                      'হ্যাঁ',
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
                          trx.category,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          DateFormat('dd MMM yyyy').format(trx.date),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        trailing: _buildTransactionAction(context,isIncome, trx, isSmall, controller),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${isIncome ? '+' : '-'} ${trx.amount.toInt()} ৳',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green : Colors.red,
            fontSize: 15,
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
                      'Confirm Delete',
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
                              controller.deleteTransaction(trx.id);
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
          '${total.toInt()}৳',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
        );
      },
    );
  }
}
