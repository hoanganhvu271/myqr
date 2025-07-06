import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myqr/core/vietqr/vietqr_generator.dart';

final generateRepository = Provider<GenerateRepository>(
  (ref) => GenerateRepositoryImpl(),
);

abstract class GenerateRepository {
  String generateQRString({
    required String bankBIN,
    required String accountNumber,
    required double amount,
    String note = "",
    bool isOneTime = false,
  });
}

class GenerateRepositoryImpl implements GenerateRepository {
  @override
  String generateQRString({
    required String bankBIN,
    required String accountNumber,
    required double amount,
    String note = "",
    bool isOneTime = false,
  }) {
    String qr = VietQRGenerator.generateWithParams(
      amount: amount,
      bankBIN: bankBIN,
      accountNumber: accountNumber,
      note: note,
      isOneTime: isOneTime,
    );
    return qr;
  }
}