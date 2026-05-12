import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import 'invite_share_link_dialog.dart';

class ShareLinkCard extends StatelessWidget {
  final dynamic item;
  final int no;
  final VoidCallback onTap;

  const ShareLinkCard({
    super.key,
    required this.item,
    required this.no,
    required this.onTap,
  });

  String _getRemainingTime(DateTime? expiredAt) {
    final int expiredNumber = item['expired_number'] ?? -1;
    if (expiredNumber == 0) return 'No Expired';
    if (expiredAt == null) return '00:00:00';
    final now = DateTime.now();
    final difference = expiredAt.difference(now);
    if (difference.isNegative) return '00:00:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(difference.inHours)}:${twoDigits(difference.inMinutes.remainder(60))}:${twoDigits(difference.inSeconds.remainder(60))}';
  }

  void _showBarcodeDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rw(context, 16)),
        ),
        child: Container(
          padding: EdgeInsets.all(rw(context, 24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Scan QR Code',
                style: TextStyle(
                  fontSize: rfs(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              vSpace(context, 24),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(rw(context, 16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rw(context, 16)),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: QrImageView(
                  data: url.isNotEmpty ? url : 'no-url',
                  version: QrVersions.auto,
                  size: rw(context, 260),
                  padding: EdgeInsets.zero,
                ),
              ),
              vSpace(context, 24),
              SizedBox(
                width: double.infinity,
                height: rh(context, 45),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rw(context, 8)),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: rfs(context, 14),
                      fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    final String agenda = item['agenda'] ?? '-';

    final expiredAtStr = item['expired_at'];
    DateTime? expiredAt;
    if (expiredAtStr != null) {
      String normalized = expiredAtStr.toString();
      if (!normalized.endsWith('Z') && !normalized.contains('+')) {
        normalized = '${normalized.replaceFirst(' ', 'T')}Z';
      }
      expiredAt = DateTime.tryParse(normalized)?.toLocal();
    }

    bool isExpired = false;
    if (expiredAt != null && expiredAt.isBefore(DateTime.now())) {
      isExpired = true;
    }

    final Color statusColor = isExpired
        ? const Color(0xFFE53935)
        : const Color(0xFF43A047);
    final String status = isExpired ? 'Expired' : 'Active';

    final String url = item['url'] ?? '';

    String formatDate(String? dateStr) {
      if (dateStr == null) return '-';
      try {
        String normalized = dateStr;
        if (!normalized.endsWith('Z') && !normalized.contains('+')) {
          normalized = '${normalized.replaceFirst(' ', 'T')}Z';
        }
        final date = DateTime.parse(normalized).toLocal();
        return DateFormat('dd MMM yyyy, HH:mm').format(date);
      } catch (e) {
        return dateStr;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(rw(context, 16)),
        decoration: BoxDecoration(
          color: isExpired ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 16)),
          border: Border.all(color: isExpired ? Colors.grey.shade300 : Colors.grey.withValues(alpha: 0.15)),
          boxShadow: [
            if (!isExpired)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: rw(context, 10),
                offset: Offset(0, rh(context, 4)),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 8),
                          vertical: rh(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius: BorderRadius.circular(rw(context, 20)),
                        ),
                        child: Text(
                          'No. $no',
                          style: TextStyle(
                            color: AppColors.primary500,
                            fontSize: rfs(context, 10),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      hSpace(context, 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 8),
                          vertical: rh(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: isExpired
                              ? Colors.grey.shade100
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(rw(context, 20)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: rw(context, 12),
                              color: isExpired
                                  ? Colors.grey
                                  : Colors.orange.shade800,
                            ),
                            hSpace(context, 4),
                            Text(
                              _getRemainingTime(expiredAt),
                              style: TextStyle(
                                fontSize: rfs(context, 10),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: isExpired
                                    ? Colors.grey
                                    : Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  vSpace(context, 10),
                  Text(
                    agenda,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: rfs(context, 15),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  vSpace(context, 6),
                  Row(
                    children: [
                      Container(
                        width: rw(context, 7),
                        height: rw(context, 7),
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      hSpace(context, 6),
                      Expanded(
                        child: Text(
                          '$status · ${formatDate(item['visitor_period_start'])}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: rfs(context, 11),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  vSpace(context, 12),
                  SizedBox(
                    height: rh(context, 32),
                    child: ElevatedButton.icon(
                      onPressed: isExpired
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (context) => InviteShareLinkDialog(item: item),
                              );
                            },
                      icon: Icon(
                        isExpired ? Icons.link_off : Icons.share,
                        size: rw(context, 14),
                        color: isExpired ? Colors.grey.shade600 : Colors.white,
                      ),
                      label: Text(
                        isExpired ? 'Link Expired' : 'Share Link',
                        style: TextStyle(
                          fontSize: rfs(context, 12),
                          fontWeight: FontWeight.w600,
                          color: isExpired ? Colors.grey.shade600 : Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isExpired ? Colors.grey.shade200 : AppColors.primary500,
                        disabledBackgroundColor: Colors.grey.shade200,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: rw(context, 12)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(rw(context, 6)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            hSpace(context, 16),
            GestureDetector(
              onTap: () {
                if (url.isNotEmpty) {
                  _showBarcodeDialog(context, url);
                }
              },
              child: Container(
                width: rw(context, 64),
                height: rw(context, 64),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rw(context, 12)),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.all(4),
                child: QrImageView(
                  data: url.isNotEmpty ? url : 'no-url',
                  version: QrVersions.auto,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black87,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
