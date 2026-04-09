package com.clocker.clocker.ui

import android.animation.ObjectAnimator
import android.app.AlertDialog
import android.media.AudioAttributes
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.CountDownTimer
import android.view.animation.LinearInterpolator
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.clocker.clocker.AlarmScheduler
import com.clocker.clocker.R
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

/**
 * 闹钟响铃界面 - 全屏显示
 */
class AlarmRingActivity : AppCompatActivity() {

    private lateinit var alarmIcon: ImageView
    private lateinit var timeText: TextView
    private lateinit var stopButton: Button
    private lateinit var snoozeButton: Button
    private lateinit var scheduler: AlarmScheduler
    private var ringtone: Ringtone? = null
    private var timer: CountDownTimer? = null
    private var alarmId: String? = null
    private var alarmLabel: String? = null
    private var alarmHour: Int = 0
    private var alarmMinute: Int = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_alarm_ring)

        scheduler = AlarmScheduler(this)

        // 获取闹钟信息
        alarmId = intent.getStringExtra("alarm_id")
        alarmLabel = intent.getStringExtra("alarm_label") ?: "闹钟"
        alarmHour = intent.getIntExtra("alarm_hour", 7)
        alarmMinute = intent.getIntExtra("alarm_minute", 0)

        initViews()
        startAlarmAnimation()
        playAlarmSound()
        startTimeUpdate()
    }

    private fun initViews() {
        alarmIcon = findViewById(R.id.alarm_icon)
        timeText = findViewById(R.id.time_text)
        stopButton = findViewById(R.id.btn_stop)
        snoozeButton = findViewById(R.id.btn_snooze)

        findViewById<TextView>(R.id.message_text).text = alarmLabel

        stopButton.setOnClickListener {
            showStopConfirmDialog()
        }

        snoozeButton.setOnClickListener {
            snoozeFor5Minutes()
        }

        updateTime()
    }

    private fun startAlarmAnimation() {
        // 闹钟图标摇摆动画
        ObjectAnimator.ofFloat(alarmIcon, "rotation", -10f, 10f).apply {
            duration = 500
            repeatCount = ObjectAnimator.INFINITE
            repeatMode = ObjectAnimator.REVERSE
            interpolator = LinearInterpolator()
            start()
        }

        // 闹钟图标缩放动画
        ObjectAnimator.ofFloat(alarmIcon, "scaleX", 1f, 1.1f, 1f).apply {
            duration = 1000
            repeatCount = ObjectAnimator.INFINITE
            start()
        }

        ObjectAnimator.ofFloat(alarmIcon, "scaleY", 1f, 1.1f, 1f).apply {
            duration = 1000
            repeatCount = ObjectAnimator.INFINITE
            start()
        }
    }

    private fun playAlarmSound() {
        try {
            val alarmUri: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ringtone = RingtoneManager.getRingtone(applicationContext, alarmUri)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
                ringtone?.audioAttributes = audioAttributes
            }

            ringtone?.play()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun startTimeUpdate() {
        timer = object : CountDownTimer(Long.MAX_VALUE, 1000) {
            override fun onTick(millisUntilFinished: Long) {
                updateTime()
            }

            override fun onFinish() {}
        }.start()
    }

    private fun updateTime() {
        val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
        val currentTime = timeFormat.format(Date())
        timeText.text = currentTime
    }

    private fun showStopConfirmDialog() {
        AlertDialog.Builder(this)
            .setTitle(getString(R.string.confirm_schedule_tomorrow))
            .setPositiveButton(getString(R.string.yes)) { _, _ ->
                scheduleForTomorrow()
            }
            .setNegativeButton(getString(R.string.no)) { _, _ ->
                stopAlarm()
            }
            .setCancelable(false)
            .show()
    }

    private fun scheduleForTomorrow() {
        ringtone?.stop()
        timer?.cancel()
        scheduler.cancelAlarmNotification()

        // 调度为明天同一时间
        alarmId?.let { id ->
            scheduler.scheduleForTomorrow(id, alarmLabel, alarmHour, alarmMinute)
        }

        showToast(getString(R.string.scheduled_for_tomorrow))
        finish()
    }

    private fun snoozeFor5Minutes() {
        ringtone?.stop()
        timer?.cancel()
        scheduler.cancelAlarmNotification()

        // 调度5分钟后的闹钟
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.MINUTE, 5)

        alarmId?.let { id ->
            scheduler.scheduleOneTime(
                id,
                alarmLabel ?: "闹钟",
                calendar.get(Calendar.HOUR_OF_DAY),
                calendar.get(Calendar.MINUTE)
            )
        }

        showToast(getString(R.string.snoozed_for_5min))
        finish()
    }

    private fun stopAlarm() {
        ringtone?.stop()
        timer?.cancel()
        scheduler.cancelAlarmNotification()
        finish()
    }

    private fun showToast(message: String) {
        android.widget.Toast.makeText(this, message, android.widget.Toast.LENGTH_SHORT).show()
    }

    override fun onDestroy() {
        super.onDestroy()
        ringtone?.stop()
        timer?.cancel()
    }

    override fun onBackPressed() {
        // 防止返回键关闭响铃界面
        // 必须点击停止或等会按钮
    }
}
