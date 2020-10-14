import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  var notification = FlutterLocalNotificationsPlugin();

  NotificationManager() {
    initNotification();
  }
  getNotificationInstance() {
    return notification;
  }

  void initNotification() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    notification.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    print("Notification clicked");
    return Future.value(0);
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return Future.value(1);
  }

  void showNotificationDaily(
      int id, String title, String body, int hour, int minute) async {
    var time = Time(hour, minute, 0);
    await notification.showDailyAtTime(
        id, title, body, time, getPlatformChannelSpecifics());
    print('Notification Succesfully Scheduled at ${time.toString()}');
  }

  getPlatformChannelSpecifics() {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'Daily Goal Reminder');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    return platformChannelSpecifics;
  }

  void removeReminder(int notificationId) {
    notification.cancel(notificationId);
  }

  void removeAllReminder() {
    notification.cancelAll();
  }
}
