import  'package:flutter/material.dart' ;
import  'package:visionx/widgets/chat_input_field.dart' ;
import  'package:visionx/widgets/hero_section.dart' ;
import  'package:visionx/widgets/chat_bubble.dart' ;
import  'package:visionx/services/api_service.dart' ;
import  'package:firebase_auth/firebase_auth.dart' ;

class ChatScreen extends StatefulWidget {
  final String? chatId;
  const ChatScreen({super.key, this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  bool _isUserWriting = false;
  bool _isLowData = false;
  bool _isLoading = false;
  String? _currentChatId;
  
  // قائمة الرسائل (تدعم النصوص والصور)
  List<Map<String, dynamic>> _messages = [];
  
  // تاريخ المحادثة لتمريره إلى API
  List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _currentChatId = widget.chatId ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    _chatController.addListener(() {
      setState(() {
        _isUserWriting = _chatController.text.isNotEmpty;
      });
    });
  }

  // إرسال رسالة
  Future<void> _sendMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty || _isLoading) return;
    
    // إضافة رسالة المستخدم للواجهة
    setState(() {
      _messages.add({
         'role' :  'user' ,
         'type' :  'text' ,
         'text' : message,
      });
      _history.add({ 'role' :  'user' ,  'message' : message});
      _chatController.clear();
      _isLoading = true;
    });
    
    // إرسال إلى API
    final response = await _apiService.sendMessage(message, _history, _currentChatId);
    
    // معالجة الرد
    if (response == "_IMAGE_QUERY_") {
      // طلب صورة
      final imagePrompt = _extractImagePrompt(message);
      final imageBytes = await _apiService.generateImage(imagePrompt);
      
      if (imageBytes != null) {
        setState(() {
          _messages.add({
             'role' :  'model' ,
             'type' :  'image' ,
             'imageBytes' : imageBytes,
             'prompt' : imagePrompt,
             'text' : "_IMAGE_QUERY_",
          });
          _history.add({ 'role' :  'model' ,  message : "[تم إنشاء صورة: $imagePrompt]"});
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages.add({
             'role' :  'model' ,
             'type' :  'text' ,
             'text' : "❌ عذراً، لم أستطع توليد الصورة المطلوبة",
          });
          _history.add({ 'role' :  'model' ,  'message' : "فشل توليد الصورة"});
          _isLoading = false;
        });
      }
    } else {
      // رد نصي عادي
      setState(() {
        _messages.add({
           'role' :  'model' ,
           'type' :  'text' ,
           'text' : response,
        });
        _history.add({ 'role' :  'model' ,  'message' : response});
        _isLoading = false;
      });
    }
  }
  
  // استخراج وصف الصورة من طلب المستخدم
  String _extractImagePrompt(String message) {
    String cleaned = message
        .replaceAll(RegExp(r'ارسم|رسم|صورة|صور|ارسم لي|صور لي|طلع لي صورة ', caseSensitive: false), ''  )
        .trim();
    if (cleaned.isEmpty) return message;
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // واجهة Hero (تختفي عند وجود رسائل أو كتابة)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: (_isUserWriting || _messages.isNotEmpty) ? 0.0 : 1.0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 500),
                      scale: (_isUserWriting || _messages.isNotEmpty) ? 0.8 : 1.0,
                      child: IgnorePointer(
                        ignoring: _isUserWriting || _messages.isNotEmpty,
                        child: HeroSection(
                          isLowData: _isLowData,
                          onLowDataChanged: (val) => setState(() => _isLowData = val),
                        ),
                      ),
                    ),
                  ),
                  
                  // قائمة الرسائل
                  if (_messages.isNotEmpty || _isLoading)
                    ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        // مؤشر التحميل
                        if (_isLoading && index == _messages.length) {
                          return const ChatBubble(
                            text: "",
                            isUser: false,
                            isLoading: true,
                          );
                        }
                        
                        final msg = _messages[index];
                        
                        // رسالة صورة
                        if (msg[ 'type' ] ==  'image' ) {
                          return ChatBubble(
                            text: msg[ 'text' ] ?? "",
                            isUser: msg[ 'role' ] ==  'user' ,
                            imageBytes: msg[ 'imageBytes' ],
                            imagePrompt: msg[ 'prompt' ],
                          );
                        }
                        
                        // رسالة نصية
                        return ChatBubble(
                          text: msg[ 'text' ] ?? "",
                          isUser: msg[ 'role' ] ==  'user' ,
                        );
                      },
                    ),
                ],
              ),
            ),
            
            // حقل الإدخال
            ChatInputField(
              controller: _chatController,
              isWriting: _isUserWriting,
              isLoading: _isLoading,
              onSend: _sendMessage,
              onPickImage: () {
                // يمكن إضافة رفع الصور لاحقاً
              },
              onTapTools: () {},
              onTapMic: () {},
              onStop: () {},
            ),
          ],
        ),
      ),
    );
  }
}



// import  'package:flutter/material.dart' ;
// // استيراد كل القطع اللي برمجناها
// import  'package:visionx/widgets/chat_input_field.dart' ;
// import  'package:visionx/widgets/hero_section.dart' ;

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _chatController = TextEditingController();
//   bool _isUserWriting = false; 
//   bool _isLowData = false;
//   List<String> messages = []; // مصفوفة الرسائل مؤقتاً

//   @override
//   void initState() {
//     super.initState();
//     // مراقبة الكتابة لتشغيل الـ Animation
//     _chatController.addListener(() {
//       setState(() {
//         _isUserWriting = _chatController.text.isNotEmpty;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FB), // لون خلفية هادئ
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // --- 1. واجهة الـ Hero (تختفي وتصغر عند الكتابة) ---
//                   AnimatedOpacity(
//                     duration: const Duration(milliseconds: 500),
//                     opacity: (_isUserWriting || messages.isNotEmpty) ? 0.0 : 1.0,
//                     child: AnimatedScale(
//                       duration: const Duration(milliseconds: 500),
//                       scale: (_isUserWriting || messages.isNotEmpty) ? 0.8 : 1.0,
//                       child: IgnorePointer(
//                         ignoring: _isUserWriting || messages.isNotEmpty,
//                         child: HeroSection(
//                           isLowData: _isLowData,
//                           onLowDataChanged: (val) => setState(() => _isLowData = val),
//                         ),
//                       ),
//                     ),
//                   ),

//                   // --- 2. قائمة الرسائل (تظهر تدريجياً) ---
//                   if (messages.isNotEmpty)
//                     ListView.builder(
//                       itemCount: messages.length,
//                       itemBuilder: (context, index) => Text(messages[index]), // هنا نضع الـ Bubble لاحقاً
//                     ),
//                 ],
//               ),
//             ),

//             // --- 3. بوكس الإدخال (الذي برمجناه معاً) ---
//             ChatInputField(
//               controller: _chatController,
//               isWriting: _isUserWriting,
//               isLoading: false,
//               onSend: () {
//                 setState(() {
//                   messages.add(_chatController.text);
//                   _chatController.clear();
//                 });
//               },
//               onPickImage: () {},
//               onTapTools: () {},
//               onTapMic: () {},
//               onStop: () {},
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
