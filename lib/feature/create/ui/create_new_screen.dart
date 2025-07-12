import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:myqr/core/vietqr/vietqr_parser.dart';
import 'package:myqr/core/vietqr/vietqr_data.dart';
import 'package:myqr/model/qr_custom.dart';
import 'package:myqr/model/qr_data.dart';
import 'package:myqr/feature/custom/ui/custom_screen.dart';
import 'package:myqr/feature/generate/ui/generate_screen.dart';

class CreateNewScreen extends StatefulWidget {
  const CreateNewScreen({super.key});

  @override
  State<CreateNewScreen> createState() => _CreateNewScreenState();
}

class _CreateNewScreenState extends State<CreateNewScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _scannerController;
  bool _isScanning = false;
  bool _hasPermission = false;
  bool _isFlashOn = false;

  final TextEditingController _manualInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });

    if (_hasPermission) {
      _initializeScanner();
    }
  }

  void _initializeScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  void _handleQRDetection(BarcodeCapture capture) {
    if (_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        _processQRCode(code);
        break;
      }
    }
  }

  void _processQRCode(String qrString) {
    setState(() {
      _isScanning = true;
    });

    // Vibrate to give feedback
    HapticFeedback.mediumImpact();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Process QR code
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context); // Close loading dialog

      final vietQRData = VietQRParser.parse(qrString);

      if (vietQRData != null) {
        _showQRPreview(vietQRData);
      } else {
        _showErrorDialog('Invalid VietQR code format');
      }

      setState(() {
        _isScanning = false;
      });
    });
  }

  void _showQRPreview(VietQRData vietQRData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _QRPreviewSheet(
        vietQRData: vietQRData,
        onCreateNew: (qrData) {
          Navigator.pop(context); // Close bottom sheet
          _navigateToCustomScreen(qrData);
        }
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToCustomScreen(QrData qrData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomScreen(
          qrCustom: const QrCustom(),
          qrData: qrData,
        ),
      ),
    );
  }

  void _navigateToGenerateScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GenerateScreen(),
      ),
    );
  }

  void _toggleFlash() {
    if (_scannerController != null) {
      _scannerController!.toggleTorch();
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  void _processManualInput() {
    final qrString = _manualInputController.text.trim();
    if (qrString.isEmpty) {
      _showErrorDialog('Please enter a QR code string');
      return;
    }

    _processQRCode(qrString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: _buildCameraTab()
    );
  }

  Widget _buildCameraTab() {
    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Camera permission required',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please grant camera permission to scan QR codes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _requestCameraPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      );
    }

    if (_scannerController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController!,
          onDetect: _handleQRDetection,
        ),

        // Overlay with scan area
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
          ),
          child: Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Corner indicators
                  Positioned(
                    top: -2,
                    left: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.blue[400]!, width: 4),
                          left: BorderSide(color: Colors.blue[400]!, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.blue[400]!, width: 4),
                          right: BorderSide(color: Colors.blue[400]!, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    left: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.blue[400]!, width: 4),
                          left: BorderSide(color: Colors.blue[400]!, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.blue[400]!, width: 4),
                          right: BorderSide(color: Colors.blue[400]!, width: 4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Instructions
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Position the QR code within the frame to scan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),

        // Flash button
        Positioned(
          bottom: 50,
          right: 20,
          child: FloatingActionButton(
            onPressed: _toggleFlash,
            backgroundColor: _isFlashOn ? Colors.yellow[700] : Colors.grey[800],
            child: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
          ),
        ),

        // Manual input button
        Positioned(
          bottom: 50,
          left: 20,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GenerateScreen(),
              ),
            ),
            backgroundColor: Colors.blue[600],
            child: const Icon(
              Icons.keyboard,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _QRPreviewSheet extends StatelessWidget {
  final VietQRData vietQRData;
  final Function(QrData) onCreateNew;

  const _QRPreviewSheet({
    required this.vietQRData,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    final qrData = QrData(
      bankBin: vietQRData.bankBIN,
      bankName: vietQRData.bankName,
      accountNumber: vietQRData.accountNumber,
      accountName: vietQRData.accountName,
      amount: double.tryParse(vietQRData.amount) ?? 0,
      note: vietQRData.note,
      qrString: vietQRData.qrString,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 28),
              const SizedBox(width: 12),
              const Text(
                'QR Code Detected',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // QR Details
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDetailCard('Bank Information', [
                    _buildDetailRow('Bank', vietQRData.bankName),
                    _buildDetailRow('BIN', vietQRData.bankBIN),
                    _buildDetailRow('Account', vietQRData.accountNumber),
                    if (vietQRData.accountName.isNotEmpty)
                      _buildDetailRow('Account Name', vietQRData.accountName),
                  ]),

                  const SizedBox(height: 16),

                  _buildDetailCard('Transaction Details', [
                    if (vietQRData.amount.isNotEmpty)
                      _buildDetailRow('Amount', '${vietQRData.amount} ${vietQRData.currency}'),
                    if (vietQRData.note.isNotEmpty)
                      _buildDetailRow('Note', vietQRData.note),
                    _buildDetailRow('Service Type', vietQRData.serviceType),
                    _buildDetailRow('Country', vietQRData.countryCode),
                  ]),

                  const SizedBox(height: 16),

                  _buildDetailCard('Technical Details', [
                    _buildDetailRow('QR String', vietQRData.qrString, isMonospace: true),
                    _buildDetailRow('Created', vietQRData.createdAt.toString().split('.')[0]),
                  ]),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          ElevatedButton.icon(
            onPressed: () => onCreateNew(qrData),
            icon: const Icon(Icons.edit),
            label: const Text('Customize'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMonospace = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: isMonospace ? 'monospace' : null,
                fontSize: isMonospace ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}