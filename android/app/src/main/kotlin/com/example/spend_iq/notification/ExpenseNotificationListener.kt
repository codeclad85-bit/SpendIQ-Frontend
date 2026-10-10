package com.example.spend_iq.notification

import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import kotlin.concurrent.thread

class ExpenseNotificationListener : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification?) {

        if (sbn == null) return

        val notification = sbn.notification
        val extras = notification.extras
        val packageName = sbn.packageName

        val title = extras.getCharSequence("android.title")?.toString() ?: ""
        val text = extras.getCharSequence("android.text")?.toString() ?: ""
        val bigText = extras.getCharSequence("android.bigText")?.toString() ?: ""
        val subText = extras.getCharSequence("android.subText")?.toString() ?: ""
        val ticker = notification.tickerText?.toString() ?: ""

        val fullText = "$title $text $bigText $subText $ticker".trim()

        Log.d(
            "SpendIQ_NOTIFICATION",
            "APP: $packageName | TITLE: $title | TEXT: $text | BIGTEXT: $bigText | SUBTEXT: $subText | TICKER: $ticker"
        )

        val paymentKeywords = listOf(
            "upi", "payment", "paid", "debit", "debited",
            "sent", "transaction", "spent", "purchase",
            "withdrawn", "transferred", "transfer", "a/c", "account"
        )

        val isPaymentNotification =
            paymentKeywords.any { fullText.contains(it, ignoreCase = true) }

        if (!isPaymentNotification) return

        // ---------------- AMOUNT ----------------

        val amountRegex = Regex(
            """(?:₹|Rs\.?|INR)\s*([0-9,]+(?:\.[0-9]+)?)""",
            RegexOption.IGNORE_CASE
        )

        val amountMatch = amountRegex.find(fullText)

        if (amountMatch == null) {
            Log.d("SpendIQ_PAYMENT", "Payment detected but amount not found")
            return
        }

        val amount = amountMatch.groupValues[1]
            .replace(",", "")
            .toDoubleOrNull()

        if (amount == null || amount <= 0) {
            Log.d("SpendIQ_PAYMENT", "Invalid amount")
            return
        }

        // ---------------- PAYMENT TYPE ----------------

        val outgoingKeywords = listOf(
            "debited", "debit", "you paid", "paid to",
            "payment to", "sent to", "sent", "spent",
            "purchase", "withdrawn", "transferred to", "transfer to"
        )

        val incomingKeywords = listOf(
            "credited", "credit", "received", "received from",
            "paid you", "money received", "deposit"
        )

        val isOutgoing =
            outgoingKeywords.any { fullText.contains(it, ignoreCase = true) }

        val isIncoming =
            incomingKeywords.any { fullText.contains(it, ignoreCase = true) }

        when {

            isOutgoing -> {

                val transactionRef =
                    extractTransactionReference(fullText)

                val paymentMode =
                    extractPaymentMode(fullText)

                val merchant =
                    extractMerchant(fullText)

                Log.d("SpendIQ_PAYMENT", "================================")
                Log.d("SpendIQ_PAYMENT", "OUTGOING / DEBIT PAYMENT")
                Log.d("SpendIQ_PAYMENT", "AMOUNT: ₹$amount")
                Log.d("SpendIQ_PAYMENT", "MERCHANT: $merchant")
                Log.d("SpendIQ_PAYMENT", "PAYMENT MODE: $paymentMode")
                Log.d("SpendIQ_PAYMENT", "TRANSACTION REF: $transactionRef")
                Log.d("SpendIQ_PAYMENT", "APP: $packageName")
                Log.d("SpendIQ_PAYMENT", "================================")

                saveExpenseToBackend(
                    amount = amount,
                    description = fullText,
                    transactionRef = transactionRef,
                    merchant = merchant,
                    paymentMode = paymentMode
                )
            }

            isIncoming -> {

                Log.d(
                    "SpendIQ_PAYMENT",
                    "INCOMING / CREDIT PAYMENT - not saved as expense"
                )
            }

            else -> {

                Log.d(
                    "SpendIQ_PAYMENT",
                    "PAYMENT TYPE UNKNOWN - not saved"
                )
            }
        }
    }

    // ---------------- TRANSACTION REF ----------------

    private fun extractTransactionReference(text: String): String? {

        val patterns = listOf(

            Regex(
                """\bRef(?:erence)?[\s:#-]*([A-Za-z0-9]{6,})""",
                RegexOption.IGNORE_CASE
            ),

            Regex(
                """\bUTR[\s:#-]*([A-Za-z0-9]{6,})""",
                RegexOption.IGNORE_CASE
            ),

            Regex(
                """\b(?:Txn|Transaction)[\s_-]*(?:ID|No)?[\s:#-]*([A-Za-z0-9]{6,})""",
                RegexOption.IGNORE_CASE
            )
        )

        for (pattern in patterns) {

            val match = pattern.find(text)

            if (match != null) {
                return match.groupValues[1].trim()
            }
        }

        return null
    }

    // ---------------- PAYMENT MODE ----------------

    private fun extractPaymentMode(text: String): String {

        return when {

            text.contains("UPI", ignoreCase = true) ->
                "UPI"

            text.contains("credit card", ignoreCase = true) ->
                "CREDIT_CARD"

            text.contains("debit card", ignoreCase = true) ->
                "DEBIT_CARD"

            text.contains("ATM", ignoreCase = true) ->
                "ATM"

            text.contains("NEFT", ignoreCase = true) ->
                "NEFT"

            text.contains("IMPS", ignoreCase = true) ->
                "IMPS"

            text.contains("RTGS", ignoreCase = true) ->
                "RTGS"

            text.contains("net banking", ignoreCase = true) ->
                "NET_BANKING"

            else ->
                "UNKNOWN"
        }
    }

    // ---------------- MERCHANT / PAYEE ----------------

    private fun extractMerchant(text: String): String? {

        val patterns = listOf(

            // "for UPI to aditya kumar a on 04-09-26"
            Regex(
                """for\s+UPI\s+to\s+(.+?)\s+on\s+\d{1,2}[-/]\d{1,2}[-/]\d{2,4}""",
                RegexOption.IGNORE_CASE
            ),

            // "paid to ABC Store"
            Regex(
                """paid\s+to\s+(.+?)(?:\s+on\s+|\s+via\s+|\s+Ref\b|$)""",
                RegexOption.IGNORE_CASE
            ),

            // "sent to name"
            Regex(
                """sent\s+to\s+(.+?)(?:\s+on\s+|\s+via\s+|\s+Ref\b|$)""",
                RegexOption.IGNORE_CASE
            ),

            // "payment to merchant"
            Regex(
                """payment\s+to\s+(.+?)(?:\s+on\s+|\s+via\s+|\s+Ref\b|$)""",
                RegexOption.IGNORE_CASE
            ),

            // "UPI to merchant"
            Regex(
                """UPI\s+to\s+(.+?)(?:\s+on\s+|\s+Ref\b|$)""",
                RegexOption.IGNORE_CASE
            )
        )

        for (pattern in patterns) {

            val match = pattern.find(text)

            if (match != null) {

                val merchant = match.groupValues[1]
                    .trim()
                    .trim('.', ',', '-', ':')

                if (merchant.isNotBlank()) {
                    return merchant
                }
            }
        }

        return null
    }

    // ---------------- BACKEND API ----------------

    private fun saveExpenseToBackend(
        amount: Double,
        description: String,
        transactionRef: String?,
        merchant: String?,
        paymentMode: String
    ) {

        val preferences = getSharedPreferences(
            "SpendIQPrefs",
            Context.MODE_PRIVATE
        )

        val userId = preferences.getLong("userId", -1L)

        if (userId == -1L) {
            Log.e("SpendIQ_API", "User ID not found. Expense not saved.")
            return
        }

        Log.d("SpendIQ_API", "Sending expense for userId=$userId")

        thread {

            var connection: HttpURLConnection? = null

            try {

                val url = URL(
                    "http://127.0.0.1:8080/api/expenses"
                )

                connection = url.openConnection() as HttpURLConnection

                connection.requestMethod = "POST"
                connection.connectTimeout = 10000
                connection.readTimeout = 10000
                connection.doOutput = true

                connection.setRequestProperty(
                    "Content-Type",
                    "application/json"
                )

                connection.setRequestProperty(
                    "Accept",
                    "application/json"
                )

                val json = JSONObject()

                json.put("amount", amount)
                json.put("description", description)
                json.put("userId", userId)
                json.put("source", "AUTO")
                json.put("paymentMode", paymentMode)

                if (!merchant.isNullOrBlank()) {
                    json.put("merchant", merchant)
                }

                if (!transactionRef.isNullOrBlank()) {
                    json.put("transactionRef", transactionRef)
                }

                val jsonData = json.toString()

                Log.d("SpendIQ_API", "REQUEST: $jsonData")

                connection.outputStream.use { outputStream ->

                    outputStream.write(
                        jsonData.toByteArray(Charsets.UTF_8)
                    )

                    outputStream.flush()
                }

                val responseCode = connection.responseCode

                Log.d(
                    "SpendIQ_API",
                    "RESPONSE CODE: $responseCode"
                )

                when {

                    responseCode in 200..299 -> {

                        val response =
                            connection.inputStream
                                .bufferedReader()
                                .use { it.readText() }

                        Log.d(
                            "SpendIQ_API",
                            "EXPENSE SAVED SUCCESSFULLY"
                        )

                        Log.d(
                            "SpendIQ_API",
                            "RESPONSE: $response"
                        )
                    }

                    responseCode == 409 -> {

                        Log.d(
                            "SpendIQ_API",
                            "DUPLICATE TRANSACTION - NOT SAVED"
                        )
                    }

                    else -> {

                        val error =
                            connection.errorStream
                                ?.bufferedReader()
                                ?.use { it.readText() }
                                ?: "No error response"

                        Log.e(
                            "SpendIQ_API",
                            "FAILED TO SAVE EXPENSE: $error"
                        )
                    }
                }

            } catch (e: Exception) {

                Log.e(
                    "SpendIQ_API",
                    "API ERROR: ${e.message}",
                    e
                )

            } finally {

                connection?.disconnect()
            }
        }
    }
}