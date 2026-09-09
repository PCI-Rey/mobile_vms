import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/helper/responsive_helper.dart';

class AccessPassModal {
  static void show(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: rw(ctx, 28),
            vertical: rh(ctx, 24),
          ),
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pass Card Container
              _BankIndonesiaPassCard(item: item),
              vSpace(ctx, 16),
              // Close button
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  padding: EdgeInsets.all(rw(ctx, 8)),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: rw(ctx, 24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BankIndonesiaPassCard extends StatelessWidget {
  final dynamic item;

  const _BankIndonesiaPassCard({required this.item});

  @override
  Widget build(BuildContext context) {
    // Resolve QR Code data (strictly invitation code)
    final String qrData = () {
      if (item.invitationCode != null &&
          item.invitationCode.toString().trim().isNotEmpty) {
        return item.invitationCode.toString().trim();
      }
      if (item.initialTrxCode != null &&
          item.initialTrxCode.toString().trim().isNotEmpty) {
        return item.initialTrxCode.toString().trim();
      }
      return '-';
    }();

    // Resolve Invitation Code
    final String invitationCode = () {
      if (item.invitationCode != null &&
          item.invitationCode.toString().trim().isNotEmpty) {
        return item.invitationCode.toString().trim();
      }
      return '-';
    }();

    // Resolve Parking Slot
    final String parkingSlot = () {
      if (item.parkingSlot != null &&
          item.parkingSlot.toString().trim().isNotEmpty) {
        return item.parkingSlot.toString().trim();
      }
      if (item.parkingArea != null &&
          item.parkingArea.toString().trim().isNotEmpty) {
        return item.parkingArea.toString().trim();
      }
      return '-';
    }();

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: rw(context, 340)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: rw(context, 28),
            offset: Offset(0, rh(context, 10)),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rw(context, 26)),
        child: Stack(
          children: [
            // Corner Wave Accents
            Positioned.fill(
              child: CustomPaint(
                painter: _CardCornerAccentPainter(),
              ),
            ),

            // Card Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 20),
                vertical: rh(context, 24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  vSpace(context, 6),

                  // ── 1. BI Logo ──────────────────────────────────────
                  Container(
                    width: rw(context, 66),
                    height: rw(context, 66),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/bi_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  vSpace(context, 10),

                  // ── 2. "BANK INDONESIA" Title ──────────────────────
                  Text(
                    'BANK INDONESIA',
                    style: TextStyle(
                      color: const Color(0xFF0D3B66),
                      fontSize: rfs(context, 16),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  vSpace(context, 18),

                  // ── 3. QR Code Container ───────────────────────────
                  Container(
                    padding: EdgeInsets.all(rw(context, 12)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(rw(context, 20)),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: rw(context, 10),
                          offset: Offset(0, rh(context, 4)),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: rw(context, 160),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  vSpace(context, 22),

                  // ── 4. Invitation Code ─────────────────────────────
                  Text(
                    'INVITATION CODE',
                    style: TextStyle(
                      color: const Color(0xFF8C9BAE),
                      fontSize: rfs(context, 11),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                  vSpace(context, 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: rh(context, 11)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF5FF),
                      borderRadius: BorderRadius.circular(rw(context, 14)),
                    ),
                    child: Center(
                      child: Text(
                        invitationCode,
                        style: TextStyle(
                          color: const Color(0xFF1E3A8A),
                          fontSize: rfs(context, 17),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                  vSpace(context, 14),

                  // ── 5. Parking Slot ────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 16),
                      vertical: rh(context, 12),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8F0),
                      borderRadius: BorderRadius.circular(rw(context, 16)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: rw(context, 44),
                          height: rw(context, 44),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD4F3E1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.directions_car_rounded,
                            color: const Color(0xFF169B4B),
                            size: rw(context, 24),
                          ),
                        ),
                        hSpace(context, 14),
                        Container(
                          width: 1.2,
                          height: rh(context, 32),
                          color: const Color(0xFFBFE7CE),
                        ),
                        hSpace(context, 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'PARKING SLOT',
                                style: TextStyle(
                                  fontSize: rfs(context, 10),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF5B8A6E),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              vSpace(context, 2),
                              Text(
                                parkingSlot,
                                style: TextStyle(
                                  fontSize: rfs(context, 22),
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF169B4B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  vSpace(context, 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the top-left and bottom-right corner wave accents
class _CardCornerAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final darkBluePaint = Paint()
      ..color = const Color(0xFF1565C0)
      ..style = PaintingStyle.fill;
    final lightBluePaint = Paint()
      ..color = const Color(0xFF64B5F6)
      ..style = PaintingStyle.fill;

    // ── Top-Left Wave Accents ──
    // Light blue under-layer
    final tlLight = Path();
    tlLight.moveTo(0, size.height * 0.15);
    tlLight.quadraticBezierTo(
      size.width * 0.18,
      size.height * 0.09,
      size.width * 0.28,
      0,
    );
    tlLight.lineTo(0, 0);
    tlLight.close();
    canvas.drawPath(tlLight, lightBluePaint);

    // Dark blue top-layer
    final tlDark = Path();
    tlDark.moveTo(0, size.height * 0.11);
    tlDark.quadraticBezierTo(
      size.width * 0.14,
      size.height * 0.06,
      size.width * 0.22,
      0,
    );
    tlDark.lineTo(0, 0);
    tlDark.close();
    canvas.drawPath(tlDark, darkBluePaint);

    // ── Bottom-Right Wave Accents ──
    // Light blue under-layer
    final brLight = Path();
    brLight.moveTo(size.width, size.height * 0.85);
    brLight.quadraticBezierTo(
      size.width * 0.82,
      size.height * 0.91,
      size.width * 0.72,
      size.height,
    );
    brLight.lineTo(size.width, size.height);
    brLight.close();
    canvas.drawPath(brLight, lightBluePaint);

    // Dark blue top-layer
    final brDark = Path();
    brDark.moveTo(size.width, size.height * 0.89);
    brDark.quadraticBezierTo(
      size.width * 0.86,
      size.height * 0.94,
      size.width * 0.78,
      size.height,
    );
    brDark.lineTo(size.width, size.height);
    brDark.close();
    canvas.drawPath(brDark, darkBluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
