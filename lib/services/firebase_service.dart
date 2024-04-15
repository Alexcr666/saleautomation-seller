import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:multivendor_seller/screens/home_screen.dart';

dynamic notificationData;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class FirebaseService {
  static init(context, uid, User currentUser) {
    updateFirebaseToken(currentUser);
    initFCM(uid, context, currentUser);
    configureFirebaseListeners(context, currentUser);
  }
}

//FCM
updateFirebaseToken(User currentUser) {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  print(currentUser.uid);

  firebaseMessaging.getToken().then((token) {
    print(token);
    FirebaseFirestore.instance
        .collection('Sellers')
        .doc(currentUser.uid)
        .update({
      'tokenId': token,
    });
  });
}

initFCM(String uid, context, User currentUser) async {
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  var android = new AndroidInitializationSettings('seller');
  var ios = new IOSInitializationSettings();
  var initSetting = new InitializationSettings(
    android: android,
    iOS: ios,
  );

  flutterLocalNotificationsPlugin.initialize(
    initSetting,
    onSelectNotification: (data) async {
      print('Send to my orders ::: $notificationData');
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => OrdersPage(
      //       // currentUser: currentUser,
      //     ),
      //   ),
      // );
    },
  );
}

configureFirebaseListeners(context, User currentUser) async {
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage message) {
    print('INITIAL MESSAGE :: $message');

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => HomeScreen(),
    //   ),
    // );
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('ON MESSAGE :: $message');

    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;

    if (notification != null && android != null) {
      showNotification(
        notification,
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  });

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title

    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // firebaseMessaging.configure(
  //   onBackgroundMessage: firebaseBackgroundMessageHandler,
  //   onMessage: (Map<String, dynamic> message) async {
  //     print('onMessage: $message');
  //     notificationData = message;
  //     showNotification(
  //       notificationData,
  //       notificationData['data']['type'],
  //       context,
  //     );
  //   },
  //   onLaunch: (Map<String, dynamic> message) async {
  //     notificationData = message;
  //     print('onLaunch: $notificationData');
  //     //send user to my orders

  //     // Navigator.push(
  //     //   context,
  //     //   MaterialPageRoute(
  //     //     builder: (context) => HomeScreen(),
  //     //   ),
  //     // );
  //   },
  //   onResume: (Map<String, dynamic> message) async {
  //     notificationData = message;
  //     print('onResume: $notificationData');

  //     //send to my orders
  //     // Navigator.push(
  //     //   context,
  //     //   MaterialPageRoute(
  //     //     builder: (context) => MyOrdersScreen(
  //     //       currentUser: currentUser,
  //     //     ),
  //     //   ),
  //     // );
  //   },
  // );
}

showNotification(
  RemoteNotification data,
) async {
  var aNdroid = new AndroidNotificationDetails(
    'channelId',
    'channel_name',

    importance: Importance.high,
  );
  var iOS = new IOSNotificationDetails();
  var platform = new NotificationDetails(android: aNdroid, iOS: iOS);

  await flutterLocalNotificationsPlugin.show(
    Random().nextInt(100),
    data.title,
    data.body,
    platform,
  );
}

Future<dynamic> firebaseBackgroundMessageHandler(
    Map<String, dynamic> message) async {
  notificationData = message;
  print(notificationData);

  return Future<void>.value();
}

Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  print('ON MESSAGE :: $message');

  RemoteNotification notification = message.notification;
  AndroidNotification android = message.notification?.android;

  if (notification != null && android != null) {
    showNotification(
      notification,
    );
  }
}
