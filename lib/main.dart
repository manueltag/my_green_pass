import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static const platform = MethodChannel('manueltag.dev/decodeqrcode');

  String _qrCodeData = 'Data:';

  Future<void> _getDecodedQrCode() async {
    String qrCodeData;
    try {
      final String result = await platform.invokeMethod('decodeQrCode');
      qrCodeData = 'Data: $result';
    } on PlatformException catch (e) {
      qrCodeData = "Failed to get data: '${e.message}'.";
    }

    setState(() {
      _qrCodeData = qrCodeData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              child: const Text('Decode qrcode'),
              onPressed: _getDecodedQrCode,
            ),
            Text(_qrCodeData),
          ],
        ),
      ),
    );
  }
}
