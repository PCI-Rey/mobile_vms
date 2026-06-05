import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/helper/responsive_helper.dart';

class ScanTicketPage extends StatefulWidget {
  const ScanTicketPage({super.key});

  @override
  State<ScanTicketPage> createState() => _ScanTicketPageState();
}

class _ScanTicketPageState extends State<ScanTicketPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isFlashOn = false;

  @override
  Widget build(BuildContext context) {
    final scanAreaSize = rw(context, 250.0);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scan Ticket',
          style: TextStyle(
            color: Colors.black,
            fontSize: rfs(context, 18),
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.black,
            ),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        children: [
          // QR Code Camera view
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                // Only process QR codes
                if (barcode.format == BarcodeFormat.qrCode &&
                    barcode.rawValue != null) {
                  _showScanResult(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // Custom overlay with transparent center using CustomPainter
          CustomPaint(
            painter: ScannerOverlayPainter(scanAreaSize: scanAreaSize),
            child: const SizedBox(width: double.infinity, height: double.infinity),
          ),

          // Scanner frame with corner brackets
          Center(
            child: SizedBox(
              width: scanAreaSize,
              height: scanAreaSize,
              child: Stack(
                children: [
                  // Top-left corner
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: rw(context, 30),
                      height: rw(context, 30),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white, width: rw(context, 4)),
                          left: BorderSide(color: Colors.white, width: rw(context, 4)),
                        ),
                      ),
                    ),
                  ),
                  // Top-right corner
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: rw(context, 30),
                      height: rw(context, 30),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white, width: rw(context, 4)),
                          right: BorderSide(color: Colors.white, width: rw(context, 4)),
                        ),
                      ),
                    ),
                  ),
                  // Bottom-left corner
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: rw(context, 30),
                      height: rw(context, 30),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white, width: rw(context, 4)),
                          left: BorderSide(color: Colors.white, width: rw(context, 4)),
                        ),
                      ),
                    ),
                  ),
                  // Bottom-right corner
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: rw(context, 30),
                      height: rw(context, 30),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white, width: rw(context, 4)),
                          right: BorderSide(color: Colors.white, width: rw(context, 4)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Instructions text
          Positioned(
            bottom: rh(context, 100),
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Position the QR code within the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: rfs(context, 16),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                vSpace(context, 8),
                Text(
                  'The QR code will be scanned automatically',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: rfs(context, 14),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFlash() async {
    await cameraController.toggleTorch();
    setState(() {
      isFlashOn = !isFlashOn;
    });
  }

  void _showScanResult(String qrData) {
    // Stop scanning to prevent multiple triggers
    cameraController.stop();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.qr_code, color: Colors.green),
            hSpace(context, 8),
            const Text('QR Code Scanned'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('QR Code Content:'),
            vSpace(context, 8),
            Container(
              padding: EdgeInsets.all(rw(context, 12)),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(rw(context, 8)),
              ),
              child: Text(
                qrData,
                style: TextStyle(fontFamily: 'monospace', fontSize: rfs(context, 12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Resume scanning
              cameraController.start();
            },
            child: const Text('Scan Another'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, qrData);
            },
            child: const Text('Use QR Code'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

// Custom painter for creating overlay with transparent center
class ScannerOverlayPainter extends CustomPainter {
  final double scanAreaSize;

  ScannerOverlayPainter({required this.scanAreaSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.5);

    // Calculate center position for the transparent area
    final center = Offset(size.width / 2, size.height / 2);
    final scanArea = Rect.fromCenter(center: center, width: scanAreaSize, height: scanAreaSize);

    // Create a path that covers the entire canvas
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Subtract the scan area to make it transparent
    final scanAreaPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(12)));

    // Combine paths to create the overlay with transparent center
    final finalPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      scanAreaPath,
    );

    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
