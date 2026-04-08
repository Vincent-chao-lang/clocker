import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// 通知点击回调函数类型
typedef NotificationTapCallback = void Function(NotificationResponse response);

/// 通知工具类
class NotificationUtils {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static NotificationTapCallback? _onNotificationTapCallback;

  /// 设置通知点击回调
  static void setNotificationTapCallback(NotificationTapCallback callback) {
    _onNotificationTapCallback = callback;
  }

  /// 初始化通知
  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestProvisionalPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 创建Android通知渠道
    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin
          .createNotificationChannel(const AndroidNotificationChannel(
        'alarm_channel',
        '闹钟通知',
        description: '闹钟提醒通知,使用声音和震动',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      ));
    }

    _initialized = true;
  }

  /// 请求通知权限
  static Future<bool> requestPermissions() async {
    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final iosPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    bool granted = true;

    if (androidPlugin != null) {
      final result = await androidPlugin.requestNotificationsPermission();
      granted = granted && (result ?? false);
    }

    if (iosPlugin != null) {
      final result = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = granted && (result ?? false);
    }

    return granted;
  }

  /// 调度通知
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      '闹钟通知',
      channelDescription: '闹钟提醒通知',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 计算延迟时间
    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    // 如果今天的时间已过，设置为明天
    final targetTime = scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(targetTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 取消通知
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// 取消所有通知
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// 处理通知点击
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // 调用外部设置的回调函数
    _onNotificationTapCallback?.call(response);
  }

  /// 获取待发送的通知
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}
