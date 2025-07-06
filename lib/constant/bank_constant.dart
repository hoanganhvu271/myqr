import '../core/vietqr/bank_data.dart';

class BanksConstant {
  static const List<BankData> vietnameseBanks = [
    BankData(bin: '970415', name: 'Ngân hàng TMCP Công Thương Việt Nam', shortName: 'Vietinbank', code: 'VTB'),
    BankData(bin: '970436', name: 'Ngân hàng TMCP Ngoại Thương Việt Nam', shortName: 'Vietcombank', code: 'VCB'),
    BankData(bin: '970418', name: 'Ngân hàng TMCP Đầu tư và Phát triển Việt Nam', shortName: 'BIDV', code: 'BIDV'),
    BankData(bin: '970405', name: 'Ngân hàng Nông nghiệp và Phát triển Nông thôn', shortName: 'Agribank', code: 'AGB'),
    BankData(bin: '970422', name: 'Ngân hàng TMCP Quân Đội', shortName: 'MB Bank', code: 'MBB'),
    BankData(bin: '970407', name: 'Ngân hàng TMCP Kỹ Thương Việt Nam', shortName: 'Techcombank', code: 'TCB'),
    BankData(bin: '970443', name: 'Ngân hàng TMCP Sài Gòn - Hà Nội', shortName: 'SHB', code: 'SHB'),
    BankData(bin: '970431', name: 'Ngân hàng TMCP Xuất Nhập Khẩu Việt Nam', shortName: 'Eximbank', code: 'EXB'),
    BankData(bin: '970441', name: 'Ngân hàng TMCP Quốc Tế Việt Nam', shortName: 'VIB', code: 'VIB'),
    BankData(bin: '970448', name: 'Ngân hàng TMCP Phương Đông', shortName: 'OCB', code: 'OCB'),
    BankData(bin: '970429', name: 'Ngân hàng TMCP Sài Gòn Thương Tín', shortName: 'SCB', code: 'SCB'),
    BankData(bin: '970454', name: 'Ngân hàng TMCP Bản Việt', shortName: 'VietCapital Bank', code: 'VCCB'),
    BankData(bin: '970410', name: 'Ngân hàng TMCP Sài Gòn Thương Tín', shortName: 'SacomBank', code: 'STB'),
    BankData(bin: '970439', name: 'Ngân hàng TNHH MTV Public Việt Nam', shortName: 'Public Bank', code: 'PUB'),
    BankData(bin: '970434', name: 'Ngân hàng TMCP Việt Nam Thịnh Vượng', shortName: 'VPBank', code: 'VPB'),
    BankData(bin: '970423', name: 'Ngân hàng TMCP Tiên Phong', shortName: 'TPBank', code: 'TPB'),
    BankData(bin: '970426', name: 'Ngân hàng TMCP Hàng Hải', shortName: 'MSB', code: 'MSB'),
    BankData(bin: '970416', name: 'Ngân hàng TMCP Á Châu', shortName: 'ACB', code: 'ACB'),
    BankData(bin: '970440', name: 'Ngân hảng TMCP Đông Nam Á', shortName: 'SeABank', code: 'SSB'),
    BankData(bin: '970449', name: 'Ngân hàng TMCP Bưu Điện Liên Việt', shortName: 'LienVietPostBank', code: 'LPB'),
  ];

  static BankData? getBankByBIN(String bin) {
    try {
      return vietnameseBanks.firstWhere((bank) => bank.bin == bin);
    } catch (e) {
      return null;
    }
  }

  static BankData? getBankByCode(String code) {
    try {
      return vietnameseBanks.firstWhere((bank) => bank.code == code);
    } catch (e) {
      return null;
    }
  }
}