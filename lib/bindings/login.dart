import 'package:get/get.dart';
import 'package:sentinal/controller/login.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
