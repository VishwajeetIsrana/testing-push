import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter/material.dart';

import 'package:testnotifications/main.dart';
import 'package:testnotifications/secondpage.dart';

// not worked
@pragma('vm:entry-point')
void notificationTapBackground(
    NotificationResponse notificationResponse) async {
  print('notification action tapped with input:');
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  // print("handleBackgroundMessage");
  // print("Title ${message.notification?.title}");
  // print("Body ${message.notification?.body}");
  // print("Payload ${message.data}");
  // print("All Data ${message.toMap()}");

  // when this function used in handle background meesage dont need of channel id  pop is coming
  // FireBaseApi.showNotification(message, flutterLocalNotificationsPlugin, false);
}

class FireBaseApi {
  final firebaseMessaging = FirebaseMessaging.instance;

// main function // its called on main page
  Future<void> initNotification(flutterLocalNotificationsPlugin) async {
    await firebaseMessaging.requestPermission();

    final fcmtocken = await firebaseMessaging.getToken();
    // refresh();

    debugPrint('fcmtocken: ${fcmtocken}');
    initPushNotification(flutterLocalNotificationsPlugin);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  // void refresh() async {
  //   firebaseMessaging.onTokenRefresh.listen(
  //     (event) {
  //       event.toString();
  //       debugPrint('fcm refreshed: $event}');
  //     },
  //   );
  // }

// all code related to notification
  Future initPushNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = const DarwinInitializationSettings();

    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);

    // local notification package   initialize first
    flutterLocalNotificationsPlugin.initialize(
      initializationsSettings,
      // its call when user in app and tap on notification
      onDidReceiveNotificationResponse: (details) async {
        print("onDidReceiveNotificationResponse");

        await Navigator.push(
          navigationKey.currentState!.context,
          MaterialPageRoute(builder: (context) => const SecondPage()),
        );
      },
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    //
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        print("listen onMessage  ${message.toMap()}");

        showNotification(message, flutterLocalNotificationsPlugin, false);
        return;
      },
    );

    // when app in background mode not killed
    //  tap on notification when app  in background mode  this function is called
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      try {
        print("at show onMessageOpenedApp");
        Navigator.push(
          navigationKey.currentState!.context,
          MaterialPageRoute(builder: (context) => const SecondPage()),
        );
        //
      } catch (e) {
        print(' catch onMessageOpenedApp $e');
      }
    });
  }

// functions showNotification
  static Future<void> showNotification(RemoteMessage message,
      FlutterLocalNotificationsPlugin fln, bool data) async {
    print("at show notification");
    String? _title;

    String? _body;

    if (data) {
      _title = message.notification?.title;
      _body = message.notification?.body;
    } else {
      _title = message.notification?.title;
      _body = message.notification?.body;
    }
    debugPrint('_title: ${_title}');
    debugPrint('_body: ${_body}');
    await showBigTextNotification(_title!, _body!, message, fln);
  }

// show notification
  static Future<void> showBigTextNotification(String title, String body,
      RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    print("showBigTextNotification");
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    );
    // Create the AndroidNotificationChannel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      // '1', // Use the same ID as defined in the resources
      "mychannel",
      'high_importance_channel',
      // 'High Importance Channel Description',
      importance: Importance.max,
      playSound: true,
    );

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      // Random.secure().nextInt(100000).toString(),
      // 'high_importance_channel',
      importance: Importance.high,
      styleInformation: bigTextStyleInformation,
      priority: Priority.high,
      playSound: true,
      // sound: const RawResourceAndroidNotificationSound('notification'),

      enableLights: true,
      icon: '@mipmap/ic_launcher',
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: jsonEncode(message.toMap()),
    );
  }
}
