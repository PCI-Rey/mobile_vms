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

  Widget _buildCardField(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: rw(context, 12), color: Colors.grey.shade500),
        hSpace(context, 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: rfs(context, 12),
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
            height: 1.2,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: rfs(context, 10),
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black87,
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

    final int maxUsage = item['max_usage'] ?? 0;
    final int currentUsage = item['current_usage'] ?? 0;
    final bool isSingleUse = item['is_single_use'] == true;

    bool isExpired = false;
    if (expiredAt != null && expiredAt.isBefore(DateTime.now())) {
      isExpired = true;
    }
    if ((maxUsage > 0 && currentUsage >= maxUsage) || (isSingleUse && currentUsage >= 1)) {
      isExpired = true;
    }

    final String status = isExpired ? 'Expired' : 'Active';

    final String shortenUrl = (item['shorten_url'] ?? item['short_url'] ?? '').toString().trim();
    final String url = (shortenUrl.isNotEmpty && shortenUrl != 'null')
        ? shortenUrl
        : (item['url'] ?? '').toString().trim();

    String formatDate(String? dateStr) {
      if (dateStr == null) return '-';
      try {
        String normalized = dateStr;
        if (!normalized.endsWith('Z') && !normalized.contains('+')) {
          normalized = '${normalized.replaceFirst(' ', 'T')}Z';
        }
        final date = DateTime.parse(normalized).toLocal();
        return DateFormat('dd MMMM yyyy, HH:mm').format(date);
      } catch (e) {
        return dateStr;
      }
    }

    String formatPeriod(String? startStr, String? endStr) {
      if (startStr == null || endStr == null) return '-';
      try {
        String normStart = startStr;
        if (!normStart.endsWith('Z') && !normStart.contains('+')) {
          normStart = '${normStart.replaceFirst(' ', 'T')}Z';
        }
        String normEnd = endStr;
        if (!normEnd.endsWith('Z') && !normEnd.contains('+')) {
          normEnd = '${normEnd.replaceFirst(' ', 'T')}Z';
        }
        final start = DateTime.parse(normStart).toLocal();
        final end = DateTime.parse(normEnd).toLocal();

        final dateFmt = DateFormat('dd MMMM yyyy');
        final timeFmt = DateFormat('HH:mm');

        if (start.year == end.year && start.month == end.month && start.day == end.day) {
          return '${dateFmt.format(start)} ${timeFmt.format(start)} - ${timeFmt.format(end)}';
        } else {
          return '${dateFmt.format(start)} ${timeFmt.format(start)} - ${dateFmt.format(end)} ${timeFmt.format(end)}';
        }
      } catch (e) {
        return '-';
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: rw(context, 10),
              offset: Offset(0, rh(context, 3)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar: No + badges ──────────────────
            Padding(
              padding: EdgeInsets.only(
                left: rw(context, 16),
                right: rw(context, 16),
                top: rh(context, 16),
                bottom: rh(context, 12),
              ),
              child: Row(
                children: [
                  // No circle
                  Container(
                    width: rw(context, 26),
                    height: rw(context, 26),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF005596),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$no',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  hSpace(context, 10),
                  Expanded(
                    child: Text(
                      agenda,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: rfs(context, 16),
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  hSpace(context, 6),
                  // Timer Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 7),
                      vertical: rh(context, 3),
                    ),
                    decoration: BoxDecoration(
                      color: isExpired
                          ? Colors.grey.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(rw(context, 20)),
                      border: Border.all(
                        color: isExpired
                            ? Colors.grey.withValues(alpha: 0.4)
                            : Colors.orange.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: rw(context, 12),
                          color: isExpired ? Colors.grey : Colors.orange.shade800,
                        ),
                        hSpace(context, 4),
                        Text(
                          _getRemainingTime(expiredAt),
                          style: TextStyle(
                            fontSize: rfs(context, 12),
                            fontWeight: FontWeight.w600,
                            color: isExpired ? Colors.grey : Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  hSpace(context, 6),
                  // Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 8),
                      vertical: rh(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: isExpired
                          ? const Color(0xFFE53935)
                          : const Color(0xFF43A047),
                      borderRadius: BorderRadius.circular(rw(context, 20)),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade100,
            ),
            // ── Body: info rows & QR Code ───────────────────────
            Padding(
              padding: EdgeInsets.only(
                left: rw(context, 16),
                right: rw(context, 16),
                top: rh(context, 12),
                bottom: rh(context, 16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCardField(
                          context,
                          Icons.group_outlined,
                          'Usage',
                          isSingleUse ? '$currentUsage/$maxUsage (Single)' : '$currentUsage/$maxUsage',
                        ),
                        vSpace(context, 6),
                        _buildCardField(
                          context,
                          Icons.date_range_outlined,
                          'Period',
                          formatPeriod(item['visitor_period_start'], item['visitor_period_end']),
                        ),
                        vSpace(context, 6),
                        _buildCardField(
                          context,
                          Icons.timer_off_outlined,
                          'Expired At',
                          item['expired_number'] == 0 ? 'Never' : formatDate(item['expired_at']),
                          color: Colors.red.shade600,
                        ),
                      ],
                    ),
                  ),
                  hSpace(context, 16),
                  Container(
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
                ],
              ),
            ),

            // ── Action Button: Share Link ───────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                rw(context, 16),
                0,
                rw(context, 16),
                rh(context, 16),
              ),
              child: SizedBox(
                width: double.infinity,
                height: rh(context, 36),
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
                      fontSize: rfs(context, 13),
                      fontWeight: FontWeight.w600,
                      color: isExpired ? Colors.grey.shade600 : Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isExpired ? Colors.grey.shade200 : AppColors.primary500,
                    disabledBackgroundColor: Colors.grey.shade200,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rw(context, 8)),
                    ),
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
