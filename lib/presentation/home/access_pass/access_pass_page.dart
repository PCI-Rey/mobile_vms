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
    final double topPadding = MediaQuery.of(context).padding.top;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: GestureDetector(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.only(top: topPadding + 60),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(rw(context, 28)),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(rw(context, 28)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Padding(
                      padding: EdgeInsets.only(top: rh(context, 12)),
                      child: Container(
                        width: rw(context, 40),
                        height: rh(context, 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(rw(context, 2)),
                        ),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 20),
                        vertical: rh(context, 14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(rw(context, 10)),
                            decoration: BoxDecoration(
                              color: const Color(0xFF005596).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(rw(context, 10)),
                            ),
                            child: const Icon(
                              Icons.badge_outlined,
                              color: Color(0xFF005596),
                            ),
                          ),
                          hSpace(context, 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Your Access Pass',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: rfs(context, 16),
                                    color: Colors.black87,
                                  ),
                                ),
                                vSpace(context, 2),
                                Text(
                                  'Show this pass at the gate',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: rfs(context, 13),
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1, color: Colors.grey.shade100),

                    // Content - Scrollable Body
                    Flexible(
                      child: SingleChildScrollView(
                        child: RepaintBoundary(
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

                                // QR Access Pass Card Container
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(rw(context, 16)),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(rw(context, 16)),
                                    border: Border.all(color: Colors.grey.shade200),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Access Pass Title (Centered)
                                      Center(
                                        child: Text(
                                          'Access Pass',
                                          style: TextStyle(
                                            fontSize: rfs(context, 18),
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      vSpace(context, 12),

                                      // QR Code Box (Enlarged)
                                      Container(
                                        width: rw(context, 195),
                                        height: rw(context, 195),
                                        padding: EdgeInsets.all(rw(context, 10)),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(rw(context, 10)),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: _buildQRCodePlaceholder(),
                                      ),
                                      vSpace(context, 12),

                                      // Tracked / Low Battery Row (Centered)
                                      if (widget.isTracked || widget.isLowBattery) ...[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (widget.isTracked)
                                              Text(
                                                'Tracked',
                                                style: TextStyle(
                                                  color: Colors.red.shade600,
                                                  fontSize: rfs(context, 11),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            if (widget.isTracked && widget.isLowBattery)
                                              hSpace(context, 16),
                                            if (widget.isLowBattery)
                                              Text(
                                                'Low Battery',
                                                style: TextStyle(
                                                  color: Colors.red.shade600,
                                                  fontSize: rfs(context, 11),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ],
                                        ),
                                        vSpace(context, 10),
                                      ],

                                      // Show this while visiting
                                      Text(
                                        'Show this while visiting',
                                        style: TextStyle(
                                          fontSize: rfs(context, 12),
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      vSpace(context, 2),

                                      // ID
                                      Text(
                                        'ID : ${widget.visitorId.isNotEmpty ? widget.visitorId : '-'}',
                                        style: TextStyle(
                                          fontSize: rfs(context, 13),
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black87,
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
                      ),
                    ),

                    // Close button (Unified Blue color)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        rw(context, 24),
                        rh(context, 8),
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

// Helper function to show the access pass bottom sheet
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
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
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

