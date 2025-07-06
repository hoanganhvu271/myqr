class VietQRGenerator {
  static const Map<String, String> _vnMap = {
    'ạ': 'a', 'ả': 'a', 'ã': 'a', 'à': 'a', 'á': 'a', 'â': 'a', 'ậ': 'a',
    'ầ': 'a', 'ấ': 'a', 'ẩ': 'a', 'ẫ': 'a', 'ă': 'a', 'ắ': 'a', 'ằ': 'a',
    'ặ': 'a', 'ẳ': 'a', 'ẵ': 'a',
    'ó': 'o', 'ò': 'o', 'ọ': 'o', 'õ': 'o', 'ỏ': 'o', 'ô': 'o', 'ộ': 'o',
    'ổ': 'o', 'ỗ': 'o', 'ồ': 'o', 'ố': 'o', 'ơ': 'o', 'ờ': 'o', 'ớ': 'o',
    'ợ': 'o', 'ở': 'o', 'ỡ': 'o',
    'é': 'e', 'è': 'e', 'ẻ': 'e', 'ẹ': 'e', 'ẽ': 'e', 'ê': 'e', 'ế': 'e',
    'ề': 'e', 'ệ': 'e', 'ể': 'e', 'ễ': 'e',
    'ú': 'u', 'ù': 'u', 'ụ': 'u', 'ủ': 'u', 'ũ': 'u', 'ư': 'u', 'ự': 'u',
    'ữ': 'u', 'ử': 'u', 'ừ': 'u', 'ứ': 'u',
    'í': 'i', 'ì': 'i', 'ị': 'i', 'ỉ': 'i', 'ĩ': 'i',
    'ý': 'y', 'ỳ': 'y', 'ỷ': 'y', 'ỵ': 'y', 'ỹ': 'y',
    'đ': 'd',
    'Ạ': 'A', 'Ả': 'A', 'Ã': 'A', 'À': 'A', 'Á': 'A', 'Â': 'A', 'Ậ': 'A',
    'Ầ': 'A', 'Ấ': 'A', 'Ẩ': 'A', 'Ẫ': 'A', 'Ă': 'A', 'Ắ': 'A', 'Ằ': 'A',
    'Ặ': 'A', 'Ẳ': 'A', 'Ẵ': 'A',
    'Ó': 'O', 'Ò': 'O', 'Ọ': 'O', 'Õ': 'O', 'Ỏ': 'O', 'Ô': 'O', 'Ộ': 'O',
    'Ổ': 'O', 'Ỗ': 'O', 'Ồ': 'O', 'Ố': 'O', 'Ơ': 'O', 'Ờ': 'O', 'Ớ': 'O',
    'Ợ': 'O', 'Ở': 'O', 'Ỡ': 'O',
    'É': 'E', 'È': 'E', 'Ẻ': 'E', 'Ẹ': 'E', 'Ẽ': 'E', 'Ê': 'E', 'Ế': 'E',
    'Ề': 'E', 'Ệ': 'E', 'Ể': 'E', 'Ễ': 'E',
    'Ú': 'U', 'Ù': 'U', 'Ụ': 'U', 'Ủ': 'U', 'Ũ': 'U', 'Ư': 'U', 'Ự': 'U',
    'Ữ': 'U', 'Ử': 'U', 'Ừ': 'U', 'Ứ': 'U',
    'Í': 'I', 'Ì': 'I', 'Ị': 'I', 'Ỉ': 'I', 'Ĩ': 'I',
    'Ý': 'Y', 'Ỳ': 'Y', 'Ỷ': 'Y', 'Ỵ': 'Y', 'Ỹ': 'Y',
    'Đ': 'D',
  };

  // Mã tiền tệ
  static const Map<String, String> _currencyMap = {
    'VND': '704',
    'USD': '840',
    'EUR': '978',
    'JPY': '392',
  };

  // Mã quốc gia
  static const Map<String, String> _countryMap = {
    'VN': 'Viet Nam',
    'US': 'United States',
    'JP': 'Japan',
  };

  static const String _guidVietQR = 'A000000727';
  static const String _serviceTypeAccount = 'QRIBFTTA';
  static const String _serviceTypeCard = 'QRIBFTTC';

  /// Tạo mã VietQR với các tham số đầy đủ
  static String generateWithParams({
    required String bankBIN,
    required String accountNumber,
    bool isOneTime = true,
    String serviceType = _serviceTypeAccount,
    double amount = 0,
    String note = '',
    String currency = 'VND',
    String countryCode = 'VN',
  }) {
    final contents = <String, String>{};

    // Payload Format Indicator
    contents['00'] = '01';

    // Point of Initiation Method
    contents['01'] = isOneTime ? '12' : '11';

    // Merchant Account Information
    contents['3800'] = _guidVietQR;
    contents['380100'] = bankBIN;
    contents['380101'] = accountNumber;
    contents['3802'] = serviceType;

    // Transaction Currency
    final currencyCode = _currencyMap[currency] ?? '704';
    contents['53'] = currencyCode;

    // Country Code
    contents['58'] = countryCode;

    // Transaction Amount
    if (amount > 0) {
      if (currencyCode == '704') {
        // VND không có phần thập phân
        contents['54'] = amount.toInt().toString();
      } else {
        contents['54'] = amount.toStringAsFixed(2);
      }
    }

    // Additional Data Field (note)
    note = note.trim();
    if (note.isNotEmpty) {
      contents['6208'] = _toAscii(note);
    }

    // Tạo QR string
    final qrString = _generateObject(contents);
    final withCrcPrefix = qrString + '6304';

    return withCrcPrefix + _calculateCRC(withCrcPrefix);
  }

  /// Tạo mã VietQR đơn giản
  static String generate({
    required double amount,
    required String bankBIN,
    required String accountNumber,
    String note = '',
  }) {
    return generateWithParams(
      bankBIN: bankBIN,
      accountNumber: accountNumber,
      amount: amount,
      note: note,
      isOneTime: true,
      serviceType: _serviceTypeAccount,
      currency: 'VND',
      countryCode: 'VN',
    );
  }

  /// Tạo chuỗi QR từ contents
  static String _generateObject(Map<String, String> contents) {
    final buffer = StringBuffer();

    // Xử lý các trường cơ bản
    _addField(buffer, '00', contents['00'] ?? '');
    _addField(buffer, '01', contents['01'] ?? '');

    // Xử lý Merchant Account Information (38)
    final merchantAccount = _buildMerchantAccount(contents);
    if (merchantAccount.isNotEmpty) {
      _addField(buffer, '38', merchantAccount);
    }

    // Transaction Currency
    _addField(buffer, '53', contents['53'] ?? '');

    // Transaction Amount
    if (contents.containsKey('54')) {
      _addField(buffer, '54', contents['54']!);
    }

    // Country Code
    _addField(buffer, '58', contents['58'] ?? '');

    // Additional Data Field
    if (contents.containsKey('6208')) {
      final additionalData = _buildAdditionalData(contents);
      if (additionalData.isNotEmpty) {
        _addField(buffer, '62', additionalData);
      }
    }

    return buffer.toString();
  }

  /// Xây dựng Merchant Account Information
  static String _buildMerchantAccount(Map<String, String> contents) {
    final buffer = StringBuffer();

    _addField(buffer, '00', contents['3800'] ?? '');

    // Beneficiary Organization
    final beneficiary = _buildBeneficiaryOrganization(contents);
    if (beneficiary.isNotEmpty) {
      _addField(buffer, '01', beneficiary);
    }

    _addField(buffer, '02', contents['3802'] ?? '');

    return buffer.toString();
  }

  /// Xây dựng Beneficiary Organization
  static String _buildBeneficiaryOrganization(Map<String, String> contents) {
    final buffer = StringBuffer();

    _addField(buffer, '00', contents['380100'] ?? '');
    _addField(buffer, '01', contents['380101'] ?? '');

    return buffer.toString();
  }

  /// Xây dựng Additional Data Field
  static String _buildAdditionalData(Map<String, String> contents) {
    final buffer = StringBuffer();

    _addField(buffer, '08', contents['6208'] ?? '');

    return buffer.toString();
  }

  /// Thêm field vào buffer với format: ID + Length + Content
  static void _addField(StringBuffer buffer, String id, String content) {
    if (content.isEmpty) return;

    final length = content.length;
    if (length > 99) {
      content = content.substring(0, 99);
    }

    buffer.write(id);
    buffer.write(length.toString().padLeft(2, '0'));
    buffer.write(content);
  }

  /// Tính toán CRC-16 checksum
  static String _calculateCRC(String data) {
    const int crcInit = 0xFFFF;
    const int crcPoly = 0x1021;

    int crc = crcInit;
    final bytes = data.codeUnits;

    for (final byte in bytes) {
      crc ^= (byte << 8);
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ crcPoly) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }

    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  /// Chuyển đổi text tiếng Việt sang ASCII
  static String _toAscii(String text) {
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      // Kiểm tra ký tự ASCII
      if (char.codeUnitAt(0) <= 127) {
        buffer.write(char);
        continue;
      }

      // Chuyển đổi ký tự Việt Nam
      if (_vnMap.containsKey(char)) {
        buffer.write(_vnMap[char]);
      }
      // Bỏ qua các ký tự không hỗ trợ
    }

    return buffer.toString();
  }

  /// Cắt chuỗi theo số ký tự
  static String substring(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength);
  }
}
