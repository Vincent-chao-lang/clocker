import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:clocker/screens/home_screen.dart';
import 'package:clocker/screens/alarm_ring_screen.dart';
import 'package:clocker/utils/notifications.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化通知
  await NotificationUtils.initialize();

  // 请求通知权限
  await NotificationUtils.requestPermissions();

  // 设置通知点击处理
  NotificationUtils.setNotificationTapCallback((NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // 当通知被点击时，导航到闹钟响铃界面
    navigatorKey.currentState?.push(MaterialPage(
      child: AlarmRingScreen(
        alarmId: response.payload,
        notificationResponse: response,
      ),
    ));
  });

  runApp(const ClockerApp());
}

class ClockerApp extends StatelessWidget {
  const ClockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clocker',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // 老年人友好的字体配置
        fontFamily: 'System',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
          displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
          displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
