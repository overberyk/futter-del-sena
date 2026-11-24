import 'package:flutter/material.dart';

// Aquí están los colores y estilos de toda la app (es como el CSS).
class Tema {
  static const Color _red = Color(0xFFE53935);
  static const Color _background = Color(0xFF101114);
  static const Color _surface = Color(0xFF1B1D23);
  static const Color _surfaceLight = Color(0xFF252831);

  static ThemeData get oscuro {
    final scheme = ColorScheme.fromSeed(
      seedColor: _red,
      brightness: Brightness.dark,
      surface: _surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme.copyWith(
        primary: _red,
        onPrimary: Colors.white,
        secondary: const Color(0xFFFF6B63),
        surface: _surface,
        onSurface: const Color(0xFFF5F5F5),
      ),

      scaffoldBackgroundColor: _background,

      appBarTheme: const AppBarTheme(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      cardTheme: CardTheme(
        color: _surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF30333D)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceLight,
        hintStyle: const TextStyle(color: Colors.white54),
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIconColor: Colors.white70,
        suffixIconColor: Colors.white70,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF383B46)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF383B46)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _red, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade800,
          disabledForegroundColor: Colors.white54,
          minimumSize: const Size.fromHeight(50),
          elevation: 0,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: _red),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFF6B63),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _red,
        foregroundColor: Colors.white,
        elevation: 3,
      ),

      iconTheme: const IconThemeData(
        color: Colors.white70,
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF30333D),
        thickness: 1,
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: _red,
        textColor: Colors.white,
      ),

      dialogTheme: DialogTheme(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _surfaceLight,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _red,
      ),
    );
  }
}
