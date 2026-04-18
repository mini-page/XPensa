import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessed = false;
  bool _isPickingImage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessed) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null) {
        _parseAndNavigate(rawValue);
        break;
      }
    }
  }

  void _parseAndNavigate(String rawValue) {
    setState(() {
      _isProcessed = true;
    });

    double? amount;
    String? note;

    // Basic UPI URI Parsing: upi://pay?pa=...&pn=...&am=...&tn=...
    if (rawValue.startsWith('upi://pay')) {
      final Uri uri = Uri.parse(rawValue);
      final String? am = uri.queryParameters['am'];
      final String? pn = uri.queryParameters['pn'];
      final String? tn = uri.queryParameters['tn'];

      if (am != null) {
        amount = double.tryParse(am);
      }
      note = tn ?? pn;
    }

    if (!mounted) return;

    // Navigate to AddExpenseScreen with parsed data
    AppRoutes.replaceWithAddExpense(
        context, initialAmount: amount, initialNote: note);
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

      final capture = await controller.analyzeImage(path);

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
        title: const Text('Scan QR / Barcode'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _onDetect),
          // Scanner Overlay
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
          // Hint pill + controls — stacked at the very bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hint pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Point camera at a UPI or Receipt QR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Flash toggle + image picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ValueListenableBuilder<MobileScannerState>(
                          valueListenable: controller,
                          builder: (_, state, __) {
                            final torchOn =
                                state.torchState == TorchState.on;
                            return _ScannerControlButton(
                              icon: torchOn
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              label: torchOn ? 'Flash On' : 'Flash Off',
                              highlighted: torchOn,
                              onTap: controller.toggleTorch,
                            );
                          },
                        ),
                        const SizedBox(width: 32),
                        _ScannerControlButton(
                          icon: Icons.photo_library_outlined,
                          label: 'Gallery',
                          loading: _isPickingImage,
                          onTap: _pickImageAndScan,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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

