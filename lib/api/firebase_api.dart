import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:payapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseApi {
  //create an instance of firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;
  //function to initialize notification
  Future<void> initNotifications() async {
    //request permission from user (will prompt user)
    await _firebaseMessaging.requestPermission();
    //fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();

    //print the token(normally you would send this to your server)
    debugPrint('Token: $fCMToken');

    //initialize further settings for push noti
    initPushNotifications();
  }

  //function to handle received from user
  void handleMessage(RemoteMessage? message) async {
    //if the message is null, do nothing
    if (message == null) return;

    // Save the notification to shared preferences
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications') ?? [];
    notifications.add(
      '${message.notification!.title}|${message.notification!.body}|${message.data}',
    );
    await prefs.setStringList('notifications', notifications);

    //navigation to new screen when message is recevied and user taps notification
    navigatorKey.currentState
        ?.pushNamed('/notificationPage', arguments: message);
  }

  //function to initialize foreground and background settings
  Future initPushNotifications() async {
    //handle notification if the app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    //attach event listerner for when a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
