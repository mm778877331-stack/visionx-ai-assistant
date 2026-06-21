import  'package:flutter/material.dart' ;
import  'package:firebase_auth/firebase_auth.dart' ;

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // دالة التسجيل (إنشاء حساب جديد)
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      print("🎯 تم إنشاء الحساب: ${result.user?.uid}");
      return result.user;
    } catch (e) {
      print("❌ خطأ في التسجيل: $e");
      return null;
    }
  }

  // دالة تسجيل الدخول
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      print("🎯 تم الدخول: ${result.user?.uid}");
      return result.user;
    } catch (e) {
      print("❌ خطأ في الدخول: $e");
      return null;
    }
  }
}