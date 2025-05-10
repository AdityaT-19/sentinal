import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentinal/controller/auth.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString name = ''.obs;
  final Rxn<DateTime> dob = Rxn<DateTime>(DateTime(DateTime.now().year - 19));

  final RxBool isLogin = true.obs;

  final RxBool ageVerified = false.obs;
  final RxBool isUploading = false.obs;
  final ImagePicker _picker = ImagePicker();
  final selectedAgePhoto = Rx<File?>(null);

  final AuthController authController = Get.find<AuthController>();
  void toggleLogin() {
    isLogin.value = !isLogin.value;
  }

  void createUserWithEmailAndPassword() {
    if (dob.value == null) {
      Get.snackbar(
        'Error',
        'Please select a date of birth.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (!ageVerified.value) {
      Get.snackbar(
        'Error',
        'Please verify your age.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
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

  /// Pick a photo from the gallery for age verification.
  Future<void> pickAgePhoto() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      selectedAgePhoto.value = File(pickedFile.path);
    }
  }

  Future<void> verifyAge() async {
    await pickAgePhoto();
    if (selectedAgePhoto.value == null) {
      Get.snackbar(
        'Error',
        'Please select a photo to verify your age.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isUploading.value = true;
    try {
      // Create a multipart request to your FastAPI endpoint.
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://sential.share.zrok.io/check_dob/'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('file', selectedAgePhoto.value!.path),
      );
      request.headers['skip_zrok_interstitial'] = 'true';
      // Optionally, send additional fields if needed.
      // request.fields['title'] = title;

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(respStr);

      if (jsonResponse['dob_found'] == true) {
        ageVerified.value = true;
        Get.snackbar(
          'Success',
          'Age verification successful.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        ageVerified.value = false;
        Get.snackbar(
          'Error',
          'Age verification failed. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload photo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
    }
  }
}
