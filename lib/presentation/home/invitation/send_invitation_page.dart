import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'controller/invitation_controller.dart';
import '../../../../presentation/home/visitor_request/add_pra_registration_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/components/custom_card.dart';
import '../../../core/core.dart';
import '../../history/widgets/filter_bottom_sheet.dart';
import '../../../../data/models/access_pass_model.dart';
import 'widgets/create_share_link_dialog.dart';
import 'widgets/invite_share_link_dialog.dart';

class SendInvitationPage extends StatefulWidget {
  final int initialTab;
  const SendInvitationPage({super.key, this.initialTab = 0});

  @override
  State<SendInvitationPage> createState() => _SendInvitationPageState();
}

class _SendInvitationPageState extends State<SendInvitationPage> {
  final controller = Get.put(InvitationController());
  DateTime? startDate;
  DateTime? endDate;
  String? selectedGedung;

  // 0 = Invitation, 1 = Share Link
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Create Invitation",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(),
        actions: [
          // Tombol Tambah + hanya muncul di tab Invitation
          if (_selectedTab == 0)
            IconButton(
              onPressed: () async {
                final result = await showAddPraRegistrationDialog(context);
                if (result == true) {
                  setState(() {
                    startDate = null;
                    endDate = null;
                    selectedGedung = null;
                  });
                  controller.fetchOngoingInvitations(clearFilters: true);
                }
              },
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary500,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          // Tombol Add Share Link hanya muncul di tab Share Link
          if (_selectedTab == 1)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const CreateShareLinkDialog(),
                ).then((_) => controller.fetchShareLinks());
              },
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary500,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          // ── Tab Switcher ──────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? AppColors.primary500
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Invitation',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _selectedTab == 0
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedTab = 1);
                      // Trigger load share links when switching to Share Link tab
                      controller.fetchShareLinks(resetPage: true);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1
                            ? AppColors.primary500
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Share Link',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _selectedTab == 1
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Content Area ──────────────────────────────────────────
          Expanded(
            child: _selectedTab == 0
                ? _buildInvitationTab()
                : _buildShareLinkTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationTab() {
    return RefreshIndicator(
      onRefresh: () async {
        final inviteCtrl = Get.find<InvitationController>();
        await inviteCtrl.fetchOngoingInvitations();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final inviteCtrl = Get.find<InvitationController>();
                      final result =
                          await showModalBottomSheet<Map<String, dynamic>>(
                            context: context,
                            enableDrag: true,
                            isDismissible: true,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder: (context) => FilterBottomSheet(
                              initialStartDate: startDate,
                              initialEndDate: endDate,
                              initialSiteId: inviteCtrl.selectedSiteId.value,
                            ),
                          );

                      if (result != null) {
                        setState(() {
                          startDate = result['startDate'];
                          endDate = result['endDate'];
                          selectedGedung = result['siteName'];
                        });
                        inviteCtrl.setFilters(
                          start: startDate,
                          end: endDate,
                          siteId: result['siteId'],
                          siteName: result['siteName'],
                        );
                      }
                    },
                    child: _buildFilterChip('Filter'),
                  ),
                  const SizedBox(width: 10),
                  Obx(() {
                    final inviteCtrl = Get.find<InvitationController>();
                    return GestureDetector(
                      onTap: () => inviteCtrl.toggleSort(),
                      child: _buildSortChip(
                        inviteCtrl.isNewestFirst.value ? 'Newest' : 'Oldest',
                      ),
                    );
                  }),
                  if (selectedGedung != null) ...[
                    const SizedBox(width: 10),
                    _buildFilterValueChip(
                      selectedGedung!,
                      onClear: () {
                        final inviteCtrl = Get.find<InvitationController>();
                        setState(() => selectedGedung = null);
                        inviteCtrl.setFilters(
                          start: startDate,
                          end: endDate,
                          siteId: null,
                          siteName: null,
                        );
                      },
                    ),
                  ],
                  if (startDate != null || endDate != null) ...[
                    const SizedBox(width: 10),
                    _buildFilterValueChip(
                      _formatDateRange(startDate, endDate),
                      onClear: () {
                        final inviteCtrl = Get.find<InvitationController>();
                        setState(() {
                          startDate = null;
                          endDate = null;
                        });
                        inviteCtrl.setFilters(
                          start: null,
                          end: null,
                          siteId: inviteCtrl.selectedSiteId.value,
                          siteName: inviteCtrl.selectedSiteName.value,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Loading indicator for background refresh
            Obx(() {
              final inviteCtrl = Get.isRegistered<InvitationController>()
                  ? Get.find<InvitationController>()
                  : null;
              if (inviteCtrl != null &&
                  inviteCtrl.isLoading.value &&
                  inviteCtrl.ongoingInvitations.isNotEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary500,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Obx(() {
              final inviteCtrl = Get.isRegistered<InvitationController>()
                  ? Get.find<InvitationController>()
                  : Get.put(InvitationController());

              if (inviteCtrl.isLoading.value &&
                  inviteCtrl.ongoingInvitations.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (inviteCtrl.ongoingInvitations.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Invitation Found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: inviteCtrl.ongoingInvitations.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = inviteCtrl.ongoingInvitations[index];
                  final isCheckout = item.visitorStatus.toLowerCase().contains(
                    'checkout',
                  );
                  final isCheckin = item.visitorStatus.toLowerCase().contains(
                    'checkin',
                  );
                  final isPreregis = item.visitorStatus.toLowerCase().contains(
                    'preregis',
                  );
                  final isDone = item.isPraregisterDone;

                  // Tentukan Ikon dan Warna berdasarkan 4 Status
                  IconData statusIcon;
                  Color statusColor;

                  if (isCheckout) {
                    statusIcon = Icons.cancel;
                    statusColor = AppColors.success500;
                  } else if (isCheckin) {
                    statusIcon = Icons.check_circle;
                    statusColor = AppColors.success500;
                  } else if (isPreregis && isDone) {
                    statusIcon = Icons.fact_check;
                    statusColor = Colors.grey;
                  } else {
                    statusIcon = Icons.assignment_late;
                    statusColor = Colors.grey;
                  }

                  return GestureDetector(
                    onTap: () => _showInvitationDetailDialog(item, statusColor),
                    child: CustomCard(
                      image: Icon(statusIcon, color: Colors.white),
                      size: 26,
                      title: item.visitorName,
                      subtitle: item.sitePlaceName.isNotEmpty
                          ? item.sitePlaceName
                          : item.groupName,
                      additional: DateFormat('EEE, dd MMM yyyy').format(
                        DateTime.parse(
                          '${item.visitorPeriodStart.toIso8601String().split('Z').first}Z',
                        ).toLocal(),
                      ),
                      additionalDesc:
                          '${DateFormat('HH:mm').format(DateTime.parse('${item.visitorPeriodStart.toIso8601String().split('Z').first}Z').toLocal())} - ${DateFormat('HH:mm').format(DateTime.parse('${item.visitorPeriodEnd.toIso8601String().split('Z').first}Z').toLocal())}',
                      backgroundIconColor: statusColor,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.invitationCode,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.visitorStatus,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildShareLinkTab() {
    return const ShareLinkListInline();
  }

  void _showInvitationDetailDialog(AccessPassModel item, Color statusColor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Invitation Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow('Visitor Name', item.visitorName, isBold: true),
              _buildDetailRow(
                'Invitation Code',
                item.invitationCode,
                color: const Color(0xFF005596),
              ),
              _buildDetailRow(
                'Status',
                item.visitorStatus,
                badgeColor: statusColor,
              ),
              _buildDetailRow('Host', item.hostName),
              _buildDetailRow('Location', item.sitePlaceName),
              _buildDetailRow('Agenda', item.agenda),
              _buildDetailRow(
                'Visit Period',
                '${DateFormat('dd MMM yyyy').format(DateTime.parse('${item.visitorPeriodStart.toIso8601String().split('Z').first}Z').toLocal())}\n${DateFormat('HH.mm').format(DateTime.parse('${item.visitorPeriodStart.toIso8601String().split('Z').first}Z').toLocal())} - ${DateFormat('HH.mm').format(DateTime.parse('${item.visitorPeriodEnd.toIso8601String().split('Z').first}Z').toLocal())}',
              ),
              if (item.parkingArea.isNotEmpty || item.parkingSlot.isNotEmpty)
                _buildDetailRow(
                  'Parking',
                  '${item.parkingArea} - ${item.parkingSlot}',
                ),
              if (item.vehiclePlateNumber.isNotEmpty)
                _buildDetailRow('Vehicle Plate', item.vehiclePlateNumber),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005596),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
    Color? badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          if (badgeColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? '-' : value,
                    style: TextStyle(
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      color: color ?? Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (label == 'Invitation Code' && value.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      Get.snackbar(
                        'Copied',
                        'Invitation Code copied to clipboard',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 1),
                        margin: const EdgeInsets.all(10),
                      );
                    },
                    child: Icon(
                      Icons.content_copy,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(width: 6),
          const Icon(
            FontAwesomeIcons.chevronDown,
            size: 12,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(FontAwesomeIcons.sort, size: 12, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterValueChip(String label, {required VoidCallback onClear}) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Ini kunci agar lebar mengikuti isi
        children: [
          Text(
            label.trim(), // Pastikan tidak ada spasi tambahan
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close, size: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '';
    final format = DateFormat('dd/MM/yyyy');
    if (start != null && end != null) {
      return '${format.format(start)} - ${format.format(end)}';
    } else if (start != null) {
      return 'Dari ${format.format(start)}';
    } else {
      return 'Sampai ${format.format(end!)}';
    }
  }
}

// ─── Inline Share Link List (displayed inside SendInvitationPage) ────────────
class ShareLinkListInline extends StatefulWidget {
  const ShareLinkListInline({super.key});

  @override
  State<ShareLinkListInline> createState() => _ShareLinkListInlineState();
}

class _ShareLinkListInlineState extends State<ShareLinkListInline> {
  final InvitationController controller =
      Get.isRegistered<InvitationController>()
          ? Get.find<InvitationController>()
          : Get.put(InvitationController());

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.shareLinkPageSize.value = 10;
      controller.fetchShareLinks(resetPage: true);
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
          controller.shareLinks.isEmpty) {
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

      return Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchShareLinks(resetPage: true),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.shareLinks.length,
                separatorBuilder: (_, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = controller.shareLinks[index];
                  return _buildShareLinkCard(
                    item,
                    index +
                        1 +
                        (controller.shareLinkCurrentPage.value *
                            controller.shareLinkPageSize.value),
                  );
                },
              ),
            ),
          ),
          // Pagination footer
          if (controller.shareLinkTotalRecords.value > 10)
            _buildPaginationBar(),
        ],
      );
    });
  }

  Widget _buildPaginationBar() {
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
                Text(
                  '${controller.shareLinkCurrentPage.value + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
  }

  Widget _buildShareLinkCard(dynamic item, int no) {
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
      final now = DateTime.now();
      final difference = expiredAt.difference(now);
      if (difference.isNegative) return '00:00:00';
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      return '${twoDigits(difference.inHours)}:${twoDigits(difference.inMinutes.remainder(60))}:${twoDigits(difference.inSeconds.remainder(60))}';
    }

    final Color statusColor =
        isExpired ? const Color(0xFFE53935) : const Color(0xFF43A047);
    final String status = isExpired ? 'Expired' : 'Active';

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
                        width: 22,
                        height: 22,
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
                      Icon(
                        isExpired ? Icons.link_off : Icons.link,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
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
}
