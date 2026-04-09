package com.clocker.clocker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * 闹钟广播接收器
 */
class AlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra("alarm_id") ?: return
        val alarmLabel = intent.getStringExtra("alarm_label") ?: "闹钟"
        val alarmHour = intent.getIntExtra("alarm_hour", 7)
        val alarmMinute = intent.getIntExtra("alarm_minute", 0)
        val isSnooze = intent.getBooleanExtra("is_snooze", false)

        // 显示通知并启动响铃界面
        val scheduler = AlarmScheduler(context)
        scheduler.showAlarmNotification(alarmId, alarmLabel, alarmHour, alarmMinute)

        // 如果不是贪睡闹钟，可以在这里重新调度为明天
        // 但根据需求，我们在用户点击停止时才询问是否调度明天
    }
}
