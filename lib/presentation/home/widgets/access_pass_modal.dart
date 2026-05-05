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

  static void show(BuildContext context, dynamic item, double sw) {
    final startStr = DateFormat(
      'EEE, dd MMM yyyy HH:mm',
    ).format(item.visitorPeriodStart);
    final endStr = DateFormat(
      'EEE, dd MMM yyyy HH:mm',
    ).format(item.visitorPeriodEnd);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: _bgPage,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Fixed handle + title ──────────────────────────
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                child: Row(
                  children: [
                    Text(
                      'Access Pass',
                      style: TextStyle(
                        fontSize: rfs(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Pass Content ───────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  sw * 0.04,
                  0,
                  sw * 0.04,
                  sw * 0.1,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_blue, _blueDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(sw * 0.06),
                  ),
                  child: Column(
                    children: [
                      // Top name + status
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          sw * 0.05,
                          sw * 0.05,
                          sw * 0.05,
                          sw * 0.04,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'VMS · Guest Pass',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: rfs(context, 11),
                                    ),
                                  ),
                                  SizedBox(height: sw * 0.01),
                                  Text(
                                    (item.visitorName as String).isNotEmpty
                                        ? item.visitorName
                                        : UserController.to.fullName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: rfs(context, 20),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    item.sitePlaceName,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: rfs(context, 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: sw * 0.04),
                            CustomCircleImage(
                              image: UserController.to.faceUrl != null
                                  ? Image.network(
                                      UserController.to.faceUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          Assets.images.avaPerson1.image(
                                            fit: BoxFit.cover,
                                          ),
                                    )
                                  : Assets.images.avaPerson1.image(
                                      fit: BoxFit.cover,
                                    ),
                              size: sw * 0.16,
                              borderWidth: 2,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.visitorStatus,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: rfs(context, 11),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Barcode card
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: sw * 0.05),
                        padding: EdgeInsets.all(sw * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(sw * 0.04),
                        ),
                        child: Column(
                          children: [
                            QrImageView(
                              data: item.visitorNumber,
                              version: QrVersions.auto,
                              size: sw * 0.48,
                            ),
                            SizedBox(height: sw * 0.02),
                            Text(
                              item.visitorNumber,
                              style: TextStyle(
                                fontSize: rfs(context, 15),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: sw * 0.01),
                            Text(
                              'Tunjukkan kode ini ke petugas',
                              style: TextStyle(
                                fontSize: rfs(context, 11),
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: sw * 0.04),

                      // Info tiles
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          sw * 0.05,
                          0,
                          sw * 0.05,
                          0,
                        ),
                        child: Column(
                          children: [
                            AccessPassModal.buildInfoTile(
                               context,
                               Icons.vpn_key_outlined,
                               'Invitation Code',
                               item.invitationCode,
                               sw,
                             ),
                             SizedBox(height: sw * 0.02),
                             Row(
                               children: [
                                 Expanded(
                                   child: AccessPassModal.buildInfoTile(
                                     context,
                                     Icons.person_outline,
                                     'Host',
                                     item.hostName,
                                     sw,
                                   ),
                                 ),
                                 SizedBox(width: sw * 0.02),
                                 Expanded(
                                   child: AccessPassModal.buildInfoTile(
                                     context,
                                     Icons.event_note_outlined,
                                     'Agenda',
                                     item.agenda,
                                     sw,
                                   ),
                                 ),
                               ],
                             ),
                             SizedBox(height: sw * 0.02),
                             AccessPassModal.buildInfoTile(
                               context,
                               Icons.calendar_today_outlined,
                               'Visit Period',
                               '$startStr\n$endStr',
                               sw,
                             ),
                             if (item.isDriving) ...[
                               SizedBox(height: sw * 0.02),
                               Row(
                                 children: [
                                   Expanded(
                                     child: AccessPassModal.buildInfoTile(
                                       context,
                                       Icons.location_on_outlined,
                                       'Area',
                                       item.parkingArea,
                                       sw,
                                     ),
                                   ),
                                   SizedBox(width: sw * 0.02),
                                   Expanded(
                                     child: AccessPassModal.buildInfoTile(
                                       context,
                                       Icons.local_parking_outlined,
                                       'Slot',
                                       item.parkingSlot,
                                       sw,
                                     ),
                                   ),
                                   SizedBox(width: sw * 0.02),
                                   Expanded(
                                     child: AccessPassModal.buildInfoTile(
                                       context,
                                       Icons.directions_car_outlined,
                                       'Plate',
                                       item.vehiclePlateNumber,
                                       sw,
                                     ),
                                   ),
                                 ],
                               ),
                             ],
                           ],
                         ),
                       ),
                       SizedBox(height: sw * 0.05),
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
 
   static Widget buildInfoTile(
     BuildContext context,
     IconData icon,
     String label,
     String value,
     double sw,
   ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.03,
        vertical: sw * 0.025,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: rfs(context, 11), color: Colors.white60),
              SizedBox(width: sw * 0.01),
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
          SizedBox(height: sw * 0.01),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rfs(context, 13),
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
