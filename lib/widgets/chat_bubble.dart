import  'package:flutter/material.dart' ;
import  'package:flutter_markdown/flutter_markdown.dart' ;
import  '../code_builder.dart' ;
import  'package:lottie/lottie.dart' ;
import  'dart:typed_data' ;
import  'package:image_gallery_saver_plus/image_gallery_saver_plus.dart' ;
import  'package:path_provider/path_provider.dart' ;
import  'dart:io' ;


class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isLoading;
  final bool isLastMessage;
  final Uint8List? imageBytes;
  final String? imagePrompt;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.isLoading = false,
    this.isLastMessage = false,
    this.imageBytes,
    this.imagePrompt,
  });

  @override
  Widget build(BuildContext context) {
    bool hasImage = imageBytes != null;
    bool isImageQuery = text == "_IMAGE_QUERY_";

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(
          top: isUser ? 8 : 2,
          bottom: 2,
          right: 16,
          left: 16,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFE9EEF6) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.only(
          top: isUser ? 10 : 0,
          bottom: 10,
          left: 10,
          right: 10,
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // اسم Vision X
              if (!isUser)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0, top: 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 35,
                        height: 35,
                        child: Lottie.asset(
                           'assets/Loop.json' ,
                          repeat: isLoading,
                          animate: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isLoading ? "Vision X يحلل الآن..." : "Vision X",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isLoading ? Colors.blueAccent : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

              // ✅ عرض الصورة مع تأثيرات احترافية
              if (hasImage) ...[
                _buildImageWithEffects(context),
                const SizedBox(height: 8),
                _buildDownloadButton(context),
              ]
              // ✅ مؤشر تحميل الصورة (وهي تُنشأ)
              else if (isImageQuery && isLoading) ...[
                _buildImageLoadingIndicator(),
              ]
              // ✅ عرض النص العادي
              else if (!isImageQuery && text.isNotEmpty)
                SelectionArea(
                  child: FadeInWidget(
                    key: ValueKey(text.length),
                    child: MarkdownBody(
                      data: text.trim().isEmpty ? (!isUser ? "" : "...") : text,
                      selectable: false,
                      builders: { 'code' : CodeBlockBuilder()},
                      styleSheet: MarkdownStyleSheet(
                        codeblockDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        codeblockPadding: EdgeInsets.zero,
                        p: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                        code: const TextStyle(
                          backgroundColor: Color(0xFFF1F3F4),
                          color: Color(0xFFD81B60),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily:  'monospace' ,
                        ),
                        h1: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 2.0,
                        ),
                        h2: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF202124),
                          height: 1.8,
                        ),
                        h3: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3C4043),
                        ),
                        blockSpacing: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ صورة مع تأثيرات احترافية (وميض، ظهور تدريجي، تكبير)
  Widget _buildImageWithEffects(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context),
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 500),
        tween: Tween<double>(begin: 0.8, end: 1.0),
        curve: Curves.easeOutCubic,
        builder: (context, double scale, child) {
          return Transform.scale(
            scale: scale,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.8), Colors.transparent],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcOver,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width * 0.75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.memory(
                    imageBytes!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ مؤشر تحميل الصورة (مربع رمادي مع وميض)
  Widget _buildImageLoadingIndicator() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.3, end: 1.0),
      curve: Curves.easeInOut,
      builder: (context, double opacity, child) {
        return AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 500),
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      begin: Alignment(-1, -1),
                      end: Alignment(1, 1),
                      colors: [Colors.white, Colors.transparent],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcOver,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                  ),
                ),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
                const SizedBox(height: 12),
                const Text(
                  "جاري إنشاء الصورة...",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ عرض الصورة بحجم الشاشة عند الضغط عليها
  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Scaffold(
              backgroundColor: Colors.black.withOpacity(0.95),
              body: Center(
                child: Hero(
                  tag: "visionx_image_${imageBytes.hashCode}",
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.memory(
                      imageBytes!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  // ✅ زر التحميل
  Widget _buildDownloadButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        await _saveImageToGallery(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.download_for_offline,
              size: 18,
              color: Colors.blueAccent,
            ),
            SizedBox(width: 5),
            Text(
              "حفظ الصورة في المعرض",
              style: TextStyle(
                fontSize: 12,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ دالة حفظ الصورة
  Future<void> _saveImageToGallery(BuildContext context) async {
    if (imageBytes == null) return;

    try {
      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes!,
        quality: 100,
        name: "visionx_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      if (result[ 'isSuccess' ] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text( '✅ تم حفظ الصورة في المعرض '),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception( 'فشل الحفظ ');
      }
    } catch (e) {
      try {
        final directory = await getTemporaryDirectory();
        final filePath =  '${directory.path}/visionx_${DateTime.now().millisecondsSinceEpoch}.png' ;
        final file = File(filePath);
        await file.writeAsBytes(imageBytes!);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text( '✅ تم حفظ الصورة في: $filePath' ),
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (e2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text( '❌ فشل حفظ الصورة: $e2' ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}



// --- ويدجت الوميض الأصلية ---
// FadeInWidget كما هو بدون تغيير
class FadeInWidget extends StatefulWidget {
  final Widget child;
  const FadeInWidget({super.key, required this.child});

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) setState(() => _opacity = 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeIn,
      child: widget.child,
    );
  }
}

