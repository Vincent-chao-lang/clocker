import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 闹钟数据模型
class Alarm {
  final String id;
  final TimeOfDay time;
  final String label;
  final bool isEnabled;
  final DateTime createdAt;

  Alarm({
    required this.id,
    required this.time,
    required this.label,
    this.isEnabled = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 从JSON创建
  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as String,
      time: TimeOfDay(
        hour: json['hour'] as int,
        minute: json['minute'] as int,
      ),
      label: json['label'] as String,
      isEnabled: json['isEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': time.hour,
      'minute': time.minute,
      'label': label,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 获取下次响铃时间
  DateTime getNextAlarmTime() {
    final now = DateTime.now();
    DateTime alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // 如果今天的时间已过,设置为明天
    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    return alarmTime;
  }

  /// 获取格式化的时间字符串
  String getFormattedTime() {
    return DateFormat('HH:mm').format(
      DateTime(2024, 1, 1, time.hour, time.minute),
    );
  }

  /// 获取时段标签
  String getPeriodLabel() {
    if (time.hour >= 5 && time.hour < 12) return '早上';
    if (time.hour >= 12 && time.hour < 14) return '中午';
    if (time.hour >= 14 && time.hour < 18) return '下午';
    return '晚上';
  }

  /// 复制并修改
  Alarm copyWith({
    String? id,
    TimeOfDay? time,
    String? label,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
