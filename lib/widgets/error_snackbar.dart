import 'package:flutter/material.dart';

void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFFFDECEC), // soft red background
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFB00020), // calm red text
          fontSize: 14,
        ),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}
