/*
import 'package:ay_bay_app/features/common/models/category_model.dart';
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

    if (widget.transaction != null) {
      final trx = widget.transaction!;

      controller.noteCtrl.text = trx.title;
      controller.amountCtrl.text = trx.amount.toString();
      controller.type.value = trx.type;
      controller.selectedDate.value = trx.date;
      controller.isMonthly.value = trx.isMonthly;

      controller.editingTransactionId = trx.id;

      // ======================
      // Category prefill
      // ======================
      final list = trx.type == TransactionType.income
          ? controller.incomeCategories
          : controller.expenseCategories;

      final cat = list.firstWhere(
        (c) => c.name == trx.category,
        orElse: () => CategoryModel(name: 'Other', icon: Icons.more_horiz),
      );

      controller.selectedCategory.value = cat;

      if (trx.category != cat.name) {
        controller.otherCategoryCtrl.text = trx.category;
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;
    final padding = 16.0;
    final width = MediaQuery.of(context).size.width;



    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(isEdit ? 'লেনদেন এডিট করুন' : 'আয়-ব্যয় যোগ'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            padding,
            padding,
            padding,
            padding + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: width * 0.3),

              /// 🔹 Title
              Text(
                isEdit ? 'লেনদেন আপডেট করুন' : 'আয়-ব্যয় যোগ করুন',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              /// 🔹 Amount
              TextField(
                controller: controller.amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'টাকার পরিমাণ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              /// 🔹 Type + Date
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      return DropdownButtonFormField<TransactionType>(
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
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      return InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: controller.selectedDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) controller.pickDate(date);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'তারিখ',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            DateFormat(
                              'dd MMM yyyy',
                            ).format(controller.selectedDate.value),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// 🔹 Category label
              const Text(
                'CATEGORY SELECT',
                style: TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              Obx(() {
                final list = controller.type.value == TransactionType.income
                    ? controller.incomeCategories
                    : controller.expenseCategories;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    height: 100, // ✅ fixed height prevents bottom overflow
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: list.length,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final cat = list[i];
                        return Obx(() {
                          final isSelected =
                              controller.selectedCategory.value?.name ==
                              cat.name;
                          return GestureDetector(
                            onTap: () =>
                                controller.selectedCategory.value = cat,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Colors.blue.withValues(alpha: 0.2)
                                        : Colors.grey.shade100,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    cat.icon,
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    cat.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                      },
                    ),
                  ),
                );
              }),

              /// 🔹 Other category
              Obx(() {
                if (controller.selectedCategory.value?.name != 'Other') {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextField(
                    controller: controller.otherCategoryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'খরচের বর্ণনা লিখুন',
                      border: OutlineInputBorder(),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 32),

              /// 🔹 Save Button
              Obx(() {
                return ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.saveTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEdit ? 'পুনরায় যোগ করুন' : 'যোগ করুন',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
*/

import 'package:ay_bay_app/features/common/models/category_model.dart';
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
  late final AddTransactionController controller;
  late final HomeController hController;

  @override
  void initState() {
    super.initState();

    // ✅ নতুন instance না হলে পুরানো data থেকে conflict হতে পারে
    controller = Get.put(AddTransactionController(), permanent: false);
    hController = Get.find<HomeController>();

    // যদি নতুন transaction হয় → সব field খালি
    if (widget.transaction == null) {
      controller.clearForm();
    } else {
      _prefillTransaction(widget.transaction!);
    }
  }

  void _prefillTransaction(TransactionModel trx) {
    controller.editingTransactionId = trx.id;
    controller.noteCtrl.text = trx.title;
    controller.amountCtrl.text = trx.amount.toString();
    controller.type.value = trx.type;
    controller.selectedDate.value = trx.date;
    controller.isMonthly.value = trx.isMonthly;

    // Category prefill
    final list = trx.type == TransactionType.income
        ? controller.incomeCategories
        : controller.expenseCategories;

    final cat = list.firstWhere(
          (c) => c.name == trx.category,
      orElse: () => CategoryModel(name: 'Other', icon: Icons.more_horiz),
    );

    controller.selectedCategory.value = cat;

    if (trx.category != cat.name) {
      controller.otherCategoryCtrl.text = trx.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;
    final padding = 16.0;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(isEdit ? 'লেনদেন এডিট করুন' : 'আয়-ব্যয় যোগ'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                padding,
                padding,
                padding,
                padding + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: width * 0.3),

                      /// Title
                      Text(
                        isEdit ? 'লেনদেন আপডেট করুন' : 'আয়-ব্যয় যোগ করুন',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      /// Amount
                      Obx(() {
                        return TextField(
                          controller: controller.amountCtrl,
                          keyboardType: TextInputType.text, // number + operators
                          decoration: InputDecoration(
                            labelText: 'টাকার পরিমাণ (e.g. 100+50-30*2/5)',
                            border: const OutlineInputBorder(),
                            suffixText: controller.calculatedAmount.value.toStringAsFixed(0),
                            suffixStyle: TextStyle(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          onChanged: (val) => controller.onAmountChanged(val),
                        );
                      }),
                      const SizedBox(height: 12),

                      /// Type + Date
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              return DropdownButtonFormField<TransactionType>(
                                value: controller.type.value,
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
                              );
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() {
                              return InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: controller.selectedDate.value,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) controller.pickDate(date);
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
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      /// Category label
                      const Text(
                        'CATEGORY SELECT',
                        style: TextStyle(
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// Horizontal Category Scroll
                      Obx(() {
                        final list = controller.type.value ==
                            TransactionType.income
                            ? controller.incomeCategories
                            : controller.expenseCategories;

                        return SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: list.length,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                            separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final cat = list[i];
                              return Obx(() {
                                final isSelected = controller
                                    .selectedCategory.value?.name ==
                                    cat.name;
                                return GestureDetector(
                                  onTap: () =>
                                  controller.selectedCategory.value = cat,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? Colors.blue.withOpacity(0.2)
                                              : Colors.grey.shade100,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          cat.icon,
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.grey,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          cat.name,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            overflow: TextOverflow.ellipsis,
                                          ),
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

                      /// Other Category
                      Obx(() {
                        if (controller.selectedCategory.value?.name != 'Other') {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: TextField(
                            controller: controller.otherCategoryCtrl,
                            decoration: const InputDecoration(
                              labelText: 'খরচের বর্ণনা লিখুন',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 32),

                      /// Save Button
                      Obx(() {
                        return ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.saveTransaction,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            isEdit ? 'পুনরায় যোগ করুন' : 'যোগ করুন',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

