import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/helper/responsive_helper.dart';
import '../controllers/guest_home_controller.dart';
import '../../parking/as_guest/parking_map_webview_page.dart';

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
            horizontal: rw(ctx, 16),
            vertical: rh(ctx, 16),
          ),
          elevation: 0,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.92,
              maxWidth: rw(ctx, 360),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Top Check In & Check Out Row ──────────────────
                  CheckStatusRow(item: item),
                  vSpace(ctx, 10),

                  // ── Main Visitor Code Card ────────────────────────
                  WebVisitorCodeCard(item: item),
                  vSpace(ctx, 14),

                  // ── Close button ──────────────────────────────────
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
            ),
          ),
        );
      },
    );
  }
}

class CheckStatusRow extends StatelessWidget {
  final dynamic item;

  const CheckStatusRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    // Check In info
    final String checkinTimeStr = () {
      if (item.checkinAt != null) {
        return dateFormat.format(item.checkinAt);
      }
      return '-';
    }();
    final String checkinByStr = (item.checkinBy != null &&
            item.checkinBy.toString().trim().isNotEmpty)
        ? item.checkinBy.toString().trim()
        : '-';

    // Check Out info
    final String checkoutTimeStr = () {
      if (item.checkoutAt != null) {
        return dateFormat.format(item.checkoutAt);
      }
      return '-';
    }();
    final String checkoutByStr = (item.checkoutBy != null &&
            item.checkoutBy.toString().trim().isNotEmpty)
        ? item.checkoutBy.toString().trim()
        : '-';

    return Row(
      children: [
        // ── Check In Card (Clean White Card with Emerald Accent) ─
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 12),
              vertical: rh(context, 8),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(rw(context, 12)),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: rw(context, 8),
                  offset: Offset(0, rh(context, 2)),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(rw(context, 3)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(rw(context, 5)),
                      ),
                      child: Icon(
                        Icons.login_rounded,
                        color: const Color(0xFF16A34A),
                        size: rw(context, 12),
                      ),
                    ),
                    hSpace(context, 6),
                    Text(
                      'Check In',
                      style: TextStyle(
                        fontSize: rfs(context, 11.5),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
                vSpace(context, 5),
                Text(
                  'Check In At',
                  style: TextStyle(
                    fontSize: rfs(context, 9),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  checkinTimeStr,
                  style: TextStyle(
                    fontSize: rfs(context, 10.5),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                vSpace(context, 2),
                Text(
                  'Check In By',
                  style: TextStyle(
                    fontSize: rfs(context, 9),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  checkinByStr,
                  style: TextStyle(
                    fontSize: rfs(context, 10.5),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        hSpace(context, 8),

        // ── Check Out Card (Clean White Card with Rose Accent) ───
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 12),
              vertical: rh(context, 8),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(rw(context, 12)),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: rw(context, 8),
                  offset: Offset(0, rh(context, 2)),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(rw(context, 3)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(rw(context, 5)),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: const Color(0xFFE11D48),
                        size: rw(context, 12),
                      ),
                    ),
                    hSpace(context, 6),
                    Text(
                      'Check Out',
                      style: TextStyle(
                        fontSize: rfs(context, 11.5),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFBE123C),
                      ),
                    ),
                  ],
                ),
                vSpace(context, 5),
                Text(
                  'Check Out At',
                  style: TextStyle(
                    fontSize: rfs(context, 9),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  checkoutTimeStr,
                  style: TextStyle(
                    fontSize: rfs(context, 10.5),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                vSpace(context, 2),
                Text(
                  'Check Out By',
                  style: TextStyle(
                    fontSize: rfs(context, 9),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  checkoutByStr,
                  style: TextStyle(
                    fontSize: rfs(context, 10.5),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WebVisitorCodeCard extends StatefulWidget {
  final dynamic item;

  const WebVisitorCodeCard({super.key, required this.item});

  @override
  State<WebVisitorCodeCard> createState() => _WebVisitorCodeCardState();
}

class _WebVisitorCodeCardState extends State<WebVisitorCodeCard> {
  bool _isOpeningBlocker = false;
  final GlobalKey _cardRepaintKey = GlobalKey();

  String get qrData {
    if (widget.item.invitationCode != null &&
        widget.item.invitationCode.toString().trim().isNotEmpty) {
      return widget.item.invitationCode.toString().trim();
    }
    if (widget.item.initialTrxCode != null &&
        widget.item.initialTrxCode.toString().trim().isNotEmpty) {
      return widget.item.initialTrxCode.toString().trim();
    }
    return '-';
  }

  String get invitationCode {
    if (widget.item.invitationCode != null &&
        widget.item.invitationCode.toString().trim().isNotEmpty) {
      return widget.item.invitationCode.toString().trim();
    }
    return '-';
  }

  String get visitorIdDisplay {
    if (widget.item.visitorNumber != null &&
        widget.item.visitorNumber.toString().trim().isNotEmpty) {
      return widget.item.visitorNumber.toString().trim();
    }
    if (widget.item.visitorCode != null &&
        widget.item.visitorCode.toString().trim().isNotEmpty) {
      return widget.item.visitorCode.toString().trim();
    }
    final rawId = widget.item.id.toString();
    return rawId.length > 10 ? rawId.substring(0, 10) : rawId;
  }

  String get agenda {
    if (widget.item.agenda != null &&
        widget.item.agenda.toString().trim().isNotEmpty) {
      return widget.item.agenda.toString().trim();
    }
    return 'Agenda Visitor';
  }

  String get hostName {
    if (widget.item.hostName != null &&
        widget.item.hostName.toString().trim().isNotEmpty) {
      return widget.item.hostName.toString().trim();
    }
    if (widget.item.host != null &&
        widget.item.host.toString().trim().isNotEmpty) {
      return widget.item.host.toString().trim();
    }
    return '-';
  }

  String get groupName {
    if (widget.item.groupName != null &&
        widget.item.groupName.toString().trim().isNotEmpty) {
      return widget.item.groupName.toString().trim();
    }
    return widget.item.isGroup == true ? 'Group' : '-';
  }

  String get statusText {
    if (widget.item.visitorStatus != null &&
        widget.item.visitorStatus.toString().trim().isNotEmpty) {
      return widget.item.visitorStatus.toString().trim();
    }
    return 'Preregis';
  }

  String get siteName {
    if (widget.item.sitePlaceName != null &&
        widget.item.sitePlaceName.toString().trim().isNotEmpty) {
      return widget.item.sitePlaceName.toString().trim();
    }
    return 'Gedung SINERGI';
  }

  String get parkingArea {
    if (widget.item.parkingArea != null &&
        widget.item.parkingArea.toString().trim().isNotEmpty) {
      return widget.item.parkingArea.toString().trim();
    }
    return 'AREA PARKIR';
  }

  String get parkingSlot {
    if (widget.item.parkingSlot != null &&
        widget.item.parkingSlot.toString().trim().isNotEmpty) {
      return widget.item.parkingSlot.toString().trim();
    }
    return '-';
  }

  String get vehiclePlate {
    if (widget.item.vehiclePlateNumber != null &&
        widget.item.vehiclePlateNumber.toString().trim().isNotEmpty) {
      return widget.item.vehiclePlateNumber.toString().trim();
    }
    return '-';
  }

  String get vehicleType {
    if (widget.item.vehicleType != null &&
        widget.item.vehicleType.toString().trim().isNotEmpty) {
      final t = widget.item.vehicleType.toString().trim();
      return t[0].toUpperCase() + t.substring(1).toLowerCase();
    }
    return 'Car';
  }

  void _copyInvitationCode() {
    Clipboard.setData(ClipboardData(text: invitationCode));
    Get.snackbar(
      'Copied',
      'Invitation Code copied to clipboard',
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
    );
  }

  Future<void> _downloadCard() async {
    try {
      final boundary = _cardRepaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        _copyInvitationCode();
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _copyInvitationCode();
        return;
      }
      final pngBytes = byteData.buffer.asUint8List();

      final code = invitationCode.isNotEmpty && invitationCode != '-'
          ? invitationCode
          : 'visitor_pass';
      String? path;
      bool saveSuccess = false;

      if (Platform.isAndroid) {
        try {
          final dir = Directory('/storage/emulated/0/Download');
          if (await dir.exists()) {
            final testPath = '${dir.path}/visitor_code_$code.png';
            final file = File(testPath);
            await file.writeAsBytes(pngBytes);
            path = testPath;
            saveSuccess = true;
          }
        } catch (e) {
          debugPrint('Save to Download directory failed: $e');
        }
      }

      if (!saveSuccess) {
        final dir = await getApplicationDocumentsDirectory();
        path = '${dir.path}/visitor_code_$code.png';
        final file = File(path);
        await file.writeAsBytes(pngBytes);
      }

      Get.snackbar(
        'Success',
        'Visitor Card berhasil diunduh!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        mainButton: path != null
            ? TextButton(
                onPressed: () => OpenFilex.open(path!),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'BUKA',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : null,
      );
    } catch (e) {
      debugPrint('Error downloading card: $e');
      _copyInvitationCode();
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rw(context, 16)),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(rw(context, 20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top close X
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(dialogCtx).pop(),
                    child: Container(
                      padding: EdgeInsets.all(rw(context, 2)),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.red.shade400,
                        size: rw(context, 20),
                      ),
                    ),
                  ),
                ],
              ),
              vSpace(context, 4),

              // Question Mark Circle (matches web frame_06)
              Container(
                width: rw(context, 60),
                height: rw(context, 60),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF93C5FD),
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '?',
                    style: TextStyle(
                      fontSize: rfs(context, 32),
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF60A5FA),
                    ),
                  ),
                ),
              ),
              vSpace(context, 16),

              Text(
                'Are you sure to open the parking blocker?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: rfs(context, 14),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              vSpace(context, 22),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: rh(context, 40),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF94A3B8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(rw(context, 6)),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: rfs(context, 13),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  hSpace(context, 12),
                  Expanded(
                    child: SizedBox(
                      height: rh(context, 40),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          _executeOpenParkingBlocker();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(rw(context, 6)),
                          ),
                        ),
                        child: Text(
                          'Yes',
                          style: TextStyle(
                            fontSize: rfs(context, 13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _executeOpenParkingBlocker() async {
    setState(() {
      _isOpeningBlocker = true;
    });

    final String trxVisitorId = () {
      if (widget.item.transactionVisitorId != null &&
          widget.item.transactionVisitorId.toString().trim().isNotEmpty) {
        return widget.item.transactionVisitorId.toString().trim();
      }
      return widget.item.id.toString().trim();
    }();

    final bool success =
        await GuestHomeController.to.openParkingBlockerAction(trxVisitorId);

    if (mounted) {
      setState(() {
        _isOpeningBlocker = false;
      });
    }

    if (success && mounted) {
      // ── Success Dialog (matches web frame_10) ───────────────────
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (successCtx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rw(context, 16)),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 20),
              vertical: rh(context, 24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top close X
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(successCtx).pop(),
                      child: Container(
                        padding: EdgeInsets.all(rw(context, 2)),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.red.shade400,
                          size: rw(context, 20),
                        ),
                      ),
                    ),
                  ],
                ),
                vSpace(context, 4),

                // Green Checkmark Circle
                Container(
                  width: rw(context, 62),
                  height: rw(context, 62),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF86EFAC),
                      width: 2.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: const Color(0xFF22C55E),
                      size: rw(context, 36),
                    ),
                  ),
                ),
                vSpace(context, 16),

                Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: rfs(context, 18),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF16A34A),
                  ),
                ),
                vSpace(context, 6),

                Text(
                  'Successfully opened parking blocker.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: rfs(context, 13),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                vSpace(context, 18),

                SizedBox(
                  width: double.infinity,
                  height: rh(context, 40),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(successCtx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rw(context, 8)),
                      ),
                    ),
                    child: Text(
                      'View Parking Location',
                      style: TextStyle(
                        fontSize: rfs(context, 13),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Navigate immediately to 2D Map Page
      if (mounted) {
        final String? mapUrl = () {
          try {
            final pm = widget.item.parkingMap?.toString().trim();
            if (pm != null && pm.isNotEmpty && pm != 'null' && pm != '-') {
              return pm;
            }
          } catch (_) {}
          return null;
        }();
        Get.to(() => ParkingMapWebViewPage(
              item: widget.item,
              customUrl: mapUrl,
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');

    final String visitStartStr = widget.item.visitorPeriodStart != null
        ? dateFormat.format(widget.item.visitorPeriodStart)
        : '-';
    final String visitEndStr = widget.item.visitorPeriodEnd != null
        ? dateFormat.format(widget.item.visitorPeriodEnd)
        : '-';

    return RepaintBoundary(
      key: _cardRepaintKey,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: rw(context, 16),
              offset: Offset(0, rh(context, 4)),
            ),
          ],
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rw(context, 16),
            vertical: rh(context, 14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── 1. Header: Bank Indonesia Logo + Download Icon (Right Aligned) ──
              SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Logo BI Centered
                    Image.asset(
                      'assets/images/bi_logo.png',
                      width: rw(context, 44),
                      height: rw(context, 44),
                      fit: BoxFit.contain,
                    ),
                    // Tombol download di sebelah kanan dan sejajar dengan logo BI
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: _downloadCard,
                        child: Container(
                          width: rw(context, 38),
                          height: rw(context, 38),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F1FB),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFCCE0F5),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF005596)
                                    .withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.download_rounded,
                            size: rw(context, 20),
                            color: const Color(0xFF005596),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              vSpace(context, 6),
              Text(
                'Visitor Code',
                style: TextStyle(
                  fontSize: rfs(context, 16),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),

              vSpace(context, 10),

              // ── 2. Information 2-Column Grid ────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Agenda, Host Name, Visit Start, Visit End (Centered)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildInfoField(context, 'Agenda', agenda),
                        vSpace(context, 6),
                        _buildInfoField(context, 'Host Name', hostName),
                        vSpace(context, 6),
                        _buildInfoField(context, 'Visit Start', visitStartStr),
                        vSpace(context, 6),
                        _buildInfoField(context, 'Visit End', visitEndStr),
                      ],
                    ),
                  ),
                  hSpace(context, 12),

                  // Right Column: Group Name, Status, Site (Centered)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildInfoField(context, 'Group Name', groupName),
                        vSpace(context, 6),
                        _buildStatusField(context, 'Status', statusText),
                        vSpace(context, 6),
                        _buildInfoField(context, 'Site', siteName),
                      ],
                    ),
                  ),
                ],
              ),

              vSpace(context, 10),

              // ── 3. QR Code Box ──────────────────────────────────────
              Container(
                padding: EdgeInsets.all(rw(context, 8)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rw(context, 12)),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: rw(context, 8),
                      offset: Offset(0, rh(context, 2)),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: rw(context, 130),
                  padding: EdgeInsets.zero,
                ),
              ),

              vSpace(context, 8),

              // ── 4. Invitation Code + Copy Icon + ID ─────────────────
              Text(
                'Invitation Code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: rfs(context, 10),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              vSpace(context, 2),
              GestureDetector(
                onTap: _copyInvitationCode,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      invitationCode,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: rfs(context, 14.5),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E3A8A),
                        letterSpacing: 0.8,
                      ),
                    ),
                    hSpace(context, 6),
                    Icon(
                      Icons.copy_rounded,
                      size: rw(context, 14),
                      color: const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
              vSpace(context, 2),
              Text(
                'ID: $visitorIdDisplay',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: rfs(context, 9.5),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),

              vSpace(context, 10),

              // ── 5. Divider: Parking & Facilities ────────────────────
              Row(
                children: [
                  const Expanded(
                    child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rw(context, 10)),
                    child: Text(
                      'Parking & Facilities',
                      style: TextStyle(
                        fontSize: rfs(context, 10.5),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                  ),
                ],
              ),

              vSpace(context, 8),

              // ── 6. Parking Grid (2x2) ───────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:
                        _buildInfoField(context, 'Parking Area', parkingArea),
                  ),
                  hSpace(context, 12),
                  Expanded(
                    child:
                        _buildInfoField(context, 'Parking Slot', parkingSlot),
                  ),
                ],
              ),
              vSpace(context, 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:
                        _buildInfoField(context, 'Vehicle Plate', vehiclePlate),
                  ),
                  hSpace(context, 12),
                  Expanded(
                    child:
                        _buildInfoField(context, 'Vehicle Type', vehicleType),
                  ),
                ],
              ),

              vSpace(context, 12),

              // ── 7. Open Parking Blocker Button ──────────────────────
              SizedBox(
                width: double.infinity,
                height: rh(context, 44),
                child: ElevatedButton(
                  onPressed: _isOpeningBlocker ? null : _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3B74),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF94A3B8),
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rw(context, 10)),
                    ),
                  ),
                  child: _isOpeningBlocker
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: rw(context, 16),
                              height: rw(context, 16),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            hSpace(context, 8),
                            Text(
                              'Opening...',
                              style: TextStyle(
                                fontSize: rfs(context, 13),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_car_filled_rounded,
                              size: rw(context, 18),
                              color: Colors.white,
                            ),
                            hSpace(context, 8),
                            Text(
                              'Open Parking Blocker',
                              style: TextStyle(
                                fontSize: rfs(context, 13.5),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: rfs(context, 9.5),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        vSpace(context, 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: rfs(context, 11.5),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusField(BuildContext context, String label, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: rfs(context, 9.5),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        vSpace(context, 2),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: rw(context, 10),
            vertical: rh(context, 2.5),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(rw(context, 6)),
          ),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rfs(context, 10.5),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}
