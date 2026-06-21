import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;
// 🛑 تأكد أنك تستخدم هذا الثيم الفاتح ليتطابق مع الصورة
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart'; // 👈 ثيم GitHub الفاتح والواضح

class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String codeContent = element.textContent.trim();

    String language = 'code';
    if (element.attributes['class'] != null) {
      language = element.attributes['class']!.replaceAll('language-', '');
    }

    String formattedLanguage = language.isNotEmpty
        ? "${language[0].toUpperCase()}${language.substring(1).toLowerCase()}"
        : language;

    // استخدم StatefulBuilder هنا للتحكم في حالة النسخ والموشن داخل البوكس
    return StatefulBuilder(
      builder: (context, setState) {
        bool isCopied = false;

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3F8), // لون البوكس السادة
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- الرأس (اللغة + موشن النسخ) ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedLanguage,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),

                      // حركـة النسخ الاحترافية (Motion)
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: codeContent));
                          // إظهار رسالة Snack وكأنها ويدجت طائرة (اختياري)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("تم النسخ بنجاح"),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(milliseconds: 800),
                              width: 150,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.copy_all_rounded,
                          size: 20,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Colors.black.withOpacity(0.08),
                ),

                // --- منطقة الكود (وداعاً للون الأبيض) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),

                    child: HighlightView(
                      codeContent,
                      language: language,
                      // دمج توزيع الألوان مع قتل الخلفية البيضاء في ثيم واحد 🛑
                      theme: Map<String, TextStyle>.from(githubTheme)
                        ..['root'] = TextStyle(
                          backgroundColor: Colors.transparent, // إجبار الشفافية
                          color: const Color(0xFF000000),
                        ),
                      padding: const EdgeInsets.all(0),
                      textStyle: GoogleFonts.firaCode(
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
