import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stackduo/models/notification_model.dart';
import 'package:stackduo/services/notifications_service.dart';
import 'package:stackduo/utilities/prefs.dart';

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future<NotificationDetails> _notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails('channel id', 'channel name',
          channelDescription: 'channel description',
          // importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker'),
      iOS: IOSNotificationDetails(),
    );
  }

  static Future<void> init({bool initScheduled = false}) async {
    const android = AndroidInitializationSettings('app_icon_alpha');
    const iOS = IOSInitializationSettings();
    const linux =
        LinuxInitializationSettings(defaultActionName: "temporary_stack_duo");
    const settings =
        InitializationSettings(android: android, iOS: iOS, linux: linux);
    await _notifications.initialize(
      settings,
      onSelectNotification: (payload) async {
        onNotifications.add(payload);
      },
    );
  }

  static Future<void> clearNotifications() async => _notifications.cancelAll();

  static Future<void> clearNotification(int id) async =>
      _notifications.cancel(id);

  //===================================
  static late Prefs prefs;
  static late NotificationsService notificationsService;

  static Future<void> showNotification({
    required String title,
    required String body,
    required String walletId,
    required String iconAssetName,
    required DateTime date,
    required bool shouldWatchForUpdates,
    required String coinName,
    String? txid,
    int? confirmations,
    int? requiredConfirmations,
    String? changeNowId,
    String? payload,
  }) async {
    await prefs.incrementCurrentNotificationIndex();
    final id = prefs.currentNotificationId;

    String confirms = "";
    if (txid != null) {
      confirms = " (${confirmations!}/${requiredConfirmations!})";
    }

    final NotificationModel model = NotificationModel(
      id: id,
      title: title + confirms,
      description: body,
      iconAssetName: iconAssetName,
      date: date,
      walletId: walletId,
      read: false,
      shouldWatchForUpdates: shouldWatchForUpdates,
      coinName: coinName,
      txid: txid,
      changeNowId: changeNowId,
    );

    await Future.wait([
      _notifications.show(
        id,
        title,
        body,
        await _notificationDetails(),
        payload: payload,
      ),
      notificationsService.add(model, true),
    ]);
  }
}
