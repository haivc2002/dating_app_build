import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  int? lastNotificationId;

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null,
    );

    await _localNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id',
      'your_channel_name',
      description: 'your_channel_description',
      importance: Importance.high,
    );

    await _localNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print("Token: $fCMToken");
    initPushNotification();
  }

  void handleMessage(RemoteMessage? message, {bool isFromNotification = false}) {
    if (message == null) return;

    // Kiểm tra xem có phải là thông báo từ thông báo đã hiển thị hay không
    if (!isFromNotification && message.notification != null) {
      _showNotification(message.notification!.title, message.notification!.body);
    } else if (isFromNotification) {
      // Nếu mở ứng dụng từ thông báo, có thể xử lý thông điệp khác
      // Ví dụ: điều hướng đến trang khác hoặc thực hiện hành động cụ thể
    }
  }

  Future<void> _showNotification(String? title, String? body) async {
    // Sử dụng ID thông báo duy nhất để theo dõi thông báo đã hiển thị
    const notificationId = 0; // Sử dụng ID cố định hoặc bạn có thể tạo ID khác nếu cần

    // Kiểm tra xem thông báo đã được hiển thị chưa
    if (lastNotificationId != notificationId) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('your_channel_id', 'your_channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false);

      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

      await _localNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: 'item x',
      );

      lastNotificationId = notificationId; // Cập nhật ID thông báo đã hiển thị
    }
  }

  Future<void> initPushNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      handleMessage(message, isFromNotification: true);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleMessage(message, isFromNotification: true);
    });
  }
}
