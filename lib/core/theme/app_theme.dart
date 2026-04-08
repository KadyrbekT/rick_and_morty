import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color _green = Color(0xFF97CE4C);
  static const Color _darkBg = Color(0xFF1A1A2E);
  static const Color _darkSurface = Color(0xFF16213E);
  static const Color _darkCard = Color(0xFF0F3460);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _darkBg,
        primaryColor: _green,
        colorScheme: const ColorScheme.dark(
          primary: _green,
          secondary: _green,
          surface: _darkSurface,
        ),
        cardTheme: CardThemeData(
          color: _darkCard,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _darkSurface,
          foregroundColor: _green,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: _green,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          iconTheme: IconThemeData(color: _green),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _darkSurface,
          selectedItemColor: _green,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIconColor: Colors.white38,
          suffixIconColor: Colors.white38,
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
        textTheme: const TextTheme(
          titleMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 13),
          bodySmall: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        useMaterial3: true,
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF43A047),
          surface: Colors.white,
          surfaceContainerHighest: Colors.grey.shade100,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2E7D32),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF2E7D32),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          iconTheme: IconThemeData(color: Color(0xFF2E7D32)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF2E7D32),
          unselectedItemColor: Colors.black38,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIconColor: Colors.black38,
          suffixIconColor: Colors.black38,
        ),
        textTheme: const TextTheme(
          titleMedium: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          bodyMedium: TextStyle(color: Colors.black54, fontSize: 13),
          bodySmall: TextStyle(color: Colors.black38, fontSize: 12),
        ),
        useMaterial3: true,
      );

  static Color statusColor(String status) => switch (status.toLowerCase()) {
        'alive' => const Color(0xFF55CC44),
        'dead' => const Color(0xFFD63D2E),
        _ => Colors.grey,
      };
}
