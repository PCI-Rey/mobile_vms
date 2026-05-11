import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/invitation_controller.dart';
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
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
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
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.dashboardShareLinks.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(Icons.link_off, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text(
                  'No share links found',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 12),
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
          const SizedBox(height: 12),

          // List of cards (max 3, no scroll)
          ...controller.dashboardShareLinks.take(3).map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildShareLinkCard(context, item),
            ),
          ),

          // More Link button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Get.to(
                  () => const SendInvitationPage(initialTab: 1),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('More Link'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary500,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildShareLinkCard(BuildContext context, dynamic item) {
    final String agenda = item['agenda'] ?? '-';
    final int maxUsage = item['max_usage'] ?? 0;
    final String url = item['url'] ?? '';

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

    final Color statusColor =
        isExpired ? const Color(0xFFE53935) : const Color(0xFF43A047);
    final String statusLabel = isExpired ? 'Expired' : 'Active';

    String formatDate(String? dateStr) {
      if (dateStr == null) return '-';
      try {
        String normalized = dateStr;
        if (!normalized.endsWith('Z') && !normalized.contains('+')) {
          normalized = '${normalized.replaceFirst(' ', 'T')}Z';
        }
        return DateFormat('dd MMM yyyy, HH:mm')
            .format(DateTime.parse(normalized).toLocal());
      } catch (_) {
        return dateStr;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: status badge + timer ──────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status pill with icon
                Container(
                  padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            isExpired ? Icons.link_off : Icons.link,
                            size: 13,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: isExpired ? Colors.grey : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        getRemainingTime(),
                        style: TextStyle(
                          fontSize: 11,
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Agenda', agenda, isBold: true),
                const SizedBox(height: 6),
                _buildInfoRow(
                  'Usage',
                  item['is_single_use'] == true
                      ? '$maxUsage (Single Use)'
                      : '$maxUsage',
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  'Visit Start',
                  formatDate(item['visitor_period_start']),
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  'Visit End',
                  formatDate(item['visitor_period_end']),
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
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
                    Clipboard.setData(ClipboardData(text: url));
                    Get.snackbar(
                      'Copied',
                      'URL copied to clipboard',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.visibility,
                  color: Colors.grey,
                  onTap: () {
                    // Logic to show details if needed
                  },
                ),
                const SizedBox(width: 12),
                _buildActionButton(
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
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
