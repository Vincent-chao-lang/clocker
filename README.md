# Clocker - 极简闹钟应用

一款专为老年人设计的极简闹钟应用，最多2步即可完成闹钟设置。

## 技术栈

- **原生 Android (Kotlin)**: 直接使用 AlarmManager API
- **Material Design 3**: 现代化 UI 设计
- **Gson**: 数据持久化

## 功能特点

- **6个预设时间卡片**: 6:00、7:00、8:00、12:00、18:00、21:00
- **自定义时间**: 支持选择任意时间
- **极简交互**: 点击卡片 → 完成
- **全屏响铃**: 大号时钟界面
- **闹钟管理**: 启用/禁用/删除

## 老年人友好设计

- 大字体（最小 18sp）
- 高对比度配色
- 大按钮区域（最小 48dp）
- 简洁的界面
- 清晰的反馈

## 项目结构

```
app/src/main/java/com/clocker/clocker/
├── model/
│   └── Alarm.kt          # 闹钟数据模型
├── ui/
│   ├── HomeActivity.kt   # 主界面
│   └── AlarmRingActivity.kt  # 响铃界面
├── AlarmScheduler.kt     # 闹钟调度器
└── AlarmReceiver.kt      # 广播接收器
```

## 下载最新版本

https://github.com/Vincent-chao-lang/clocker/releases

## 构建

```bash
./gradlew assembleDebug
```

## License

MIT
