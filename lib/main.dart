import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:visionx/screens/home_screen.dart';
// استدعاء الملفات اللي سويناها (تأكد من المسارات صح)
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // كود التوكن حقك (خليه شغال)
  String? token = await FirebaseMessaging.instance.getToken();
  print("🔑 HISHAM_TOKEN: $token");

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vision X',
      // هنا "السر": البداية من شاشة السبراش اللي فيها الـ JSON
      home: const MySplashScreen(),
      // theme: ThemeData(
      //   scaffoldBackgroundColor: Colors.white,
      //   brightness: Brightness.light,
      // ),
    ),
  );
}
