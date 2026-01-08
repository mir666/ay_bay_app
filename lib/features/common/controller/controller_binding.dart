
import 'package:ay_bay_app/features/auth/controllers/auth_controller.dart';
import 'package:ay_bay_app/features/home/controllers/add_transaction_controller.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:get/get.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(HomeController());
    Get.put(AddTransactionController());
  }
}
