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
    return Scaffold(
      appBar: AppBar(title: const Text('যোগ করুন'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: Get.height * 0.15),
              const Text(
                'মাসের বাজেট',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'যোগ করুন',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 40),

              // Amount Input
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'মোট টাকা',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'মাস ও তারিখ',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    selectedDate == null
                        ? 'তারিখ নির্বাচন করুন'
                        : DateFormat('MMMM yyyy').format(selectedDate!),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
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

                  Get.back(); // Close screen after adding/updating
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.loginTextButtonColor,
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                ),
                child: const Text(
                  'যোগ করুন',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
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
