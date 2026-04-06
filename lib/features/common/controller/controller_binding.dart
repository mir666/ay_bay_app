import 'package:ay_bay_app/core/loan/controllers/debt_controller.dart';
import 'package:ay_bay_app/core/localization/controllers/localization_controller.dart';
import 'package:ay_bay_app/core/profile/controllers/user_controller.dart';
import 'package:ay_bay_app/core/settings/controllers/change_password_contoller.dart';
import 'package:ay_bay_app/core/settings/controllers/settings_controller.dart';
import 'package:ay_bay_app/features/auth/controllers/auth_controller.dart';
import 'package:ay_bay_app/features/common/transaction/controllers/add_transaction_controller.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:ay_bay_app/features/home/controllers/notification_controller.dart';
import 'package:get/get.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(HomeController());
    Get.put(AddTransactionController());
    Get.put(UserController());
    Get.put(ChangePasswordController());
    Get.put(SettingsController(), permanent: true);
    Get.put(LocaleController());
    Get.put(DebtController(), permanent: true);
    Get.put(NotificationController());
  }
}
