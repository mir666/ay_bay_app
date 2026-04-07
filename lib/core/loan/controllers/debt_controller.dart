import 'package:ay_bay_app/core/loan/models/debt_model.dart';
import 'package:ay_bay_app/core/services/notification_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DebtController extends GetxController {
  final box = GetStorage();
  static const String notificationDateTimeKey = 'notify_datetime';
  RxList<DebtModel> debts = <DebtModel>[].obs;
  RxBool showOwe = true.obs;

  DateTime get notifyDateTime {
    final value = box.read(notificationDateTimeKey);
    if (value == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, 21, 0);
    }
    return DateTime.parse(value);
  }

  static const String hasSeenNotificationHintKey = 'seen_notify_hint';
  bool get hasSeenNotificationHint => box.read(hasSeenNotificationHintKey) ?? false;

  void markNotificationHintSeen() {
    box.write(hasSeenNotificationHintKey, true);
  }

  @override
  void onInit() {
    super.onInit();
    if (!box.hasData(notificationDateTimeKey)) {
      final now = DateTime.now();
      final defaultTime = DateTime(now.year, now.month, now.day, 21, 0);
      box.write(notificationDateTimeKey, defaultTime.toIso8601String());
    }
    loadDebts();
  }

  void loadDebts() {
    final data = box.read<List>('debts');
    if (data != null) {
      debts.value = data
          .map((e) => DebtModel.fromJson(Map<String, dynamic>.from(e)))
          .where((d) => d.name.isNotEmpty && d.id.isNotEmpty)
          .toList();
    }
  }

  void saveDebts() async {
    box.write('debts', debts.map((e) => e.toJson()).toList());
  }

  double get totalOwe =>
      debts.where((d) => d.isOwe && !d.isCleared).fold(0.0, (sum, d) => sum + d.amount);

  double get totalReceive =>
      debts.where((d) => !d.isOwe && !d.isCleared).fold(0.0, (sum, d) => sum + d.amount);

  /// 🔹 Schedule Debt Notification
  void scheduleDebtNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) {
    // NotificationService ব্যবহার করে schedule করো
    NotificationService.showScheduledNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }

  /// 🔹 Add Debt with Notification
  Future<void> addDebt(DebtModel debt) async {
    debts.add(debt);
    saveDebts();

    int debtId;
    try {
      debtId = int.parse(debt.id);
    } catch (e) {
      debtId = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
    }

    // 🔹 Schedule Debt Reminder Notification
    await NotificationService.scheduleDebtReminder(debt.dueDate, debtId);

    print("Debt added and notification scheduled for ${debt.dueDate}");
  }

  /// 🔹 Update Debt with Notification Reschedule
  void updateDebt(DebtModel updatedDebt) async {
    int index = debts.indexWhere((d) => d.id == updatedDebt.id);
    int debtId = int.tryParse(updatedDebt.id) ?? DateTime.now().millisecondsSinceEpoch.remainder(2147483647);

    await NotificationService.cancelNotification(debtId);

    if (index != -1) {
      debts[index] = updatedDebt;
      debts.refresh();
      saveDebts();

      // Reschedule notification
      await NotificationService.scheduleDebtReminder(updatedDebt.dueDate, debtId);

      print("Debt updated and notification rescheduled for ${updatedDebt.dueDate}");
    }
  }

  /// 🔹 Toggle Cleared Status
  void toggleClear(DebtModel debt) async {
    debt.isCleared = !debt.isCleared;
    debts.refresh();
    saveDebts();
  }

  /// 🔹 Delete Debt and Cancel Notification
  void deleteDebt(DebtModel debt) async {
    int debtId = int.tryParse(debt.id) ?? DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
    await NotificationService.cancelNotification(debtId);

    debts.removeWhere((d) => d.id == debt.id);
    saveDebts();

    print("Debt deleted and notification canceled for ID $debtId");
  }
}