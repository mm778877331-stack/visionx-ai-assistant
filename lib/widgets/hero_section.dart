import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroSection extends StatefulWidget {
  final bool isLowData;
  final Function(bool) onLowDataChanged;

  const HeroSection({
    super.key,
    required this.isLowData,
    required this.onLowDataChanged,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        "مرحباً بك في Vision X",
        style: GoogleFonts.tajawal(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }
}
