package com.example.spend_iq

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "spend_iq_test"
    private val NOTIFICATION_PERMISSION_REQUEST = 7001

    private var coinPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                // ==========================================
                // TEST PAYMENT NOTIFICATION
                // ==========================================
                "sendTestNotification" -> {
                    TestNotification.send(this)
                    result.success("Notification sent")
                }

                // ==========================================
                // SAVE USER ID
                // ==========================================
                "saveUserId" -> {
                    val userId =
                        call.argument<Number>("userId")?.toLong()

                    if (userId != null) {

                        getSharedPreferences(
                            "SpendIQPrefs",
                            Context.MODE_PRIVATE
                        ).edit()
                            .putLong("userId", userId)
                            .apply()

                        result.success("User ID saved: $userId")

                    } else {

                        result.error(
                            "INVALID_USER_ID",
                            "User ID not received",
                            null
                        )
                    }
                }

                // ==========================================
                // GET SAVED USER ID
                // ==========================================
                "getSavedUserId" -> {

                    val preferences =
                        getSharedPreferences(
                            "SpendIQPrefs",
                            Context.MODE_PRIVATE
                        )

                    val userId =
                        preferences.getLong(
                            "userId",
                            -1L
                        )

                    if (userId > 0) {
                        result.success(userId)
                    } else {
                        result.success(null)
                    }
                }

                // ==========================================
                // OPTION 4 - HEAVY RUPEE COIN SOUND
                // ==========================================
                "playCoinSound" -> {

                    try {

                        coinPlayer?.release()
                        coinPlayer = null

                        coinPlayer =
                            MediaPlayer.create(
                                applicationContext,
                                R.raw.spendiq_coin
                            )

                        if (coinPlayer == null) {

                            result.error(
                                "COIN_SOUND_ERROR",
                                "spendiq_coin.wav could not be loaded",
                                null
                            )

                        } else {

                            coinPlayer?.setOnCompletionListener {
                                it.release()

                                if (coinPlayer === it) {
                                    coinPlayer = null
                                }
                            }

                            coinPlayer?.start()

                            result.success(true)
                        }

                    } catch (e: Exception) {

                        result.error(
                            "COIN_SOUND_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                // ==========================================
                // REQUEST NOTIFICATION PERMISSION
                // ==========================================
                "requestNotificationPermission" -> {

                    requestNotificationPermissionIfNeeded()

                    result.success(
                        hasNotificationPermission()
                    )
                }

                // ==========================================
                // CHECK PERSISTENT BUDGET STATUS
                // ==========================================
                "isBudgetStatusEnabled" -> {

                    val preferences =
                        getSharedPreferences(
                            "SpendIQPrefs",
                            Context.MODE_PRIVATE
                        )

                    val enabled =
                        preferences.getBoolean(
                            "budgetStatusEnabled",
                            true
                        )

                    result.success(enabled)
                }

                // ==========================================
                // ENABLE / DISABLE BUDGET STATUS
                // ==========================================
                "setBudgetStatusEnabled" -> {

                    val enabled =
                        call.argument<Boolean>("enabled")
                            ?: true

                    val preferences =
                        getSharedPreferences(
                            "SpendIQPrefs",
                            Context.MODE_PRIVATE
                        )

                    preferences.edit()
                        .putBoolean(
                            "budgetStatusEnabled",
                            enabled
                        )
                        .apply()

                    if (enabled) {

                        requestNotificationPermissionIfNeeded()

                    } else {

                        BudgetStatusNotification.cancel(this)
                    }

                    result.success(true)
                }

                // ==========================================
                // UPDATE PERSISTENT BUDGET NOTIFICATION
                // ==========================================
                "updateBudgetStatus" -> {

                    val preferences =
                        getSharedPreferences(
                            "SpendIQPrefs",
                            Context.MODE_PRIVATE
                        )

                    val enabled =
                        preferences.getBoolean(
                            "budgetStatusEnabled",
                            true
                        )

                    if (!enabled) {
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    if (!hasNotificationPermission()) {

                        requestNotificationPermissionIfNeeded()

                        result.success(false)

                        return@setMethodCallHandler
                    }

                    val dailyLimit =
                        number(
                            call.argument<Any>("dailyLimit")
                        )

                    val todaySpending =
                        number(
                            call.argument<Any>("todaySpending")
                        )

                    val weeklyLimit =
                        number(
                            call.argument<Any>("weeklyLimit")
                        )

                    val thisWeekSpending =
                        number(
                            call.argument<Any>("thisWeekSpending")
                        )

                    val fifteenDayLimit =
                        number(
                            call.argument<Any>("fifteenDayLimit")
                        )

                    val lastFifteenDaysSpending =
                        number(
                            call.argument<Any>(
                                "lastFifteenDaysSpending"
                            )
                        )

                    val monthlyLimit =
                        number(
                            call.argument<Any>("monthlyLimit")
                        )

                    val currentMonthSpending =
                        number(
                            call.argument<Any>(
                                "currentMonthSpending"
                            )
                        )

                    // IMPORTANT:
                    // BudgetStatusNotification.kt has update(), not showOrUpdate()
                    BudgetStatusNotification.update(
                        context = this,
                        dailyLimit = dailyLimit,
                        todaySpending = todaySpending,
                        weeklyLimit = weeklyLimit,
                        thisWeekSpending = thisWeekSpending,
                        fifteenDayLimit = fifteenDayLimit,
                        lastFifteenDaysSpending =
                            lastFifteenDaysSpending,
                        monthlyLimit = monthlyLimit,
                        currentMonthSpending =
                            currentMonthSpending
                    )

                    result.success(true)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // ==============================================
    // NUMBER CONVERTER
    // ==============================================
    private fun number(value: Any?): Double {

        return when (value) {

            is Number ->
                value.toDouble()

            is String ->
                value.toDoubleOrNull() ?: 0.0

            else ->
                0.0
        }
    }

    // ==============================================
    // NOTIFICATION PERMISSION CHECK
    // ==============================================
    private fun hasNotificationPermission(): Boolean {

        return if (
            Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.TIRAMISU
        ) {

            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED

        } else {

            true
        }
    }

    // ==============================================
    // REQUEST NOTIFICATION PERMISSION
    // ==============================================
    private fun requestNotificationPermissionIfNeeded() {

        if (
            Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.TIRAMISU &&
            !hasNotificationPermission()
        ) {

            ActivityCompat.requestPermissions(
                this,
                arrayOf(
                    Manifest.permission.POST_NOTIFICATIONS
                ),
                NOTIFICATION_PERMISSION_REQUEST
            )
        }
    }

    // ==============================================
    // CLEAN MEDIA PLAYER
    // ==============================================
    override fun onDestroy() {

        coinPlayer?.release()
        coinPlayer = null

        super.onDestroy()
    }
}