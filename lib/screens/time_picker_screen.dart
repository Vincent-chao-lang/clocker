import 'package:flutter/material.dart';
import 'package:clocker/models/alarm.dart';

/// 时间选择器界面
class TimePickerScreen extends StatefulWidget {
  final Alarm? initialAlarm;

  const TimePickerScreen({
    super.key,
    this.initialAlarm,
  });

  @override
  State<TimePickerScreen> createState() => _TimePickerScreenState();
}

class _TimePickerScreenState extends State<TimePickerScreen> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialAlarm?.time ?? const TimeOfDay(hour: 7, minute: 0);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _confirm() {
    Navigator.of(context).pop(_selectedTime);
  }

  @override
  Widget build(BuildContext context) {
    // 计算时段标签
    String periodLabel;
    if (_selectedTime.hour >= 5 && _selectedTime.hour < 12) {
      periodLabel = '早上';
    } else if (_selectedTime.hour >= 12 && _selectedTime.hour < 14) {
      periodLabel = '中午';
    } else if (_selectedTime.hour >= 14 && _selectedTime.hour < 18) {
      periodLabel = '下午';
    } else {
      periodLabel = '晚上';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('选择时间', style: TextStyle(fontSize: 24)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // 时间显示
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _selectTime,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _selectedTime.hour.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            ':',
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            _selectedTime.minute.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      periodLabel,
                      style: TextStyle(
                        fontSize: 32,
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // 提示文字
              Text(
                '点击时间可以修改',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              // 确认按钮
              SizedBox(
                width: double.infinity,
                height: 64,
                child: FilledButton(
                  onPressed: _confirm,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('确定', style: TextStyle(fontSize: 24)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
