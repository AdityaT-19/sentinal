import 'package:get/get.dart';
import 'package:sentinal/controller/auth.dart';

class LoginController extends GetxController {
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString name = ''.obs;
  final Rxn<DateTime> dob = Rxn<DateTime>(DateTime(DateTime.now().year - 19));

  final RxBool isLogin = true.obs;

  final AuthController authController = Get.find<AuthController>();
  void toggleLogin() {
    isLogin.value = !isLogin.value;
  }

  void createUserWithEmailAndPassword() {
    authController.createUserWithEmailAndPassword(
      email.value,
      password.value,
      name.value,
      dob.value!,
    );
    print('Date of Birth: ${dob.value}');
  }

  void signInWithEmailAndPassword() {
    authController.signInWithEmailAndPassword(email.value, password.value);
  }
}
