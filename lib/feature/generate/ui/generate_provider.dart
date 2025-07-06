import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myqr/feature/generate/data/generate_repository.dart';

final generateViewModel = AutoDisposeNotifierProvider<GenerateProvider, String>(
  () => GenerateProvider()
);

class GenerateProvider extends AutoDisposeNotifier<String> {
  @override
  String build() {
    return '';
  }

  void generateNewQrString({
    required String bankBIN,
    required String accountNumber,
    required double amount,
    required String note,
    bool isOneTime = false,
  }) {
    String qr = ref.read(generateRepository).generateQRString(
      bankBIN: bankBIN,
      accountNumber: accountNumber,
      amount: amount,
      note: note,
    );
    print(qr);
    state = qr;
  }

  void updateQRString(String newQRString) {
    state = newQRString;
  }
}