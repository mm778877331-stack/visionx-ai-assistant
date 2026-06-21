import 'package:cloud_firestore/cloud_firestore.dart';

class ChatHistoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. جلب رسايل محادثة "معينة" (تم إضافة timeout للأمان)
  Future<List<Map<String, dynamic>>> getChatMessages(String chatId) async {
    // 🛑 فحص أولي: إذا كان الآيدي فارغ، لا تتعب نفسك ولا تتعب السيرفر
    if (chatId.isEmpty) return [];

    try {
      final docRef = _db.collection("sessions").doc(chatId);

      // 🕵️ فحص ذكي: هل المستند موجود أصلاً؟
      final docSnap = await docRef.get();
      if (!docSnap.exists) {
        print("⚠️ تنبيه: المحادثة $chatId غير موجودة في السيرفر بعد.");
        return [];
      }

      final snapshot = await docRef
          .collection("messages")
          .orderBy("timestamp", descending: false)
          .get()
          .timeout(const Duration(seconds: 15));

      return snapshot.docs
          .map((doc) => {"role": doc["role"], "text": doc["text"]})
          .toList();
    } catch (e) {
      print("❌ خطأ في جلب الرسائل: $e");
      return [];
    }
  }

  // 2. حفظ رسالة (التعديل الجوهري هنا لمنع التعليق)
  // 2. حفظ رسالة (نسخة الطوارئ - لا تعطل الواجهة أبداً)
  Future<void> saveMessage(String text, String role, String chatId) async {
    // الحفظ في الخلفية كما طلبت لضمان سلاسة الواجهة
    _saveToFirestore(text, role, chatId);
    print("🚀 جاري الحفظ في الخلفية لمحادثة: $chatId");
  }

  Future<void> _saveToFirestore(String text, String role, String chatId) async {
    try {
      // استخدام Future.wait مع التوقيت المستقطع الذي حددته
      await Future.wait([
        _db.collection('sessions').doc(chatId).collection('messages').add({
          'text': text,
          'role': role,
          'timestamp': FieldValue.serverTimestamp(),
        }),
        _db.collection('sessions').doc(chatId).set({
          'lastUpdate': FieldValue.serverTimestamp(),
          // تحديث العنوان تلقائياً إذا كانت الرسالة من المستخدم
          if (role == 'user')
            'title': text.length > 30 ? text.substring(0, 30) + "..." : text,
        }, SetOptions(merge: true)),
      ]).timeout(const Duration(seconds: 30));

      print("✅ تم الحفظ بنجاح فيsessions");
    } catch (e) {
      print("⚠️ عائق تقني في الحفظ (تجاهلناه لكي لا يعلق التطبيق): $e");
    }
  }

  // دالة جلب الجلسات (الدراور)
  Stream<QuerySnapshot> getAllSessions() {
    return _db
        .collection('sessions')
        .orderBy('lastUpdate', descending: true)
        .snapshots();
  }
}
