import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:ay_bay_app/features/common/models/category_icon.dart';
import 'package:ay_bay_app/features/common/models/category_model.dart';
import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
import 'package:ay_bay_app/features/common/transaction/controllers/add_transaction_controller.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

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
    controller = Get.put(AddTransactionController(), permanent: false);
    hController = Get.find<HomeController>();

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

    final list = trx.type == TransactionType.income
        ? controller.incomeCategories
        : controller.expenseCategories;

    final cat = list.firstWhere(
          (c) => c.name == trx.category,
      orElse: () => CategoryModel(name: 'Other', iconId: 5),
    );

    controller.selectedCategory.value = cat;

    if (trx.category != cat.name) {
      controller.otherCategoryCtrl.text = trx.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isEdit = widget.transaction != null;
    final height = media.size.height;
    final padding = 16.0;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.loginTextButtonColor,
        elevation: 1,
        title: Text(
          isEdit ? context.localization.editTransaction : context.localization.addIncomeAndExpenses,
          style: const TextStyle(color: Colors.white,fontSize: 22),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                padding,
                padding,
                padding,
                padding + media.viewInsets.bottom + 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: height -
                        kToolbarHeight -
                        media.padding.top -
                        media.padding.bottom,
                    maxWidth: 520, // tablet friendly
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: width * 0.1),

                      /// Title
                      Text(
                        isEdit ? context.localization.updateTransaction : context.localization.addIncomeAndExpenses,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      /// Amount Field
                      Obx(() {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: controller.amountCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: context.localization.amountOfMoney,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              suffixText:
                              "৳ ${controller.calculatedAmount.value.toStringAsFixed(0)}",
                              suffixStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.withValues(alpha: 0.15),
                              ),
                            ),
                            onChanged: controller.onAmountChanged,
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      /// Type Selector + Date
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              return Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: TransactionType.values.map((type) {
                                    final selected = controller.type.value == type;
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          controller.type.value = type;
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                          const Duration(milliseconds: 250),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? Colors.white
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: selected
                                                ? [
                                              BoxShadow(
                                                color:
                                                Colors.black.withValues(alpha: 0.06),
                                                blurRadius: 8,
                                              )
                                            ]
                                                : [],
                                          ),
                                          child: Text(
                                            type == TransactionType.income
                                                ? context.localization.income
                                                : context.localization.expense,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'HindSiliguri',
                                              color: type == TransactionType.income
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() {
                              return InkWell(
                                onTap: () async {
                                  final now = DateTime.now();
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: controller.selectedDate.value,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                    helpText: context.localization.selectDate,
                                    cancelText: context.localization.cancel,
                                    confirmText: context.localization.confirm,
                                    fieldLabelText: context.localization.date,
                                    fieldHintText: 'DD/MM/YYYY',
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: AppColors.bannerTopColor, // header background
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black87,
                                          ),
                                          datePickerTheme: DatePickerThemeData(
                                            cancelButtonStyle: TextButton.styleFrom(
                                              foregroundColor: Colors.red, // ❌ Cancel = Red
                                            ),
                                            confirmButtonStyle: TextButton.styleFrom(
                                              foregroundColor: Colors.green, // ✅ Confirm = Green
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },

                                  );

                                  if (date != null) controller.pickDate(date);
                                },
                                child: InputDecorator(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ).toInputDecoration(),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('dd MMM yyyy').format(controller.selectedDate.value),
                                      ),
                                      Icon(Icons.calendar_today, size: 20),

                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),

                        ],
                      ),
                      const SizedBox(height: 24),

                      /// Category Card
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text(
                                'CATEGORY SELECT',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Obx(() {
                              final list = controller.type.value == TransactionType.income
                                  ? controller.incomeCategories
                                  : controller.expenseCategories;
                              return SizedBox(
                                height: 110,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: list.length,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  itemBuilder: (context, i) {
                                    final cat = list[i];
                                    return Obx(() {
                                      final isSelected =
                                          controller.selectedCategory.value?.name == cat.name;
                                      return GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          controller.selectedCategory.value = cat;
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 100),
                                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: isSelected ? 0 : 8),
                                          padding: const EdgeInsets.all(6),
                                          width: 80,
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.white : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: isSelected
                                                ? [
                                              BoxShadow(
                                                color: Colors.blue.withValues(alpha: 0.25),
                                                blurRadius: 12,
                                                offset: const Offset(0, 6),
                                              ),
                                              BoxShadow(
                                                color: Colors.blue.withValues(alpha: 0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, -2),
                                              ),
                                            ]
                                                : [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.03),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              AnimatedContainer(
                                                duration: const Duration(milliseconds: 100),
                                                height: isSelected ? 58 : 48,
                                                width: isSelected ? 58 : 48,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.05),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  CategoryIcons.fromId(cat.iconId),
                                                  size: isSelected ? 28 : 24,
                                                  color: isSelected ? Colors.blue : Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                child: Text(
                                                  cat.name,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                    isSelected ? FontWeight.bold : FontWeight.normal,
                                                    color: isSelected ? Colors.blue : Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                ),
                              );
                            }),

                            /// Smart Other Category Field
                            Obx(() {
                              if (controller.selectedCategory.value?.name != 'Other') return const SizedBox.shrink();
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.only(top: 12),
                                child: TextField(
                                  autofocus: true,
                                  controller: controller.otherCategoryCtrl,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    labelText: 'খরচের বর্ণনা লিখুন',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),



                      const SizedBox(height: 32),

                      /// Save Button
                      Obx(() {
                        return GestureDetector(
                          onTap: controller.isLoading.value
                              ? null
                              : controller.saveTransaction,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                colors: [AppColors.bannerTopColor, AppColors.bannerBottomColor],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: controller.isLoading.value
                                  ? const CircularProgressIndicator(
                                  color: Colors.white)
                                  : Text(
                                isEdit ? context.localization.reAdd : context.localization.add,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'HindSiliguri',
                                ),
                              ),
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

  @override
  void dispose() {
    Get.delete<AddTransactionController>();
    super.dispose();
  }
}

extension BoxDecorationToInputDecoration on BoxDecoration {
  InputDecoration toInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
