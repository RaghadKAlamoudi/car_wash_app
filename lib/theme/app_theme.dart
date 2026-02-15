import 'package:flutter/material.dart';

class AppTheme {
  // ================= BRAND COLORS =================
  static const Color primary = Color(0xFFFF8C2B); // Orange
  static const Color dark = Color(0xFF1E1E1E);
  static const Color lightGrey = Color(0xFFF3F3F3);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    primaryColor: primary,
    scaffoldBackgroundColor: Colors.white,

    // ================= APP BAR =================
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      foregroundColor: Colors.black,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),

    // ================= INPUT FIELDS =================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightGrey,
      hintStyle: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),
    ),

    // ================= BUTTONS =================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ================= CHIPS =================
    chipTheme: ChipThemeData(
      backgroundColor: lightGrey,
      selectedColor: primary,
      labelStyle: const TextStyle(color: Colors.black),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),

    // ================= CARDS =================
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),

    // ================= LIST TILE =================
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.black87,
      textColor: Colors.black,
    ),

    // ================= BOTTOM NAV =================
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),

    // ================= DIALOG =================
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
      ),
    ),

    // ================= BOTTOM SHEET =================
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
    ),

    // ================= SNACK BAR =================
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // ================= ICONS =================
    iconTheme: const IconThemeData(
      color: Colors.black87,
      size: 24,
    ),

    // ================= TEXT =================
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        color: Colors.black87,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        color: Colors.grey,
      ),
    ),
  );
}