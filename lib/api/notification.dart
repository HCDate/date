import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class FirebaseApi {
  // final _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final String? fcmToken = await _firebaseMessaging.getToken();
    initPushNotification();
  }

  void initPushNotification() {
    try {
      // Get initial message when the app is launched from a terminated state
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        handleMessage(message);
      });

      // Listen for messages when the app is in the foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print("Foreground Message: $message");
        }
        handleMessage(message);
      });

      // Get initial message when the app is launched from a terminated state
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          handleMessage(message);
        }
      });
    } catch (e) {
      return;
    }
  }

  void handleMessage(RemoteMessage message) {
    try {
      // Your logic to handle the message goes here

      // Check if the app is in the foreground
      if (Get.overlayContext != null) {
        // Show a dialog when a notification is received in the foreground
        Get.snackbar(
          message.notification?.title ?? "Notification",

          message.notification?.title ?? "No body",
          // Set the position to the top
          snackPosition: SnackPosition.TOP,
          showProgressIndicator: true,
          // Set the duration
          duration: const Duration(seconds: 5),
          // Callback when the snackbar is dismissed
          // onClosed: (reason) {
          //   // If not pressed, handle it as a background notification
          //   if (reason == SnackDismissReason.swipe || reason == SnackDismissReason.timeout) {
          //     navigateToTargetPage(message.data);
          //   }
          // },
        );
      } else {
        // App is in the background, show the notification as a bar at the top
        Get.snackbar(
          "Notification",
          message.notification?.body ?? "No body",
          // Set the position to the top
          snackPosition: SnackPosition.TOP,
          // Set the duration
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      return;
    }
  }
}
