import 'dart:convert';

import 'package:flutter/cupertino.dart';
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
      theme: ThemeData.light(),
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
  MyCertificateModel? _certificateModel;
  bool _debug = false;

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
        if (_verificationViewModel != null) {
          _certificateModel =
              MyCertificateModel.fromJson(json.decode(_verificationViewModel!));
        }
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
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Expanded(
              child: _debug
                  ? _buildDebugInfo()
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _certificateModel != null
                          ? _buildCard()
                          : const Center(child: Text('Inquadra il qrcode')),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() => Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16.0),
          ),
        ),
        elevation: 8.0,
        color: _certificateModel != null
            ? _certificateModel!.certificateStatus == 'VALID'
                ? Colors.green
                : Colors.red
            : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _certificateModel!.certificateStatus == 'VALID'
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  size: 96,
                  color: Colors.white,
                ),
                const SizedBox(height: 24.0),
                Text(
                  _certificateModel!.formattedName,
                  style: Theme.of(context).textTheme.headline1!.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  _certificateModel!.dateOfBirth,
                  style: Theme.of(context).textTheme.headline1!.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w200,
                      ),
                )
              ],
            ),
          ),
        ),
      );

  Widget _buildDebugInfo() => Column(
        children: [
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
      );

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class MyCertificateModel {
  final MySimplePersonModel person;
  final String dateOfBirth;
  final String certificateStatus;
  final String timeStamp;

  MyCertificateModel({
    required this.person,
    required this.dateOfBirth,
    required this.certificateStatus,
    required this.timeStamp,
  });

  factory MyCertificateModel.fromJson(Map<String, dynamic> json) {
    return MyCertificateModel(
      person: MySimplePersonModel.fromJson(json["person"]),
      dateOfBirth: json["dateOfBirth"],
      certificateStatus: json["certificateStatus"],
      timeStamp: json["timeStamp"],
    );
  }

  String get formattedName =>
      person.standardisedFamilyName + ' ' + person.standardisedGivenName;
}

class MySimplePersonModel {
  final String standardisedFamilyName;
  final String familyName;
  final String standardisedGivenName;
  final String givenName;

  MySimplePersonModel({
    required this.standardisedFamilyName,
    required this.familyName,
    required this.standardisedGivenName,
    required this.givenName,
  });

  factory MySimplePersonModel.fromJson(Map<String, dynamic> json) {
    return MySimplePersonModel(
      standardisedFamilyName: json["standardisedFamilyName"],
      familyName: json["familyName"],
      standardisedGivenName: json["standardisedGivenName"],
      givenName: json["givenName"],
    );
  }
}
