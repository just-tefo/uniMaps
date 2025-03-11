import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  static TextStyle anekDevanagariBold({Color? color, double? fontSize}) {
    return GoogleFonts.anekDevanagari(
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
      color: color,
    );
  }
}
