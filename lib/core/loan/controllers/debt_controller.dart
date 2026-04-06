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

  void addDebt(DebtModel debt) {
    debts.add(debt);
    saveDebts();
    _scheduleDebtNotification(debt);
  }

  void updateDebt(DebtModel updatedDebt) async {
    int index = debts.indexWhere((d) => d.id == updatedDebt.id);

    if (index != -1) {
      await NotificationService.cancelNotification(updatedDebt.id.hashCode);
      await NotificationService.cancelNotification(updatedDebt.id.hashCode + 1);

      debts[index] = updatedDebt;
      debts.refresh();
      saveDebts();

      _scheduleDebtNotification(updatedDebt);
    }
  }

  void toggleClear(DebtModel debt) async {
    debt.isCleared = !debt.isCleared;

    debts.refresh();
    saveDebts();

    if (debt.isCleared) {
      await NotificationService.cancelNotification(debt.id.hashCode);
      await NotificationService.cancelNotification(debt.id.hashCode + 1);
    } else {
      _scheduleDebtNotification(debt);
    }
  }

  void deleteDebt(DebtModel debt) async {
    await NotificationService.cancelNotification(debt.id.hashCode);
    await NotificationService.cancelNotification(debt.id.hashCode + 1);

    debts.removeWhere((d) => d.id == debt.id);
    saveDebts();
  }

  void _scheduleDebtNotification(DebtModel debt) {
    if (debt.isCleared) return;

    final now = DateTime.now();
    final notifyBase = DateTime(
      debt.dueDate.year,
      debt.dueDate.month,
      debt.dueDate.day,
      debt.dueDate.hour,
      debt.dueDate.minute,
    );

    final daysDifference = debt.dueDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    DateTime beforeNotify;

    if (daysDifference <= 0) {
      // আজকের debt → 1 hour আগে
      beforeNotify = notifyBase.subtract(Duration(hours: 1));
    } else if (daysDifference == 2) {
      // 2 দিন পর → 1 day আগে
      beforeNotify = notifyBase.subtract(Duration(days: 1));
    } else {
      // 2 দিনের বেশি → 2 দিন আগে
      beforeNotify = notifyBase.subtract(Duration(days: 2));
    }

    // 🔹 Ensure notification is in future
    if (beforeNotify.isAfter(now)) {
      NotificationService.showScheduledNotification(
        id: debt.id.hashCode,
        title: debt.isOwe ? 'টাকা পাওয়ার সময় আসছে' : 'টাকা ফেরত দেওয়ার সময় আসছে',
        body: debt.isOwe
            ? 'আপনি ${debt.name} থেকে ${debt.amount.toStringAsFixed(0)} ৳ পাবেন।'
            : 'আপনি ${debt.name} কে ${debt.amount.toStringAsFixed(0)} ৳ দিতে হবে।',
        scheduledDate: beforeNotify,
      );
    }

    // 🔹 Due date notification at exact time
    if (notifyBase.isAfter(now)) {
      NotificationService.showScheduledNotification(
        id: debt.id.hashCode + 100000,
        title: debt.isOwe ? 'টাকা পাওয়ার সময় আসছে' : 'টাকা ফেরত দেওয়ার সময় আসছে',
        body: debt.isOwe
            ? 'আপনি ${debt.name} থেকে ${debt.amount.toStringAsFixed(0)} ৳ পাবেন।'
            : 'আপনি ${debt.name} কে ${debt.amount.toStringAsFixed(0)} ৳ দিতে হবে।',
        scheduledDate: notifyBase,
      );
    }
  }
}