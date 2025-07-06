class QrData {
  final String bankBin;
  final String accountNumber;
  final double amount;
  final String note;
  final bool isOneTime;
  final String qrString;
  final DateTime createdAt;

  QrData({
    required this.bankBin,
    required this.accountNumber,
    required this.amount,
    required this.note,
    this.isOneTime = false,
    required this.qrString,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
