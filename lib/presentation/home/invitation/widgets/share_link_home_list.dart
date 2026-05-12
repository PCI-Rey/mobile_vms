import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/invitation_controller.dart';
import 'invite_share_link_dialog.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../send_invitation_page.dart';

class ShareLinkHomeList extends StatefulWidget {
  const ShareLinkHomeList({super.key});

  @override
  State<ShareLinkHomeList> createState() => _ShareLinkHomeListState();
}

class _ShareLinkHomeListState extends State<ShareLinkHomeList> {
  final InvitationController controller =
      Get.isRegistered<InvitationController>()
      ? Get.find<InvitationController>()
      : Get.put(InvitationController());
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Always fetch newest 3 after frame completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDashboardShareLinks();
    });

    // Start timer for live countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _confirmDelete(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Share Link'),
        content: const Text('Are you sure you want to delete this share link?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isShareLinkLoading.value &&
          controller.dashboardShareLinks.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(rw(context, 20.0)),
            child: const CircularProgressIndicator(),
          ),
        );
      }

      if (controller.dashboardShareLinks.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(rw(context, 20.0)),
            child: Column(
              children: [
                Icon(Icons.link_off, size: rw(context, 48), color: Colors.grey.shade300),
                vSpace(context, 8),
                Text(
                  'No share links found',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: rfs(context, 12)),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: title only
          Text(
            'List Share Link',
            style: TextStyle(
              fontSize: rfs(context, 15),
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          vSpace(context, 12),

          // List of cards (max 3, no scroll)
          ...controller.dashboardShareLinks
              .take(3)
              .toList()
              .asMap()
              .entries
              .map((entry) {
                final int idx = entry.key + 1;
                final item = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: rh(context, 12)),
                  child: _buildShareLinkCard(context, item, idx),
                );
              }),

          // More Link button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Get.to(() => const SendInvitationPage(initialTab: 1));
              },
              icon: Icon(Icons.arrow_forward_rounded, size: rw(context, 16)),
              label: const Text('Show More Link'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary500,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: rfs(context, 13),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildShareLinkCard(BuildContext context, dynamic item, int no) {
    final String agenda = item['agenda'] ?? '-';
    final int maxUsage = item['max_usage'] ?? 0;

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

    String getRemainingTime() {
      final int expiredNumber = item['expired_number'] ?? -1;
      if (expiredNumber == 0) return 'No Expired';
      if (expiredAt == null) return '00:00:00';
      final difference = expiredAt.difference(DateTime.now());
      if (difference.isNegative) return '00:00:00';
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(difference.inHours)}:${two(difference.inMinutes.remainder(60))}:${two(difference.inSeconds.remainder(60))}';
    }

    final Color statusColor = isExpired
        ? const Color(0xFFE53935)
        : const Color(0xFF43A047);
    final String statusLabel = isExpired ? 'Expired' : 'Active';

    String formatDate(String? dateStr) {
      if (dateStr == null) return '-';
      try {
        String normalized = dateStr;
        if (!normalized.endsWith('Z') && !normalized.contains('+')) {
          normalized = '${normalized.replaceFirst(' ', 'T')}Z';
        }
        return DateFormat(
          'dd MMM yyyy, HH:mm',
        ).format(DateTime.parse(normalized).toLocal());
      } catch (_) {
        return dateStr;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: rw(context, 10),
            offset: Offset(0, rh(context, 4)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: status badge + timer ──────────────────────────
          Padding(
            padding: EdgeInsets.all(rw(context, 12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status pill with icon
                Container(
                  padding: EdgeInsets.fromLTRB(rw(context, 4), rh(context, 4), rw(context, 12), rh(context, 4)),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(rw(context, 20)),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.2),
                        blurRadius: rw(context, 4),
                        offset: Offset(0, rh(context, 2)),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: rw(context, 22),
                        height: rw(context, 22),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            no.toString(),
                            style: TextStyle(
                              fontSize: rfs(context, 10),
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ),
                      hSpace(context, 6),
                      Icon(
                        isExpired ? Icons.link_off : Icons.link,
                        size: rw(context, 14),
                        color: Colors.white,
                      ),
                      hSpace(context, 4),
                      Text(
                        statusLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: rfs(context, 10),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                // Timer box
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(context, 8),
                    vertical: rh(context, 4),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(rw(context, 6)),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: rw(context, 14),
                        color: isExpired ? Colors.grey : Colors.orange,
                      ),
                      hSpace(context, 4),
                      Text(
                        getRemainingTime(),
                        style: TextStyle(
                          fontSize: rfs(context, 11),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: isExpired ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── Content rows ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(rw(context, 12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(context, 'Agenda', agenda, isBold: true),
                vSpace(context, 6),
                _buildInfoRow(
                  context,
                  'Usage',
                  item['is_single_use'] == true
                      ? '$maxUsage (Single Use)'
                      : '$maxUsage',
                ),
                vSpace(context, 6),
                _buildInfoRow(
                  context,
                  'Visit Start',
                  formatDate(item['visitor_period_start']),
                ),
                vSpace(context, 6),
                _buildInfoRow(
                  context,
                  'Visit End',
                  formatDate(item['visitor_period_end']),
                ),
                vSpace(context, 6),
                _buildInfoRow(
                  context,
                  'Expired At',
                  item['expired_number'] == 0
                      ? 'Never'
                      : formatDate(item['expired_at']),
                  color: isExpired
                      ? Colors.orange.shade700
                      : Colors.green.shade700,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: rw(context, 12), vertical: rh(context, 8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.copy,
                  color: isExpired ? Colors.grey : Colors.orange.shade400,
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
                    showDialog(
                      context: context,
                      builder: (context) => InviteShareLinkDialog(item: item),
                    );
                  },
                ),
                hSpace(context, 12),
                _buildActionButton(
                  context,
                  icon: Icons.visibility,
                  color: Colors.grey,
                  onTap: () {
                    // Logic to show details if needed
                  },
                ),
                hSpace(context, 12),
                _buildActionButton(
                  context,
                  icon: Icons.delete,
                  color: Colors.red,
                  onTap: () => _confirmDelete(item['id'].toString()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: rw(context, 80),
          child: Text(
            label,
            style: TextStyle(fontSize: rfs(context, 11), color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: rfs(context, 11),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rw(context, 8)),
      child: Container(
        padding: EdgeInsets.all(rw(context, 6)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(rw(context, 8)),
        ),
        child: Icon(icon, size: rw(context, 18), color: color),
      ),
    );
  }
}
