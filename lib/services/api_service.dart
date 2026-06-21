import "dart:async";
import "dart:convert";
import "dart:typed_data";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:http/http.dart" as http;
import "package:visionx/chat_history_service.dart";
import "package:flutter/services.dart";
// import "dart:io";
import '../env/.env.dart';

class ApiService {
  // ===================== إعدادات CloudRift =====================
  static const String _cloudRiftUrl = Env.apiUrl;
  static const String _defaultModel = Env.model; // ستحصل عليه مجاناً

  // ===================== إعدادات Tavily للبحث الذكي =====================
  static const String _tavilyApiKey = Env.tavilyKey; // ضع مفتاحك من tavily.com

  // ===================== البروتوكولات =====================
  final String _hishamProtocol = Env.hishamProtocol;
  final String _globalProtocol = Env.globalProtocol;

  // ===================== الخدمات =====================
  final ChatHistoryService _chatHistoryService = ChatHistoryService();
  bool _isGenerating = false;
  final List<Future> _queue = []; // نظام طابور الانتظار

  // ===================== المنشئ =====================
  ApiService();

  // ===================== 1. الدالة الرئيسية للمحادثة (مع طابور الانتظار) =====================
  Future<String> sendMessage(
    String prompt,
    List<Map<String, String>> history,
    String? chatId,
  ) async {
    final completer = Completer<String>();
    _queue.add(completer.future);

    if (_queue.length == 1) {
      _processQueue(prompt, history, chatId, completer);
    } else {
      await Future.delayed(Duration(seconds: 2));
      _processQueue(prompt, history, chatId, completer);
    }

    return completer.future;
  }

  Future<void> _processQueue(
    String prompt,
    List<Map<String, String>> history,
    String? chatId,
    Completer<String> completer,
  ) async {
    if (_isGenerating) {
      completer.complete("⚠️ يرجى الانتظار، يتم إنشاء الرد الحالي...");
      _queue.removeAt(0);
      return;
    }

    try {
      _isGenerating = true;
      final user = FirebaseAuth.instance.currentUser;

      if (chatId != null && history.isEmpty) {
        _handleNewChatTitle(chatId, prompt);
      }

      if (chatId != null) {
        _chatHistoryService.saveMessage(prompt, "user", chatId);
      }

      String activeProtocol = (user?.uid == Env.masterUid)
          ? _hishamProtocol
          : _globalProtocol;

      final intent = await _classifyIntent(prompt);
      String finalPrompt = prompt;

      if (intent["type"] == "news" && intent["confidence"] > 0.7) {
        final searchResult = await _searchWeb(prompt);
        finalPrompt = "$prompt\n\nمعلومات محدثة من البحث:\n$searchResult";
      }

      if (intent["type"] == "image" && intent["confidence"] > 0.7) {
        _isGenerating = false;
        _queue.removeAt(0);
        completer.complete("_IMAGE_QUERY_");
        return;
      }

      final fullPrompt = _buildContextPrompt(
        finalPrompt,
        history,
        activeProtocol,
      );
      String responseText = await _sendToCloudRift(fullPrompt);

      responseText = responseText
          .replaceAll(RegExp(r"^{|}$"), "")
          .replaceAll(RegExp(r"^|$"), "")
          .trim();

      if (chatId != null) {
        _chatHistoryService.saveMessage(responseText, "model", chatId);
        _updateLastMessage(chatId, responseText);
      }

      _isGenerating = false;
      _queue.removeAt(0);
      completer.complete(responseText);
    } catch (e) {
      _isGenerating = false;
      _queue.removeAt(0);
      print("❌ خطأ في VisionX: $e");

      try {
        final fallbackResponse = await _fallbackToFreeModel(prompt);
        completer.complete(fallbackResponse);
      } catch (_) {
        completer.complete("❌ عذراً، حدث خطأ: $e");
      }
    }
  }

  // ===================== 2. الاتصال بـ CloudRift =====================
  Future<String> _sendToCloudRift(String prompt) async {
    final response = await http
        .post(
          Uri.parse(_cloudRiftUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "model": _defaultModel,
            "messages": [
              {"role": "user", "content": prompt},
            ],
            "temperature": 0.7,
            "max_tokens": 1000,
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      throw Exception("CloudRift API error: ${response.statusCode}");
    }
  }

  // ===================== 3. النموذج الاحتياطي المجاني =====================
  Future<String> _fallbackToFreeModel(String prompt) async {
    return "⚠️ النموذج الرئيسي غير متاح، جرب مرة أخرى.";
  }

  // ===================== 4. التصنيف الذكي =====================
  Future<Map<String, dynamic>> _classifyIntent(String prompt) async {
    try {
      final response = await http
          .post(
            Uri.parse(_cloudRiftUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "model": _defaultModel,
              "messages": [
                {
                  "role": "system",
                  "content":
                      "أنت مصنف ذكي. صنف طلب المستخدم إلى واحدة من هذه الفئات فقط:\n"
                      "1.  image  - إذا طلب رسم أو صورة أو تصميم\n"
                      "2.  news  - إذا طلب معلومات حديثة أو أخبار أو أحداث جارية\n"
                      "3.  general  - لأي شيء آخر\n"
                      "أخرج فقط اسم الفئة، بدون أي كلمات أخرى.",
                },
                {"role": "user", "content": prompt},
              ],
              "temperature": 0.1,
              "max_tokens": 10,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String intent = data["choices"][0]["message"]["content"]
            .trim()
            .toLowerCase();
        return {"type": intent, "confidence": 0.9};
      }
      return {"type": "general", "confidence": 0.5};
    } catch (e) {
      print("⚠️ فشل التصنيف الذكي: $e");
      return {"type": "general", "confidence": 0.5};
    }
  }

  // ===================== 5. البحث الذكي (Tavily) =====================
  Future<String> _searchWeb(String query) async {
    try {
      final response = await http
          .post(
            Uri.parse("https://api.tavily.com/search"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "api_key": _tavilyApiKey,
              "query": query,
              "search_depth": "advanced",
              "max_results": 3,
              "include_answer": true,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data["answer"] ?? "";
        final results = data["results"] as List? ?? [];

        String resultText = answer.isNotEmpty ? answer : "";
        for (var res in results) {
          resultText += "\n- ${res["title"]}: ${res["content"]}";
        }
        return resultText.isNotEmpty ? resultText : "لم أجد نتائج.";
      }
      return "لم أجد نتائج.";
    } catch (e) {
      return "عذراً، لا يمكنني البحث حالياً.";
    }
  }

  // ===================== 6. دوال مساعدة =====================
  String _buildContextPrompt(
    String prompt,
    List<Map<String, String>> history,
    String protocol,
  ) {
    StringBuffer contextBuffer = StringBuffer();
    contextBuffer.writeln(protocol);
    contextBuffer.writeln();

    if (history.isNotEmpty) {
      contextBuffer.writeln("[السياق]:");
      int start = (history.length > 10) ? history.length - 10 : 0;
      for (int i = start; i < history.length; i++) {
        String role = (history[i]["role"] == "user") ? "المستخدم" : "Vision X";
        contextBuffer.writeln("$role: ${history[i]["message"]}");
      }
      contextBuffer.writeln();
    }

    contextBuffer.writeln("المستخدم: $prompt");
    return contextBuffer.toString();
  }

  // ===================== 7. توليد الصور =====================
  Future<Uint8List?> generateImage(String prompt) async {
    try {
      String cleanPrompt = prompt
          .replaceAll(RegExp(r"[#%&?]"), "")
          .replaceAll(RegExp(r"\s+"), " ")
          .trim();

      final encodedPrompt = Uri.encodeComponent(cleanPrompt);
      final random = DateTime.now().millisecondsSinceEpoch;
      final url =
          "https://image.pollinations.ai/prompt/$encodedPrompt?width=512&height=512&nologo=true&_=$random";

      print("🎨 جاري توليد الصورة...");

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception("الخادم بطيء، حاول مرة أخرى"),
          );

      if (response.statusCode == 200) {
        if (response.bodyBytes.length > 100 &&
            (response.bodyBytes[0] == 0x89 || response.bodyBytes[0] == 0xFF)) {
          print("✅ تم توليد الصورة بنجاح");
          return response.bodyBytes;
        } else {
          final errorText = utf8.decode(response.bodyBytes);
          print("❌ الخادم رفض الطلب: $errorText");
          return null;
        }
      } else {
        print("❌ فشل: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("🚨 خطأ في توليد الصورة: $e");
      return null;
    }
  }

  // ===================== 8. دوال Firebase =====================
  Future<void> _handleNewChatTitle(String chatId, String firstMsg) async {
    String title = await generateTitle(firstMsg);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("chats")
          .doc(chatId)
          .set({
            "title": title,
            "lastMessage": firstMsg,
            "timestamp": FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    }
  }

  Future<void> _updateLastMessage(String chatId, String lastMsg) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("chats")
          .doc(chatId)
          .set({
            "lastMessage": lastMsg,
            "timestamp": FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    }
  }

  Future<String> generateTitle(String firstMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_cloudRiftUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "model": _defaultModel,
          "messages": [
            {
              "role": "system",
              "content": "لخص هذا السؤال في كلمتين فقط كعنوان:",
            },
            {"role": "user", "content": firstMessage},
          ],
          "temperature": 0.3,
          "max_tokens": 20,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String title = data["choices"][0]["message"]["content"]
            .toString()
            .trim();
        if (title.length > 50) title = title.substring(0, 50);
        return title;
      }
      return "محادثة جديدة";
    } catch (e) {
      return "محادثة جديدة";
    }
  }

  Stream<String> sendMessageStream(
    String prompt,
    List<Map<String, String>> history,
    String? chatId,
  ) async* {
    final result = await sendMessage(prompt, history, chatId);
    yield result;
  }

  void resetChat() {
    // إعادة تعيين المحادثة
  }
}
