package com.example.my_green_pass

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import it.ministerodellasalute.verificaC19sdk.model.VerificationViewModel;

class MainActivity : FlutterActivity() {
    private val CHANNEL = "manueltag.dev/decodeqrcode"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "decodeQrCode") {
                val qrCodeData = decodeQrCode()

                if (qrCodeData != null) {
                    result.success(qrCodeData)
                } else {
                    result.error("UNAVAILABLE", "Data not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun decodeQrCode(): String {
        val qrCodeData: String = "Test 123";

        //val viewModel = VerificationViewModel();
        //viewModel.init

        return qrCodeData
    }
}
