import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static Future<void> init() async {
    // 🚫 Skip on Web
    if (kIsWeb) {
      debugPrint('🔕 Firebase Messaging skipped on Web');
      return;
    }

    // 🚫 Skip on emulator-safe environments if needed
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint('🔕 Firebase Messaging skipped on unsupported platform');
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission();

      final token = await messaging.getToken();
      debugPrint('🔔 FCM Token: $token');
    } catch (e) {
      // ✅ THIS is the key line that fixes everything
      debugPrint('⚠️ Firebase Messaging skipped (emulator issue): $e');
    }
  }
}

