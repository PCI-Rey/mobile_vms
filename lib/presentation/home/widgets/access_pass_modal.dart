import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
      builder: (ctx) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: _bgPage,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(rw(context, 28)),
            ),
          ),
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
                  rh(ctx, 40),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_blue, _blueDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(rw(ctx, 24)),
                  ),
                  child: Column(
                    children: [
                      // Top name + status
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          rw(ctx, 20),
                          rh(ctx, 20),
                          rw(ctx, 20),
                          rh(ctx, 16),
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
                                      color: Colors.white60,
                                      fontSize: rfs(ctx, 11),
                                    ),
                                  ),
                                  vSpace(ctx, 4),
                                  Text(
                                    (item.visitorName as String).isNotEmpty
                                        ? item.visitorName
                                        : UserController.to.fullName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: rfs(ctx, 22),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    item.sitePlaceName,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: rfs(ctx, 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            hSpace(ctx, 16),
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
                              size: rw(ctx, 64),
                              borderWidth: 2,
                            ),
                            hSpace(ctx, 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: rw(ctx, 10),
                                vertical: rh(ctx, 5),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  rw(ctx, 20),
                                ),
                              ),
                              child: Text(
                                item.visitorStatus,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: rfs(ctx, 11),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Barcode card
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: rw(ctx, 20)),
                        padding: EdgeInsets.all(rw(ctx, 16)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(rw(ctx, 16)),
                        ),
                        child: Column(
                          children: [
                            QrImageView(
                              data: item.visitorNumber,
                              version: QrVersions.auto,
                              size: rw(ctx, 240),
                            ),
                            vSpace(ctx, 12),
                            Text(
                              item.visitorNumber,
                              style: TextStyle(
                                fontSize: rfs(ctx, 18),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                                letterSpacing: 2,
                              ),
                            ),
                            vSpace(ctx, 4),
                            Text(
                              'Tunjukkan kode ini ke petugas',
                              style: TextStyle(
                                fontSize: rfs(ctx, 11),
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      vSpace(ctx, 16),

                      // Info tiles
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          rw(ctx, 20),
                          0,
                          rw(ctx, 20),
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
                            vSpace(ctx, 8),
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
                                hSpace(ctx, 8),
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
                            vSpace(ctx, 8),
                            AccessPassModal.buildInfoTile(
                              ctx,
                              Icons.calendar_today_outlined,
                              'Visit Period',
                              '$startStr\n$endStr',
                            ),
                            if (item.isDriving) ...[
                              vSpace(ctx, 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: AccessPassModal.buildInfoTile(
                                      ctx,
                                      Icons.location_on_outlined,
                                      'Area',
                                      item.parkingArea,
                                    ),
                                  ),
                                  hSpace(ctx, 8),
                                  Expanded(
                                    child: AccessPassModal.buildInfoTile(
                                      ctx,
                                      Icons.local_parking_outlined,
                                      'Slot',
                                      item.parkingSlot,
                                    ),
                                  ),
                                  hSpace(ctx, 8),
                                  Expanded(
                                    child: AccessPassModal.buildInfoTile(
                                      ctx,
                                      Icons.directions_car_outlined,
                                      'Plate',
                                      item.vehiclePlateNumber,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      vSpace(ctx, rh(ctx, 24)),
                    ],
                  ),
                ),
              ),

              // ── Bottom Close Button ────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  rw(ctx, 16),
                  0,
                  rw(ctx, 16),
                  rh(ctx, 20),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: rh(ctx, 52),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(rw(ctx, 14)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(
                      'CLOSE',
                      style: TextStyle(
                        fontSize: rfs(ctx, 14),
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
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rw(context, 12)),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: rfs(context, 11), color: Colors.white60),
              hSpace(context, 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: rfs(context, 9),
                  color: Colors.white60,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
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
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
