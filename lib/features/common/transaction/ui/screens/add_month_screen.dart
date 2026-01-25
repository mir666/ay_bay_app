import 'package:ay_bay_app/app/app_colors.dart';
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
  final mode = Get.arguments ?? 'NEW_MONTH'; // Mode from arguments
  final amountCtrl = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          mode == 'NEW_MONTH' ? 'মাস যোগ করুন' : 'বাজেট আপডেট',
          style: const TextStyle(color: Colors.black,fontFamily: 'HindSiliguri',),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 24 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              SizedBox(height: height * 0.05),

              /// Header Text
              const Text(
                'মাসের বাজেট',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'যোগ করুন',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  fontFamily: 'HindSiliguri',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              /// Card-style Inputs
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
                    /// Amount Input
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
                        labelText: 'মোট টাকা',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        suffixText: '৳',
                        prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Date Picker
                    /// Smart Date Picker Widget
                    InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? now,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          helpText: 'তারিখ নির্বাচন করুন',
                          cancelText: 'বাতিল',
                          confirmText: 'নিশ্চিত',
                          fieldLabelText: 'তারিখ',
                          fieldHintText: 'DD/MM/YYYY',
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.bannerTopColor, // Header background
                                  onPrimary: Colors.white, // Header text
                                  onSurface: Colors.black87, // Body text
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.bannerTopColor, // Button text
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.textFieldBorderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate != null
                                  ? DateFormat('dd MMM yyyy').format(selectedDate!)
                                  : 'তারিখ নির্বাচন করুন',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Icon(Icons.calendar_today, size: 20),
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
                  // Validation
                  if (amountCtrl.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Please enter an amount');
                    return;
                  }
                  if (selectedDate == null) {
                    Get.snackbar('Error', 'Please select a date');
                    return;
                  }

                  final amount = double.tryParse(amountCtrl.text.trim());
                  if (amount == null) {
                    Get.snackbar('Error', 'Invalid amount');
                    return;
                  }

                  // Call HomeController methods
                  if (mode == 'NEW_MONTH') {
                    await controller.addMonth(
                      monthDate: selectedDate!,
                      openingBalance: amount,
                    );
                  } else if (mode == 'UPDATE_BUDGET') {
                    await controller.updateCurrentMonthBudget(amount);
                  }
                  controller.canAddTransaction.value = true;
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [AppColors.bannerTopColor, AppColors.bannerBottomColor],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'যোগ করুন',
                      style: TextStyle(
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
    );
  }
}

/// Extension to convert BoxDecoration to InputDecoration
extension BoxDecorationToInputDecoration on BoxDecoration {
  InputDecoration toInputDecoration({String? labelText, Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: labelText,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
