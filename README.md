# Clocker - 极简闹钟应用

一款专为老年人设计的极简闹钟应用,最多2步即可完成闹钟设置。

## 功能特点

- **6个预设时间卡片**: 常用时间一键设置(6:00、7:00、8:00、12:00、18:00、21:00)
- **自定义时间选择**: 支持选择任意时间
- **极简交互**: 点击卡片 → 确认,2步完成设置
- **老年人友好**: 大字体、高对比度、大按钮

## 项目结构

```
clocker/
├── lib/
│   ├── main.dart                      # 应用入口
│   ├── models/
│   │   └── alarm.dart                 # 闹钟数据模型
│   ├── screens/
│   │   ├── home_screen.dart           # 主界面(时间卡片)
│   │   ├── confirmation_screen.dart   # 确认界面
│   │   └── time_picker_screen.dart    # 自定义时间选择器
│   ├── widgets/
│   │   ├── time_card.dart             # 时间卡片组件
│   │   └── custom_time_button.dart    # 自定义时间按钮
│   ├── services/
│   │   └── alarm_service.dart         # 闹钟服务(通知调度)
│   └── utils/
│       └── notifications.dart         # 通知工具
├── android/                           # Android原生配置
├── ios/                               # iOS原生配置
└── pubspec.yaml                       # 依赖配置
```

## 技术栈

- **Flutter**: 跨平台UI框架
- **flutter_local_notifications**: 本地通知
- **shared_preferences**: 本地数据持久化
- **intl**: 时间格式化
- **timezone**: 时区处理

## 运行项目

### 前置要求

- Flutter SDK 3.0+
- Android Studio / Xcode
- Android设备/模拟器 或 iOS设备/模拟器

### 安装依赖

```bash
cd clocker
flutter pub get
```

### 运行应用

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# 或使用Flutter工具选择设备
flutter run
```

## 构建发布版本

### Android

```bash
flutter build apk --release
# 或生成App Bundle
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## 权限说明

### Android
- `SCHEDULE_EXACT_ALARM`: 精确闹钟权限
- `POST_NOTIFICATIONS`: 通知权限
- `VIBRATE`: 震动权限

### iOS
- 通知权限会在首次使用时请求

## 待扩展功能

- [ ] 自定义铃声
- [ ] 贪睡功能(响铃后延迟提醒)
- [ ] 多闹钟支持
- [ ] 重复周期(每天/工作日/周末)
- [ ] 语音设置闹钟

## 许可证

MIT License
