import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request permissions
    await _fcm.requestPermission();

    // Get the device token (for sending push from server)
    String? token = await _fcm.getToken();
    print('FCM Token: $token');

    // Handle foreground messages

    // Handle background opened messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked!');
    });
  }
}
