import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';

/// A QR scanner specialised for the "Pay Directly" flow.
///
/// Detects a UPI payment QR, extracts the full URI, and opens
/// [AddExpenseScreen] in pay-mode so the user can fill in the amount,
/// launch their UPI app, and then save the transaction.
class UpiScannerScreen extends StatefulWidget {
  const UpiScannerScreen({super.key});

  @override
  State<UpiScannerScreen> createState() => _UpiScannerScreenState();
}

class _UpiScannerScreenState extends State<UpiScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessed = false;
  bool _isPickingImage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessed) return;
    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null) {
        _parseAndNavigate(rawValue);
        break;
      }
    }
  }

  void _parseAndNavigate(String rawValue) {
    if (!rawValue.startsWith('upi://pay')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not a UPI payment QR. Try again.')),
      );
      return;
    }

    setState(() => _isProcessed = true);

    final uri = Uri.parse(rawValue);
    final am = uri.queryParameters['am'];
    final pn = uri.queryParameters['pn'];
    final tn = uri.queryParameters['tn'];
    final amount = am != null ? double.tryParse(am) : null;
    // Prefer merchant name (pn) as pre-filled note, fall back to transaction note (tn).
    final note = pn?.isNotEmpty == true ? pn : tn;

    if (!mounted) return;

    AppRoutes.replaceWithPayExpense(
      context,
      payUpiUri: rawValue,
      initialAmount: amount,
      initialNote: note,
    );
  }

  Future<void> _pickImageAndScan() async {
    if (_isPickingImage || _isProcessed) return;
    setState(() => _isPickingImage = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (!mounted) return;

      final path = result?.files.singleOrNull?.path;
      if (path == null) {
        setState(() => _isPickingImage = false);
        return;
      }

      final capture = await _controller.analyzeImage(path);

      if (!mounted) return;

      if (capture == null || capture.barcodes.isEmpty) {
        setState(() => _isPickingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No QR code found in the image.')),
        );
        return;
      }

      _onDetect(capture);
    } catch (_) {
      if (mounted) {
        setState(() => _isPickingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read QR from image.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan UPI QR'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Hint text — sits above the bottom controls
          const Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Point camera at a UPI payment QR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.black45,
                ),
              ),
            ),
          ),
          // Bottom controls: flash toggle + image picker
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flash toggle
                ValueListenableBuilder<MobileScannerState>(
                  valueListenable: _controller,
                  builder: (_, state, __) {
                    final torchOn = state.torchState == TorchState.on;
                    return _ScannerControlButton(
                      icon: torchOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      label: torchOn ? 'Flash On' : 'Flash Off',
                      highlighted: torchOn,
                      onTap: _controller.toggleTorch,
                    );
                  },
                ),
                const SizedBox(width: 32),
                // Image picker
                _ScannerControlButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  loading: _isPickingImage,
                  onTap: _pickImageAndScan,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared control button ─────────────────────────────────────────────────────

class _ScannerControlButton extends StatelessWidget {
  const _ScannerControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: highlighted
                  ? Colors.amber.withValues(alpha: 0.85)
                  : Colors.black54,
              shape: BoxShape.circle,
            ),
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(icon,
                    color: highlighted ? Colors.black87 : Colors.white,
                    size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}

