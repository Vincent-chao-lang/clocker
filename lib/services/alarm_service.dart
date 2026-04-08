import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clocker/models/alarm.dart';
import 'package:clocker/utils/notifications.dart';

/// 闹钟服务
class AlarmService {
  static const String _alarmKey = 'current_alarm';
  static const int _notificationId = 1001;

  /// 设置闹钟
  Future<void> setAlarm(Alarm alarm) async {
    final prefs = await SharedPreferences.getInstance();

    // 取消之前的闹钟
    await cancelAlarm();

    // 保存闹钟信息
    await prefs.setString(_alarmKey, jsonEncode(alarm.toJson()));

    // 调度通知
    final nextAlarmTime = alarm.getNextAlarmTime();
    await NotificationUtils.scheduleNotification(
      id: _notificationId,
      title: '⏰ 闹钟',
      body:
          '${alarm.getPeriodLabel()} ${alarm.getFormattedTime()} - ${alarm.label}',
      scheduledTime: nextAlarmTime,
    );
  }

  /// 获取当前闹钟
  Future<Alarm?> getCurrentAlarm() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmJson = prefs.getString(_alarmKey);

    if (alarmJson == null) return null;

    try {
      final alarmData = jsonDecode(alarmJson) as Map<String, dynamic>;
      return Alarm.fromJson(alarmData);
    } catch (e) {
      // 如果解析失败,清除损坏的数据
      await prefs.remove(_alarmKey);
      return null;
    }
  }

  /// 取消闹钟
  Future<void> cancelAlarm() async {
    final prefs = await SharedPreferences.getInstance();

    // 取消通知
    await NotificationUtils.cancelNotification(_notificationId);

    // 清除保存的闹钟
    await prefs.remove(_alarmKey);
  }

  /// 检查是否有活动的闹钟
  Future<bool> hasActiveAlarm() async {
    final alarm = await getCurrentAlarm();
    return alarm != null && alarm.isEnabled;
  }
}
