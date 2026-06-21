import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static void showHishamLogin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مؤشر السحب
            Container(
              width: 45,
              height: 5,
              margin: const EdgeInsets.only(bottom: 25),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Text(
              "VisionX Login",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // زر جوجل (الألوان الرسمية)
            _authBtn(
              "Continue with Google",
              FontAwesomeIcons.google,
              const Color(0xFF4285F4), // Google Blue
              () => _handleGoogleSignIn(context),
            ),
            const SizedBox(height: 15),

            // زر جيت هب (اللون الأسود)
            _authBtn(
              "Continue with GitHub",
              FontAwesomeIcons.github,
              const Color(0xFF181717), // GitHub Black
              () => _handleGitHubSignIn(context),
            ),
            const SizedBox(height: 15),

            // زر أبل
            _authBtn(
              "Continue with Apple",
              FontAwesomeIcons.apple,
              Colors.black,
              () => debugPrint("Apple Login Clicked"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- منطق جوجل ---
  static Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (context.mounted) {
        Navigator.pop(context);
        _showSuccessSnack(context, "Welcome ${googleUser.displayName}!");
      }
    } catch (e) {
      debugPrint("Google Error: $e");
    }
  }

  // --- منطق جيت هب (المعدل) ---
  static Future<void> _handleGitHubSignIn(BuildContext context) async {
    try {
      // تعريف مزود خدمة جيت هب
      GithubAuthProvider githubProvider = GithubAuthProvider();

      // فتح المتصفح لتسجيل الدخول
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithProvider(githubProvider);

      if (context.mounted) {
        Navigator.pop(context);
        _showSuccessSnack(
          context,
          "GitHub Login Successful: ${userCredential.user?.displayName}",
        );
      }
    } catch (e) {
      debugPrint("GitHub Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("GitHub Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- تصميم الزر ---
  static Widget _authBtn(
    String text,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12, width: 1.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: iconColor, size: 22),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  static void _showSuccessSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
