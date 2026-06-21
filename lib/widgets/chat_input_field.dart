import 'package:flutter/material.dart';
import 'dart:ui'; // ضرورية للتأثير الزجاجي
// تأكد من أن المسار هنا يطابق اسم مشروعك ومجلداتك
import 'package:visionx/widgets/bento_tools_grid.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final bool isWriting;
  final bool isLoading;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback onTapTools;
  final VoidCallback onTapMic;
  final VoidCallback onStop;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.isWriting,
    required this.isLoading,
    required this.onSend,
    required this.onPickImage,
    required this.onTapTools,
    required this.onTapMic,
    required this.onStop,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  // --- المتغيرات اللي كانت تسبب خط أحمر ---
  bool _isToolsOpen = false; // للتحكم في دوران علامة الـ +
  bool _isLowData = false; // للتحكم في نمط توفير البيانات

  // --- دالة إظهار قائمة الـ Bento الزجاجية ---
  void _showBentoMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // شفاف عشان يظهر التصميم حقنا
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(bottom: 20, top: 10),
          decoration: BoxDecoration(
            color: const Color(
              0xFF121212,
            ).withOpacity(0.95), // خلفية داكنة فخمة
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // خط صغير في الأعلى للجمالية
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              // استدعاء شبكة الأدوات اللي برمجناها
              BentoToolsGrid(
                lowDataMode: _isLowData,
                onLowDataChanged: (val) {
                  setState(() => _isLowData = val);
                  Navigator.pop(context); // إغلاق القائمة بعد الاختيار
                },
                onTranslateDoc: () {
                  Navigator.pop(context);
                  widget.onPickImage(); // نفتح الاستوديو للمترجم
                },
                onBrainstorm: () {
                  Navigator.pop(context);
                  // هنا سنضيف لاحقاً منطق مولد الأفكار
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. حقل النص
            TextField(
              controller: widget.controller,
              textAlign: TextAlign.right,
              maxLines: 7,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: "اسأل Vision X",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),

            // 2. سطر الأيقونات المطور
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- جهة اليمين (الأدوات والزائد) ---
                  Row(
                    children: [
                      // زر الـ + المطور
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: _isToolsOpen ? 0.125 : 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isToolsOpen = !_isToolsOpen);
                          },
                          child: Icon(
                            _isToolsOpen
                                ? Icons.add
                                : Icons.add_circle_outline_rounded,
                            color: _isToolsOpen
                                ? Colors.redAccent
                                : Colors.black87,
                            size: 28,
                          ),
                        ),
                      ),

                      // ظهور أدوات الكاميرا والاستوديو
                      if (_isToolsOpen) ...[
                        const SizedBox(width: 12),
                        _buildQuickAction(
                          Icons.camera_alt_outlined,
                          Colors.blueAccent,
                          widget.onPickImage,
                        ),
                        const SizedBox(width: 8),
                        _buildQuickAction(
                          Icons.image_outlined,
                          Colors.purpleAccent,
                          widget.onPickImage,
                        ),
                      ] else ...[
                        const SizedBox(width: 15),
                        // 🛑 زر الأدوات اللي بيفتح الـ Bento Menu
                        GestureDetector(
                          onTap: () {
                            _showBentoMenu(context); // استدعاء الدالة
                            widget.onTapTools(); // إبلاغ الأب
                          },
                          child: const Icon(
                            Icons.tune_outlined,
                            color: Colors.black45,
                            size: 22,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // --- جهة اليسار (إرسال / مايك) ---
                  _buildLeftButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت صغير للأزرار السريعة
  Widget _buildQuickAction(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildLeftButton() {
    if (widget.isLoading) {
      return GestureDetector(
        onTap: widget.onStop,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.stop, color: Colors.white, size: 16),
        ),
      );
    }
    if (widget.isWriting) {
      return GestureDetector(
        onTap: widget.onSend,
        child: const Icon(
          Icons.arrow_circle_up_rounded,
          color: Colors.blueAccent,
          size: 32,
        ),
      );
    }
    return GestureDetector(
      onTap: widget.onTapMic,
      child: const Icon(
        Icons.mic_none_outlined,
        color: Colors.black87,
        size: 26,
      ),
    );
  }
}
