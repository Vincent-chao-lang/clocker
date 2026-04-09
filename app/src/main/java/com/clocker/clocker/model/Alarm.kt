package com.clocker.clocker.model

import android.content.Context
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.util.Calendar

/**
 * 闹钟数据模型
 */
data class Alarm(
    val id: String,
    val hour: Int,
    val minute: Int,
    val label: String,
    var isEnabled: Boolean = true,
    val createdAt: Long = System.currentTimeMillis()
) {
    /**
     * 获取下次响铃时间
     */
    fun getNextAlarmTime(): Calendar {
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, hour)
        calendar.set(Calendar.MINUTE, minute)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)

        // 如果今天的时间已过，设置为明天
        val now = Calendar.getInstance()
        if (calendar.before(now)) {
            calendar.add(Calendar.DAY_OF_MONTH, 1)
        }

        return calendar
    }

    /**
     * 获取格式化的时间字符串
     */
    fun getFormattedTime(): String {
        return String.format("%02d:%02d", hour, minute)
    }

    /**
     * 获取时段标签
     */
    fun getPeriodLabel(): String {
        return when (hour) {
            in 5..11 -> "早上"
            in 12..13 -> "中午"
            in 14..17 -> "下午"
            else -> "晚上"
        }
    }

    /**
     * 转换为 JSON
     */
    fun toJson(): String {
        return Gson().toJson(this)
    }

    companion object {
        /**
         * 从 JSON 创建
         */
        fun fromJson(json: String): Alarm {
            return Gson().fromJson(json, Alarm::class.java)
        }

        /**
         * 从 SharedPreferences 加载所有闹钟
         */
        fun loadAll(context: Context): List<Alarm> {
            val prefs = context.getSharedPreferences("alarms", Context.MODE_PRIVATE)
            val json = prefs.getString("alarm_list", null) ?: return emptyList()

            return try {
                val type = object : TypeToken<List<Alarm>>() {}.type
                Gson().fromJson(json, type) ?: emptyList()
            } catch (e: Exception) {
                emptyList()
            }
        }

        /**
         * 保存所有闹钟到 SharedPreferences
         */
        fun saveAll(context: Context, alarms: List<Alarm>) {
            val prefs = context.getSharedPreferences("alarms", Context.MODE_PRIVATE)
            val json = Gson().toJson(alarms)
            prefs.edit().putString("alarm_list", json).apply()
        }
    }
}
