import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
import 'package:ay_bay_app/features/home/controllers/add_transaction_controller.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final controller = Get.find<AddTransactionController>();
  final hController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();

    /// Prefill data if edit mode
    if (widget.transaction != null) {
      final trx = widget.transaction!;
      controller.noteCtrl.text = trx.title;
      controller.amountCtrl.text = trx.amount.toString();
      controller.type.value = trx.type;
      controller.selectedDate.value = trx.date;
      controller.isMonthly.value = trx.isMonthly;

      // Save editing ID
      controller.editingTransactionId = trx.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'লেনদেন এডিট করুন' : 'আয়-ব্যয় যোগ'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - padding * 2,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    SizedBox(height: Get.width * 0.05),
                    Text(
                      isEdit ? 'লেনদেন আপডেট করুন' : 'আয়-ব্যয় যোগ করুন',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),


                    // Amount
                    TextField(
                      controller: controller.amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'টাকার পরিমাণ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Type + Date Row
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                                () => DropdownButtonFormField<TransactionType>(
                              initialValue: controller.type.value,
                              decoration: const InputDecoration(
                                labelText: 'ধরন',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: TransactionType.income,
                                  child: Text('⬆ আয়'),
                                ),
                                DropdownMenuItem(
                                  value: TransactionType.expense,
                                  child: Text('⬇ ব্যয়'),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) controller.type.value = v;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                                () => InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: controller.selectedDate.value,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  controller.pickDate(date);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'তারিখ',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  DateFormat('dd MMM yyyy')
                                      .format(controller.selectedDate.value),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Category Label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'CATEGORY SELECT',
                        style: TextStyle(
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category Grid
                  Obx(() {
                    final list = controller.type.value == TransactionType.income
                        ? controller.incomeCategories
                        : controller.expenseCategories;

                    final screenWidth = MediaQuery.of(context).size.width;
                    final itemWidth = 80.0; // icon + text approx
                    final spacing = 16.0;

                    // Calculate crossAxisCount dynamically
                    final crossAxisCount = (screenWidth / (itemWidth + spacing)).floor().clamp(1, 6);

                    final rowCount = (list.length / crossAxisCount).ceil();
                    final itemHeight = 64 + 6 + 16; // icon + spacing + text
                    final gridHeight = rowCount * itemHeight + (rowCount - 1) * spacing;

                    return SizedBox(
                      height: gridHeight,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: 0.9,
                        ),
                        itemBuilder: (_, i) {
                          final cat = list[i];

                          return Obx(() {
                            final isSelected = controller.selectedCategory.value?.name == cat.name;

                            return GestureDetector(
                              onTap: () {
                                controller.selectedCategory.value = cat; // ✅ Rx update
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 64,
                                    width: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Colors.blue.withOpacity(0.2)
                                          : Colors.grey.shade100,
                                      border: Border.all(
                                        color: isSelected ? Colors.blue : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      cat.icon,
                                      color: isSelected ? Colors.blue : Colors.grey,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    cat.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                        },
                      ),
                    );
                  }),


                  // Other Field
                    Obx(() {
                      if (controller.selectedCategory.value?.name != 'Other') {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TextField(
                          controller: controller.otherCategoryCtrl,
                          decoration: const InputDecoration(
                            labelText: 'ক্যাটাগরির নাম লিখুন',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 30),

                    // Save / Update Button
                    Obx(
                          () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.saveTransaction,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : Text(
                          isEdit ? 'পুনরায় যোগ করুন' : 'যোগ করুন',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
