import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import '../../shared/config/routes.dart';

@lazySingleton
class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // Request permissions
      await _requestPermission();

      // Initialize local notifications
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      // Get FCM Token
      if (Platform.isIOS) {
        // On iOS, we need APNs token first. If not configured, this might fail/hang.
        // We'll try to get it, but catch specific errors.
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
           final token = await _firebaseMessaging.getToken();
           debugPrint('🔥 FCM Token: $token');
        } else {
           debugPrint('⚠️ APNs Token is null. Push notifications may not work on iOS Simulator or without proper config.');
        }
      } else {
        final token = await _firebaseMessaging.getToken();
        debugPrint('🔥 FCM Token: $token');
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background/terminated messages (when app opens from notification)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🔔 App opened from notification: ${message.data}');
        _handleRemoteMessageTap(message);
      });

      // Handle initial message (app launched from terminated state)
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🔔 App launched from notification: ${initialMessage.data}');
        _handleRemoteMessageTap(initialMessage);
      }

    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  void _handleRemoteMessageTap(RemoteMessage message) {
    // Convert RemoteMessage data to string payload format for consistency if needed,
    // or just handle logic directly.
    final data = message.data;
    if (data.containsKey('carId')) {
       router.push('/my-listings');
    } else if (data.containsKey('chatId')) {
       router.push('/chat/${data['chatId']}');
    }
  }

  Future<void> showTestNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    debugPrint('🚀 Sending Test Notification: $title');
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
    debugPrint('✅ Test Notification Sent!');
  }

  Future<String?> getToken() async {
    try {
      if (Platform.isIOS) {
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('❌ APNs Token is null. Are you on a Simulator? Push notifications require a physical device or properly configured Simulator.');
          return null;
        }
        debugPrint('🍏 APNs Token retrieved: $apnsToken');
      }
      final token = await _firebaseMessaging.getToken();
      debugPrint('🔥 FCM Token retrieved: $token');
      return token;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('🔔 Foreground message received: ${message.notification?.title}');
    
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: android?.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  void _handleNotificationTap(NotificationResponse details) {
    final payload = details.payload;
    if (payload != null) {
      debugPrint('🔔 Notification tapped with payload: $payload');
      // Parse payload (it might be a stringified map or just a string depending on how it's sent)
      // For simplicity, assuming the payload string contains keys we look for.
      // In a real app, we should parse the JSON properly.
      
      // Check for Car Status Notification
      if (payload.contains('carId') && (payload.contains('approved') || payload.contains('rejected'))) {
         // Extract carId (simplified parsing)
         final carIdRegExp = RegExp(r'carId:\s*([a-zA-Z0-9_-]+)');
         final match = carIdRegExp.firstMatch(payload);
         if (match != null) {
           final carId = match.group(1);
           // Navigate to My Listings or specific car details if we had the object
           // Since we only have ID, My Listings is safer/easier for now.
           router.push('/my-listings');
         }
      } 
      // Check for Chat Notification
      else if (payload.contains('chatId')) {
         final chatIdRegExp = RegExp(r'chatId:\s*([a-zA-Z0-9_-]+)');
         final match = chatIdRegExp.firstMatch(payload);
         if (match != null) {
           final chatId = match.group(1);
           router.push('/chat/$chatId');
         }
      }
    }
  }
}
