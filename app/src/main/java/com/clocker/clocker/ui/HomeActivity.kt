package com.clocker.clocker.ui

import android.app.AlertDialog
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.CompoundButton
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.Switch
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.cardview.widget.CardView
import androidx.core.content.ContextCompat
import com.clocker.clocker.AlarmScheduler
import com.clocker.clocker.R
import com.clocker.clocker.model.Alarm
import java.util.Calendar

/**
 * 主界面 - 闹钟列表和快速添加
 */
class HomeActivity : AppCompatActivity() {

    private lateinit var alarmsContainer: LinearLayout
    private lateinit var emptyView: LinearLayout
    private lateinit var statusText: TextView
    private lateinit var scheduler: AlarmScheduler
    private var alarms: MutableList<Alarm> = mutableListOf()

    // 预设时间
    private val presetTimes = listOf(
        Pair(6, "早起"),
        Pair(7, "上班"),
        Pair(8, "上学"),
        Pair(12, "午休"),
        Pair(18, "下班"),
        Pair(21, "睡前")
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_home)

        scheduler = AlarmScheduler(this)

        initViews()
        loadAlarms()
        setupPresetButtons()
    }

    private fun initViews() {
        alarmsContainer = findViewById(R.id.alarms_container)
        emptyView = findViewById(R.id.empty_view)
        statusText = findViewById(R.id.status_text)

        findViewById<Button>(R.id.btn_custom_time).setOnClickListener {
            showCustomTimePicker()
        }
    }

    private fun loadAlarms() {
        alarms = Alarm.loadAll(this).toMutableList()
        updateUI()
    }

    private fun updateUI() {
        alarmsContainer.removeAllViews()

        if (alarms.isEmpty()) {
            emptyView.visibility = View.VISIBLE
            alarmsContainer.visibility = View.GONE
        } else {
            emptyView.visibility = View.GONE
            alarmsContainer.visibility = View.VISIBLE

            alarms.forEach { alarm ->
                addAlarmView(alarm)
            }
        }

        updateStatus()
    }

    private fun updateStatus() {
        val enabledCount = alarms.count { it.isEnabled }
        statusText.text = "$enabledCount/${alarms.size} 已开启"
    }

    private fun addAlarmView(alarm: Alarm) {
        val view = layoutInflater.inflate(R.layout.item_alarm, alarmsContainer, false)

        val iconView = view.findViewById<ImageView>(R.id.alarm_icon)
        val labelView = view.findViewById<TextView>(R.id.alarm_label)
        val timeView = view.findViewById<TextView>(R.id.alarm_time)
        val statusView = view.findViewById<TextView>(R.id.alarm_status)
        val switchView = view.findViewById<Switch>(R.id.alarm_switch)
        val deleteBtn = view.findViewById<CardView>(R.id.delete_btn)

        if (alarm.isEnabled) {
            iconView.setImageResource(R.drawable.ic_alarm_on)
            iconView.setColorFilter(ContextCompat.getColor(this, R.color.blue_500))
        } else {
            iconView.setImageResource(R.drawable.ic_alarm_off)
            iconView.setColorFilter(ContextCompat.getColor(this, R.color.gray_800))
        }

        labelView.text = alarm.label
        timeView.text = "${alarm.getPeriodLabel()} ${alarm.getFormattedTime()}"

        if (!alarm.isEnabled) {
            statusView.visibility = View.VISIBLE
            statusView.text = "已关闭"
        }

        switchView.isChecked = alarm.isEnabled
        switchView.setOnCheckedChangeListener { _, isChecked ->
            toggleAlarm(alarm, isChecked)
        }

        deleteBtn.setOnClickListener {
            showDeleteDialog(alarm)
        }

        alarmsContainer.addView(view)
    }

    private fun setupPresetButtons() {
        val gridContainer = findViewById<LinearLayout>(R.id.preset_grid)

        // 第一行
        val row1 = createRow()
        row1.addView(createPresetCard(0))
        row1.addView(createPresetCard(1))
        gridContainer.addView(row1)

        // 第二行
        val row2 = createRow()
        row2.addView(createPresetCard(2))
        row2.addView(createPresetCard(3))
        gridContainer.addView(row2)

        // 第三行
        val row3 = createRow()
        row3.addView(createPresetCard(4))
        row3.addView(createPresetCard(5))
        gridContainer.addView(row3)
    }

    private fun createRow(): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dp(16)
            }
            weightSum = 2f
        }
    }

    private fun createPresetCard(index: Int): CardView {
        val (hour, label) = presetTimes[index]

        val card = layoutInflater.inflate(R.layout.item_time_card, null) as CardView
        card.layoutParams = LinearLayout.LayoutParams(
            0,
            dp(140),
            1f
        ).apply {
            rightMargin = dp(8)
        }

        val timeView = card.findViewById<TextView>(R.id.card_time)
        val labelView = card.findViewById<TextView>(R.id.card_label)

        timeView.text = String.format("%02d:00", hour)
        labelView.text = label

        card.setOnClickListener {
            addAlarm(hour, 0, label)
        }

        return card
    }

    private fun showCustomTimePicker() {
        val currentTime = Calendar.getInstance()
        val hour = currentTime.get(Calendar.HOUR_OF_DAY)
        val minute = currentTime.get(Calendar.MINUTE)

        val picker = android.app.TimePickerDialog(
            this,
            { _, selectedHour, selectedMinute ->
                addAlarm(selectedHour, selectedMinute, "自定义")
            },
            hour,
            minute,
            true // 24小时制
        )
        picker.show()
    }

    private fun addAlarm(hour: Int, minute: Int, label: String) {
        val alarm = Alarm(
            id = System.currentTimeMillis().toString(),
            hour = hour,
            minute = minute,
            label = label,
            isEnabled = true
        )

        alarms.add(alarm)
        Alarm.saveAll(this, alarms)
        scheduler.scheduleAlarm(alarm)

        updateUI()
        Toast.makeText(this, "闹钟已添加", Toast.LENGTH_SHORT).show()
    }

    private fun toggleAlarm(alarm: Alarm, enabled: Boolean) {
        val index = alarms.indexOf(alarm)
        if (index != -1) {
            alarms[index].isEnabled = enabled
            Alarm.saveAll(this, alarms)

            if (enabled) {
                scheduler.scheduleAlarm(alarms[index])
            } else {
                scheduler.cancelAlarm(alarm)
            }

            updateUI()
            Toast.makeText(
                this,
                if (enabled) "闹钟已开启" else "闹钟已关闭",
                Toast.LENGTH_SHORT
            ).show()
        }
    }

    private fun showDeleteDialog(alarm: Alarm) {
        AlertDialog.Builder(this)
            .setTitle("删除闹钟")
            .setMessage("确定要删除这个闹钟吗？")
            .setPositiveButton("删除") { _, _ ->
                deleteAlarm(alarm)
            }
            .setNegativeButton("取消", null)
            .show()
    }

    private fun deleteAlarm(alarm: Alarm) {
        scheduler.cancelAlarm(alarm)
        alarms.remove(alarm)
        Alarm.saveAll(this, alarms)
        updateUI()
        Toast.makeText(this, "闹钟已删除", Toast.LENGTH_SHORT).show()
    }

    private fun dp(px: Int): Int {
        return (px * resources.displayMetrics.density).toInt()
    }
}
