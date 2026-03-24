import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff0a192f),
      brightness: Brightness.light,
      primary: const Color(0xff2094f3),
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: GoogleFonts.lexendTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff0a192f),
      brightness: Brightness.dark,
      primary: const Color(0xff2094f3),
      surface: const Color(0xff0a192f),
      background: const Color(0xff0a192f),
    ),
    scaffoldBackgroundColor: const Color(0xff0a192f),
    textTheme: GoogleFonts.lexendTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff0a192f),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
