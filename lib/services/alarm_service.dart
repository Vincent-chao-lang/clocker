import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clocker/models/alarm.dart';
import 'package:clocker/utils/notifications.dart';

/// 闹钟服务
class AlarmService {
  static const String _alarmKey = 'default_alarm';
  static const int _notificationId = 1001;

  /// 获取或创建默认闹钟
  Future<Alarm> getOrCreateDefaultAlarm() async {
    final alarm = await getCurrentAlarm();
    if (alarm != null) {
      return alarm;
    }

    // 创建默认闹钟:早上7点
    final defaultAlarm = Alarm(
      id: 'default_alarm',
      time: const TimeOfDay(hour: 7, minute: 0),
      label: '起床',
      isEnabled: false, // 默认关闭
    );

    await _saveAlarm(defaultAlarm);
    return defaultAlarm;
  }

  /// 设置闹钟
  Future<void> setAlarm(Alarm alarm) async {
    final prefs = await SharedPreferences.getInstance();

    // 取消之前的通知
    await NotificationUtils.cancelNotification(_notificationId);

    // 保存闹钟信息
    await _saveAlarm(alarm);

    // 如果闹钟启用,调度通知
    if (alarm.isEnabled) {
      final nextAlarmTime = alarm.getNextAlarmTime();
      await NotificationUtils.scheduleNotification(
        id: _notificationId,
        title: '⏰ 闹钟',
        body:
            '${alarm.getPeriodLabel()} ${alarm.getFormattedTime()} - ${alarm.label}',
        scheduledTime: nextAlarmTime,
      );
    }
  }

  /// 更新闹钟时间
  Future<void> updateAlarmTime(TimeOfDay newTime) async {
    final currentAlarm = await getCurrentAlarm();
    if (currentAlarm == null) return;

    final updatedAlarm = currentAlarm.copyWith(
      time: newTime,
      isEnabled: true, // 修改时间时自动启用
    );

    await setAlarm(updatedAlarm);
  }

  /// 启用/关闭闹钟
  Future<void> toggleAlarm(bool enabled) async {
    final currentAlarm = await getCurrentAlarm();
    if (currentAlarm == null) return;

    final updatedAlarm = currentAlarm.copyWith(isEnabled: enabled);
    await setAlarm(updatedAlarm);
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

  /// 保存闹钟到本地
  Future<void> _saveAlarm(Alarm alarm) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alarmKey, jsonEncode(alarm.toJson()));
  }

  /// 取消闹钟通知(但不删除闹钟)
  Future<void> cancelAlarmNotification() async {
    await NotificationUtils.cancelNotification(_notificationId);

    // 将闹钟设置为关闭状态
    await toggleAlarm(false);
  }

  /// 检查是否有活动的闹钟
  Future<bool> hasActiveAlarm() async {
    final alarm = await getCurrentAlarm();
    return alarm != null && alarm.isEnabled;
  }
}
