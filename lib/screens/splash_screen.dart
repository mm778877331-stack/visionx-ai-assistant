import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:visionx/screens/home_screen.dart';
import 'login_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  @override
  void initState() {
    super.initState();
    // ننتظر 4 ثواني (وقت كافي جداً للأنيميشن مرة واحدة) ثم ننتقل
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const VisionXApp()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/logo.png', // صورتك الثابتة
          width: 200, // حجم صغير وأنيق
        ),
      ),
    );
  }
}
