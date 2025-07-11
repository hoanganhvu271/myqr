class BankData {
  final String bin;
  final String name;
  final String shortName;
  final String code;
  final String? swiftCode;
  final String? logoPath;

  const BankData({
    required this.bin,
    required this.name,
    required this.shortName,
    required this.code,
    this.swiftCode,
    this.logoPath,
  });

  factory BankData.fromJson(Map<String, dynamic> json) {
    return BankData(
      bin: json['bin'] ?? '',
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? '',
      code: json['code'] ?? '',
      swiftCode: json['swiftCode'],
      logoPath: json['logoPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bin': bin,
      'name': name,
      'shortName': shortName,
      'code': code,
      'swiftCode': swiftCode,
      'logoPath': logoPath,
    };
  }

  @override
  String toString() => '$shortName ($bin)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BankData && other.bin == bin;
  }

  @override
  int get hashCode => bin.hashCode;
}