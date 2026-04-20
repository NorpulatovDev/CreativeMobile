package com.example.creative

import android.Manifest
import android.content.pm.PackageManager
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "com.example.creative/sms"
    private val smsPermissionCode = 101

    private var pendingPhone: String? = null
    private var pendingMessage: String? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                if (call.method == "sendSms") {
                    val phone = call.argument<String>("phone")
                        ?: return@setMethodCallHandler result.error("INVALID", "phone is required", null)
                    val message = call.argument<String>("message")
                        ?: return@setMethodCallHandler result.error("INVALID", "message is required", null)
                    sendSms(phone, message, result)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun sendSms(phone: String, message: String, result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            pendingPhone = phone
            pendingMessage = message
            pendingResult = result
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.SEND_SMS),
                smsPermissionCode
            )
            return
        }
        doSendSms(phone, message, result)
    }

    private fun doSendSms(phone: String, message: String, result: MethodChannel.Result) {
        try {
            @Suppress("DEPRECATION")
            val smsManager = SmsManager.getDefault()
            val parts = smsManager.divideMessage(message)
            if (parts.size == 1) {
                smsManager.sendTextMessage(phone, null, message, null, null)
            } else {
                smsManager.sendMultipartTextMessage(phone, null, parts, null, null)
            }
            result.success("sent")
        } catch (e: Exception) {
            result.error("SMS_ERROR", e.message, null)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == smsPermissionCode) {
            val pr = pendingResult ?: return
            val phone = pendingPhone ?: return
            val message = pendingMessage ?: return
            pendingPhone = null
            pendingMessage = null
            pendingResult = null
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                doSendSms(phone, message, pr)
            } else {
                pr.error("PERMISSION_DENIED", "SMS permission denied", null)
            }
        }
    }
}
