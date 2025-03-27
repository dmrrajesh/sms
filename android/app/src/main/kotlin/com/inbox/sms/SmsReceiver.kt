package com.inbox.sms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import io.flutter.plugin.common.EventChannel

class SmsReceiver(private val eventSink: EventChannel.EventSink?) : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            messages.forEach { msg ->
                val smsData = mapOf(
                    "_id" to System.currentTimeMillis(), // Dummy ID since we don't get actual _id from SMS
                    "thread_id" to msg.originatingAddress.hashCode(), // Simulating thread_id
                    "address" to (msg.originatingAddress ?: "Unknown"),
                    "body" to msg.displayMessageBody,
                    "read" to 0, // Received SMS are usually unread
                    "kind" to "received", // Assuming incoming messages
                    "date" to msg.timestampMillis,
                    "date_sent" to msg.timestampMillis // Assuming same as received time
                )
                eventSink?.success(smsData)
            }
        }
    }
}
