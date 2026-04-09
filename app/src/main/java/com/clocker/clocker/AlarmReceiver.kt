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

        // 显示通知并启动响铃界面
        val scheduler = AlarmScheduler(context)
        scheduler.showAlarmNotification(alarmLabel)

        // 重新调度闹钟（每天重复）
        // TODO: 可以在这里添加重新调度逻辑
    }
}
