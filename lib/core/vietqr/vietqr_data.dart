class VietQRData {
  final String id;
  final String bankBIN;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String amount;
  final String note;
  final String serviceType;
  final String currency;
  final String countryCode;
  final String qrString;
  final DateTime createdAt;

  const VietQRData({
    required this.id,
    required this.bankBIN,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.amount,
    required this.note,
    required this.serviceType,
    required this.currency,
    required this.countryCode,
    required this.qrString,
    required this.createdAt,
  });

  factory VietQRData.fromJson(Map<String, dynamic> json) {
    return VietQRData(
      id: json['id'] ?? '',
      bankBIN: json['bankBIN'] ?? '',
      bankName: json['bankName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      accountName: json['accountName'] ?? '',
      amount: json['amount'] ?? '',
      note: json['note'] ?? '',
      serviceType: json['serviceType'] ?? '',
      currency: json['currency'] ?? 'VND',
      countryCode: json['countryCode'] ?? 'VN',
      qrString: json['qrString'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankBIN': bankBIN,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'amount': amount,
      'note': note,
      'serviceType': serviceType,
      'currency': currency,
      'countryCode': countryCode,
      'qrString': qrString,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  VietQRData copyWith({
    String? id,
    String? bankBIN,
    String? bankName,
    String? accountNumber,
    String? accountName,
    String? amount,
    String? note,
    String? serviceType,
    String? currency,
    String? countryCode,
    String? qrString,
    DateTime? createdAt,
  }) {
    return VietQRData(
      id: id ?? this.id,
      bankBIN: bankBIN ?? this.bankBIN,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      serviceType: serviceType ?? this.serviceType,
      currency: currency ?? this.currency,
      countryCode: countryCode ?? this.countryCode,
      qrString: qrString ?? this.qrString,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'VietQRData(bankName: $bankName, accountNumber: $accountNumber, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VietQRData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}