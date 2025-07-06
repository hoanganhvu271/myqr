import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'dart:io';
import '../../../model/qr_data.dart';

// Dependency: pretty_qr_code: ^3.0.0

class CustomScreen extends StatefulWidget {
  final bool isSmooth;
  final bool isCircle;
  final Color color;
  final bool hasCenterImage;
  final XFile? imageFile;
  final QrData qrData;

  const CustomScreen({
    super.key,
    this.isSmooth = false,
    this.isCircle = false,
    this.color = Colors.black,
    this.hasCenterImage = false,
    this.imageFile,
    required this.qrData,
  });

  @override
  State<CustomScreen> createState() => _CustomScreenState();
}

class _CustomScreenState extends State<CustomScreen> {
  late bool _isSmooth;
  late bool _isCircle;
  late Color _color;
  late bool _hasCenterImage;
  XFile? _imageFile;
  Color _backgroundColor = Colors.white;
  double _roundFactor = 0;

  @override
  void initState() {
    super.initState();
    _isSmooth = widget.isSmooth;
    _isCircle = widget.isCircle;
    _color = widget.color;
    _hasCenterImage = widget.hasCenterImage;
    _imageFile = widget.imageFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom QR Design'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // QR Preview
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.grey[100],
              child: Center(
                child: _buildQR(),
              ),
            ),
          ),

          // Controls
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: _buildControls(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQR() {
    return PrettyQrView.data(
      data: widget.qrData.qrString,
      decoration: PrettyQrDecoration(
        shape: _isSmooth
            ? PrettyQrSmoothSymbol(
          color: _color,
          roundFactor: _isCircle ? 1.0 : _roundFactor,
        )
            : PrettyQrRoundedSymbol(
          color: _color,
          borderRadius: BorderRadius.circular(_isCircle ? 15 : 0),
        ),
        background: _backgroundColor,
        image: _hasCenterImage && _imageFile != null
            ? PrettyQrDecorationImage(
          image: FileImage(File(_imageFile!.path)),
          fit: BoxFit.contain,
        )
            : null,
      ),
    );
  }

  Widget _buildControls() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QR Style',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Style Switches
          SwitchListTile(
            title: const Text('Smooth Style'),
            value: _isSmooth,
            onChanged: (value) => setState(() => _isSmooth = value),
            activeColor: Colors.blue,
          ),

          SwitchListTile(
            title: const Text('Circular'),
            value: _isCircle,
            onChanged: (value) => setState(() => _isCircle = value),
            activeColor: Colors.blue,
          ),

          SwitchListTile(
            title: const Text('Center Image'),
            value: _hasCenterImage,
            onChanged: (value) => setState(() => _hasCenterImage = value),
            activeColor: Colors.blue,
          ),

          // Round Factor (only for smooth style)
          if (_isSmooth && !_isCircle) ...[
            const SizedBox(height: 16),
            Text('Roundness: ${_roundFactor.toStringAsFixed(1)}'),
            Slider(
              value: _roundFactor,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: (value) => setState(() => _roundFactor = value),
              activeColor: Colors.blue,
            ),
          ],

          const SizedBox(height: 16),

          // Color Selection
          const Text('QR Color', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildColorRow([
            Colors.black, Colors.blue, Colors.red, Colors.green,
            Colors.purple, Colors.orange, Colors.indigo, Colors.teal,
          ], _color, (color) => setState(() => _color = color)),

          const SizedBox(height: 16),

          // Background Color
          const Text('Background Color', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildColorRow([
            Colors.white, Colors.grey[100]!, Colors.blue[50]!, Colors.green[50]!,
            Colors.red[50]!, Colors.purple[50]!, Colors.orange[50]!, Colors.yellow[50]!,
          ], _backgroundColor, (color) => setState(() => _backgroundColor = color)),

          // Image Picker
          if (_hasCenterImage) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: Text(_imageFile != null ? 'Change Image' : 'Pick Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColorRow(List<Color> colors, Color selectedColor, ValueChanged<Color> onChanged) {
    return Wrap(
      spacing: 8,
      children: colors.map((color) {
        final isSelected = color.value == selectedColor.value;
        return GestureDetector(
          onTap: () => onChanged(color),
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey[300]!,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? Icon(
              Icons.check,
              color: color == Colors.white ? Colors.black : Colors.white,
              size: 18,
            )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 100,
      maxHeight: 100,
    );

    if (image != null) {
      setState(() => _imageFile = image);
    }
  }
}
