import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:get/get.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../auth/controller/user_controller.dart';
import '../../../core/components/custom_circle_image.dart';
import '../../../core/gen/assets.gen.dart';

class AccessPassModal {
  static const _bgPage = Color(0xFFF4F7FB);
  static const _primaryBlue = Color(0xFF1976D2);
  static const _darkBlue = Color(0xFF0D47A1);

  static void show(BuildContext context, dynamic item) {
    final startStr = DateFormat(
      'EEEE, dd MMMM yyyy, HH:mm',
      'en',
    ).format(item.visitorPeriodStart);
    final endStr = DateFormat(
      'EEEE, dd MMMM yyyy, HH:mm',
      'en',
    ).format(item.visitorPeriodEnd);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (ctx) {
        final double topPadding = MediaQuery.of(ctx).padding.top;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(ctx),
          child: GestureDetector(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.only(top: topPadding + 120),
              child: Container(
            decoration: BoxDecoration(
              color: _bgPage,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(rw(context, 28)),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(rw(context, 28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Handle ─────────────────────────────────────────
                  vSpace(ctx, 12),
                  Center(
                    child: Container(
                      width: rw(ctx, 40),
                      height: rh(ctx, 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(rw(ctx, 2)),
                      ),
                    ),
                  ),
                  vSpace(ctx, 12),

                  // ── Title Row ─────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rw(ctx, 20)),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(rw(ctx, 7)),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_primaryBlue, _darkBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(rw(ctx, 8)),
                          ),
                          child: Icon(
                            Icons.badge_outlined,
                            color: Colors.white,
                            size: rw(ctx, 16),
                          ),
                        ),
                        hSpace(ctx, 10),
                        Text(
                          'Guest Pass',
                          style: TextStyle(
                            fontSize: rfs(ctx, 20),
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: EdgeInsets.all(rw(ctx, 6)),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.grey.shade600,
                              size: rw(ctx, 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  vSpace(ctx, 16),

                  // ── Scrollable Pass Content ─────────────────────
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          rw(ctx, 16),
                          0,
                          rw(ctx, 16),
                          rh(ctx, 12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(rw(ctx, 20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: rw(ctx, 16),
                                offset: Offset(0, rh(ctx, 6)),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            children: [
                              // ── Gradient Header: Name + Status ──
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1976D2),
                                      Color(0xFF0D47A1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(rw(ctx, 20)),
                                    topRight: Radius.circular(rw(ctx, 20)),
                                  ),
                                ),
                                padding: EdgeInsets.fromLTRB(
                                  rw(ctx, 18),
                                  rh(ctx, 16),
                                  rw(ctx, 18),
                                  rh(ctx, 16),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: rw(ctx, 8),
                                              vertical: rh(ctx, 3),
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    rw(ctx, 20),
                                                  ),
                                            ),
                                            child: Text(
                                              'VMS',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: rfs(ctx, 10),
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ),
                                          vSpace(ctx, 6),
                                          Text(
                                            (item.visitorName as String)
                                                    .isNotEmpty
                                                ? item.visitorName
                                                : UserController.to.fullName,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: rfs(ctx, 22),
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          vSpace(ctx, 4),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.location_on_outlined,
                                                size: rw(ctx, 15),
                                                color: Colors.white60,
                                              ),
                                              hSpace(ctx, 4),
                                              Flexible(
                                                child: Text(
                                                  item.sitePlaceName,
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: rfs(ctx, 15),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    hSpace(ctx, 12),
                                    Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                              width: 2.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.2,
                                                ),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: CustomCircleImage(
                                            image: UserController.to.faceUrl !=
                                                        null &&
                                                    UserController.to.faceUrl!
                                                        .isNotEmpty
                                                ? Image.network(
                                                    UserController.to.faceUrl!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, _, _) =>
                                                        Container(
                                                      color: const Color(
                                                        0xFFE2E8F0,
                                                      ),
                                                      child: Icon(
                                                        Icons.person,
                                                        color: const Color(
                                                          0xFF94A3B8,
                                                        ),
                                                        size: rw(ctx, 28),
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    color: const Color(
                                                      0xFFE2E8F0,
                                                    ),
                                                    child: Icon(
                                                      Icons.person,
                                                      color: const Color(
                                                        0xFF94A3B8,
                                                      ),
                                                      size: rw(ctx, 28),
                                                    ),
                                                  ),
                                            size: rw(ctx, 52),
                                            borderWidth: 0,
                                          ),
                                        ),
                                        vSpace(ctx, 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: rw(ctx, 10),
                                            vertical: rh(ctx, 4),
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(
                                                  rw(ctx, 20),
                                                ),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.4,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            item.visitorStatus,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: rfs(ctx, 11),
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // ── Dashed separator ────────────────────
                              Row(
                                children: [
                                  Container(
                                    width: rw(ctx, 16),
                                    height: rh(ctx, 16),
                                    decoration: BoxDecoration(
                                      color: _bgPage,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(rw(ctx, 16)),
                                        bottomRight: Radius.circular(
                                          rw(ctx, 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (ctx, bc) {
                                        final dashW = rw(ctx, 6.0);
                                        final dashSpace = rw(ctx, 4.0);
                                        final count =
                                            (bc.maxWidth / (dashW + dashSpace))
                                                .floor();
                                        return Row(
                                          children: List.generate(
                                            count,
                                            (_) => Container(
                                              width: dashW,
                                              height: rh(ctx, 1.5),
                                              margin: EdgeInsets.only(
                                                right: dashSpace,
                                              ),
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    width: rw(ctx, 16),
                                    height: rh(ctx, 16),
                                    decoration: BoxDecoration(
                                      color: _bgPage,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(rw(ctx, 16)),
                                        bottomLeft: Radius.circular(
                                          rw(ctx, 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // ── QR Code Section ─────────────────────
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  rw(ctx, 24),
                                  rh(ctx, 12),
                                  rw(ctx, 24),
                                  rh(ctx, 6),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(rw(ctx, 16)),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      rw(ctx, 16),
                                    ),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF1976D2,
                                        ).withValues(alpha: 0.06),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // QR code with subtle background
                                      Container(
                                        padding: EdgeInsets.all(rw(ctx, 8)),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            rw(ctx, 10),
                                          ),
                                        ),
                                        child: QrImageView(
                                          data: item.visitorNumber,
                                          version: QrVersions.auto,
                                          size: rw(ctx, 180),
                                        ),
                                      ),
                                      vSpace(ctx, 10),
                                      // Visitor number with prominent styling
                                      Text(
                                        item.visitorNumber,
                                        style: TextStyle(
                                          fontSize: rfs(ctx, 20),
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF1E293B),
                                          letterSpacing: 2.5,
                                        ),
                                      ),
                                      vSpace(ctx, 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: rw(ctx, 11),
                                            color: Colors.grey.shade400,
                                          ),
                                          hSpace(ctx, 4),
                                          Text(
                                            'Show this code to the officer',
                                            style: TextStyle(
                                              fontSize: rfs(ctx, 11),
                                              color: Colors.grey.shade500,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              vSpace(ctx, 12),

                              // ── Info tiles ──────────────────────────
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  rw(ctx, 16),
                                  0,
                                  rw(ctx, 16),
                                  0,
                                ),
                                child: Column(
                                  children: [
                                    // Invitation Code — full width
                                    _buildInfoTile(
                                      ctx,
                                      Icons.vpn_key_outlined,
                                      'Invitation Code',
                                      item.invitationCode,
                                      highlight: true,
                                    ),
                                    vSpace(ctx, 8),

                                    // Host + Agenda
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoTile(
                                            ctx,
                                            Icons.person_outline,
                                            'Host',
                                            item.hostName,
                                          ),
                                        ),
                                        hSpace(ctx, 8),
                                        Expanded(
                                          child: _buildInfoTile(
                                            ctx,
                                            Icons.event_note_outlined,
                                            'Agenda',
                                            item.agenda,
                                          ),
                                        ),
                                      ],
                                    ),
                                    vSpace(ctx, 8),

                                    // Visit Period — full width
                                    _buildInfoTile(
                                      ctx,
                                      Icons.calendar_today_outlined,
                                      'Visit Period',
                                      '$startStr\n$endStr',
                                    ),
                                    vSpace(ctx, 8),

                                    // Parking Area + Parking Slot
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoTile(
                                            ctx,
                                            Icons.local_parking_outlined,
                                            'Parking Area',
                                            item.parkingArea.isEmpty ||
                                                    item.parkingArea
                                                            .toLowerCase() ==
                                                        'not available'
                                                ? 'Not available'
                                                : item.parkingArea,
                                          ),
                                        ),
                                        hSpace(ctx, 8),
                                        Expanded(
                                          child: _buildInfoTile(
                                            ctx,
                                            Icons.crop_free_outlined,
                                            'Parking Slot',
                                            item.parkingSlot.isEmpty ||
                                                    item.parkingSlot
                                                            .toLowerCase() ==
                                                        'not available'
                                                ? 'Not available'
                                                : item.parkingSlot,
                                          ),
                                        ),
                                      ],
                                    ),
                                    vSpace(ctx, 8),

                                    // Vehicle Type + Plate Number
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoTile(
                                            ctx,
                                            Icons.directions_car_outlined,
                                            'Vehicle Type',
                                            (() {
                                              if (!item.isDriving) {
                                                return 'Not Driving';
                                              }
                                              final type = item.vehicleType;
                                              if (type.isEmpty ||
                                                  type.toLowerCase() ==
                                                      'not available') {
                                                return 'Not available';
                                              }
                                              final cleaned = type
                                                  .replaceAll('vehicle_', '')
                                                  .replaceAll('_', ' ');
                                              return cleaned
                                                  .split(' ')
                                                  .map((word) {
                                                    if (word.isEmpty)
                                                      return '';
                                                    return word[0]
                                                            .toUpperCase() +
                                                        word.substring(1);
                                                  })
                                                  .join(' ');
                                            })(),
                                          ),
                                        ),
                                        hSpace(ctx, 8),
                                        Expanded(
                                          child: _buildInfoTile(
                                            ctx,
                                            Icons.badge_outlined,
                                            'Plate Number',
                                            !item.isDriving ||
                                                    item
                                                        .vehiclePlateNumber
                                                        .isEmpty ||
                                                    item.vehiclePlateNumber
                                                            .toLowerCase() ==
                                                        'not available'
                                                ? 'Not available'
                                                : item.vehiclePlateNumber,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              vSpace(ctx, rh(ctx, 20)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Open Parking Blocker Button ──────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      rw(ctx, 16),
                      0,
                      rw(ctx, 16),
                      rh(ctx, 8),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: rh(ctx, 50),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.snackbar(
                            'Success',
                            'Parking blocker opened successfully',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        },
                        icon: const Icon(
                          Icons.local_parking,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          'Open Parking Blocker',
                          style: TextStyle(
                            fontSize: rfs(ctx, 14),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(rw(ctx, 14)),
                          ),
                        ),
                      ),
                    ),
                  ),

                  vSpace(ctx, rh(ctx, 24)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  },
);
  }

  static Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 14),
        vertical: rh(context, 12),
      ),
      decoration: BoxDecoration(
        color: highlight
            ? const Color(0xFFEEF4FF)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(rw(context, 12)),
        border: Border.all(
          color: highlight
              ? const Color(0xFFBDD0F7)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: rfs(context, 14),
                color: highlight
                    ? const Color(0xFF1976D2)
                    : Colors.grey.shade500,
              ),
              hSpace(context, 5),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: rfs(context, 14),
                  color: highlight
                      ? const Color(0xFF1976D2)
                      : Colors.grey.shade500,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          vSpace(context, 6),
          // Value
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rfs(context, 12),
              fontWeight: FontWeight.w800,
              color: highlight
                  ? const Color(0xFF0D47A1)
                  : const Color(0xFF1E293B),
              letterSpacing: highlight ? 1.0 : 0.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Public alias kept for backward compatibility.
  static Widget buildInfoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) =>
      _buildInfoTile(context, icon, label, value);
}
