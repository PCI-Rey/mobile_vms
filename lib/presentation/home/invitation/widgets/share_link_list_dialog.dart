import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/invitation_controller.dart';
import 'create_share_link_dialog.dart';
import 'invite_share_link_dialog.dart';

class ShareLinkListDialog extends StatefulWidget {
  const ShareLinkListDialog({super.key});

  @override
  State<ShareLinkListDialog> createState() => _ShareLinkListDialogState();
}

class _ShareLinkListDialogState extends State<ShareLinkListDialog> {
  final InvitationController controller = Get.find<InvitationController>();
  Timer? _timer;
  final RxInt _refreshTick = 0.obs;

  @override
  void initState() {
    super.initState();
    controller.fetchShareLinks(resetPage: true);
    // Jalankan timer setiap 5 detik untuk update status expired secara real-time
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _refreshTick.value++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'List Share Link',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: Color(0xFF005596),
                size: 28,
              ),
              onPressed: () => _showCreateDialog(),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Obx(() {
          // Listen to refreshTick to force rebuild every 30 seconds
          _refreshTick.value;

          if (controller.isShareLinkLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.shareLinks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link_off, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No share links found',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchShareLinks(resetPage: true),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics:
                  const AlwaysScrollableScrollPhysics(), // Memastikan bisa ditarik meski data sedikit
              itemCount: controller.shareLinks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = controller.shareLinks[index];
                return _buildShareLinkCard(
                  item,
                  (controller.shareLinkCurrentPage.value *
                          controller.shareLinkPageSize.value) +
                      index +
                      1,
                );
              },
            ),
          );
        }),
        bottomNavigationBar: Obx(() {
          if (controller.shareLinkTotalRecords.value <=
              controller.shareLinkPageSize.value) {
            return const SizedBox.shrink();
          }

          final start =
              (controller.shareLinkCurrentPage.value *
                  controller.shareLinkPageSize.value) +
              1;
          final end = start + controller.shareLinks.length - 1;
          final total = controller.shareLinkTotalRecords.value;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing $start to $end of $total',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 20),
                        onPressed: controller.shareLinkCurrentPage.value > 0
                            ? () => controller.prevShareLinkPage()
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF005596).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${controller.shareLinkCurrentPage.value + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005596),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 20),
                        onPressed:
                            (controller.shareLinkCurrentPage.value + 1) *
                                    controller.shareLinkPageSize.value <
                                total
                            ? () => controller.nextShareLinkPage()
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShareLinkCard(dynamic item, int no) {
    final String agenda = item['agenda'] ?? '-';
    final int maxUsage = item['max_usage'] ?? 0;
    final String url = item['url'] ?? '';

    final expiredAtStr = item['expired_at'];
    DateTime? expiredAt;
    if (expiredAtStr != null) {
      // API usually sends UTC. Ensure it's treated as UTC before converting to local.
      String normalized = expiredAtStr.toString();
      if (!normalized.endsWith('Z') && !normalized.contains('+')) {
        normalized = '${normalized.replaceFirst(' ', 'T')}Z';
      }
      expiredAt = DateTime.tryParse(normalized)?.toLocal();
    }

    // Tentukan status real-time berdasarkan waktu sekarang
    bool isExpired = false;
    if (expiredAt != null && expiredAt.isBefore(DateTime.now())) {
      isExpired = true;
    }

    String getRemainingTime() {
      // Check if it's "No Expired" (expired_number is 0)
      final int expiredNumber = item['expired_number'] ?? -1;
      if (expiredNumber == 0) return 'No Expired';

      if (expiredAt == null) return '00:00:00';
      final now = DateTime.now();
      final difference = expiredAt.difference(now);
      if (difference.isNegative) return '00:00:00';

      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = twoDigits(difference.inHours);
      final minutes = twoDigits(difference.inMinutes.remainder(60));
      final seconds = twoDigits(difference.inSeconds.remainder(60));

      return "$hours:$minutes:$seconds";
    }

    String status = isExpired ? 'Expired' : (item['link_status'] ?? 'Active');
    Color statusColor = isExpired
        ? const Color(0xFFE53935)
        : const Color(0xFF43A047);
    // Formatting dates
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
          // Header: No & Status
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            no.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status.toUpperCase(),
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
                          fontSize: 12,
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
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Agenda', agenda, isBold: true),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Usage',
                  item['is_single_use'] == true
                      ? '$maxUsage (Single Use)'
                      : '$maxUsage',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Period Start',
                  formatDate(item['visitor_period_start']),
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  'Period End',
                  formatDate(item['visitor_period_end']),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Expired At',
                  item['expired_number'] == 0
                      ? 'Never'
                      : formatDate(item['expired_at']),
                  color: Colors.orange.shade700,
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
                    showDialog(
                      context: context,
                      builder: (context) => InviteShareLinkDialog(item: item),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.visibility,
                  color: Colors.grey,
                  onTap: () {
                    // Show details logic
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
          width: 90,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
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

  void _showCreateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateShareLinkDialog(),
    ).then((_) => controller.fetchShareLinks());
  }
}
