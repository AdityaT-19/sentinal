import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sentinal/controller/login.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  // Helper function to build input fields with icons
  InputDecoration buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Get.theme.primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Get.theme.primaryColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find<LoginController>();
    final formKey = GlobalKey<FormState>();
    final TextEditingController dobController = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Get.theme.primaryColor, Get.theme.colorScheme.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 40.0,
            ),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        "Welcome to Sentinel",
                        style: Get.textTheme.headlineMedium?.copyWith(
                          color: Get.theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Email Field
                      TextFormField(
                        decoration: buildInputDecoration('Email', Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        onChanged:
                            (value) => loginController.email.value = value,
                        validator:
                            (value) =>
                                (value?.isEmpty ?? true)
                                    ? 'Please enter your email'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      TextFormField(
                        decoration: buildInputDecoration(
                          'Password',
                          Icons.lock,
                        ),
                        obscureText: true,
                        onChanged:
                            (value) => loginController.password.value = value,
                        validator:
                            (value) =>
                                (value?.isEmpty ?? true)
                                    ? 'Please enter your password'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      // Additional Fields for Signup Mode
                      Obx(() {
                        if (!loginController.isLogin.value) {
                          return Column(
                            children: [
                              TextFormField(
                                decoration: buildInputDecoration(
                                  'Name',
                                  Icons.person,
                                ),
                                onChanged:
                                    (value) =>
                                        loginController.name.value = value,
                                validator:
                                    (value) =>
                                        (value?.isEmpty ?? true)
                                            ? 'Please enter your name'
                                            : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: dobController,
                                decoration: buildInputDecoration(
                                  'Date of Birth',
                                  Icons.calendar_today,
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    loginController.dob.value = date;
                                    dobController.text = DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(loginController.dob.value!);
                                  }
                                },
                                validator:
                                    (value) =>
                                        (value?.isEmpty ?? true)
                                            ? 'Please select your date of birth'
                                            : null,
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      // Submit Button
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            if (loginController.isLogin.value) {
                              loginController.signInWithEmailAndPassword();
                            } else {
                              loginController.createUserWithEmailAndPassword();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 32,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 10,
                        ),
                        child: Obx(() {
                          return Text(
                            loginController.isLogin.value
                                ? 'Login'
                                : 'Create Account',
                            style: Get.textTheme.labelMedium?.copyWith(
                              fontSize: 16,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      // Toggle Login/Signup Mode
                      TextButton(
                        onPressed: loginController.toggleLogin,
                        child: Obx(() {
                          return Text(
                            loginController.isLogin.value
                                ? "Don't have an account? Create one"
                                : "Already have an account? Login",
                            style: Get.textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
