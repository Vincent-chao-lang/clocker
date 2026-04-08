import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clocker/models/alarm.dart';
import 'package:clocker/utils/notifications.dart';

/// 闹钟服务
class AlarmService {
  static const String _alarmsKey = 'alarms_list';
  static const String _firstRunKey = 'first_run';
  static const int _baseNotificationId = 1000;

  /// 获取所有闹钟
  Future<List<Alarm>> getAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = prefs.getString(_alarmsKey);

    if (alarmsJson == null) {
      // 首次使用,返回空列表,由调用方决定是否创建默认闹钟
      return [];
    }

    try {
      final alarmsList = jsonDecode(alarmsJson) as List;
      return alarmsList
          .map((json) => Alarm.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // 如果解析失败,返回空列表
      return [];
    }
  }

  /// 检查是否是首次运行
  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstRunKey) ?? true;
  }

  /// 标记首次运行已完成
  Future<void> setFirstRunComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstRunKey, false);
  }

  /// 确保至少有一个默认闹钟（仅首次运行）
  Future<Alarm?> ensureDefaultAlarm() async {
    final firstRun = await isFirstRun();
    if (!firstRun) {
      // 不是首次运行，不创建默认闹钟
      return null;
    }

    final alarms = await getAlarms();
    if (alarms.isEmpty) {
      final defaultAlarm = Alarm(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        time: const TimeOfDay(hour: 7, minute: 0),
        label: '起床',
        isEnabled: false,
      );
      await addAlarm(defaultAlarm);
      await setFirstRunComplete();
      return defaultAlarm;
    }
    // 已有闹钟，标记首次运行完成
    await setFirstRunComplete();
    return alarms.first;
  }

  /// 添加闹钟
  Future<void> addAlarm(Alarm alarm) async {
    final alarms = await getAlarms();
    alarms.add(alarm);
    await _saveAlarms(alarms);

    // 如果闹钟启用,调度通知
    if (alarm.isEnabled) {
      await _scheduleAlarm(alarm);
    }
  }

  /// 更新闹钟
  Future<void> updateAlarm(Alarm alarm) async {
    final alarms = await getAlarms();
    final index = alarms.indexWhere((a) => a.id == alarm.id);
    if (index != -1) {
      // 取消旧通知
      await _cancelAlarmNotification(alarm);

      alarms[index] = alarm;
      await _saveAlarms(alarms);

      // 如果闹钟启用,调度新通知
      if (alarm.isEnabled) {
        await _scheduleAlarm(alarm);
      }
    }
  }

  /// 删除闹钟
  Future<void> deleteAlarm(String alarmId) async {
    final alarms = await getAlarms();

    // 查找要删除的闹钟
    final alarmIndex = alarms.indexWhere((a) => a.id == alarmId);
    if (alarmIndex == -1) {
      // 闹钟不存在,直接返回
      return;
    }

    final alarm = alarms[alarmIndex];

    // 取消通知
    await _cancelAlarmNotification(alarm);

    // 从列表中移除
    alarms.removeAt(alarmIndex);
    await _saveAlarms(alarms);
  }

  /// 切换闹钟开关状态
  Future<void> toggleAlarm(String alarmId, bool enabled) async {
    final alarms = await getAlarms();
    final index = alarms.indexWhere((a) => a.id == alarmId);
    if (index != -1) {
      final alarm = alarms[index];
      final updatedAlarm = alarm.copyWith(isEnabled: enabled);
      alarms[index] = updatedAlarm;
      await _saveAlarms(alarms);

      if (enabled) {
        await _scheduleAlarm(updatedAlarm);
      } else {
        await _cancelAlarmNotification(updatedAlarm);
      }
    }
  }

  /// 保存闹钟列表到本地
  Future<void> _saveAlarms(List<Alarm> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = jsonEncode(alarms.map((a) => a.toJson()).toList());
    await prefs.setString(_alarmsKey, alarmsJson);
  }

  /// 调度闹钟通知
  Future<void> _scheduleAlarm(Alarm alarm) async {
    final notificationId = _getNotificationId(alarm.id);
    final nextAlarmTime = alarm.getNextAlarmTime();

    await NotificationUtils.scheduleNotification(
      id: notificationId,
      title: '⏰ 闹钟',
      body:
          '${alarm.getPeriodLabel()} ${alarm.getFormattedTime()} - ${alarm.label}',
      scheduledTime: nextAlarmTime,
    );
  }

  /// 取消闹钟通知
  Future<void> _cancelAlarmNotification(Alarm alarm) async {
    final notificationId = _getNotificationId(alarm.id);
    await NotificationUtils.cancelNotification(notificationId);
  }

  /// 根据闹钟ID生成通知ID
  int _getNotificationId(String alarmId) {
    // 使用闹钟ID的哈希值绝对值,确保正数
    // 每个闹钟有唯一的通知ID,支持最多10000个闹钟
    return _baseNotificationId + alarmId.hashCode.abs() % 10000;
  }

  /// 检查是否有活动的闹钟
  Future<bool> hasActiveAlarm() async {
    final alarms = await getAlarms();
    return alarms.any((alarm) => alarm.isEnabled);
  }
}
