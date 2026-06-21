import  'package:flutter/material.dart' ;
import  'package:google_fonts/google_fonts.dart' ;

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, right: 10),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Stack(alignment: Alignment.center, children: [
            SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 1.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent))),
            Icon(Icons.blur_on, color: Colors.blueAccent, size: 16),
          ]),
          const SizedBox(width: 10),
          Text("Vision X يفكر...", style: GoogleFonts.tajawal(fontSize: 12, color: Colors.blueAccent.withOpacity(0.7))),
        ],
      ),
    );
  }
}