import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:get/get.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../auth/controller/user_controller.dart';
import '../../../core/components/custom_circle_image.dart';
import '../../../core/gen/assets.gen.dart';

class AccessPassModal {
  static const _blue = Color(0xFF1976D2);
  static const _blueDark = Color(0xFF0E5DB5);
  static const _bgPage = Color(0xFFF4F7FB);

  static void show(BuildContext context, dynamic item) {
    final startStr = DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id').format(
      item.visitorPeriodStart,
    );
    final endStr = DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id').format(
      item.visitorPeriodEnd,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final double topPadding = MediaQuery.of(ctx).padding.top;
        return Padding(
          padding: EdgeInsets.only(top: topPadding + 16),
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
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
              // ── Fixed handle + title ──────────────────────────
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rw(ctx, 20)),
                child: Row(
                  children: [
                    Text(
                      'Guest Pass',
                      style: TextStyle(
                        fontSize: rfs(ctx, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              vSpace(ctx, 16),

              // ── Pass Content ───────────────────────────────
              Padding(
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
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: rw(ctx, 12),
                        offset: Offset(0, rh(ctx, 6)),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // Top name + status
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          rw(ctx, 16),
                          rh(ctx, 12),
                          rw(ctx, 16),
                          rh(ctx, 10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'VMS',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: rfs(ctx, 10),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  vSpace(ctx, 2),
                                  Text(
                                    (item.visitorName as String).isNotEmpty
                                        ? item.visitorName
                                        : UserController.to.fullName,
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: rfs(ctx, 18),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    item.sitePlaceName,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: rfs(ctx, 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            hSpace(ctx, 12),
                            CustomCircleImage(
                              image: UserController.to.faceUrl != null
                                  ? Image.network(
                                      UserController.to.faceUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Assets
                                          .images
                                          .avaPerson1
                                          .image(fit: BoxFit.cover),
                                    )
                                  : Assets.images.avaPerson1.image(
                                      fit: BoxFit.cover,
                                    ),
                              size: rw(ctx, 48),
                              borderWidth: 1.5,
                            ),
                            hSpace(ctx, 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: rw(ctx, 8),
                                vertical: rh(ctx, 3),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(
                                  rw(ctx, 20),
                                ),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                item.visitorStatus,
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: rfs(ctx, 10),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Barcode card
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: rw(ctx, 16)),
                        padding: EdgeInsets.all(rw(ctx, 10)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(rw(ctx, 12)),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            QrImageView(
                              data: item.visitorNumber,
                              version: QrVersions.auto,
                              size: rw(ctx, 150),
                            ),
                            vSpace(ctx, 6),
                            Text(
                              item.visitorNumber,
                              style: TextStyle(
                                fontSize: rfs(ctx, 15),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                                letterSpacing: 1.5,
                              ),
                            ),
                            vSpace(ctx, 2),
                            Text(
                              'Tunjukkan kode ini ke petugas',
                              style: TextStyle(
                                fontSize: rfs(ctx, 10),
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      vSpace(ctx, 10),

                      // Info tiles
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          rw(ctx, 16),
                          0,
                          rw(ctx, 16),
                          0,
                        ),
                        child: Column(
                          children: [
                            AccessPassModal.buildInfoTile(
                              ctx,
                              Icons.vpn_key_outlined,
                              'Invitation Code',
                              item.invitationCode,
                            ),
                            vSpace(ctx, 6),
                            Row(
                              children: [
                                Expanded(
                                  child: AccessPassModal.buildInfoTile(
                                    ctx,
                                    Icons.person_outline,
                                    'Host',
                                    item.hostName,
                                  ),
                                ),
                                hSpace(ctx, 6),
                                Expanded(
                                  child: AccessPassModal.buildInfoTile(
                                    ctx,
                                    Icons.event_note_outlined,
                                    'Agenda',
                                    item.agenda,
                                  ),
                                ),
                              ],
                            ),
                            vSpace(ctx, 6),
                            AccessPassModal.buildInfoTile(
                              ctx,
                              Icons.calendar_today_outlined,
                              'Visit Period',
                              '$startStr\n$endStr',
                            ),
                            vSpace(ctx, 6),
                            Row(
                              children: [
                                Expanded(
                                  child: AccessPassModal.buildInfoTile(
                                    ctx,
                                    Icons.local_parking_outlined,
                                    'Parking Area',
                                    item.parkingArea.isEmpty || item.parkingArea.toLowerCase() == 'not available'
                                        ? 'Not available'
                                        : item.parkingArea,
                                  ),
                                ),
                                hSpace(ctx, 6),
                                Expanded(
                                  child: AccessPassModal.buildInfoTile(
                                    ctx,
                                    Icons.crop_free_outlined,
                                    'Parking Slot',
                                    item.parkingSlot.isEmpty || item.parkingSlot.toLowerCase() == 'not available'
                                        ? 'Not available'
                                        : item.parkingSlot,
                                  ),
                                ),
                              ],
                            ),
                            vSpace(ctx, 6),
                            Row(
                              children: [
                                Expanded(
                                  child: AccessPassModal.buildInfoTile(
                                    ctx,
                                    Icons.directions_car_outlined,
                                    'Vehicle Type',
                                    (() {
                                      final type = item.vehicleType;
                                      if (type.isEmpty || type.toLowerCase() == 'not available') return 'Not available';
                                      final cleaned = type.replaceAll('vehicle_', '').replaceAll('_', ' ');
                                      return cleaned.split(' ').map((word) {
                                        if (word.isEmpty) return '';
                                        return word[0].toUpperCase() + word.substring(1);
                                      }).join(' ');
                                    })(),
                                  ),
                                ),
                                hSpace(ctx, 6),
                                Expanded(
                                  child: AccessPassModal.buildInfoTile(
                                    ctx,
                                    Icons.badge_outlined,
                                    'Plate Number',
                                    item.vehiclePlateNumber.isEmpty || item.vehiclePlateNumber.toLowerCase() == 'not available'
                                        ? 'Not available'
                                        : item.vehiclePlateNumber,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      vSpace(ctx, rh(ctx, 16)),
                    ],
                  ),
                ),
              ),

              // ── Open Parking Blocker Button ────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  rw(ctx, 16),
                  0,
                  rw(ctx, 16),
                  rh(ctx, 8),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: rh(ctx, 46),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'Success',
                        'Parking blocker opened successfully',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    icon: const Icon(Icons.local_parking, color: Colors.white, size: 20),
                    label: Text(
                      'Open Parking Blocker',
                      style: TextStyle(
                        fontSize: rfs(ctx, 13),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2), // Accent Blue
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rw(ctx, 12)),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Bottom Close Button ────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  rw(ctx, 16),
                  0,
                  rw(ctx, 16),
                  rh(ctx, 12),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: rh(ctx, 46),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rw(ctx, 12)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(
                      'CLOSE',
                      style: TextStyle(
                        fontSize: rfs(ctx, 13),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              vSpace(ctx, rh(ctx, 12)),
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

  static Widget buildInfoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 12),
        vertical: rh(context, 10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Slate 100
        borderRadius: BorderRadius.circular(rw(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: rfs(context, 11), color: Colors.grey.shade600),
              hSpace(context, 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: rfs(context, 9),
                  color: Colors.grey.shade600,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          vSpace(context, 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rfs(context, 14),
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
