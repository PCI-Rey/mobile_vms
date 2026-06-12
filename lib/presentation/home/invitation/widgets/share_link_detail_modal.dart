import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../controller/invitation_controller.dart';
import 'invite_share_link_dialog.dart';

class ShareLinkDetailModal {
  static void show(BuildContext context, dynamic item) {
    final int maxUsage = item['max_usage'] ?? 0;
    final int currentUsage = item['current_usage'] ?? 0;
    final bool isSingleUse = item['is_single_use'] == true;
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
    if ((maxUsage > 0 && currentUsage >= maxUsage) || (isSingleUse && currentUsage >= 1)) {
      isExpired = true;
    }

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

    final String shortenUrl = (item['shorten_url'] ?? item['short_url'] ?? '').toString().trim();
    final String url = (shortenUrl.isNotEmpty && shortenUrl != 'null')
        ? shortenUrl
        : (item['url'] ?? '').toString().trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7FB),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(rw(context, 28)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                      'Share Link Detail',
                      style: TextStyle(
                        fontSize: rfs(ctx, 18),
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        width: rw(ctx, 32),
                        height: rw(ctx, 32),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: rw(ctx, 16),
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              vSpace(ctx, 16),

              if (url.isNotEmpty) ...[
                Center(
                  child: QrImageView(
                    data: url,
                    version: QrVersions.auto,
                    size: rw(ctx, 200),
                    padding: EdgeInsets.zero,
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
                vSpace(ctx, 20),
              ],

              Padding(
                padding: EdgeInsets.fromLTRB(
                  rw(ctx, 16),
                  0,
                  rw(ctx, 16),
                  rh(ctx, 30),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(rw(ctx, 24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: rw(ctx, 16),
                        offset: Offset(0, rh(ctx, 6)),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(rw(ctx, 20)),
                        child: Column(
                          children: [
                            _buildInfoTile(
                              ctx,
                              Icons.event_note_outlined,
                              'Agenda',
                              agenda,
                            ),
                            vSpace(ctx, 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoTile(
                                    ctx,
                                    Icons.group_outlined,
                                    'Usage',
                                    item['is_single_use'] == true
                                        ? '$currentUsage/$maxUsage (Single Use)'
                                        : '$currentUsage/$maxUsage',
                                  ),
                                ),
                              ],
                            ),
                            vSpace(ctx, 12),
                            _buildInfoTile(
                              ctx,
                              Icons.calendar_today_outlined,
                              'Period Start',
                              formatDate(item['visitor_period_start']),
                            ),
                            vSpace(ctx, 12),
                            _buildInfoTile(
                              ctx,
                              Icons.event_available_outlined,
                              'Period End',
                              formatDate(item['visitor_period_end']),
                            ),
                            vSpace(ctx, 12),
                            _buildInfoTile(
                              ctx,
                              isExpired
                                  ? Icons.timer_off_outlined
                                  : Icons.timer_outlined,
                              'Expired At',
                              item['expired_number'] == 0
                                  ? 'Never'
                                  : formatDate(item['expired_at']),
                              valueColor: isExpired
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(ctx, 20),
                          vertical: rh(ctx, 16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildActionButton(
                              ctx,
                              label: 'Copy',
                              icon: Icons.copy,
                              color: isExpired
                                  ? Colors.grey
                                  : const Color(0xFF005596),
                              onTap: () {
                                if (isExpired) {
                                  Get.snackbar(
                                    'Link Expired',
                                    'This link has expired. Please create a new one.',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    icon: const Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                    ),
                                  );
                                  return;
                                }
                                // Do not close the detail modal, just open the invite dialog on top
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      InviteShareLinkDialog(item: item),
                                );
                              },
                            ),
                            hSpace(ctx, 16),
                            _buildActionButton(
                              ctx,
                              label: 'Delete',
                              icon: Icons.delete,
                              color: AppColors.error500,
                              onTap: () {
                                Navigator.pop(ctx);
                                _confirmDelete(context, item['id'].toString());
                              },
                            ),
                          ],
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

  static void _confirmDelete(BuildContext context, String id) {
    final controller = Get.find<InvitationController>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Share Link'),
        content: const Text('Are you sure you want to delete this share link?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await controller.deleteShareLinkAction(id);
              if (success) {
                Get.snackbar(
                  'Success',
                  'Share link deleted successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to delete share link',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(rw(context, 8)),
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(rw(context, 8)),
          ),
          child: Icon(icon, size: rw(context, 16), color: AppColors.primary500),
        ),
        hSpace(context, 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: rfs(context, 12),
                  color: Colors.grey.shade600,
                ),
              ),
              vSpace(context, 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: rfs(context, 14),
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rw(context, 12)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: rw(context, 16),
          vertical: rh(context, 10),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(rw(context, 12)),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: rw(context, 20), color: color),
            vSpace(context, 4),
            Text(
              label,
              style: TextStyle(
                fontSize: rfs(context, 10),
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
