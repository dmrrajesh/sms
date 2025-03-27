package com.inbox.sms

import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val smsChannel = "com.inbox.sms"
    private var smsReceiver: SmsReceiver? = null

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, smsChannel)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    smsReceiver = SmsReceiver(events)
                    val filter = IntentFilter("android.provider.Telephony.SMS_RECEIVED")
                    registerReceiver(smsReceiver, filter)
                }

                override fun onCancel(arguments: Any?) {
                    smsReceiver?.let { unregisterReceiver(it) }
                    smsReceiver = null
                }
            })
    }
}
