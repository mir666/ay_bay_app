import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:ay_bay_app/core/loan/controllers/debt_controller.dart';
import 'package:ay_bay_app/core/loan/models/debt_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DebtDueScreen extends StatefulWidget {
  const DebtDueScreen({super.key});

  @override
  State<DebtDueScreen> createState() => _DebtDueScreenState();
}

class _DebtDueScreenState extends State<DebtDueScreen> {
  final DebtController controller = Get.find<DebtController>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(context.localization.loan,style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: AppColors.loginTextButtonColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.loginTextButtonColor,
        child: Icon(Icons.add,color: Colors.white,),
        onPressed: () => _showAddDialog(context),
      ),
      body: Column(
        children: [
          _summary(context),
          _toggle(context),
          Expanded(child: _list(context)),
        ],
      ),
    );
  }

  /// 🔹 Summary Cards
  Widget _summary(BuildContext context) {
    return Obx(() => Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _summaryCard(context.localization.totalDebt, controller.totalOwe, Colors.redAccent),
          const SizedBox(width: 12),
          _summaryCard(context.localization.totalDue, controller.totalReceive, Colors.green),
        ],
      ),
    ));
  }

  Widget _summaryCard( String title, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: .7), color],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: Colors.white70,fontSize: 16,fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              '${amount.toStringAsFixed(0)} ৳',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Toggle
  Widget _toggle(BuildContext context) {
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _toggleBtn(context.localization.debt, true),
          _toggleBtn(context.localization.due, false),
        ],
      ),
    ));
  }

  Widget _toggleBtn(String text, bool isOwe) {
    final selected = controller.showOwe.value == isOwe;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.showOwe.value = isOwe,
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.loginTextButtonColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 List

  Widget _list(BuildContext context) {
    final controller = Get.find<DebtController>();

    return Obx(() {
      final list = controller.debts
          .where((d) => d.isOwe == controller.showOwe.value)
          .toList();

      if (list.isEmpty) {
        return Center(
          child: Text(
            context.localization.noData,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        );
      }

      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) {
          final d = list[i];
          final formattedDate = DateFormat('dd MMM, yyyy',Get.locale?.languageCode ?? 'en').format(d.date);

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: d.isOwe
                    ? Colors.redAccent.withValues(alpha: .3)
                    : Colors.green.withValues(alpha: .3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                /// 🔹 Leading Icon
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: d.isOwe
                        ? Colors.redAccent.withValues(alpha: .12)
                        : Colors.green.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    d.isOwe ? Icons.trending_down : Icons.trending_up,
                    color: d.isOwe ? Colors.redAccent : Colors.green,
                  ),
                ),

                SizedBox(width: 12),

                /// 🔹 Name + Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          decoration:
                          d.isCleared ? TextDecoration.lineThrough : null,
                          color: d.isCleared ? Colors.grey : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🔹 Amount
                Text(
                  '${d.amount.toStringAsFixed(0)} ৳',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: d.isOwe ? Colors.redAccent : Colors.green,
                  ),
                ),

                SizedBox(width: 24),

                /// 🔹 Edit Button
                GestureDetector(
                  onTap: () {
                    _showEditDialog(context,d); // Edit dialog function বানাতে হবে
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent.withValues(alpha: .15),
                    ),
                    child: Icon(
                      Icons.edit_note,
                      color: Colors.blueAccent,
                      size: 24,
                    ),
                  ),
                ),

                SizedBox(width: 8),

                /// 🔹 Delete Button
                GestureDetector(
                  onTap: () {
                    Get.dialog(
                      Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: EdgeInsets.all(20),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.localization.confirmToDelete,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${d.name} ${context.localization.wantToDeleteThisDebtDue}',
                                textAlign: TextAlign.center,
                                style:
                                const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Get.back(),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: Text(context.localization.no,style: TextStyle(color: Colors.green),),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        controller.deleteDebt(d);
                                        Get.back();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(14),
                                        ),
                                        elevation: 8,
                                      ),
                                      child: Text(
                                        context.localization.yes,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent.withValues(alpha: .15),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final RxBool isOwe = true.obs;

    final Rx<DateTime> selectedDate = DateTime.now().add(const Duration(days: 1)).obs;
    final Rx<TimeOfDay> selectedTime = const TimeOfDay(hour: 21, minute: 0).obs;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text(context.localization.newDebtDue, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              /// Name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: context.localization.personName,
                  prefixIcon: Icon(Icons.person_2_outlined, color: Colors.grey.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),

              /// Amount
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.localization.money,
                  prefixIcon: Icon(Icons.currency_exchange, color: Colors.grey.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),

              /// Date Picker
              Obx(() => _datePickerField(context, selectedDate.value, (picked) { selectedDate.value = picked; })),
              const SizedBox(height: 14),

              /// Time Picker
              Obx(() => GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: selectedTime.value);
                  if (picked != null) selectedTime.value = picked;
                },
                child: _timePickerField(context, selectedTime.value),
              )),
              const SizedBox(height: 14),

              /// Owe / Receive Toggle
              Obx(() => Row(
                children: [
                  _typeButton(title: context.localization.debt, selected: isOwe.value, color: Colors.redAccent, onTap: () => isOwe.value = true),
                  _typeButton(title: context.localization.due, selected: !isOwe.value, color: Colors.green, onTap: () => isOwe.value = false),
                ],
              )),
              const SizedBox(height: 26),

              /// Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(onPressed: () => Get.back(), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text(context.localization.cancel, style: const TextStyle(color: Colors.red))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty || amountController.text.isEmpty) return;

                        final dueDateTime = DateTime(
                          selectedDate.value.year,
                          selectedDate.value.month,
                          selectedDate.value.day,
                          selectedTime.value.hour,
                          selectedTime.value.minute,
                        );

                        controller.addDebt(DebtModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text.trim(),
                          amount: double.tryParse(amountController.text) ?? 0,
                          isOwe: isOwe.value,
                          date: dueDateTime,
                          dueDate: dueDateTime,
                        ));

                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.loginTextButtonColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 8,
                      ),
                      child: Text(context.localization.save, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Time Picker Display Field
  Widget _timePickerField(BuildContext context, TimeOfDay time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: AppColors.loginTextButtonColor),
          const SizedBox(width: 16),
          Text(
            time.format(context),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Spacer(),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  /// 🔹 Toggle Button
  Widget _typeButton({
    required String title,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, DebtModel debt) {
    final nameController = TextEditingController(text: debt.name);
    final amountController = TextEditingController(text: debt.amount.toString());
    final RxBool isOwe = debt.isOwe.obs;

    final Rx<DateTime> selectedDate = debt.dueDate.obs;
    final Rx<TimeOfDay> selectedTime = TimeOfDay.fromDateTime(debt.dueDate).obs;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              Row(
                children: [
                  const Icon(Icons.edit, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text(context.localization.editDebtDue, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              /// Name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: context.localization.personName,
                  prefixIcon: Icon(Icons.person_2_outlined, color: Colors.grey.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),

              /// Amount
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.localization.money,
                  prefixIcon: Icon(Icons.currency_exchange, color: Colors.grey.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),

              /// Date Picker
              Obx(() => _datePickerField(context, selectedDate.value, (picked) { selectedDate.value = picked; })),
              const SizedBox(height: 14),

              /// Time Picker
              Obx(() => GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: selectedTime.value);
                  if (picked != null) selectedTime.value = picked;
                },
                child: _timePickerField(context, selectedTime.value),
              )),
              const SizedBox(height: 14),

              /// Owe / Receive Toggle
              Obx(() => Row(
                children: [
                  _typeButton(title: context.localization.debt, selected: isOwe.value, color: Colors.redAccent, onTap: () => isOwe.value = true),
                  _typeButton(title: context.localization.due, selected: !isOwe.value, color: Colors.green, onTap: () => isOwe.value = false),
                ],
              )),
              const SizedBox(height: 26),

              /// Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(onPressed: () => Get.back(), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text(context.localization.cancel, style: const TextStyle(color: Colors.red))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty || amountController.text.isEmpty) return;

                        final updatedDateTime = DateTime(
                          selectedDate.value.year,
                          selectedDate.value.month,
                          selectedDate.value.day,
                          selectedTime.value.hour,
                          selectedTime.value.minute,
                        );

                        final updatedDebt = DebtModel(
                          id: debt.id,
                          name: nameController.text.trim(),
                          amount: double.tryParse(amountController.text) ?? 0,
                          isOwe: isOwe.value,
                          isCleared: debt.isCleared,
                          date: updatedDateTime,
                          dueDate: updatedDateTime,
                        );

                        controller.updateDebt(updatedDebt); // 🔹 এখানে notification reschedule হবে
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.loginTextButtonColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 8),
                      child: Text(context.localization.save, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime selectedDate = DateTime.now().add(Duration(days: 1));

  Widget _datePickerField(BuildContext context, DateTime selected, ValueChanged<DateTime> onChanged) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selected,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.loginTextButtonColor, // header color
                  onPrimary: Colors.white, // text color
                  onSurface: Colors.black87, // day text color
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.loginTextButtonColor, // button color
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onChanged(picked);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.loginTextButtonColor.withValues(alpha: 0.7), AppColors.loginTextButtonColor],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.calendar_month, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                DateFormat('dd MMM, yyyy').format(selected),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  void showNotificationDateTimePicker(BuildContext context) async {
    final controller = Get.find<DebtController>();

    // 📅 Date picker
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.notifyDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    // ⏰ Time picker
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(controller.notifyDateTime),
    );

    if (pickedTime == null) return;

    final selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    controller.box.write(
      DebtController.notificationDateTimeKey,
      selectedDateTime.toIso8601String(),
    );

    // 🔁 Reschedule all notifications
    for (final d in controller.debts) {
      controller.updateDebt(d);
    }

    Get.snackbar(
      'Saved',
      'নটিফিকেশন সেট হয়েছে '
          '${pickedDate.day}/${pickedDate.month}/${pickedDate.year} '
          '${pickedTime.format(context)}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}