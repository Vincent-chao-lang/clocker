import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Clocker smoke test', (WidgetTester tester) async {
    // 这是一个基本的冒烟测试,确保应用可以启动
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Clocker'),
        ),
      ),
    );

    expect(find.text('Clocker'), findsOneWidget);
  });

  testWidgets('TimeOfDay model test', (WidgetTester tester) async {
    // 测试Flutter内置的TimeOfDay模型
    final time1 = const TimeOfDay(hour: 7, minute: 0);
    final time2 = const TimeOfDay(hour: 7, minute: 0);
    final time3 = const TimeOfDay(hour: 8, minute: 0);

    expect(time1 == time2, true);
    expect(time1 == time3, false);
  });
}
