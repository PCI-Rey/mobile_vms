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
          borderRadius: BorderRadius.circular(rw(context, 24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: rh(context, 24),
                  bottom: rh(context, 12),
                  left: rw(context, 24),
                  right: rw(context, 24),
                ),
                child: Column(
                  children: [
                    Container(
                      width: rw(context, 40),
                      height: rh(context, 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    vSpace(context, 16),
                    Text(
                      'Your Access Pass',
                      style: TextStyle(
                        fontSize: rfs(context, 20),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
                    top: rh(context, 16),
                  ),
                  child: Column(
                    children: [
                      // User info section
                      Row(
                        children: [
                          // Profile picture with border
                          Container(
                            width: rw(context, 52),
                            height: rw(context, 52),
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
                                      width: rw(context, 52),
                                      height: rw(context, 52),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: rw(context, 32),
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
                                    fontSize: rfs(context, 18),
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                vSpace(context, 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: rw(context, 13),
                                      color: const Color(0xFF64748B),
                                    ),
                                    hSpace(context, 4),
                                    Expanded(
                                      child: Text(
                                        '${widget.date} • ${widget.time}',
                                        style: TextStyle(
                                          fontSize: rfs(context, 12),
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF64748B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
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
                                width: rw(context, 42),
                                height: rw(context, 42),
                                decoration: BoxDecoration(
                                  color: _isCapturing
                                      ? Colors.transparent
                                      : const Color(0xFFE8F1FB),
                                  shape: BoxShape.circle,
                                ),
                                child: _isCapturing
                                    ? const SizedBox.shrink()
                                    : const Icon(
                                        Icons.download_rounded,
                                        size: 20,
                                        color: Color(0xFF1976D2),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      vSpace(context, 20),

                      // Structured Info Card Grid
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 16),
                          vertical: rh(context, 16),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(rw(context, 16)),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
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
                                  height: rh(context, 36),
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
                                  height: rh(context, 36),
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

                      vSpace(context, 20),

                      // Building name with icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 20,
                            color: Color(0xFF1976D2),
                          ),
                          hSpace(context, 6),
                          Text(
                            widget.buildingName,
                            style: TextStyle(
                              fontSize: rfs(context, 18),
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),

                      vSpace(context, 20),

                      // QR Code section
                      Container(
                        width: rw(context, 220),
                        height: rw(context, 220),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(rw(context, 20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(rw(context, 16)),
                          child: _buildQRCodePlaceholder(),
                        ),
                      ),

                      // Status indicators (Pill badges)
                      if (widget.isTracked || widget.isLowBattery) ...[
                        vSpace(context, 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.isTracked)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: rw(context, 12),
                                  vertical: rh(context, 6),
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(rw(context, 30)),
                                  border: Border.all(color: const Color(0xFFFEE2E2)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEF4444),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    hSpace(context, 6),
                                    Text(
                                      'Tracked',
                                      style: TextStyle(
                                        fontSize: rfs(context, 12),
                                        color: const Color(0xFFB91C1C),
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
                                  horizontal: rw(context, 12),
                                  vertical: rh(context, 6),
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(rw(context, 30)),
                                  border: Border.all(color: const Color(0xFFFFEDD5)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF97316),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    hSpace(context, 6),
                                    Text(
                                      'Low Battery',
                                      style: TextStyle(
                                        fontSize: rfs(context, 12),
                                        color: const Color(0xFFC2410C),
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
                          fontSize: rfs(context, 12),
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      vSpace(context, 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 16),
                          vertical: rh(context, 8),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(rw(context, 30)),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ID: ',
                              style: TextStyle(
                                fontSize: rfs(context, 13),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              widget.visitorId,
                              style: TextStyle(
                                fontSize: rfs(context, 13),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      vSpace(context, 24),
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
                  height: rh(context, 50),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005596),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rw(context, 14)),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: rfs(context, 16),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
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

