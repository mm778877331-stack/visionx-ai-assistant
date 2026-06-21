import  'package:flutter/material.dart' ;
import  'dart:math'  as math;

class VisionXLogo extends StatefulWidget {
  final double size;
  const VisionXLogo({super.key, this.size = 250}); // كبرنا الحجم الافتراضي

  @override
  State<VisionXLogo> createState() => _VisionXLogoState();
}

class _VisionXLogoState extends State<VisionXLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // سرعة الحركة ناعمة (3 ثواني للنبض الكامل وتفكك النقاط)
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true); 
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // نستخدم Curves.easeInOutSine لنعومة فائقة في الحركة
        final Animation<double> animation = CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOutSine,
        );

        return Center(
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                // 1. هالة خارجية كبيرة وناعمة جداً (الجلو الخلفي)
                BoxShadow(
                  color: Colors.white.withOpacity(0.02 * (1 - animation.value)),
                  blurRadius: 70,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _LogoPainter(animation.value),
            ),
          ),
        );
      },
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double progress;
  _LogoPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // دالة مساعدة لرسم "نقطة ضوء ناعمة" (Glow Dot)
    void drawGlowDot(Canvas canvas, Offset offset, double radius, double opacity) {
      if (opacity <= 0) return;
      
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5); // التنعيم هنا
      
      canvas.drawCircle(offset, radius, paint);
      
      // إضافة طبقة داخلية ناصعة عشان يطلع "يشع"
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(opacity * 1.5.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(offset, radius * 0.5, corePaint);
    }

    // رسم طبقات النقاط المتفككة (توزيع هندسي ناعم)
    for (int ring = 1; ring <= 3; ring++) {
      int dotCount = ring * 8; 
      double baseRadius = ring * 30.0; // المسافة الأساسية
      
      for (int i = 0; i < dotCount; i++) {
        double angle = (i * 2 * math.pi) / dotCount;
        
        // حساب التفكك: النقاط تبتعد وتصغر بناءً على الـ progress
        double expansion = progress * 20.0 * ring; 
        double currentRadius = baseRadius + expansion;
        
        // حجم النقطة يصغر وهي تبتعد
        double dotSize = (6.0 - (progress * 2.0)) / (ring * 0.7);
        // الشفافية تقل وهي تبتعد
        double opacity = (0.7 - (progress * 0.3)) / (ring * 0.7);

        double x = center.dx + currentRadius * math.cos(angle);
        double y = center.dy + currentRadius * math.sin(angle);

        drawGlowDot(canvas, Offset(x, y), dotSize, opacity);
      }
    }
    
    // النواة المركزية (تنبض في مكانها)
    double coreSize = 15.0 * (1 - (progress * 0.1));
    drawGlowDot(canvas, center, coreSize, 0.9 * (1 - (progress * 0.1)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}