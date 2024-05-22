


import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MessagingService {
  static String? fcmToken;

  static final MessagingService _instance = MessagingService._internal();


  final FirebaseAuth auth = FirebaseAuth.instance;



  factory MessagingService() => _instance;

  MessagingService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;



  Future<void> init(BuildContext context,{
    String? foodName,
    String? foodPrice,
    String? restaurantName,
  }) async {

    // Requesting permission for notifications

    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
        'User granted notifications permission: ${settings.authorizationStatus}');

    // Retrieving the FCM token
    fcmToken = await _fcm.getToken();
    print('fcmToken: $fcmToken');









    // Handling background messages using the specified handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listening for incoming messages while the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.notification!.title.toString()}');

      if (message.notification != null) {
        if (message.notification!.title != null &&
            message.notification!.body != null) {
          print(message.notification?.title);
          print(message.notification?.body);

          final notificationData = message.data;
          final screen = notificationData['screen'];



          // Showing an alert dialog when a notification is received (Foreground state)
         {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: Container(
                    child: AlertDialog(
                      backgroundColor: Colors.orange,
                      title: Text(message.notification!.title!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23,color: Colors.white)),
                      content: Text(message.notification!.body!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19,color: Colors.black)),
                      actions: [
                        if (notificationData.containsKey('screen'))
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushNamed(screen);
                            },
                            child: const Text('Open Screen'),
                          ),
                        TextButton(style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.brown),),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        }
      }
    });


    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationClick(context, message);
      }
    });

    // Handling a notification click event when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          'onMessageOpenedApp: ${message.notification!.title.toString()}');
      _handleNotificationClick(context, message);
    });
  }

  // Handling a notification click event by navigating to the specified screen
  void _handleNotificationClick(BuildContext context, RemoteMessage message) {
    final notificationData = message.data;

    if (notificationData.containsKey('screen')) {
      final screen = notificationData['screen'];
      Navigator.of(context).pushNamed(screen);
    }
  }
}

// Handler for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint('Handling a background message: ${message.notification!.title}');
}


