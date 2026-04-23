import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:gal/gal.dart';

import '../../../core/core.dart';

class AccessPassDialog extends StatefulWidget {
  final String name;
  final String date;
  final String time;
  final String invitationCode;
  final String cardNumber;
  final String vehiclePlateNo;
  final String parkingSlot;
  final String buildingName;
  final String visitorId;
  final String? profileImagePath;
  final bool isTracked;
  final bool isLowBattery;

  const AccessPassDialog({
    super.key,
    required this.name,
    required this.date,
    required this.time,
    required this.invitationCode,
    required this.cardNumber,
    required this.vehiclePlateNo,
    required this.parkingSlot,
    required this.buildingName,
    required this.visitorId,
    this.profileImagePath,
    this.isTracked = false,
    this.isLowBattery = false,
  });

  @override
  State<AccessPassDialog> createState() => _AccessPassDialogState();
}

class _AccessPassDialogState extends State<AccessPassDialog> {
  final GlobalKey _accessPassKey = GlobalKey();
  bool _isCapturing = false; // State untuk hide/show download button

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Text(
                  'Your Access Pass',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Content - Wrapped with RepaintBoundary for screenshot
              RepaintBoundary(
                key: _accessPassKey,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.only(left: 24,right:24, top: 20),
                  child: Column(
                    children: [
                      // User info section
                      Row(
                        children: [
                          // Profile picture
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.grey200,
                            ),
                            child: widget.profileImagePath != null
                                ? ClipOval(
                                    child: Image.asset(
                                      widget.profileImagePath!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 28,
                                    color: AppColors.grey600,
                                  ),
                          ),
                          const SizedBox(width: 12),

                          // User details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.date} ${widget.time}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grey600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Download button - Hidden saat capturing
                          AnimatedOpacity(
                            opacity: _isCapturing ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: GestureDetector(
                              onTap: _isCapturing ? null : _downloadAccessPass,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _isCapturing
                                      ? Colors.transparent
                                      : AppColors.primary500,
                                  shape: BoxShape.circle,
                                ),
                                child: _isCapturing
                                    ? const SizedBox.shrink()
                                    : const Icon(
                                        Icons.download,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Info cards row 1
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              widget.invitationCode,
                              'Invitation Code',
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              widget.cardNumber,
                              'Card',
                              crossAxisAlignment: CrossAxisAlignment.end,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Info cards row 2
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              widget.vehiclePlateNo,
                              'Vehicle Plate No.',
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              widget.parkingSlot,
                              'Parking Slot',
                              crossAxisAlignment: CrossAxisAlignment.end,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Building name
                      Text(
                        widget.buildingName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // QR Code section
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _buildQRCodePlaceholder(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Status indicators
                      if (widget.isTracked || widget.isLowBattery)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.isTracked)
                              Text(
                                'Tracked',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            if (widget.isTracked && widget.isLowBattery)
                              const SizedBox(width: 32),
                            if (widget.isLowBattery)
                              Text(
                                'Low Battery',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Instructions
                      Text(
                        'Show this while visiting',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID : ${widget.visitorId}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Close button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String value,
    String label, {
    required CrossAxisAlignment crossAxisAlignment,
  }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.grey600)),
      ],
    );
  }

  Widget _buildQRCodePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: CustomPaint(painter: QRCodePainter()),
    );
  }

  Future<void> _downloadAccessPass() async {
    try {
      // Check if Gal has access to photos
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final requestGranted = await Gal.requestAccess();
        if (!requestGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Permission diperlukan untuk menyimpan gambar ke galeri",
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text("Menyimpan Access Pass..."),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Set capturing state to true - Hide download button
      setState(() {
        _isCapturing = true;
      });

      // Wait for UI to update
      await Future.delayed(const Duration(milliseconds: 300));

      // Capture widget sebagai gambar
      RenderRepaintBoundary boundary =
          _accessPassKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Simpan ke galeri menggunakan Gal
      await Gal.putImageBytes(
        pngBytes,
        name: "access_pass_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 16),
                Text("Access Pass berhasil disimpan ke galeri"),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on GalException catch (e) {
      debugPrint(
        "Gal error while saving access pass: ${e.type} - ${e.platformException}",
      );
      if (mounted) {
        String errorMessage = "Gagal menyimpan Access Pass ke galeri";

        switch (e.type) {
          case GalExceptionType.accessDenied:
            errorMessage =
                "Akses ditolak. Mohon berikan izin untuk menyimpan gambar.";
            break;
          case GalExceptionType.notEnoughSpace:
            errorMessage = "Ruang penyimpanan tidak cukup.";
            break;
          case GalExceptionType.notSupportedFormat:
            errorMessage = "Format gambar tidak didukung.";
            break;
          case GalExceptionType.unexpected:
            errorMessage = "Terjadi kesalahan tak terduga.";
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 16),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint("Unexpected error while saving access pass: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 16),
                Text("Gagal menyimpan Access Pass ke galeri"),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Reset capturing state - Show download button again
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }
}

// Custom painter untuk QR Code placeholder
class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2D3E50)
      ..style = PaintingStyle.fill;

    final blockSize = size.width / 21;

    final pattern = [
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0],
      [0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 1],
      [1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0],
      [0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1],
      [1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
      [1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
      [1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
    ];

    for (int i = 0; i < pattern.length; i++) {
      for (int j = 0; j < pattern[i].length; j++) {
        if (pattern[i][j] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(j * blockSize, i * blockSize, blockSize, blockSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper function to show the dialog
void showAccessPassDialog({
  required BuildContext context,
  required String name,
  required String date,
  required String time,
  required String invitationCode,
  required String cardNumber,
  required String vehiclePlateNo,
  required String parkingSlot,
  required String buildingName,
  required String visitorId,
  String? profileImagePath,
  bool isTracked = false,
  bool isLowBattery = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => AccessPassDialog(
      name: name,
      date: date,
      time: time,
      invitationCode: invitationCode,
      cardNumber: cardNumber,
      vehiclePlateNo: vehiclePlateNo,
      parkingSlot: parkingSlot,
      buildingName: buildingName,
      visitorId: visitorId,
      profileImagePath: profileImagePath,
      isTracked: isTracked,
      isLowBattery: isLowBattery,
    ),
  );
}
