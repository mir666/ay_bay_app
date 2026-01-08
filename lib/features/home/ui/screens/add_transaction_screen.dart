
import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
import 'package:ay_bay_app/features/home/controllers/add_transaction_controller.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction; // ✅ ADD THIS

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

    /// ✅ IF EDIT MODE → PREFILL DATA
    if (widget.transaction != null) {
      final trx = widget.transaction!;
      controller.noteCtrl.text = trx.title;
      controller.amountCtrl.text = trx.amount.toString();
      controller.type.value = trx.type;
      controller.selectedDate.value = trx.date;
      controller.isMonthly.value = trx.isMonthly;

      controller.editingTransactionId = trx.id; // 👈 controller এ রাখতে হবে
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'লেনদেন এডিট করুন' : 'আয়-ব্যয় যোগ'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: Get.width * 0.3),

              Text(
                isEdit ? 'লেনদেন আপডেট করুন' : 'আয়-ব্যয় যোগ করুন',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 32),

              /// Title
              TextField(
                controller: controller.noteCtrl,
                decoration: const InputDecoration(labelText: 'বর্ণনা লিখুন'),
              ),

              const SizedBox(height: 12),

              /// Amount
              TextField(
                controller: controller.amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'টাকার পরিমাণ'),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  /// Type Dropdown
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

                  /// Date Picker
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
                            DateFormat(
                              'dd MMM yyyy',
                            ).format(controller.selectedDate.value),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /// Monthly Switch
              Obx(
                () => SwitchListTile(
                  title: const Text('মাসিক'),
                  value: controller.isMonthly.value,
                  onChanged: (v) => controller.isMonthly.value = v,
                ),
              ),

              const SizedBox(height: 20),

              /// Save / Update Button
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.saveTransaction,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : Text(
                          isEdit ? 'পুনরায় যোগ করুন' : 'যোগ করুন',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
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
