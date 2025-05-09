import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentinal/bindings/auth.dart';
import 'package:sentinal/models/video.dart';
import 'package:sentinal/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentinal/screens/login.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      initialBinding: AuthBinding(),
      home: HomeScreen(),
    );
  }
}
