import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

// استيراد الخدمات (تأكد أن الأسماء تطابق ملفاتك)
import '../services/api_service.dart';
import '../chat_history_service.dart';

// استيراد صفحة اللوجن (تأكد من المسار الصحيح لملفك)
import 'login_screen.dart';

// استيراد الأدوات
import '../widgets/chat_input_field.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/hero_section.dart ';
import '../widgets/loading_indicator.dart';

class VisionXApp extends StatefulWidget {
  const VisionXApp({super.key});
  @override
  State<VisionXApp> createState() => _VisionXAppState();
}

class _VisionXAppState extends State<VisionXApp> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isWriting = false;
  bool _isStopRequested = false;
  bool _isLowData = false;
  final ImagePicker _picker = ImagePicker();
  final ChatHistoryService _historyService = ChatHistoryService();

  String _loadingText = "جاري المعالجة..."; // القيمة الافتراضية

  // الذاكرة (History) التي ستُرسل للدماغ
  List<Map<String, String>> _chatHistory = [];

  String _currentChatId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _controller.addListener(() {
      if (mounted)
        setState(() => _isWriting = _controller.text.trim().isNotEmpty);
    });
  }

  void _loadHistory() async {
    try {
      final history = await _historyService.getChatMessages(_currentChatId);
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(history);
          // تحديث الذاكرة السحابية من الفايربيز عند فتح المحادثة
          _chatHistory = history
              .map(
                (m) => {
                  "role": m["role"] == "user" ? "user" : "model",
                  "text": m["text"].toString(),
                },
              )
              .toList();
        });
        _scrollToBottomManual();
      }
    } catch (e) {
      print("خطأ في جلب التاريخ: $e");
    }
  }

  void _sendToVisionX() async {
    // 1. حماية المفتاح والواجهة
    if (_controller.text.trim().isEmpty || _isLoading) return;

    final String userMsg = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add({"role": "user", "text": userMsg});
      _messages.add({"role": "ai", "text": ""}); // رسالة فارغة ستبدأ بالامتلاء
      _isLoading = true;
      _isStopRequested = false;
      _loadingText = "جاري التفكير..."; // البداية
    });

    _scrollToBottomManual();
    String fullAIResponse = "";

    try {
      // 2. فتح مجرى البيانات من الدماغ
      final stream = _apiService.sendMessageStream(
        userMsg,
        _chatHistory,
        _currentChatId,
      );

      await for (String textPart in stream) {
        if (_isStopRequested) break;

        // بمجرد وصول أول حرف، نغير النص فقط ونبقي الأيقونة تعمل
        if (fullAIResponse.isEmpty) {
          _isLoading = false;
          setState(() => _loadingText = "Vision X يكتب...");
        }

        fullAIResponse += textPart;

        setState(() {
          _messages.last["text"] = fullAIResponse; // تحديث النص حرف بحرف
        });
        // _scrollToBottomManual();
      }

      // حفظ الذاكرة بعد الاكتمال الناجح
      _chatHistory.add({"role": "user", "text": userMsg});
      _chatHistory.add({"role": "model", "text": fullAIResponse});
    } catch (e) {
      setState(() {
        _messages.last["text"] = "❌ انقطع الاتصال، حاول مجدداً.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingText = "";
        });
      }

      // 🛑 هنا كان الخط الأحمر.. هذا هو الإصلاح:
      if (_messages.length <= 2) {
        // نستخدم .then بدلاً من await لتجنب مشاكل الـ async داخل الـ finally
        _apiService
            .generateTitle(userMsg)
            .then((String title) {
              FirebaseFirestore.instance
                  .collection("sessions")
                  .doc(_currentChatId)
                  .set({"title": title}, SetOptions(merge: true));
            })
            .catchError((e) {
              print("Error generating title: $e");
            });
      }
    }
  }

  void _scrollToBottomManual() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _stopGeneration() => setState(() {
    _isStopRequested = true;
    _isLoading = false;
  });

  // --- دوال بناء الواجهة (كما هي) ---

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    bool isSelected, {
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blueAccent.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.blueAccent : Colors.grey[600],
          size: 20,
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            color: isSelected ? Colors.blueAccent : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700], size: 22),
      title: Text(
        title,
        style: GoogleFonts.tajawal(fontSize: 14, color: Colors.black87),
      ),
      onTap: onTap ?? () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // elevation: 0,
        leading: const Icon(
          Icons.blur_on,
          color: Color.fromARGB(255, 0, 0, 0),
          size: 30,
        ),
        title: Text(
          "VISION X",
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              return GestureDetector(
                onTap: () {
                  if (user == null) {
                    LoginScreen.showHishamLogin(context);
                  } else {
                    Scaffold.of(context).openEndDrawer();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.account_circle_outlined,
                            color: Colors.black87,
                            size: 26,
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.black87),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),

      endDrawer: Drawer(
        backgroundColor: const Color(0xFFF8F9FB),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data;

                return Column(
                  children: [
                    // 1. هيدر الحساب (مربوط بالفايربيز)
                    UserAccountsDrawerHeader(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              )
                            : null,
                      ),
                      accountName: Text(
                        user?.displayName ?? "مرحباً بك، ضيف",
                        style: GoogleFonts.tajawal(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      accountEmail: Text(
                        user?.email ?? "سجل لمزامنة بياناتك",
                        style: GoogleFonts.tajawal(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // 2. خانة البحث (عادت لمكانها)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "ابحث في المحادثات...",
                            hintStyle: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.blueAccent,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 3. زر محادثة جديدة
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _messages.clear();
                            _chatHistory.clear(); // تصفير الذاكرة أيضاً
                            _currentChatId = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4285F4), Color(0xFF91B9FF)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                              ),

                              const SizedBox(width: 8),
                              Text(
                                "محادثة جديدة",
                                style: GoogleFonts.tajawal(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 4. قائمة المحادثات التاريخية (عادت لمكانها)
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _historyService.getAllSessions(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting)
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          if (!snap.hasData || snap.data!.docs.isEmpty)
                            return Center(
                              child: Text(
                                "لا توجد محادثات",
                                style: GoogleFonts.tajawal(color: Colors.grey),
                              ),
                            );

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: snap.data!.docs.length,
                            itemBuilder: (context, index) {
                              var doc = snap.data!.docs[index];
                              var data = doc.data() as Map<String, dynamic>;
                              String title = data['title'] ?? "محادثة جديدة";
                              String id = doc.id;
                              return _buildDrawerItem(
                                Icons.chat_bubble_outline,
                                title,
                                _currentChatId == id,
                                onTap: () {
                                  setState(() {
                                    _currentChatId = id;
                                  });
                                  _loadHistory();
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const Divider(height: 1),

                    // 5. الفوتر (الإعدادات وغيرها)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          _buildFooterItem(
                            Icons.settings_outlined,
                            "الإعدادات",
                          ),
                          _buildFooterItem(
                            Icons.help_outline_rounded,
                            "المساعدة",
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),

      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? HeroSection(
                      isLowData: _isLowData,
                      onLowDataChanged: (value) {
                        setState(() {
                          _isLowData = value;
                        });
                      },
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isLoading)
                          return const LoadingIndicator();
                        final m = _messages[index];
                        return ChatBubble(
                          text: m['text']?.toString() ?? "",
                          isUser: (m['isUser'] is bool) ? m['isUser'] : false,
                          isLoading: false,
                          // isLastMessage: index == _messages.length -1,
                        );
                      },
                    ),
            ),
            // حقل الإدخال تحت
            ChatInputField(
              controller: _controller,
              isWriting: _isWriting,
              isLoading: _isLoading,
              onSend: _sendToVisionX,
              onStop: _stopGeneration,
              onPickImage: () {}, // بنرجع نبرمجها بعدين
              onTapTools: () {},
              onTapMic: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingDots extends StatefulWidget {
  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  int _dotCount = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // يغير عدد النقاط كل 500 ملي ثانية
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _dotCount = (_dotCount + 1) % 4;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = "." * _dotCount;
    return Text(
      dots,
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
