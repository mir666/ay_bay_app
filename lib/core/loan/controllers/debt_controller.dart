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

  void updateDebt(DebtModel updatedDebt) {
    int index = debts.indexWhere((d) => d.id == updatedDebt.id);
    if (index != -1) {
      debts[index] = updatedDebt;
      debts.refresh();
      saveDebts();
      _scheduleDebtNotification(updatedDebt);
    }
  }

  void toggleClear(DebtModel debt) {
    debt.isCleared = !debt.isCleared;
    debts.refresh();
    saveDebts();
    if (!debt.isCleared) _scheduleDebtNotification(debt);
  }

  void deleteDebt(DebtModel debt) {
    debts.removeWhere((d) => d.id == debt.id);
    saveDebts();
  }

  void _scheduleDebtNotification(DebtModel debt) {
    if (debt.isCleared) return;

    final DateTime notifyBase = box.read(notificationDateTimeKey) != null
        ? DateTime.parse(box.read(notificationDateTimeKey))
        : DateTime(debt.dueDate.year, debt.dueDate.month, debt.dueDate.day, 21, 0);

    final beforeNotify = DateTime(
      debt.dueDate.year,
      debt.dueDate.month,
      debt.dueDate.day - 2,
      notifyBase.hour,
      notifyBase.minute,
    );

    final dueNotify = DateTime(
      debt.dueDate.year,
      debt.dueDate.month,
      debt.dueDate.day,
      notifyBase.hour,
      notifyBase.minute,
    );

    final title = debt.isOwe ? 'টাকা পাওয়ার সময় আসছে' : 'টাকা ফেরত দেওয়ার সময় আসছে';
    final body = debt.isOwe
        ? 'আপনি ${debt.name} থেকে ${debt.amount.toStringAsFixed(0)} ৳ পাবেন।'
        : 'আপনি ${debt.name} কে ${debt.amount.toStringAsFixed(0)} ৳ দিতে হবে।';

    if (beforeNotify.isAfter(DateTime.now())) {
      NotificationService.showScheduledNotification(
        id: debt.id.hashCode,
        title: title,
        body: body,
        scheduledDate: beforeNotify,
      );
    }

    if (dueNotify.isAfter(DateTime.now())) {
      NotificationService.showScheduledNotification(
        id: debt.id.hashCode + 1,
        title: title,
        body: body,
        scheduledDate: dueNotify,
      );
    }
  }
}