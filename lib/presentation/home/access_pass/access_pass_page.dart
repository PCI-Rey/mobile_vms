import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:gal/gal.dart';

import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';

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
      insetPadding: EdgeInsets.all(rw(context, 20)),
      child: Container(
        constraints: BoxConstraints(maxWidth: rw(context, 400)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: rh(context, 20),
                  horizontal: rw(context, 24),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(rw(context, 20))),
                ),
                child: Text(
                  'Your Access Pass',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.5,
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
                  padding: EdgeInsets.only(
                    left: rw(context, 24),
                    right: rw(context, 24),
                    top: rh(context, 20),
                  ),
                  child: Column(
                    children: [
                      // User info section
                      Row(
                        children: [
                          // Profile picture with border
                          Container(
                            width: rw(context, 48),
                            height: rw(context, 48),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 2,
                              ),
                              color: AppColors.grey200,
                            ),
                            child: widget.profileImagePath != null
                                ? ClipOval(
                                    child: Image.asset(
                                      widget.profileImagePath!,
                                      width: rw(context, 48),
                                      height: rw(context, 48),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: rw(context, 28),
                                    color: AppColors.grey600,
                                  ),
                          ),
                          hSpace(context, 12),

                          // User details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.name,
                                  style: TextStyle(
                                    fontSize: rfs(context, 16),
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                vSpace(context, 2),
                                Text(
                                  '${widget.date} ${widget.time}',
                                  style: TextStyle(
                                    fontSize: rfs(context, 13),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
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
                                width: rw(context, 40),
                                height: rw(context, 40),
                                decoration: BoxDecoration(
                                  color: _isCapturing
                                      ? Colors.transparent
                                      : AppColors.primary500,
                                  shape: BoxShape.circle,
                                  boxShadow: _isCapturing
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: AppColors.primary500.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                ),
                                child: _isCapturing
                                    ? const SizedBox.shrink()
                                    : Icon(
                                        Icons.download,
                                        size: rw(context, 20),
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      vSpace(context, 24),

                      // Structured Info Card Grid
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 16),
                          vertical: rh(context, 16),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(rw(context, 12)),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    widget.invitationCode,
                                    'Invitation Code',
                                    Icons.confirmation_number_outlined,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: rh(context, 32),
                                  color: const Color(0xFFE2E8F0),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: rw(context, 16)),
                                    child: _buildInfoCard(
                                      widget.cardNumber,
                                      'Card',
                                      Icons.credit_card_outlined,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              color: const Color(0xFFE2E8F0),
                              height: rh(context, 24),
                              thickness: 1,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    widget.vehiclePlateNo,
                                    'Vehicle Plate No.',
                                    Icons.directions_car_outlined,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: rh(context, 32),
                                  color: const Color(0xFFE2E8F0),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: rw(context, 16)),
                                    child: _buildInfoCard(
                                      widget.parkingSlot,
                                      'Parking Slot',
                                      Icons.local_parking_outlined,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      vSpace(context, 24),

                      // Building name with icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: rw(context, 20),
                            color: AppColors.primary500,
                          ),
                          hSpace(context, 8),
                          Text(
                            widget.buildingName,
                            style: TextStyle(
                              fontSize: rfs(context, 20),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),

                      vSpace(context, 24),

                      // QR Code section
                      Container(
                        width: rw(context, 200),
                        height: rw(context, 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(rw(context, 12)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.15),
                              blurRadius: rw(context, 12),
                              offset: Offset(0, rh(context, 4)),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(rw(context, 20)),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(rw(context, 8)),
                            ),
                            child: _buildQRCodePlaceholder(),
                          ),
                        ),
                      ),

                      // Status indicators (Pill badges)
                      if (widget.isTracked || widget.isLowBattery) ...[
                        vSpace(context, 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.isTracked)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: rw(context, 10),
                                  vertical: rh(context, 4),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(rw(context, 6)),
                                  border: Border.all(color: Colors.red.shade100),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 14, color: Colors.red.shade600),
                                    hSpace(context, 4),
                                    Text(
                                      'Tracked',
                                      style: TextStyle(
                                        fontSize: rfs(context, 11),
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (widget.isTracked && widget.isLowBattery)
                              hSpace(context, 12),
                            if (widget.isLowBattery)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: rw(context, 10),
                                  vertical: rh(context, 4),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(rw(context, 6)),
                                  border: Border.all(color: Colors.orange.shade100),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.battery_alert_outlined, size: 14, color: Colors.orange.shade700),
                                    hSpace(context, 4),
                                    Text(
                                      'Low Battery',
                                      style: TextStyle(
                                        fontSize: rfs(context, 11),
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],

                      vSpace(context, 20),

                      // Instructions
                      Text(
                        'Show this while visiting',
                        style: TextStyle(
                          fontSize: rfs(context, 13),
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      vSpace(context, 6),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 12),
                          vertical: rh(context, 6),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(rw(context, 8)),
                        ),
                        child: Text(
                          'ID: ${widget.visitorId}',
                          style: TextStyle(
                            fontSize: rfs(context, 14),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF334155),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      vSpace(context, 32),
                    ],
                  ),
                ),
              ),

              // Close button (Unified Blue color)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  rw(context, 24),
                  0,
                  rw(context, 24),
                  rh(context, 24),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: rh(context, 48),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005596),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rw(context, 12)),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: rfs(context, 15),
                        fontWeight: FontWeight.w700,
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

  Widget _buildInfoCard(String value, String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: rw(context, 13), color: const Color(0xFF64748B)),
            hSpace(context, 6),
            Text(
              label,
              style: TextStyle(
                fontSize: rfs(context, 11),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        vSpace(context, 4),
        Text(
          value.isEmpty ? '-' : value,
          style: TextStyle(
            fontSize: rfs(context, 14),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
        ),
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
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: rw(context, 16),
                  height: rw(context, 16),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                hSpace(context, 16),
                const Text("Menyimpan Access Pass..."),
              ],
            ),
            duration: const Duration(seconds: 2),
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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                hSpace(context, 16),
                const Text("Access Pass berhasil disimpan ke galeri"),
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
                const Icon(Icons.error, color: Colors.white),
                hSpace(context, 16),
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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                hSpace(context, 16),
                const Text("Gagal menyimpan Access Pass ke galeri"),
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

