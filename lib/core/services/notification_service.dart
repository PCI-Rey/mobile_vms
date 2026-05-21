import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool _initialized = false;

  /// Initialize FCM — request permission, setup foreground handler, get token.
  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Request permission (iOS & Android 13+)
    await _requestPermissions();

    // 2. Handle FCM messages when app is in FOREGROUND → show as snackbar
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 3. Handle notification tap when app was in BACKGROUND (not killed)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 [FCM] Notification tapped (background): ${message.messageId}');
    });

    // 4. Log FCM token
    await _logFcmToken();

    _initialized = true;
    debugPrint('✅ [NotificationService] Initialized (FCM only)');
  }

  Future<void> _requestPermissions() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('🔔 [FCM] Permission: ${settings.authorizationStatus}');
  }

  Future<void> _logFcmToken() async {
    try {
      final token = await _fcm.getToken();
      debugPrint('📲 [FCM] Device Token: $token');
    } catch (e) {
      debugPrint('⚠️ [FCM] Gagal dapat token: $e');
    }
  }

  /// Get FCM device token — kirim ke backend setelah login.
  Future<String?> getFcmToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('⚠️ [FCM] getFcmToken error: $e');
      return null;
    }
  }

  /// Handle FCM message saat app di FOREGROUND → tampilkan sebagai snackbar.
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('🔔 [FCM] Foreground message: ${message.messageId}');

    final notification = message.notification;
    if (notification == null) return;

    final title = notification.title ?? 'Notifikasi';
    final body = notification.body ?? '';

    debugPrint('📋 [FCM] Title: $title | Body: $body');

    // Tampilkan sebagai snackbar GetX
    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1A237E),
      colorText: Colors.white,
      icon: const Icon(Icons.notifications, color: Colors.white),
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }

  /// Subscribe to a user-specific FCM topic (usually user UUID/ID)
  Future<void> subscribeToUserTopic(String userId) async {
    if (userId.isEmpty) return;
    try {
      debugPrint('📲 [FCM] Subscribing to topic: $userId');
      await _fcm.subscribeToTopic(userId);
      debugPrint('✅ [FCM] Subscribed successfully to topic: $userId');
    } catch (e) {
      debugPrint('⚠️ [FCM] Failed to subscribe to topic $userId: $e');
    }
  }

  /// Unsubscribe from a user-specific FCM topic (usually user UUID/ID)
  Future<void> unsubscribeFromUserTopic(String userId) async {
    if (userId.isEmpty) return;
    try {
      debugPrint('📲 [FCM] Unsubscribing from topic: $userId');
      await _fcm.unsubscribeFromTopic(userId);
      debugPrint('✅ [FCM] Unsubscribed successfully from topic: $userId');
    } catch (e) {
      debugPrint('⚠️ [FCM] Failed to unsubscribe from topic $userId: $e');
    }
  }
}
