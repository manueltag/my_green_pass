package com.example.my_green_pass

import androidx.annotation.NonNull
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import dagger.hilt.android.AndroidEntryPoint
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import it.ministerodellasalute.verificaC19sdk.model.CertificateSimple
import it.ministerodellasalute.verificaC19sdk.model.CertificateStatus
import it.ministerodellasalute.verificaC19sdk.model.SimplePersonModel
import it.ministerodellasalute.verificaC19sdk.model.VerificationViewModel
import java.util.*

@AndroidEntryPoint
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "manueltag.dev/verifyqrcode"
        ).setMethodCallHandler { call, result ->
            if (call.method == "verifyQrCode") {
                try {
                    var qrCode: String? = call.argument("qrcode");

                    var verificationViewModel =
                        ViewModelProvider(this).get(VerificationViewModel::class.java)

                    verificationViewModel.decode(qrCode.toString(), true);

                    verificationViewModel.certificate.observe(this, Observer {
                        if (verificationViewModel.inProgress.value === false && verificationViewModel.certificate.value != null) {
                            verificationViewModel.certificate.removeObservers(this)

                            var mySimplePersonModel: MySimplePersonModel = MySimplePersonModel(
                                verificationViewModel.certificate.value!!.person.standardisedFamilyName,
                                verificationViewModel.certificate.value!!.person.familyName,
                                verificationViewModel.certificate.value!!.person.standardisedGivenName,
                                verificationViewModel.certificate.value!!.person.givenName
                            )

                            var myCertificateModel: MyCertificateModel = MyCertificateModel(
                                mySimplePersonModel,
                                verificationViewModel.certificate.value!!.dateOfBirth,
                                verificationViewModel.certificate.value!!.certificateStatus,
                                verificationViewModel.certificate.value!!.timeStamp
                            );

                            val verificationViewModelJson: String =
                                Gson().toJson(myCertificateModel)

                            println("MODEL JSON: " + verificationViewModelJson);

                            result.success(verificationViewModelJson)
                        }
                    })
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Data not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}

data class MyCertificateModel(
    @SerializedName("person")
    var person: MySimplePersonModel = MySimplePersonModel(),
    @SerializedName("dateOfBirth")
    var dateOfBirth: String? = null,
    @SerializedName("certificateStatus")
    var certificateStatus: CertificateStatus? = null,
    @SerializedName("timeStamp")
    var timeStamp: Date? = null
)

data class MySimplePersonModel(
    @SerializedName("standardisedFamilyName")
    var standardisedFamilyName: String? = null,
    @SerializedName("familyName")
    var familyName: String? = null,
    @SerializedName("standardisedGivenName")
    var standardisedGivenName: String? = null,
    @SerializedName("givenName")
    var givenName: String? = null
)