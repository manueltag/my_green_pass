import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;

  static const MethodChannel _verificationViewModelMethodChannel =
      MethodChannel('manueltag.dev/verifyqrcode');

  String? _verificationViewModel;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.format == BarcodeFormat.qrcode) {
        if (result != null && result!.code == scanData.code) {
          return;
        }
        _verifyQrCode(scanData);
        setState(() {
          result = scanData;
        });
      }
    });
  }

  Future<void> _verifyQrCode(Barcode result) async {
    String verificationViewModel;
    try {
      var params = <String, dynamic>{
        'qrcode': result.code,
      };

      verificationViewModel = await _verificationViewModelMethodChannel
          .invokeMethod('verifyQrCode', params);

      setState(() {
        _verificationViewModel = verificationViewModel;
      });
    } on PlatformException catch (e) {
      print("Failed to get data: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: (result != null)
                    ? Text('Data: ${result!.code}')
                    : const Text('Scan a code'),
              ),
            ),
            Expanded(
              flex: 3,
              child: (_verificationViewModel != null)
                  ? Text('Data: ${_verificationViewModel!}')
                  : const Text('Waiting...'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

/*
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
*/