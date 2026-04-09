package com.clocker.clocker.ui

import android.animation.ObjectAnimator
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

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_alarm_ring)

        scheduler = AlarmScheduler(this)

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

        val label = intent.getStringExtra("alarm_label") ?: "闹钟"
        findViewById<TextView>(R.id.message_text).text = label

        stopButton.setOnClickListener {
            stopAlarm()
        }

        snoozeButton.setOnClickListener {
            snoozeAlarm()
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

    private fun stopAlarm() {
        ringtone?.stop()
        timer?.cancel()
        scheduler.cancelAlarmNotification()
        finish()
    }

    private fun snoozeAlarm() {
        // 贪睡 5 分钟
        ringtone?.stop()
        timer?.cancel()
        scheduler.cancelAlarmNotification()

        // TODO: 实现贪睡逻辑

        finish()
    }

    override fun onDestroy() {
        super.onDestroy()
        ringtone?.stop()
        timer?.cancel()
    }

    override fun onBackPressed() {
        // 防止返回键关闭响铃界面
        // 必须点击停止按钮
    }
}
