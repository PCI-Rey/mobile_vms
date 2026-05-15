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
import '../../../core/helper/responsive_helper.dart';
import '../../history/widgets/filter_bottom_sheet.dart';
import '../../../../data/models/access_pass_model.dart';
import 'widgets/create_share_link_dialog.dart';
import 'widgets/share_link_card.dart';
import 'widgets/share_link_detail_modal.dart';

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
        title: Text(
          "Create Invitation",
          style: TextStyle(
            fontSize: rfs(context, 25),
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
                padding: EdgeInsets.all(rw(context, 6)),
                decoration: BoxDecoration(
                  color: AppColors.primary500,
                  borderRadius: BorderRadius.circular(rw(context, 8)),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: rw(context, 20),
                ),
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
                padding: EdgeInsets.all(rw(context, 6)),
                decoration: BoxDecoration(
                  color: AppColors.primary500,
                  borderRadius: BorderRadius.circular(rw(context, 8)),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: rw(context, 20),
                ),
              ),
            ),
          hSpace(context, 8),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(rh(context, 1.0)),
          child: Container(color: AppColors.grey300, height: rh(context, 1.0)),
        ),
      ),
      body: Column(
        children: [
          // ── Tab Switcher ──────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 20),
              vertical: rh(context, 10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: rh(context, 10)),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? AppColors.primary500
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(rw(context, 10)),
                      ),
                      child: Center(
                        child: Text(
                          'Invitation',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: rfs(context, 13),
                            color: _selectedTab == 0
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                hSpace(context, 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedTab = 1);
                      // Trigger load share links when switching to Share Link tab
                      controller.fetchShareLinks(resetPage: true);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: rh(context, 10)),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1
                            ? AppColors.primary500
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(rw(context, 10)),
                      ),
                      child: Center(
                        child: Text(
                          'Share Link',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: rfs(context, 13),
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
        padding: EdgeInsets.all(rw(context, 20.0)),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(rw(context, 16)),
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
                    child: _buildFilterChip(context, 'Filter'),
                  ),
                  hSpace(context, 10),
                  Obx(() {
                    final inviteCtrl = Get.find<InvitationController>();
                    return GestureDetector(
                      onTap: () => inviteCtrl.toggleSort(),
                      child: _buildSortChip(
                        context,
                        inviteCtrl.isNewestFirst.value ? 'Newest' : 'Oldest',
                      ),
                    );
                  }),
                  if (selectedGedung != null) ...[
                    hSpace(context, 10),
                    _buildFilterValueChip(
                      context,
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
                    hSpace(context, 10),
                    _buildFilterValueChip(
                      context,
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
            vSpace(context, 16),
            // Loading indicator for background refresh
            Obx(() {
              final inviteCtrl = Get.isRegistered<InvitationController>()
                  ? Get.find<InvitationController>()
                  : null;
              if (inviteCtrl != null &&
                  inviteCtrl.isLoading.value &&
                  inviteCtrl.ongoingInvitations.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.only(bottom: rh(context, 12)),
                  child: LinearProgressIndicator(
                    minHeight: rh(context, 2),
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
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
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(rw(context, 40.0)),
                    child: const CircularProgressIndicator(),
                  ),
                );
              }

              if (inviteCtrl.ongoingInvitations.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(rw(context, 40.0)),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: rw(context, 48),
                          color: Colors.grey[400],
                        ),
                        vSpace(context, 16),
                        Text(
                          'No Invitation Found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                            fontSize: rfs(context, 14),
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
                separatorBuilder: (context, index) => vSpace(context, 12),
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
                      image: Icon(
                        statusIcon,
                        color: Colors.white,
                        size: rw(context, 20),
                      ),
                      size: rw(context, 26),
                      title: item.visitorName,
                      subtitle: item.sitePlaceName.isNotEmpty
                          ? item.sitePlaceName
                          : item.groupName,
                      additional: DateFormat('EEE, dd MMM yyyy').format(
                        item.visitorPeriodStart,
                      ),
                      additionalDesc:
                          '${DateFormat('HH:mm').format(item.visitorPeriodStart)} - ${DateFormat('HH:mm').format(item.visitorPeriodEnd)}',
                      backgroundIconColor: statusColor,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.invitationCode,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: rfs(context, 12),
                            ),
                          ),
                          vSpace(context, 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: rw(context, 8),
                              vertical: rh(context, 2),
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(
                                rw(context, 4),
                              ),
                            ),
                            child: Text(
                              item.visitorStatus,
                              style: TextStyle(
                                fontSize: rfs(context, 10),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rw(context, 20)),
        ),
        child: Container(
          padding: EdgeInsets.all(rw(context, 24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Invitation Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rfs(context, 20),
                  ),
                ),
              ),
              vSpace(context, 12),
              const Divider(),
              vSpace(context, 16),
              _buildDetailRow(
                context,
                'Visitor Name',
                item.visitorName,
                isBold: true,
              ),
              _buildDetailRow(
                context,
                'Invitation Code',
                item.invitationCode,
                color: const Color(0xFF005596),
              ),
              _buildDetailRow(
                context,
                'Status',
                item.visitorStatus,
                badgeColor: statusColor,
              ),
              _buildDetailRow(context, 'Host', item.hostName),
              _buildDetailRow(context, 'Location', item.sitePlaceName),
              _buildDetailRow(context, 'Agenda', item.agenda),
              _buildDetailRow(
                context,
                'Visit Period',
                '${DateFormat('dd MMM yyyy').format(item.visitorPeriodStart)}\n${DateFormat('HH:mm').format(item.visitorPeriodStart)} - ${DateFormat('HH:mm').format(item.visitorPeriodEnd)}',
              ),
              if (item.parkingArea.isNotEmpty || item.parkingSlot.isNotEmpty)
                _buildDetailRow(
                  context,
                  'Parking',
                  '${item.parkingArea} - ${item.parkingSlot}',
                ),
              if (item.vehiclePlateNumber.isNotEmpty)
                _buildDetailRow(
                  context,
                  'Vehicle Plate',
                  item.vehiclePlateNumber,
                ),
              vSpace(context, 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005596),
                    padding: EdgeInsets.symmetric(vertical: rh(context, 14)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rw(context, 12)),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: rfs(context, 14),
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
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    Color? color,
    Color? badgeColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: rfs(context, 12),
            ),
          ),
          vSpace(context, 4),
          if (badgeColor != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 8),
                vertical: rh(context, 2),
              ),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(rw(context, 4)),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: rfs(context, 12),
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
                      fontSize: rfs(context, 14),
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
                        margin: EdgeInsets.all(rw(context, 10)),
                      );
                    },
                    child: Icon(
                      Icons.content_copy,
                      size: rw(context, 16),
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label) {
    return Container(
      height: rh(context, 32),
      padding: EdgeInsets.symmetric(horizontal: rw(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(rw(context, 50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: rfs(context, 12), color: Colors.black87),
          ),
          hSpace(context, 6),
          Icon(
            FontAwesomeIcons.chevronDown,
            size: rw(context, 12),
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(BuildContext context, String label) {
    return Container(
      height: rh(context, 32),
      padding: EdgeInsets.symmetric(horizontal: rw(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(rw(context, 50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FontAwesomeIcons.sort,
            size: rw(context, 12),
            color: Colors.grey,
          ),
          hSpace(context, 6),
          Text(
            label,
            style: TextStyle(fontSize: rfs(context, 12), color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterValueChip(
    BuildContext context,
    String label, {
    required VoidCallback onClear,
  }) {
    return Container(
      height: rh(context, 32),
      padding: EdgeInsets.symmetric(horizontal: rw(context, 10)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(rw(context, 50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.trim(),
            style: TextStyle(fontSize: rfs(context, 12), color: Colors.black87),
          ),
          hSpace(context, 6),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(rw(context, 10)),
            child: Padding(
              padding: EdgeInsets.all(rw(context, 2)),
              child: Icon(
                Icons.close,
                size: rw(context, 14),
                color: Colors.grey,
              ),
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

  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  Worker? _listWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.shareLinkPageSize.value = 10;
      controller.fetchShareLinks(resetPage: true);
    });

    // Reset scroll to top when list changes (focused on new item)
    _listWorker = ever(controller.shareLinks, (_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
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
    _listWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Delete confirmation is now handled by ShareLinkDetailModal

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
              Icon(
                Icons.link_off,
                size: rw(context, 64),
                color: Colors.grey.shade300,
              ),
              vSpace(context, 16),
              Text(
                'No share links found',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: rfs(context, 14),
                ),
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
                controller: _scrollController,
                padding: EdgeInsets.all(rw(context, 16)),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.shareLinks.length,
                separatorBuilder: (_, index) => vSpace(context, 12),
                itemBuilder: (context, index) {
                  final item = controller.shareLinks[index];
                  return ShareLinkCard(
                    item: item,
                    no:
                        index +
                        1 +
                        (controller.shareLinkCurrentPage.value *
                            controller.shareLinkPageSize.value),
                    onTap: () => ShareLinkDetailModal.show(context, item),
                  );
                },
              ),
            ),
          ),
          if (controller.isShareLinkLoading.value &&
              controller.shareLinks.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: rh(context, 10)),
              child: const CircularProgressIndicator(),
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

  // UI components extracted to ShareLinkCard and ShareLinkDetailModal
}
