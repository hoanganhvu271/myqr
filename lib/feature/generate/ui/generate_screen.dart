import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myqr/constant/bank_constant.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'generate_provider.dart';

class GenerateScreen extends ConsumerStatefulWidget {
  const GenerateScreen({super.key});

  @override
  ConsumerState<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends ConsumerState<GenerateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankBINController = TextEditingController();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isOneTime = true;
  String? _selectedBank;

  @override
  void initState() {
    super.initState();
    // Set default values for testing
    _selectedBank = '970415';
    _bankBINController.text = '970415';
    _accountController.text = '1234567890';
    _amountController.text = '100000';
    _noteController.text = 'Test payment';
  }

  @override
  void dispose() {
    _bankBINController.dispose();
    _accountController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _generateQR() {
    if (_formKey.currentState!.validate()) {
      final provider = ref.read(generateViewModel.notifier);

      // Generate QR string
      provider.generateNewQrString(
        bankBIN: _bankBINController.text,
        accountNumber: _accountController.text,
        amount: double.tryParse(_amountController.text) ?? 0,
        note: _noteController.text,
        isOneTime: _isOneTime,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _copyQRString() {
    final qrString = ref.read(generateViewModel);
    if (qrString.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: qrString));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR string copied to clipboard!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _clearForm() {
    _bankBINController.clear();
    _accountController.clear();
    _amountController.clear();
    _noteController.clear();
    ref.read(generateViewModel.notifier).updateQRString('');
    setState(() {
      _selectedBank = null;
      _isOneTime = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final qrString = ref.watch(generateViewModel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VietQR Generator Test'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearForm,
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Information
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.credit_card, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          const Text(
                            'Account Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedBank,
                        decoration: const InputDecoration(
                          labelText: 'Select Bank',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance),
                        ),
                        items: BanksConstant.vietnameseBanks.map((bank) {
                          return DropdownMenuItem(
                            value: bank.bin,
                            child: Text('${bank.shortName} (${bank.bin})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBank = value;
                            _bankBINController.text = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a bank';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Account Number
                      TextFormField(
                        controller: _accountController,
                        decoration: const InputDecoration(
                          labelText: 'Account Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter account number';
                          }
                          if (value.length < 6) {
                            return 'Account number too short';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Amount
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount (VND)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.monetization_on),
                          suffixText: 'VND',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'Please enter valid amount';
                            }
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Note
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'Payment Note',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                          helperText: 'Optional payment description',
                        ),
                        maxLength: 100,
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Generate Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _generateQR,
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text(
                    'Generate VietQR',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // QR Result
              if (qrString.isNotEmpty) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[600]),
                            const SizedBox(width: 8),
                            const Text(
                              'Generated QR Code',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _copyQRString,
                              icon: const Icon(Icons.copy),
                              tooltip: 'Copy QR String',
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // QR Code Image
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: PrettyQrView.data(
                            data: qrString,
                            decoration: const PrettyQrDecoration(
                              shape: const PrettyQrRoundedSymbol(
                                borderRadius: BorderRadius.all(Radius.zero),
                                color: Colors.black,
                                // roundFactor: 0.5,
                              ),
                              quietZone: PrettyQrQuietZone.zero,
                              background: Colors.white,
                              image: PrettyQrDecorationImage(
                                scale: 0.2,
                                image: AssetImage('assets/images/memeo.jpg'),
                              ),
                            ),

                          ),
                        ),

                        const SizedBox(height: 20),

                        // QR String Display
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'QR String:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${qrString.length} chars',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                qrString,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _copyQRString,
                              icon: const Icon(Icons.copy, size: 18),
                              label: const Text('Copy'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implement share functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Share functionality not implemented yet'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Share'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
