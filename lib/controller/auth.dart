import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sentinal/bindings/login.dart';
import 'package:sentinal/bindings/video.dart';
import 'package:sentinal/models/user.dart';
import 'package:sentinal/screens/login.dart';
import 'package:sentinal/screens/video.dart';
import 'package:sentinal/services/firestore.dart';

class AuthController extends GetxController {
  final auth = FirebaseAuth.instance;
  Rxn<User> firebaseUser = Rxn<User>();
  Rxn<AppUser> appUser = Rxn<AppUser>();
  @override
  void onInit() {
    firebaseUser.bindStream(auth.authStateChanges());
    firebaseUser.listen((user) {
      if (user == null) {
        appUser.value = AppUser.empty;
      } else {
        appUser.bindStream(Firestore.instance.userStream(user.uid));
      }
    });
    ever(firebaseUser, handleAuthChanged);
    super.onInit();
  }

  void handleAuthChanged(User? user) async {
    if (user == null) {
      Get.offAll(() => LoginScreen(), binding: LoginBinding());
    } else {
      Get.offAll(() => VideoListScreen(), binding: VideoBinding());
    }
  }

  void createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    DateTime dob,
  ) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = auth.currentUser;
      await Firestore.instance.createUser(user!.uid, email, name, '', dob);
    } catch (e) {
      Get.snackbar('Error creating account', e.toString());
    }
  }

  void signInWithEmailAndPassword(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar('Error signing in', e.toString());
    }
  }

  void signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      Get.snackbar('Error signing out', e.toString());
    }
  }
}
