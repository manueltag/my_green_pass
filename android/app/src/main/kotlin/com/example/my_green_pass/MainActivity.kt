package com.example.my_green_pass

import androidx.annotation.NonNull
import dgca.verifier.app.decoder.base45.Base45Service
import dgca.verifier.app.decoder.base45.DefaultBase45Service
import dgca.verifier.app.decoder.cbor.CborService
import dgca.verifier.app.decoder.cbor.DefaultCborService
import dgca.verifier.app.decoder.compression.CompressorService
import dgca.verifier.app.decoder.compression.DefaultCompressorService
import dgca.verifier.app.decoder.cose.CoseService
import dgca.verifier.app.decoder.cose.CryptoService
import dgca.verifier.app.decoder.cose.DefaultCoseService
import dgca.verifier.app.decoder.cose.VerificationCryptoService
import dgca.verifier.app.decoder.prefixvalidation.DefaultPrefixValidationService
import dgca.verifier.app.decoder.prefixvalidation.PrefixValidationService
import dgca.verifier.app.decoder.schema.DefaultSchemaValidator
import dgca.verifier.app.decoder.schema.SchemaValidator
import dgca.verifier.app.decoder.services.X509
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import it.ministerodellasalute.verificaC19sdk.data.VerifierRepository
import it.ministerodellasalute.verificaC19sdk.data.VerifierRepositoryImpl
import it.ministerodellasalute.verificaC19sdk.data.local.AppDatabase
import it.ministerodellasalute.verificaC19sdk.data.local.AppDatabase_Impl
import it.ministerodellasalute.verificaC19sdk.data.local.Preferences
import it.ministerodellasalute.verificaC19sdk.data.local.PreferencesImpl
import it.ministerodellasalute.verificaC19sdk.data.remote.ApiService
import it.ministerodellasalute.verificaC19sdk.di.DispatcherProvider
import it.ministerodellasalute.verificaC19sdk.di.NetworkModule
import it.ministerodellasalute.verificaC19sdk.model.VerificationViewModel
import it.ministerodellasalute.verificaC19sdk.security.DefaultKeyStoreCryptor
import it.ministerodellasalute.verificaC19sdk.security.KeyStoreCryptor

class MainActivity : FlutterActivity() {
    private val CHANNEL = "manueltag.dev/decodeqrcode"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "decodeQrCode") {
                val qrCodeData = decodeQrCode("AAA")

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

    private fun decodeQrCode(qrcode: String): String {
        val qrCodeData: String = "Test 123";

        val prefixValidationService: PrefixValidationService = DefaultPrefixValidationService()
        val base45Service: Base45Service = DefaultBase45Service();
        val compressorService: CompressorService = DefaultCompressorService();

        val x509: X509 = X509();
        val cryptoService: CryptoService = VerificationCryptoService(x509);

        val coseService: CoseService = DefaultCoseService();
        val schemaValidator: SchemaValidator = DefaultSchemaValidator();
        val cborService: CborService = DefaultCborService();

        val preferences: Preferences = PreferencesImpl(this);

        var module: NetworkModule = NetworkModule // TODO
        val apiService: ApiService = ???? // TODO
        val db: AppDatabase = AppDatabase_Impl();
        val keyStoreCryptor: KeyStoreCryptor = DefaultKeyStoreCryptor();
        val dispatcherProvider: DispatcherProvider = DispatcherProvider();

        val verifierRepository: VerifierRepository = VerifierRepositoryImpl(
            apiService,
            preferences,
            db,
            keyStoreCryptor,
            dispatcherProvider
        ); // TODO

        val viewModel = VerificationViewModel(
            prefixValidationService,
            base45Service,
            compressorService,
            cryptoService,
            coseService,
            schemaValidator,
            cborService,
            verifierRepository,
            preferences,
            dispatcherProvider
        );

        viewModel.decode(qrcode, true)

        return qrCodeData
    }
}
