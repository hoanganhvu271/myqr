import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myqr/feature/custom/ui/custom_screen.dart';
import 'package:myqr/feature/generate/ui/generate_screen.dart';

import 'model/qr_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScreen(
        qrData: QrData(
          bankBin: '970422',
          accountNumber: '0382519718',
          amount: 100000,
          note: 'Payment for services',
          qrString: '00020101021138540010A00000072701240006970422011003825197180208QRIBFTTA530370454061000005802VN62160812Test payment63042F1B',
        )
      ),
    );
  }
}
