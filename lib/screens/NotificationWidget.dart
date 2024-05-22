import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationWidget {
  static final _notifications = FlutterLocalNotificationsPlugin();
  bool androidAllowWhileIdle = false;
  static Future init({bool scheduled = false}) async {
    var initAndroidSettings =
        AndroidInitializationSettings('drawable/onb1');

    final settings = InitializationSettings(android: initAndroidSettings);
    await _notifications.initialize(settings);
  }

  static Future showScheduleNotification(
          {var id = 0,
          var title,
          var body,
          var payload,

          required DateTime scheduleTime}) async =>
      _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduleTime, tz.local),
        await notificationDetails(),
        payload: payload,
      // androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

  static notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'channelId',
        'channelName',
        importance: Importance.max,
        // sound: RawResourceAndroidNotificationSound('notification')
      ),
    );
  }
}


