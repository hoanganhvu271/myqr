import 'package:myqr/constant/bank_constant.dart';
import 'package:myqr/core/vietqr/vietqr_data.dart';

class VietQRParser {
  static VietQRData? parse(String qrString) {
    try {
      final data = <String, String>{};
      int index = 0;

      while (index < qrString.length - 4) { // -4 for CRC
        if (index + 4 > qrString.length) break;

        final id = qrString.substring(index, index + 2);
        final lengthStr = qrString.substring(index + 2, index + 4);
        final length = int.tryParse(lengthStr);

        if (length == null) break;

        if (index + 4 + length > qrString.length) break;

        final content = qrString.substring(index + 4, index + 4 + length);
        data[id] = content;

        index += 4 + length;
      }

      return _extractVietQRData(data, qrString);
    } catch (e) {
      return null;
    }
  }

  static VietQRData _extractVietQRData(Map<String, String> data, String originalQR) {
    // Parse merchant account information
    String bankBIN = '';
    String accountNumber = '';
    String serviceType = '';

    if (data.containsKey('38')) {
      final merchantInfo = data['38']!;
      final merchantData = _parseMerchantAccount(merchantInfo);
      bankBIN = merchantData['bankBIN'] ?? '';
      accountNumber = merchantData['accountNumber'] ?? '';
      serviceType = merchantData['serviceType'] ?? '';
    }

    // Parse additional data
    String note = '';
    if (data.containsKey('62')) {
      final additionalInfo = data['62']!;
      final additionalData = _parseAdditionalData(additionalInfo);
      note = additionalData['note'] ?? '';
    }

    return VietQRData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bankBIN: bankBIN,
      bankName: _getBankName(bankBIN),
      accountNumber: accountNumber,
      accountName: 'Unknown', // Cần lookup từ API
      amount: data['54'] ?? '',
      note: note,
      serviceType: serviceType,
      currency: _getCurrencyFromCode(data['53'] ?? '704'),
      countryCode: data['58'] ?? 'VN',
      qrString: originalQR,
      createdAt: DateTime.now(),
    );
  }

  static Map<String, String> _parseMerchantAccount(String merchantAccount) {
    final data = <String, String>{};
    int index = 0;

    while (index < merchantAccount.length) {
      if (index + 4 > merchantAccount.length) break;

      final id = merchantAccount.substring(index, index + 2);
      final lengthStr = merchantAccount.substring(index + 2, index + 4);
      final length = int.tryParse(lengthStr);

      if (length == null) break;
      if (index + 4 + length > merchantAccount.length) break;

      final content = merchantAccount.substring(index + 4, index + 4 + length);

      switch (id) {
        case '00':
        // GUID
          break;
        case '01':
        // Parse beneficiary organization
          final beneficiaryData = _parseBeneficiaryOrganization(content);
          data.addAll(beneficiaryData);
          break;
        case '02':
          data['serviceType'] = content;
          break;
      }

      index += 4 + length;
    }

    return data;
  }

  static Map<String, String> _parseBeneficiaryOrganization(String beneficiary) {
    final data = <String, String>{};
    int index = 0;

    while (index < beneficiary.length) {
      if (index + 4 > beneficiary.length) break;

      final id = beneficiary.substring(index, index + 2);
      final lengthStr = beneficiary.substring(index + 2, index + 4);
      final length = int.tryParse(lengthStr);

      if (length == null) break;
      if (index + 4 + length > beneficiary.length) break;

      final content = beneficiary.substring(index + 4, index + 4 + length);

      switch (id) {
        case '00':
          data['bankBIN'] = content;
          break;
        case '01':
          data['accountNumber'] = content;
          break;
      }

      index += 4 + length;
    }

    return data;
  }

  static Map<String, String> _parseAdditionalData(String additionalData) {
    final data = <String, String>{};
    int index = 0;

    while (index < additionalData.length) {
      if (index + 4 > additionalData.length) break;

      final id = additionalData.substring(index, index + 2);
      final lengthStr = additionalData.substring(index + 2, index + 4);
      final length = int.tryParse(lengthStr);

      if (length == null) break;
      if (index + 4 + length > additionalData.length) break;

      final content = additionalData.substring(index + 4, index + 4 + length);

      switch (id) {
        case '08':
          data['note'] = content;
          break;
      }

      index += 4 + length;
    }

    return data;
  }

  static String _getBankName(String bankBIN) {
    return BanksConstant.getBankByBIN(bankBIN)?.name ?? 'Unknown Bank';
  }

  static String _getCurrencyFromCode(String code) {
    const currencyMap = {
      '704': 'VND',
      '840': 'USD',
      '978': 'EUR',
      '392': 'JPY',
    };

    return currencyMap[code] ?? 'VND';
  }
}