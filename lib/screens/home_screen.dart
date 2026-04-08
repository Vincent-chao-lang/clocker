import 'package:flutter/material.dart';
import 'package:clocker/models/alarm.dart';
import 'package:clocker/widgets/time_card.dart';
import 'package:clocker/widgets/custom_time_button.dart';
import 'package:clocker/services/alarm_service.dart';

/// 主界面 - 时间卡片网格
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AlarmService _alarmService = AlarmService();
  List<Alarm> _alarms = [];
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
    _initAlarms();
  }

  Future<void> _initAlarms() async {
    // 首次检查是否有闹钟,如果没有则创建默认闹钟
    final alarms = await _alarmService.getAlarms();
    if (alarms.isEmpty) {
      await _alarmService.ensureDefaultAlarm();
    }

    await _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    final alarms = await _alarmService.getAlarms();

    if (mounted) {
      setState(() {
        _alarms = alarms;
        _isLoading = false;
      });
    }
  }

  Future<void> _onPresetTimeSelected(int index) async {
    final preset = presetTimes[index];
    final newAlarm = Alarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      time: TimeOfDay(hour: preset['hour'], minute: preset['minute']),
      label: preset['label'],
      isEnabled: true,
    );

    await _alarmService.addAlarm(newAlarm);
    await _loadAlarms();
    if (mounted) {
      _showSuccessSnackBar();
    }
  }

  Future<void> _onCustomTimeSelected() async {
    // 直接打开系统时间选择器
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (selectedTime != null) {
      final newAlarm = Alarm(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        time: selectedTime,
        label: '自定义',
        isEnabled: true,
      );

      await _alarmService.addAlarm(newAlarm);
      await _loadAlarms();
      if (mounted) {
        _showSuccessSnackBar();
      }
    }
  }

  Future<void> _toggleAlarm(String alarmId, bool enabled) async {
    await _alarmService.toggleAlarm(alarmId, enabled);
    await _loadAlarms();
    if (mounted) {
      _showToggleSnackBar(enabled);
    }
  }

  Future<void> _deleteAlarm(String alarmId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除闹钟', style: TextStyle(fontSize: 24)),
        content: const Text('确定要删除这个闹钟吗?', style: TextStyle(fontSize: 20)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('取消', style: TextStyle(fontSize: 22)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('删除', style: TextStyle(fontSize: 22)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _alarmService.deleteAlarm(alarmId);
      await _loadAlarms();
      if (mounted) {
        _showDeleteSnackBar();
      }
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('闹钟已添加', style: TextStyle(fontSize: 18)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showToggleSnackBar(bool enabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled ? '闹钟已开启' : '闹钟已关闭',
          style: const TextStyle(fontSize: 18),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('闹钟已删除', style: TextStyle(fontSize: 18)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildAlarmItem(Alarm alarm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: alarm.isEnabled
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            alarm.isEnabled ? Icons.alarm : Icons.alarm_off,
            size: 32,
            color: alarm.isEnabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.5),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: (alarm.isEnabled
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant)
                        .withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${alarm.getPeriodLabel()} ${alarm.getFormattedTime()}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: alarm.isEnabled
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (!alarm.isEnabled)
                  Text(
                    '已关闭',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 开关
          Transform.scale(
            scale: 1.3, // 放大开关
            child: Switch(
              value: alarm.isEnabled,
              onChanged: (value) {
                _toggleAlarm(alarm.id, value);
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          // 删除按钮
          InkWell(
            onTap: () => _deleteAlarm(alarm.id),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_outline,
                size: 26,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
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
              const SizedBox(height: 24),
              // 闹钟列表标题
              Row(
                children: [
                  const Text(
                    '我的闹钟',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${_alarms.where((a) => a.isEnabled).length}/${_alarms.length} 已开启',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 闹钟列表
              if (_isLoading)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              else if (_alarms.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.alarm_off,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '暂无闹钟',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '点击下方卡片添加闹钟',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: List.generate(
                      _alarms.length,
                      (index) => _buildAlarmItem(_alarms[index]),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              // 分隔线
              const Divider(height: 1),
              const SizedBox(height: 24),
              // 快速添加标题
              const Text(
                '快速添加',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // 时间卡片网格
              SizedBox(
                height: 160,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 160 / 140,
                  ),
                  itemCount: presetTimes.length + 1,
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

                      return TimeCard(
                        alarm: alarm,
                        isActive: false,
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
