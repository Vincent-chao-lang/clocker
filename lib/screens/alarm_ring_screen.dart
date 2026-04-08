import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 闹钟响铃界面 - 全屏显示
class AlarmRingScreen extends StatefulWidget {
  final String? alarmId;
  final NotificationResponse? notificationResponse;

  const AlarmRingScreen({
    super.key,
    this.alarmId,
    this.notificationResponse,
  });

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  @override
  void initState() {
    super.initState();
    // 这里可以添加播放闹钟声音的逻辑
  }

  void _stopAlarm() {
    Navigator.of(context).pop();
    // 这里可以添加停止闹钟声音的逻辑
  }

  void _snoozeAlarm() {
    Navigator.of(context).pop();
    // 这里可以添加贪睡逻辑
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 80),
              // 闹钟图标
              Icon(
                Icons.alarm,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 40),
              // 时间显示
              Text(
                timeString,
                style: TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              // 提示文字
              Text(
                '闹钟响了！',
                style: TextStyle(
                  fontSize: 36,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              // 按钮区域
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  children: [
                    // 贪睡按钮
                    Expanded(
                      child: SizedBox(
                        height: 80,
                        child: OutlinedButton(
                          onPressed: _snoozeAlarm,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.snooze,
                                size: 36,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '贪睡',
                                style: TextStyle(
                                  fontSize: 24,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // 停止按钮
                    Expanded(
                      child: SizedBox(
                        height: 80,
                        child: FilledButton(
                          onPressed: _stopAlarm,
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.stop,
                                size: 36,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '停止',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
