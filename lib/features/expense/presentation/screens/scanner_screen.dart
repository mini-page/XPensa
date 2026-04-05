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
    AppRoutes.replaceWithAddExpense(context, initialAmount: amount, initialNote: note);
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
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Point camera at a UPI or Receipt QR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.black45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
