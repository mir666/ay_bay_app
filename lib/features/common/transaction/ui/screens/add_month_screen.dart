import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddMonthScreen extends StatefulWidget {
  const AddMonthScreen({super.key});

  @override
  State<AddMonthScreen> createState() => _AddMonthScreenState();
}

class _AddMonthScreenState extends State<AddMonthScreen> {
  final controller = Get.find<HomeController>();
  final mode = Get.arguments ?? 'NEW_MONTH';
  final amountCtrl = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = media.size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.loginTextButtonColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          mode == 'NEW_MONTH'
              ? context.localization.addMonth
              : context.localization.budgetUpdate,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'HindSiliguri',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            24,
            16,
            24 + media.viewInsets.bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: height -
                    kToolbarHeight -
                    media.padding.top -
                    media.padding.bottom,
                maxWidth: 480, // tablet safe
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // 🔥 CENTER
                children: [
                  /// Header
                  Text(
                    context.localization.monthlyBudget,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.localization.add,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      fontFamily: 'HindSiliguri',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  /// Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// Amount
                        TextField(
                          controller: amountCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            labelText: context.localization.totalAmount,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// Date Picker
                        InkWell(
                          onTap: () async {
                            final now = DateTime.now();
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? now,
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
                                      primary: AppColors.bannerTopColor,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black87,
                                    ),
                                    datePickerTheme: DatePickerThemeData(
                                      cancelButtonStyle:
                                      TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      confirmButtonStyle:
                                      TextButton.styleFrom(
                                        foregroundColor: Colors.green,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.textFieldBorderColor,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDate != null
                                      ? DateFormat('dd MMM yyyy')
                                      .format(selectedDate!)
                                      : context.localization.selectDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: AppColors.bannerBottomColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Submit Button
                  GestureDetector(
                    onTap: () async {
                      if (amountCtrl.text.trim().isEmpty) {
                        Get.snackbar('Error', 'Please enter an amount');
                        return;
                      }
                      if (selectedDate == null) {
                        Get.snackbar('Error', 'Please select a date');
                        return;
                      }

                      final amount =
                      double.tryParse(amountCtrl.text.trim());
                      if (amount == null) {
                        Get.snackbar('Error', 'Invalid amount');
                        return;
                      }

                      if (mode == 'NEW_MONTH') {
                        await controller.addMonth(
                          monthDate: selectedDate!,
                          openingBalance: amount,
                        );
                      } else {
                        await controller.updateCurrentMonthBudget(amount);
                      }

                      controller.canAddTransaction.value = true;
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.bannerTopColor,
                            AppColors.bannerBottomColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.blue.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          context.localization.add,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
