import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/helper/responsive_helper.dart';

class ScanInvitationPage extends StatefulWidget {
  const ScanInvitationPage({super.key});

  @override
  State<ScanInvitationPage> createState() => _ScanInvitationPageState();
}

class _ScanInvitationPageState extends State<ScanInvitationPage> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isFlashOn = false;

  @override
  Widget build(BuildContext context) {
    final scanAreaSize = rw(context, 260.0);
    final isIndonesian = Get.locale?.languageCode == 'id';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () async {
            await cameraController.stop();
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          isIndonesian ? 'Pindai Undangan' : 'Scan Invitation',
          style: TextStyle(
            color: Colors.black,
            fontSize: rfs(context, 18),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
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
                if (barcode.rawValue != null &&
                    barcode.rawValue!.trim().isNotEmpty) {
                  // Stop scanning immediately and return scanned raw data
                  final code = barcode.rawValue!.trim();
                  cameraController.stop().then((_) {
                    if (context.mounted) {
                      Navigator.pop(context, code);
                    }
                  });
                  break;
                }
              }
            },
          ),

          // Custom overlay with transparent center using CustomPainter
          CustomPaint(
            painter: ScannerOverlayPainter(scanAreaSize: scanAreaSize),
            child: const SizedBox(
              width: double.infinity,
              height: double.infinity,
            ),
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
                      width: rw(context, 32),
                      height: rw(context, 32),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.white,
                            width: rw(context, 4),
                          ),
                          left: BorderSide(
                            color: Colors.white,
                            width: rw(context, 4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Top-right corner
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: rw(context, 32),
                      height: rw(context, 32),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.white,
                            width: rw(context, 4),
                          ),
                          right: BorderSide(
                            color: Colors.white,
                            width: rw(context, 4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bottom-left corner
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: rw(context, 32),
                      height: rw(context, 32),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: rw(context, 4),
                          ),
                          left: BorderSide(
                            color: Colors.white,
                            width: rw(context, 4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bottom-right corner
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: rw(context, 32),
                      height: rw(context, 32),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: rw(context, 4),
                          ),
                          right: BorderSide(
                            color: Colors.white,
                            width: rw(context, 4),
                          ),
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
            bottom: rh(context, 120),
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  isIndonesian
                      ? 'Posisikan kode QR di dalam bingkai'
                      : 'Position the QR code within the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: rfs(context, 16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isIndonesian
                      ? 'Kode QR akan dipindai secara otomatis'
                      : 'The QR code will be scanned automatically',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: rfs(context, 13),
                    fontWeight: FontWeight.w400,
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
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.65);

    // Calculate center position for the transparent area
    final center = Offset(size.width / 2, size.height / 2);
    final scanArea = Rect.fromCenter(
      center: center,
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // Create a path that covers the entire canvas
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Subtract the scan area to make it transparent
    final scanAreaPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(16)));

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
