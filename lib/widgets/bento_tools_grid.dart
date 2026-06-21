import 'dart:ui';
import 'package:flutter/material.dart';

class BentoToolsGrid extends StatelessWidget {
  final bool lowDataMode;
  final Function(bool) onLowDataChanged;
  final VoidCallback onTranslateDoc;
  final VoidCallback onBrainstorm;

  const BentoToolsGrid({
    super.key,
    required this.lowDataMode,
    required this.onLowDataChanged,
    required this.onTranslateDoc,
    required this.onBrainstorm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // 1. مترجم المستندات (مستطيل طولي)
              Expanded(
                flex: 2,
                child: _buildBentoItem(
                  icon: Icons.g_translate_rounded,
                  title: "مترجم الـمحترفين",
                  subtitle: "ترجمة ملفات PDF وصور",
                  color: Colors.blueAccent,
                  height: 160,
                  onTap: onTranslateDoc,
                ),
              ),
              const SizedBox(width: 10),
              // 2. توفير البيانات (مربع)
              Expanded(
                flex: 1,
                child: _buildBentoItem(
                  icon: lowDataMode ? Icons.bolt : Icons.shutter_speed_rounded,
                  title: "توفير",
                  subtitle: lowDataMode ? "مفعل" : "معطل",
                  color: lowDataMode ? Colors.orange : Colors.grey,
                  height: 160,
                  onTap: () => onLowDataChanged(!lowDataMode),
                  isToggle: true,
                  isActive: lowDataMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 3. مولد الأفكار (مستطيل عرضي)
          _buildBentoItem(
            icon: Icons.psychology_outlined,
            title: "مولد الأفكار الإبداعية",
            subtitle: "Moodboards, Colors, & Concepts",
            color: Colors.purpleAccent,
            height: 80,
            onTap: onBrainstorm,
            isHorizontal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBentoItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required double height,
    required VoidCallback onTap,
    bool isToggle = false,
    bool isActive = false,
    bool isHorizontal = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: height,
            constraints: const BoxConstraints(maxHeight: 100),
            decoration: BoxDecoration(
              color: isActive
                  ? color.withOpacity(0.1)
                  : Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isActive ? color : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(15),
            child: isHorizontal
                ? Row(
                    children: [
                      Icon(icon, color: color, size: 30),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: color, size: 30),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
