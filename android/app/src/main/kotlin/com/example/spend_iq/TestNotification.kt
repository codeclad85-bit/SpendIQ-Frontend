package com.example.spend_iq

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.util.Log

object TestNotification {

    fun send(context: Context) {

        // Check 1: function call hua ya nahi
        Log.d(
            "SpendIQ_TEST",
            "send() called"
        )

        val channelId = "payment_test_channel"

        val notificationManager =
            context.getSystemService(
                Context.NOTIFICATION_SERVICE
            ) as NotificationManager

        // Create notification channel
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val channel = NotificationChannel(
                channelId,
                "Payment Test",
                NotificationManager.IMPORTANCE_HIGH
            )

            notificationManager.createNotificationChannel(
                channel
            )

            Log.d(
                "SpendIQ_TEST",
                "Notification channel created"
            )
        }

        // Create notification
        val notification =
            android.app.Notification.Builder(
                context,
                channelId
            )
                .setSmallIcon(
                    context.applicationInfo.icon
                )
                .setContentTitle(
                    "Payment Test"
                )
                .setContentText(
                    "You paid Rs. 250 to TestMerchant"
                )
                .setStyle(
                    android.app.Notification.BigTextStyle()
                        .bigText(
                            "You paid Rs. 250 to TestMerchant"
                        )
                )
                .setAutoCancel(true)
                .build()

        // Send notification
        notificationManager.notify(
            999,
            notification
        )

        // Check 2: notify() execute hua ya nahi
        Log.d(
            "SpendIQ_TEST",
            "notify() executed"
        )
    }
}