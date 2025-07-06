class BankData {
  final String bin;
  final String name;
  final String shortName;
  final String code;
  final String? swiftCode;

  const BankData({
    required this.bin,
    required this.name,
    required this.shortName,
    required this.code,
    this.swiftCode,
  });

  factory BankData.fromJson(Map<String, dynamic> json) {
    return BankData(
      bin: json['bin'] ?? '',
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? '',
      code: json['code'] ?? '',
      swiftCode: json['swiftCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bin': bin,
      'name': name,
      'shortName': shortName,
      'code': code,
      'swiftCode': swiftCode,
    };
  }
}