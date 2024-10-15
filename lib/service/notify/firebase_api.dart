import 'package:dating_build/bloc/bloc_all_tap/all_tap_bloc.dart';
import 'package:dating_build/bloc/bloc_home/home_bloc.dart';
import 'package:dating_build/common/global.dart';
import 'package:dating_build/main.dart';
import 'package:dating_build/theme/theme_config.dart';
import 'package:dating_build/ui/all_tap_bottom/all_tap_bottom_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  int? lastNotificationId;

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings("@drawable/message_notify");

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null,
    );

    await _localNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id',
      'your_channel_name',
      description: 'your_channel_description',
      importance: Importance.max,
    );

    await _localNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    Global.setString(ThemeConfig.token, fCMToken ?? "");
    initPushNotification();
  }

  void handleMessage(RemoteMessage? message, {bool isFromNotification = false}) {
    if (message == null) return;
    if (!isFromNotification && message.notification != null) {
      _showNotification(message.notification!.title, message.notification!.body);
    } else if (isFromNotification) {
      navigatorKey.currentState?.pushNamed(AllTapBottomScreen.routeName);
      navigatorKey.currentState?.context.read<HomeBloc>().add(HomeEvent(currentIndex: 2));
    }
  }

  Future<void> _showNotification(String? title, String? body) async {
    const notificationId = 0;
    if (lastNotificationId != notificationId) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        icon: "@drawable/message_notify",
        largeIcon: DrawableResourceAndroidBitmap('message_notify'),
      );

      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

      await _localNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: 'item x',
      );

      lastNotificationId = notificationId;
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
