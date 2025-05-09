import 'package:get/get.dart';
import 'package:sentinal/controller/auth.dart';
import 'package:sentinal/services/firestore.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(Firestore(), permanent: true);
  }
}
