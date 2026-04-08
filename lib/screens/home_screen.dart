import 'package:flutter/material.dart';
import 'package:clocker/models/alarm.dart';
import 'package:clocker/widgets/time_card.dart';
import 'package:clocker/widgets/custom_time_button.dart';
import 'package:clocker/screens/time_picker_screen.dart';
import 'package:clocker/screens/confirmation_screen.dart';
import 'package:clocker/services/alarm_service.dart';

/// 主界面 - 时间卡片网格
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AlarmService _alarmService = AlarmService();
  Alarm? _currentAlarm;
  bool _isLoading = true;

  // 预设时间列表
  static const List<Map<String, dynamic>> presetTimes = [
    {'hour': 6, 'minute': 0, 'label': '早起'},
    {'hour': 7, 'minute': 0, 'label': '上班'},
    {'hour': 8, 'minute': 0, 'label': '上学'},
    {'hour': 12, 'minute': 0, 'label': '午休'},
    {'hour': 18, 'minute': 0, 'label': '下班'},
    {'hour': 21, 'minute': 0, 'label': '睡前'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentAlarm();
  }

  Future<void> _loadCurrentAlarm() async {
    final alarm = await _alarmService.getCurrentAlarm();
    if (mounted) {
      setState(() {
        _currentAlarm = alarm;
        _isLoading = false;
      });
    }
  }

  Future<void> _onPresetTimeSelected(int index) async {
    final preset = presetTimes[index];
    final alarm = Alarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      time: TimeOfDay(hour: preset['hour'], minute: preset['minute']),
      label: preset['label'],
    );

    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(alarm: alarm),
      ),
    );

    if (confirmed == true) {
      await _alarmService.setAlarm(alarm);
      await _loadCurrentAlarm();
      if (mounted) {
        _showSuccessSnackBar();
      }
    }
  }

  Future<void> _onCustomTimeSelected() async {
    final selectedTime = await Navigator.of(context).push<TimeOfDay>(
      MaterialPageRoute(
        builder: (context) => const TimePickerScreen(),
      ),
    );

    if (selectedTime != null) {
      final alarm = Alarm(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        time: selectedTime,
        label: '自定义',
      );

      final confirmed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(alarm: alarm),
        ),
      );

      if (confirmed == true) {
        await _alarmService.setAlarm(alarm);
        await _loadCurrentAlarm();
        if (mounted) {
          _showSuccessSnackBar();
        }
      }
    }
  }

  Future<void> _onCancelAlarm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消闹钟', style: TextStyle(fontSize: 22)),
        content: const Text('确定要取消当前闹钟吗?', style: TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消', style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _alarmService.cancelAlarm();
      await _loadCurrentAlarm();
      if (mounted) {
        _showCancelSnackBar();
      }
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('闹钟设置成功', style: TextStyle(fontSize: 18)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCancelSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('闹钟已取消', style: TextStyle(fontSize: 18)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 标题
              const Text(
                'Clocker',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '选择时间设置闹钟',
                style: TextStyle(
                  fontSize: 18,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              // 当前闹钟状态
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_currentAlarm != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.alarm,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '当前闹钟',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_currentAlarm!.getPeriodLabel()} ${_currentAlarm!.getFormattedTime()}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _onCancelAlarm,
                        icon: Icon(
                          Icons.cancel,
                          size: 32,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.alarm_off,
                        size: 32,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.5),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '当前闹钟: 未设置',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              // 时间卡片网格
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 160 / 140,
                  ),
                  itemCount: presetTimes.length + 1, // 预设时间 + 自定义按钮
                  itemBuilder: (context, index) {
                    if (index < presetTimes.length) {
                      // 预设时间卡片
                      final preset = presetTimes[index];
                      final alarm = Alarm(
                        id: index.toString(),
                        time: TimeOfDay(
                            hour: preset['hour'], minute: preset['minute']),
                        label: preset['label'],
                      );
                      final isActive = _currentAlarm != null &&
                          _currentAlarm!.time.hour == alarm.time.hour &&
                          _currentAlarm!.time.minute == alarm.time.minute;

                      return TimeCard(
                        alarm: alarm,
                        isActive: isActive,
                        onTap: () => _onPresetTimeSelected(index),
                      );
                    } else {
                      // 自定义时间按钮
                      return CustomTimeButton(
                        onTap: _onCustomTimeSelected,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
