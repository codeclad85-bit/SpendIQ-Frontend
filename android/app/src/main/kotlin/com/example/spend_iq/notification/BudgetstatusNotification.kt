package com.example.spend_iq

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

object BudgetStatusNotification {

    private const val CHANNEL_ID = "spendiq_budget_overview_v3"
    private const val NOTIFICATION_ID = 2001
    private const val PREFS = "SpendIQPrefs"
    private const val ENABLED_KEY = "budgetStatusEnabled"

    fun isEnabled(context: Context): Boolean =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getBoolean(ENABLED_KEY, true)

    fun setEnabled(context: Context, enabled: Boolean) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putBoolean(ENABLED_KEY, enabled).apply()
        if (!enabled) cancel(context)
    }

    fun update(
        context: Context,
        dailyLimit: Double,
        todaySpending: Double,
        weeklyLimit: Double,
        thisWeekSpending: Double,
        fifteenDayLimit: Double,
        lastFifteenDaysSpending: Double,
        monthlyLimit: Double,
        currentMonthSpending: Double
    ) {
        if (!isEnabled(context)) return

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        createChannel(manager)

        val rows = mutableListOf<String>()
        if (dailyLimit > 0) rows += "Today: ₹${money(todaySpending)} / ₹${money(dailyLimit)} • ${percent(todaySpending, dailyLimit)}%"
        if (weeklyLimit > 0) rows += "Week: ₹${money(thisWeekSpending)} / ₹${money(weeklyLimit)} • ${percent(thisWeekSpending, weeklyLimit)}%"
        if (fifteenDayLimit > 0) rows += "15 Days: ₹${money(lastFifteenDaysSpending)} / ₹${money(fifteenDayLimit)} • ${percent(lastFifteenDaysSpending, fifteenDayLimit)}%"
        if (monthlyLimit > 0) rows += "Month: ₹${money(currentMonthSpending)} / ₹${money(monthlyLimit)} • ${percent(currentMonthSpending, monthlyLimit)}%"

        val status = overallStatus(
            listOf(
                ratio(todaySpending, dailyLimit),
                ratio(thisWeekSpending, weeklyLimit),
                ratio(lastFifteenDaysSpending, fifteenDayLimit),
                ratio(currentMonthSpending, monthlyLimit)
            )
        )

        val bigText = if (rows.isEmpty()) {
            "Set a spending limit in SpendIQ to see your live budget status here."
        } else {
            rows.joinToString("\n") + "\n$status"
        }

        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val pendingIntent = launchIntent?.let {
            PendingIntent.getActivity(
                context,
                0,
                it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION") Notification.Builder(context)
        }

        builder
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle("SpendIQ • Budget Overview")
            .setContentText(status)
            .setSubText("Live budget")
            .setStyle(Notification.BigTextStyle().bigText(bigText))
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setAutoCancel(false)
            .setShowWhen(false)
            .setCategory(Notification.CATEGORY_STATUS)
            .setVisibility(Notification.VISIBILITY_PRIVATE)

        if (pendingIntent != null) builder.setContentIntent(pendingIntent)

        manager.notify(NOTIFICATION_ID, builder.build())
    }

    fun cancel(context: Context) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(NOTIFICATION_ID)
    }

    private fun createChannel(manager: NotificationManager) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Live Budget",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Your current SpendIQ budget overview"
                setSound(null, null)
                enableVibration(false)
                setShowBadge(false)
            }
            manager.createNotificationChannel(channel)
        }
    }

    private fun ratio(spent: Double, limit: Double): Double? =
        if (limit > 0) spent / limit else null

    private fun overallStatus(values: List<Double?>): String {
        val max = values.filterNotNull().maxOrNull() ?: return "Budget limits not set"
        return when {
            max >= 1.0 -> "🔴 Spending limit exceeded"
            max >= 0.90 -> "🟠 Very close to your limit"
            max >= 0.80 -> "🟡 Watch your spending"
            else -> "🟢 Spending under control"
        }
    }

    private fun percent(spent: Double, limit: Double): Int =
        if (limit <= 0) 0 else ((spent / limit) * 100).toInt().coerceAtLeast(0)

    private fun money(value: Double): String =
        if (value % 1.0 == 0.0) value.toLong().toString() else String.format("%.2f", value)
}
