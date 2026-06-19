// ignore_for_file: unused_import, unused_local_variable, unused_element, use_build_context_synchronously, sized_box_for_whitespace, unnecessary_underscores, unnecessary_import, unnecessary_null_comparison, curly_braces_in_flow_control_structures, unused_element_parameter, deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'controller/invitation_controller.dart';
import 'scan_invitation_page.dart';
import '../../../../presentation/home/visitor_request/add_pra_registration_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../history/widgets/filter_bottom_sheet.dart';
import '../../../../data/models/access_pass_model.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/datasources/hive_service.dart';
import 'widgets/create_share_link_dialog.dart';
import 'widgets/share_link_card.dart';
import 'widgets/share_link_detail_modal.dart';
import 'widgets/create_quick_access_dialog.dart';
import 'widgets/duplicate_selector_sheet.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SendInvitationPage extends StatefulWidget {
  final int initialTab;
  const SendInvitationPage({super.key, this.initialTab = 0});

  @override
  State<SendInvitationPage> createState() => _SendInvitationPageState();
}

class _SendInvitationPageState extends State<SendInvitationPage>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(InvitationController());
  DateTime? startDate;
  DateTime? endDate;
  String? selectedGedung;
  String? selectedStatus;
  String? selectedFlow;

  // Share Link filter variables (moved to ShareLinkListInline for self-containment)

  // Quick Access filter variables
  DateTime? startDateQuick;
  DateTime? endDateQuick;
  String? selectedGedungQuick;
  String? selectedStatusQuick;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // Default filters to last 7 days on opening the page
    controller.startDate.value = DateTime.now().subtract(const Duration(days: 7));
    controller.endDate.value = DateTime.now();
    controller.startDateQuick.value = DateTime.now().subtract(const Duration(days: 7));
    controller.endDateQuick.value = DateTime.now();
    controller.startDateShare.value = DateTime.now().subtract(const Duration(days: 7));
    controller.endDateShare.value = DateTime.now();

    controller.invitationCurrentPage.value = 0;
    controller.quickCurrentPage.value = 0;
    controller.shareLinkCurrentPage.value = 0;

    // Apply default filters to get the initial list state
    controller.setFilters(
      start: controller.startDate.value,
      end: controller.endDate.value,
      siteId: controller.selectedSiteId.value.isEmpty ? null : controller.selectedSiteId.value,
      siteName: controller.selectedSiteName.value.isEmpty ? null : controller.selectedSiteName.value,
      status: controller.selectedStatus.value.isEmpty ? null : controller.selectedStatus.value,
      flow: controller.selectedFlow.value.isEmpty ? null : controller.selectedFlow.value,
    );
    controller.setQuickFilters(
      start: controller.startDateQuick.value,
      end: controller.endDateQuick.value,
      siteId: controller.selectedSiteIdQuick.value.isEmpty ? null : controller.selectedSiteIdQuick.value,
      siteName: controller.selectedSiteNameQuick.value.isEmpty ? null : controller.selectedSiteNameQuick.value,
      status: controller.selectedStatusQuick.value.isEmpty ? null : controller.selectedStatusQuick.value,
    );
    controller.setShareFilters(
      start: controller.startDateShare.value,
      end: controller.endDateShare.value,
      siteId: controller.selectedSiteIdShare.value.isEmpty ? null : controller.selectedSiteIdShare.value,
      siteName: controller.selectedSiteNameShare.value.isEmpty ? null : controller.selectedSiteNameShare.value,
      status: controller.selectedStatusShare.value.isEmpty ? null : controller.selectedStatusShare.value,
    );

    // Restore filter states from controller
    startDate = controller.startDate.value;
    endDate = controller.endDate.value;
    selectedGedung = controller.selectedSiteName.value.isEmpty
        ? null
        : controller.selectedSiteName.value;
    selectedStatus = controller.selectedStatus.value.isEmpty
        ? null
        : controller.selectedStatus.value;
    selectedFlow = controller.selectedFlow.value.isEmpty
        ? null
        : controller.selectedFlow.value;

    startDateQuick = controller.startDateQuick.value;
    endDateQuick = controller.endDateQuick.value;
    selectedGedungQuick = controller.selectedSiteNameQuick.value.isEmpty
        ? null
        : controller.selectedSiteNameQuick.value;
    selectedStatusQuick = controller.selectedStatusQuick.value.isEmpty
        ? null
        : controller.selectedStatusQuick.value;

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Invitation",
          style: TextStyle(
            fontSize: rfs(context, 24),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(),
        actions: [
          // Tombol Tambah + hanya muncul di tab Invitation
          if (_tabController.index == 0)
            IconButton(
              onPressed: () async {
                final result = await showAddPraRegistrationDialog(context);
                if (result == true) {
                  controller.fetchOngoingInvitations(clearFilters: false);
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
          if (_tabController.index == 1)
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
          // Tombol Add Quick Access hanya muncul di tab Quick Access
          if (_tabController.index == 2)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const CreateQuickAccessDialog(),
                ).then((result) {
                  if (result == true) {
                    controller.fetchOngoingInvitations(clearFilters: false);
                  }
                });
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
          // ── Tab Bar ───────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                labelColor: AppColors.primary600,
                unselectedLabelColor: Colors.grey.shade500,
                indicatorColor: AppColors.primary600,
                indicatorWeight: 2.5,
                labelPadding: EdgeInsets.zero,
                labelStyle: TextStyle(
                  fontSize: rfs(context, 18),
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: rfs(context, 18),
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'Invitation'),
                  Tab(text: 'Share Link'),
                  Tab(text: 'Quick Access'),
                ],
              ),
            ),
          ),

          // ── Content Area ──────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                KeepAliveWrapper(child: _buildInvitationTab()),
                const KeepAliveWrapper(child: ShareLinkListInline()),
                KeepAliveWrapper(child: _buildQuickAccessTab()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Filter bar ─────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(
            left: rw(context, 20),
            right: rw(context, 20),
            top: rh(context, 16),
            bottom: rh(context, 6),
          ),
          child: SingleChildScrollView(
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
                            initialStatus: selectedStatus,
                            initialFlow: selectedFlow,
                            showStatusFilter: false,
                            filterMode: 'invitation',
                          ),
                        );

                    if (result != null) {
                      setState(() {
                        startDate = result['startDate'];
                        endDate = result['endDate'];
                        selectedGedung = result['siteName'];
                        selectedStatus = result['status'];
                        selectedFlow = result['flow'];
                      });
                      inviteCtrl.setFilters(
                        start: startDate,
                        end: endDate,
                        siteId: result['siteId'],
                        siteName: result['siteName'],
                        status: result['status'],
                        flow: result['flow'],
                      );
                    }
                  },
                  child: _buildFilterChip(context, 'Filter'),
                ),
                if (selectedGedung != null) ...[
                  hSpace(context, 8),
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
                        status: selectedStatus,
                        flow: selectedFlow,
                      );
                    },
                  ),
                ],
                if (startDate != null || endDate != null) ...[
                  hSpace(context, 8),
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
                        status: selectedStatus,
                        flow: selectedFlow,
                      );
                    },
                  ),
                ],
                if (selectedStatus != null && selectedStatus!.isNotEmpty) ...[
                  hSpace(context, 8),
                  _buildFilterValueChip(
                    context,
                    'Status: $selectedStatus',
                    onClear: () {
                      final inviteCtrl = Get.find<InvitationController>();
                      setState(() => selectedStatus = null);
                      inviteCtrl.setFilters(
                        start: startDate,
                        end: endDate,
                        siteId: inviteCtrl.selectedSiteId.value,
                        siteName: inviteCtrl.selectedSiteName.value,
                        status: null,
                        flow: selectedFlow,
                      );
                    },
                  ),
                ],
                if (selectedFlow != null && selectedFlow!.isNotEmpty) ...[
                  hSpace(context, 8),
                  _buildFilterValueChip(
                    context,
                    'Flow: $selectedFlow',
                    onClear: () {
                      final inviteCtrl = Get.find<InvitationController>();
                      setState(() => selectedFlow = null);
                      inviteCtrl.setFilters(
                        start: startDate,
                        end: endDate,
                        siteId: inviteCtrl.selectedSiteId.value,
                        siteName: inviteCtrl.selectedSiteName.value,
                        status: selectedStatus,
                        flow: null,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),

        // ── List ──────────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              final inviteCtrl = Get.find<InvitationController>();
              await inviteCtrl.fetchOngoingInvitations();
            },
            child: Obx(() {
              final inviteCtrl = Get.isRegistered<InvitationController>()
                  ? Get.find<InvitationController>()
                  : Get.put(InvitationController());

              final listToShow = inviteCtrl.ongoingInvitations.toList();
              final isLoading = inviteCtrl.isLoading.value;

              if (isLoading && listToShow.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(rw(context, 40.0)),
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  ],
                );
              }

              if (listToShow.isEmpty) {
                final isIndonesian = Get.locale?.languageCode == 'id';
                return EmptyStateWidget(
                  illustration: const InvitationIllustration(),
                  icon: Icons.mail_outline_rounded,
                  title: isIndonesian
                      ? 'Belum ada invitation'
                      : 'No invitations yet',
                  subtitle: isIndonesian
                      ? 'Buat invitation untuk mengundang tamu, bagikan tautan atau QR code, dan lacak respons mereka dengan mudah.'
                      : 'Create invitations to invite guests, share links or QR codes, and track their responses easily.',
                  buttonText: isIndonesian
                      ? 'Buat Invitation'
                      : 'Create Invitation',
                  onButtonPressed: () async {
                    final result = await showAddPraRegistrationDialog(context);
                    if (result == true) {
                      controller.fetchOngoingInvitations(clearFilters: false);
                    }
                  },
                  tipsText: isIndonesian
                      ? 'Info: Invitation memudahkan Anda mengundang tamu dan memantau kehadiran secara real-time.'
                      : 'Info: Invitations make it easy for you to invite guests and monitor their attendance in real-time.',
                  showQuickActions: true,
                  mode: 'invitation',
                  onDuplicateSuccess: () {
                    controller.fetchOngoingInvitations(clearFilters: false);
                  },
                );
              }

              final showTopLoading = isLoading && listToShow.isNotEmpty;

              return ListView.separated(
                padding: EdgeInsets.only(
                  left: rw(context, 20.0),
                  right: rw(context, 20.0),
                  bottom: rw(context, 20.0),
                  top: rw(context, 10.0),
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: listToShow.length + (showTopLoading ? 1 : 0),
                separatorBuilder: (context, index) => vSpace(context, 10),
                itemBuilder: (context, index) {
                  if (showTopLoading && index == 0) {
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

                  final itemIndex = showTopLoading ? index - 1 : index;
                  final item = listToShow[itemIndex];
                  final now = DateTime.now();
                  final isExpired = item.visitorPeriodEnd.isBefore(now);
                  final String jenis;
                  final Color jenisColor;

                  if (item.visitorStatus.isEmpty && item.flow.isEmpty) {
                    jenis = 'Invitation';
                    jenisColor = const Color(0xFF6D4C41);
                  } else {
                    // Use flow field to determine type badge
                    final lowerFlow = item.flow.toLowerCase();
                    if (lowerFlow == 'quickaccessvisit') {
                      jenis = 'Quick Access';
                      jenisColor = const Color(0xFFD81B60);
                    } else if (lowerFlow == 'praregister') {
                      jenis = 'Praregis';
                      jenisColor = const Color(0xFF00B0FF);
                    } else if (lowerFlow == 'invitation') {
                      jenis = 'Invitation';
                      jenisColor = const Color(0xFF6D4C41);
                    } else {
                      // Fallback to transaction_status
                      final lowerStatus = item.visitorStatus.toLowerCase();
                      if (lowerStatus == 'available') {
                        jenis = 'Available';
                        jenisColor = const Color(0xFF8E24AA);
                      } else if (lowerStatus == 'pending') {
                        jenis = 'Pending';
                        jenisColor = const Color(0xFFFB8C00);
                      } else if (lowerStatus == 'undercreated') {
                        jenis = 'Under Created';
                        jenisColor = const Color(0xFF546E7A);
                      } else if (lowerStatus == 'checkin') {
                        jenis = 'Checkin';
                        jenisColor = const Color(0xFF00897B);
                      } else if (lowerStatus == 'checkout') {
                        jenis = 'Checkout';
                        jenisColor = const Color(0xFF3949AB);
                      } else if (lowerStatus == 'reject' ||
                          lowerStatus == 'rejected' ||
                          lowerStatus == 'denied') {
                        jenis = 'Rejected';
                        jenisColor = const Color(0xFFE53935);
                      } else if (item.visitorStatus.isNotEmpty) {
                        jenis =
                            item.visitorStatus[0].toUpperCase() +
                            item.visitorStatus.substring(1);
                        jenisColor = const Color(0xFF546E7A);
                      } else {
                        jenis = 'Invitation';
                        jenisColor = const Color(0xFF6D4C41);
                      }
                    }
                  }

                  return GestureDetector(
                    onTap: () => _showInvitationDetailSheet(item),
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
                        border: Border.all(color: Colors.grey.shade100),
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
                                // No
                                Container(
                                  width: rw(context, 26),
                                  height: rw(context, 26),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF005596),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${itemIndex + 1 + (inviteCtrl.invitationCurrentPage.value * inviteCtrl.invitationPageSize.value)}',
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
                                    item.agenda.isEmpty ? '-' : item.agenda,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: rfs(context, 16),
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                hSpace(context, 6),
                                // Jenis badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: rw(context, 8),
                                    vertical: rh(context, 4),
                                  ),
                                  decoration: BoxDecoration(
                                    color: jenisColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(
                                      rw(context, 20),
                                    ),
                                    border: Border.all(
                                      color: jenisColor.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    jenis,
                                    style: TextStyle(
                                      fontSize: rfs(context, 12),
                                      fontWeight: FontWeight.w600,
                                      color: jenisColor,
                                    ),
                                  ),
                                ),
                                hSpace(context, 6),
                                // Expired badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: rw(context, 8),
                                    vertical: rh(context, 4),
                                  ),
                                  decoration: BoxDecoration(
                                    color: isExpired
                                        ? const Color(0xFFE53935)
                                        : const Color(0xFF43A047),
                                    borderRadius: BorderRadius.circular(
                                      rw(context, 20),
                                    ),
                                  ),
                                  child: Text(
                                    isExpired ? 'Expired' : 'Active',
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

                          // ── Body: info rows ───────────────────────
                          Padding(
                            padding: EdgeInsets.only(
                              left: rw(context, 16),
                              right: rw(context, 16),
                              top: rh(context, 12),
                              bottom: rh(context, 16),
                            ),
                            child: Column(
                              children: [
                                // Row 1: Visitor Type + Host
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildCardField(
                                        context,
                                        Icons.badge_outlined,
                                        'Visitor Type',
                                        item.visitorTypeName.isEmpty
                                            ? '-'
                                            : item.visitorTypeName,
                                      ),
                                    ),
                                    hSpace(context, 8),
                                    Expanded(
                                      child: _buildCardField(
                                        context,
                                        Icons.person_outline,
                                        'Host',
                                        item.hostName.isEmpty
                                            ? '-'
                                            : item.hostName,
                                      ),
                                    ),
                                  ],
                                ),
                                vSpace(context, 6),
                                // Row 2: Period Start + Period End
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildCardField(
                                        context,
                                        Icons.login_outlined,
                                        'Period Start',
                                        DateFormat(
                                          'dd MMMM yyyy, HH:mm',
                                        ).format(item.visitorPeriodStart),
                                      ),
                                    ),
                                    hSpace(context, 8),
                                    Expanded(
                                      child: _buildCardField(
                                        context,
                                        Icons.logout_outlined,
                                        'Period End',
                                        DateFormat(
                                          'dd MMMM yyyy, HH:mm',
                                        ).format(item.visitorPeriodEnd),
                                        color: isExpired
                                            ? Colors.red.shade600
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
        Obx(() {
          if (controller.invitationTotalRecords.value > 10) {
            return _buildInvitationPaginationBar();
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildShareLinkTab() {
    return const ShareLinkListInline();
  }

  Widget _buildQuickAccessTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Filter bar ──
        Padding(
          padding: EdgeInsets.only(
            left: rw(context, 20),
            right: rw(context, 20),
            top: rh(context, 16),
            bottom: rh(context, 6),
          ),
          child: SingleChildScrollView(
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
                            initialStartDate: startDateQuick,
                            initialEndDate: endDateQuick,
                            initialSiteId: inviteCtrl.selectedSiteIdQuick.value,
                            initialStatus: selectedStatusQuick,
                            showStatusFilter: false,
                            filterMode: 'quick_access',
                          ),
                        );

                    if (result != null) {
                      setState(() {
                        startDateQuick = result['startDate'];
                        endDateQuick = result['endDate'];
                        selectedGedungQuick = result['siteName'];
                        selectedStatusQuick = result['status'];
                      });
                      inviteCtrl.setQuickFilters(
                        start: startDateQuick,
                        end: endDateQuick,
                        siteId: result['siteId'],
                        siteName: result['siteName'],
                        status: result['status'],
                      );
                    }
                  },
                  child: _buildFilterChip(context, 'Filter'),
                ),
                if (selectedGedungQuick != null) ...[
                  hSpace(context, 8),
                  _buildFilterValueChip(
                    context,
                    selectedGedungQuick!,
                    onClear: () {
                      final inviteCtrl = Get.find<InvitationController>();
                      setState(() => selectedGedungQuick = null);
                      inviteCtrl.setQuickFilters(
                        start: startDateQuick,
                        end: endDateQuick,
                        siteId: null,
                        siteName: null,
                        status: selectedStatusQuick,
                      );
                    },
                  ),
                ],
                if (startDateQuick != null || endDateQuick != null) ...[
                  hSpace(context, 8),
                  _buildFilterValueChip(
                    context,
                    _formatDateRange(startDateQuick, endDateQuick),
                    onClear: () {
                      final inviteCtrl = Get.find<InvitationController>();
                      setState(() {
                        startDateQuick = null;
                        endDateQuick = null;
                      });
                      inviteCtrl.setQuickFilters(
                        start: null,
                        end: null,
                        siteId: inviteCtrl.selectedSiteIdQuick.value,
                        siteName: inviteCtrl.selectedSiteNameQuick.value,
                        status: selectedStatusQuick,
                      );
                    },
                  ),
                ],
                if (selectedStatusQuick != null &&
                    selectedStatusQuick!.isNotEmpty) ...[
                  hSpace(context, 8),
                  _buildFilterValueChip(
                    context,
                    'Status: $selectedStatusQuick',
                    onClear: () {
                      final inviteCtrl = Get.find<InvitationController>();
                      setState(() => selectedStatusQuick = null);
                      inviteCtrl.setQuickFilters(
                        start: startDateQuick,
                        end: endDateQuick,
                        siteId: inviteCtrl.selectedSiteIdQuick.value,
                        siteName: inviteCtrl.selectedSiteNameQuick.value,
                        status: null,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              final inviteCtrl = Get.find<InvitationController>();
              setState(() {
                startDateQuick = null;
                endDateQuick = null;
                selectedGedungQuick = null;
                selectedStatusQuick = null;
              });
              await inviteCtrl.fetchOngoingInvitations(clearFilters: true);
            },
            child: Obx(() {
              final inviteCtrl = Get.isRegistered<InvitationController>()
                  ? Get.find<InvitationController>()
                  : Get.put(InvitationController());

              final listToShow = inviteCtrl.quickAccessInvitations.toList();
              final isLoading = inviteCtrl.isLoading.value;

              if (isLoading && listToShow.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(rw(context, 40.0)),
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  ],
                );
              }

              if (listToShow.isEmpty) {
                final isIndonesian = Get.locale?.languageCode == 'id';
                return EmptyStateWidget(
                  illustration: const QuickAccessIllustration(),
                  icon: Icons.flash_on_rounded,
                  title: isIndonesian
                      ? 'Belum ada quick access'
                      : 'No quick access yet',
                  subtitle: isIndonesian
                      ? 'Buat quick access untuk mempermudah ojek online atau kurir pengantar makanan masuk ke area perusahaan dengan cepat.'
                      : 'Create quick access to make it easier for online motorcycle taxis or food delivery couriers to enter the company area quickly.',
                  buttonText: isIndonesian
                      ? 'Buat Quick Access'
                      : 'Create Quick Access',
                  onButtonPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const CreateQuickAccessDialog(),
                    ).then((result) {
                      if (result == true) {
                        controller.fetchOngoingInvitations(clearFilters: false);
                      }
                    });
                  },
                  tipsText: isIndonesian
                      ? 'Info: Quick Access sangat cocok untuk mitra pengantar makanan agar pengiriman makanan menjadi lebih praktis tanpa perlu persetujuan manual berulang.'
                      : 'Info: Quick Access is perfect for food delivery partners to make food delivery more practical without requiring repeated manual approval.',
                  showQuickActions: true,
                  mode: 'quick_access',
                );
              }

              final showTopLoading = isLoading && listToShow.isNotEmpty;

              return ListView.builder(
                padding: EdgeInsets.all(rw(context, 20.0)),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: listToShow.length + (showTopLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (showTopLoading && index == 0) {
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

                  final itemIndex = showTopLoading ? index - 1 : index;
                  final item = listToShow[itemIndex];
                  final isExpired = DateTime.now().isAfter(
                    item.visitorPeriodEnd,
                  );

                  return GestureDetector(
                    onTap: () => _showInvitationDetailSheet(item),
                    child: Container(
                      margin: EdgeInsets.only(bottom: rh(context, 16)),
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
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        children: [
                          // TOP ROW
                          Padding(
                            padding: EdgeInsets.only(
                              left: rw(context, 16),
                              right: rw(context, 16),
                              top: rh(context, 16),
                              bottom: rh(context, 12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: rw(context, 26),
                                  height: rw(context, 26),
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF005596),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${itemIndex + 1 + (inviteCtrl.quickCurrentPage.value * inviteCtrl.quickPageSize.value)}',
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
                                    item.agenda.isEmpty ? '-' : item.agenda,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: rfs(context, 16),
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                hSpace(context, 6),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: rw(context, 8),
                                    vertical: rh(context, 4),
                                  ),
                                  decoration: BoxDecoration(
                                    color: isExpired
                                        ? const Color(0xFFE53935)
                                        : const Color(0xFF43A047),
                                    borderRadius: BorderRadius.circular(
                                      rw(context, 20),
                                    ),
                                  ),
                                  child: Text(
                                    isExpired ? 'Expired' : 'Active',
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
                          // DETAILS
                          Padding(
                            padding: EdgeInsets.only(
                              left: rw(context, 16),
                              right: rw(context, 16),
                              top: rh(context, 12),
                              bottom: rh(context, 16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row 1: Visitor Name + Org
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildCardField(
                                        context,
                                        Icons.badge_outlined,
                                        'Visitor Type',
                                        item.visitorTypeName.isEmpty
                                            ? '-'
                                            : item.visitorTypeName,
                                      ),
                                    ),
                                    hSpace(context, 8),
                                    Expanded(
                                      child: _buildCardField(
                                        context,
                                        Icons.person_outline,
                                        'Host',
                                        item.hostName.isEmpty
                                            ? '-'
                                            : item.hostName,
                                      ),
                                    ),
                                  ],
                                ),
                                vSpace(context, 8),
                                // Row 2: Period Start + Period End
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildCardField(
                                        context,
                                        Icons.login_outlined,
                                        'Period Start',
                                        DateFormat(
                                          'dd MMMM yyyy, HH:mm',
                                        ).format(item.visitorPeriodStart),
                                      ),
                                    ),
                                    hSpace(context, 8),
                                    Expanded(
                                      child: _buildCardField(
                                        context,
                                        Icons.logout_outlined,
                                        'Period End',
                                        DateFormat(
                                          'dd MMMM yyyy, HH:mm',
                                        ).format(item.visitorPeriodEnd),
                                        color: isExpired
                                            ? Colors.red.shade600
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
        Obx(() {
          if (controller.quickTotalRecords.value > 10) {
            return _buildQuickAccessPaginationBar();
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildInvitationPaginationBar() {
    final start =
        (controller.invitationCurrentPage.value *
            controller.invitationPageSize.value) +
        1;
    final end = start + controller.ongoingInvitations.length - 1;
    final total = controller.invitationTotalRecords.value;

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
                  onPressed: controller.invitationCurrentPage.value > 0
                      ? () => controller.prevInvitationPage()
                      : null,
                ),
                Text(
                  '${controller.invitationCurrentPage.value + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed:
                      (controller.invitationCurrentPage.value + 1) *
                              controller.invitationPageSize.value <
                          total
                      ? () => controller.nextInvitationPage()
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessPaginationBar() {
    final start =
        (controller.quickCurrentPage.value *
            controller.quickPageSize.value) +
        1;
    final end = start + controller.quickAccessInvitations.length - 1;
    final total = controller.quickTotalRecords.value;

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
                  onPressed: controller.quickCurrentPage.value > 0
                      ? () => controller.prevQuickPage()
                      : null,
                ),
                Text(
                  '${controller.quickCurrentPage.value + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed:
                      (controller.quickCurrentPage.value + 1) *
                              controller.quickPageSize.value <
                          total
                      ? () => controller.nextQuickPage()
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper: compact 2-line info field inside card
  Widget _buildCardField(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? color,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: rw(context, 12), color: Colors.grey.shade400),
        hSpace(context, 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: rfs(context, 12),
                  color: Colors.grey.shade500,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: rfs(context, 10),
                        fontWeight: FontWeight.w600,
                        color: color ?? Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  if (trailing != null) ...[hSpace(context, 4), trailing],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInvitationDetailSheet(AccessPassModel item) {
    showInvitationDetailSheet(context, item);
  }
}

// ─── Filter UI and Formatting Helpers (Top-Level) ────────────────────────────
Widget _buildFilterChip(BuildContext context, String label) {
  return Container(
    height: rh(context, 32),
    padding: EdgeInsets.symmetric(horizontal: rw(context, 14)),
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

Widget _buildFilterValueChip(
  BuildContext context,
  String label, {
  required VoidCallback onClear,
}) {
  return Container(
    height: rh(context, 32),
    padding: EdgeInsets.symmetric(horizontal: rw(context, 10)),
    decoration: BoxDecoration(
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
            child: Icon(Icons.close, size: rw(context, 14), color: Colors.grey),
          ),
        ),
      ],
    ),
  );
}

String _formatDateRange(DateTime? start, DateTime? end) {
  if (start == null && end == null) return '';
  final format = DateFormat('dd MMMM yyyy');
  if (start != null && end != null) {
    return '${format.format(start)} - ${format.format(end)}';
  } else if (start != null) {
    return 'From ${format.format(start)}';
  } else {
    return 'To ${format.format(end!)}';
  }
}

// ─── _SheetField model ────────────────────────────────────────────────────────
void showInvitationDetailSheet(BuildContext context, AccessPassModel item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => InvitationDetailSheet(item: item),
  );
}

// ─── InvitationDetailSheet ─────────────────────────────────────────────────
class InvitationDetailSheet extends StatefulWidget {
  final AccessPassModel item;
  final bool isFullDetail;
  const InvitationDetailSheet({
    super.key,
    required this.item,
    this.isFullDetail = false,
  });

  @override
  State<InvitationDetailSheet> createState() => InvitationDetailSheetState();
}

class InvitationDetailSheetState extends State<InvitationDetailSheet> {
  String _sitePlaceName = '';
  bool _loadingSite = true;

  bool _loadingGroupVisitors = false;
  List<AccessPassModel> _groupVisitorModels = [];
  AccessPassModel? _selectedGroupVisitor;

  @override
  void initState() {
    super.initState();
    _fetchSiteDetail();
    _fetchGroupVisitors();
  }

  Future<void> _fetchGroupVisitors() async {
    if (mounted) setState(() => _loadingGroupVisitors = true);
    try {
      final controller = Get.isRegistered<InvitationController>()
          ? Get.find<InvitationController>()
          : Get.put(InvitationController());

      final List<AccessPassModel> models = [];
      // 1. Fetch group members directly from API (Dynamic as requested)
      final String fetchId = widget.item.id;
      final list = await controller.fetchTransactionVisitors(fetchId);

      final parentFlow = widget.item.flow;
      final parentSiteId = widget.item.siteId;
      final parentSitePlaceId = widget.item.sitePlaceId;
      final parentSitePlaceName = widget.item.sitePlaceName;
      final parentPeriodStart = widget.item.visitorPeriodStart;
      final parentPeriodEnd = widget.item.visitorPeriodEnd;
      final parentAgenda = widget.item.agenda;
      final parentHostName = widget.item.hostName;
      final parentVisitorTypeName = widget.item.visitorTypeName;
      final parentVisitorTypeId = widget.item.visitorTypeId;
      final parentGCode = widget.item.groupCode.isNotEmpty
          ? widget.item.groupCode
          : (widget.item.invitationCode.contains('-')
                ? widget.item.invitationCode.split('-').first
                : '');

      for (var visitor in list) {
        final mutableVisitor = Map<String, dynamic>.from(visitor);
        if ((mutableVisitor['flow']?.toString() ?? '').isEmpty) {
          mutableVisitor['flow'] = parentFlow;
        }
        if ((mutableVisitor['site_id']?.toString() ?? '').isEmpty &&
            (mutableVisitor['site_place']?.toString() ?? '').isEmpty) {
          mutableVisitor['site_id'] = parentSiteId;
        }

        final model = AccessPassModel.fromJson(mutableVisitor);

        final finalModel = AccessPassModel(
          id: model.id.isEmpty ? widget.item.id : model.id,
          agenda: model.agenda.isEmpty ? parentAgenda : model.agenda,
          initialTrxCode: model.initialTrxCode.isEmpty
              ? widget.item.initialTrxCode
              : model.initialTrxCode,
          host: model.host.isEmpty ? widget.item.host : model.host,
          isGroup: true,
          groupName: model.groupName.isEmpty
              ? widget.item.groupName
              : model.groupName,
          groupCode: parentGCode,
          visitorPeriodStart:
              (mutableVisitor['visitor_period_start'] ??
                      mutableVisitor['visit_start']) !=
                  null
              ? model.visitorPeriodStart
              : parentPeriodStart,
          visitorPeriodEnd:
              (mutableVisitor['visitor_period_end'] ??
                      mutableVisitor['visit_end']) !=
                  null
              ? model.visitorPeriodEnd
              : parentPeriodEnd,
          visitorNumber: model.visitorNumber,
          visitorCode: model.visitorCode.isEmpty
              ? widget.item.visitorCode
              : model.visitorCode,
          invitationCode: model.invitationCode.isEmpty
              ? widget.item.invitationCode
              : model.invitationCode,
          visitorStatus: model.visitorStatus.isEmpty
              ? widget.item.visitorStatus
              : model.visitorStatus,
          sitePlaceName: model.sitePlaceName.isEmpty
              ? parentSitePlaceName
              : model.sitePlaceName,
          hostName: model.hostName.isEmpty ? parentHostName : model.hostName,
          parkingSlot: model.parkingSlot,
          parkingArea: model.parkingArea,
          vehiclePlateNumber: model.vehiclePlateNumber,
          vehicleType: model.vehicleType,
          isDriving: model.isDriving,
          tz: model.tz.isEmpty ? widget.item.tz : model.tz,
          siteId: model.siteId.isEmpty ? parentSiteId : model.siteId,
          sitePlaceId: (model.sitePlaceId ?? '').isEmpty
              ? parentSitePlaceId
              : model.sitePlaceId,
          visitorName: model.visitorName,
          isPraregisterDone: model.isPraregisterDone,
          visitorRole: model.visitorRole.isEmpty
              ? widget.item.visitorRole
              : model.visitorRole,
          approvalStatus: model.approvalStatus.isEmpty
              ? widget.item.approvalStatus
              : model.approvalStatus,
          visitorTypeName: model.visitorTypeName.isEmpty
              ? parentVisitorTypeName
              : model.visitorTypeName,
          visitorTypeId: model.visitorTypeId.isEmpty
              ? parentVisitorTypeId
              : model.visitorTypeId,
          invitedByName: model.invitedByName.isEmpty
              ? widget.item.invitedByName
              : model.invitedByName,
          invitedBy: model.invitedBy.isEmpty
              ? widget.item.invitedBy
              : model.invitedBy,
          hostOrganizationName: model.hostOrganizationName.isEmpty
              ? widget.item.hostOrganizationName
              : model.hostOrganizationName,
          flow: model.flow,
          visitorOrganizationName: model.visitorOrganizationName,
          visitorPhone: model.visitorPhone,
          visitorEmail: model.visitorEmail,
          visitorIdentityId: model.visitorIdentityId,
          receiverName: model.receiverName,
          receiverEmail: model.receiverEmail,
          receiverPhone: model.receiverPhone,
          canTrackBle: model.canTrackBle,
          canAccess: model.canAccess,
        );
        models.add(finalModel);
      }

      if (mounted) {
        setState(() {
          _groupVisitorModels = models;
          if (models.isNotEmpty) {
            _selectedGroupVisitor = models.first;
          }
          _loadingGroupVisitors = false;
        });
      }
    } catch (e) {
      debugPrint('_fetchGroupVisitors error: $e');
      if (mounted) {
        setState(() => _loadingGroupVisitors = false);
      }
    }
  }

  /// Show a brief visitor profile bottom sheet (name, email, phone).
  void _showVisitorProfilePopup(BuildContext context, AccessPassModel model) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: rw(context, 16),
            vertical: rh(context, 16),
          ),
          padding: EdgeInsets.all(rw(context, 20)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(rw(context, 20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: rw(context, 40),
                height: rh(context, 4),
                margin: EdgeInsets.only(bottom: rh(context, 16)),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(rw(context, 2)),
                ),
              ),
              // Avatar
              CircleAvatar(
                radius: rw(context, 32),
                backgroundColor: const Color(
                  0xFF005596,
                ).withValues(alpha: 0.12),
                child: Text(
                  model.visitorName.isNotEmpty
                      ? model.visitorName[0].toUpperCase()
                      : 'V',
                  style: TextStyle(
                    fontSize: rfs(context, 24),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF005596),
                  ),
                ),
              ),
              vSpace(context, 12),
              Text(
                model.visitorName.isNotEmpty ? model.visitorName : 'Visitor',
                style: TextStyle(
                  fontSize: rfs(context, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              vSpace(context, 16),
              // Info rows
              _profileInfoRow(
                context,
                Icons.email_outlined,
                'Email',
                model.visitorEmail.isNotEmpty ? model.visitorEmail : '-',
              ),
              vSpace(context, 8),
              _profileInfoRow(
                context,
                Icons.phone_outlined,
                'Phone',
                model.visitorPhone.isNotEmpty ? model.visitorPhone : '-',
              ),
              vSpace(context, 8),
              _profileInfoRow(
                context,
                Icons.confirmation_number_outlined,
                'Invitation Code',
                model.invitationCode.isNotEmpty ? model.invitationCode : '-',
              ),
              vSpace(context, 8),
              _profileInfoRow(
                context,
                Icons.pin_outlined,
                'Visitor Number',
                model.visitorNumber.isNotEmpty ? model.visitorNumber : '-',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _profileInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: rw(context, 36),
          height: rw(context, 36),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(rw(context, 8)),
          ),
          child: Icon(icon, size: rw(context, 18), color: Colors.grey.shade600),
        ),
        hSpace(context, 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: rfs(context, 11),
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: rfs(context, 13),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _fetchSiteDetail() async {
    try {
      final api = ApiService();
      final hive = HiveService();
      final token = hive.getUser()?.token ?? '';
      final id = widget.item.id;
      if (token.isEmpty || id.isEmpty) {
        if (mounted) setState(() => _loadingSite = false);
        return;
      }
      final response = await api.getVisitorDetail(token, id);
      if (response.data != null &&
          (response.data['status'] == 'success' ||
              response.data['status_code'] == 200)) {
        final col = response.data['collection'];
        if (col != null) {
          setState(() {
            _sitePlaceName = col['site_place_name']?.toString() ?? '';
            _loadingSite = false;
          });
          return;
        }
      }
    } on DioException catch (e) {
      // 404 is expected when the visitor's id belongs to the transaction endpoint, not /visitor/{id}
      if (e.response?.statusCode != 404) {
        debugPrint('fetchSiteDetail error: ${e.message}');
      }
    } catch (e) {
      debugPrint('fetchSiteDetail error: $e');
    }
    if (mounted) setState(() => _loadingSite = false);
  }

  Future<void> _downloadBarcodePdf(List<AccessPassModel> models) async {
    try {
      final pdf = pw.Document();

      pw.Widget pdfField(String label, String value) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                label,
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
              pw.SizedBox(height: 1),
              pw.Text(
                value.isEmpty ? '-' : value,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),
        );
      }

      pw.Widget sectionHeader(String title) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
          child: pw.Row(
            children: [
              pw.Container(
                width: 3,
                height: 10,
                color: const PdfColor(0.0, 0.333, 0.588),
              ),
              pw.SizedBox(width: 5),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),
        );
      }

      pw.Widget buildPdfDigitalCard(AccessPassModel model) {
        return pw.Center(
          child: pw.Container(
            width: 270,
            height: 160,
            padding: const pw.EdgeInsets.all(16),
            decoration: const pw.BoxDecoration(
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
              gradient: pw.LinearGradient(
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
                colors: [
                  PdfColor(0.0, 0.333, 0.588),
                  PdfColor(0.098, 0.462, 0.823),
                  PdfColor(0.051, 0.278, 0.631),
                ],
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                        border: pw.Border.all(color: PdfColors.white, width: 1),
                      ),
                      child: pw.Text(
                        'VISITOR CARD',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Text(
                  model.visitorName.toUpperCase(),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  model.visitorNumber.isNotEmpty ? model.visitorNumber : '-',
                  style: pw.TextStyle(
                    color: const PdfColor(1.0, 1.0, 1.0, 0.88),
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      for (final model in models) {
        final isQuickAccess =
            model.flow.toLowerCase() == 'quickaccessvisit' ||
            model.visitorStatus.toLowerCase().trim() == 'quickaccess';
        final List<MapEntry<String, String>> fields = [
          MapEntry('Visitor Type', model.visitorTypeName),
          if (!isQuickAccess ||
              (model.visitorRole.isNotEmpty && model.visitorRole.trim() != '-'))
            MapEntry('Visitor Role', model.visitorRole),
          MapEntry('Name', model.visitorName),
          MapEntry('Email', model.visitorEmail),
          MapEntry('Phone', model.visitorPhone),
          MapEntry('Agenda', model.agenda),
          MapEntry('Organization', model.visitorOrganizationName),
          if (model.flow.toLowerCase() != 'quickaccessvisit')
            MapEntry('Identity ID', model.visitorIdentityId),
          MapEntry('Location', model.sitePlaceName),
          MapEntry('Invitation Code', model.invitationCode),
          MapEntry('Visitor Code', model.visitorCode),
          MapEntry('Group Name', model.groupName),
          if (model.flow.toLowerCase() != 'quickaccessvisit')
            MapEntry('Host', model.hostName),
          MapEntry('Vehicle Type', model.vehicleType),
          MapEntry('Vehicle Plate', model.vehiclePlateNumber),
          if (model.flow.toLowerCase() == 'quickaccessvisit') ...[
            MapEntry('Receiver Name', model.receiverName),
            if (model.receiverPhone.isNotEmpty &&
                model.receiverPhone.trim() != '-')
              MapEntry('Receiver Phone', model.receiverPhone),
            MapEntry('Receiver Email', model.receiverEmail),
          ],
        ];

        final List<pw.Widget> rows = [];
        for (int i = 0; i < fields.length; i += 2) {
          final f1 = fields[i];
          final hasSecond = i + 1 < fields.length;
          final f2 = hasSecond ? fields[i + 1] : null;
          rows.add(
            pw.Row(
              children: [
                pw.Expanded(child: pdfField(f1.key, f1.value)),
                if (hasSecond) ...[
                  pw.Container(width: 1, height: 24, color: PdfColors.grey200),
                  pw.Expanded(child: pdfField(f2!.key, f2.value)),
                ] else
                  pw.Expanded(child: pw.SizedBox()),
              ],
            ),
          );
          if (i + 2 < fields.length) {
            rows.add(pw.Container(height: 1, color: PdfColors.grey200));
          }
        }

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            build: (pw.Context context) {
              return [
                // Header banner
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
                    ),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'VISITOR ACCESS PASS',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor(0.0, 0.333, 0.588),
                        ),
                      ),
                      pw.Text(
                        DateFormat('dd MMM yyyy').format(DateTime.now()),
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 6),

                // 1. Visitor Information
                sectionHeader('Visitor Information'),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                    border: pw.Border.all(color: PdfColors.grey200, width: 1),
                  ),
                  child: pw.Column(children: rows),
                ),
                pw.SizedBox(height: 6),

                // 2. Visit Period
                sectionHeader('Visit Period'),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                    border: pw.Border.all(color: PdfColors.grey200, width: 1),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pdfField(
                          'Period Start',
                          DateFormat(
                            'dd MMMM yyyy, HH:mm',
                          ).format(model.visitorPeriodStart),
                        ),
                      ),
                      pw.Container(
                        width: 1,
                        height: 24,
                        color: PdfColors.grey200,
                      ),
                      pw.Expanded(
                        child: pdfField(
                          'Period End',
                          DateFormat(
                            'dd MMMM yyyy, HH:mm',
                          ).format(model.visitorPeriodEnd),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 6),

                // 3. Access Pass
                sectionHeader('Access Pass'),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                    border: pw.Border.all(color: PdfColors.grey200, width: 1),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Container(
                        width: 90,
                        height: 90,
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(6),
                          ),
                          border: pw.Border.all(
                            color: PdfColors.grey200,
                            width: 1,
                          ),
                        ),
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: model.visitorNumber.isNotEmpty
                              ? model.visitorNumber
                              : 'N/A',
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(
                            model.canTrackBle == true
                                ? 'Tracked'
                                : 'Not Tracked',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: model.canTrackBle == true
                                  ? PdfColors.green700
                                  : PdfColors.red700,
                            ),
                          ),
                          pw.SizedBox(width: 12),
                          pw.Text(
                            model.canAccess == true
                                ? 'Accessible'
                                : 'Not Accessible',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: model.canAccess == true
                                  ? PdfColors.green700
                                  : PdfColors.red700,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Show this while visiting',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 1),
                      pw.Text(
                        'ID : ${model.visitorNumber.isNotEmpty ? model.visitorNumber : '-'}',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isQuickAccess) ...[
                  pw.SizedBox(height: 6),

                  // 4. Digital Invitation Card
                  sectionHeader('Digital Invitation Card'),
                  buildPdfDigitalCard(model),
                ],
              ];
            },
          ),
        );
      }

      final bytes = await pdf.save();

      String? path;
      final firstModel = models.first;
      final visitorNumber = firstModel.visitorNumber.isNotEmpty
          ? firstModel.visitorNumber
          : 'N_A';
      bool saveSuccess = false;

      if (Platform.isAndroid) {
        try {
          final dir = Directory('/storage/emulated/0/Download');
          if (await dir.exists()) {
            final testPath = '${dir.path}/access_pass_$visitorNumber.pdf';
            final file = File(testPath);
            await file.writeAsBytes(bytes);
            path = testPath;
            saveSuccess = true;
          }
        } catch (e) {
          debugPrint(
            'Failed to save barcode PDF to public Download folder: $e',
          );
        }
      }

      if (!saveSuccess) {
        final dir = await getApplicationDocumentsDirectory();
        path = '${dir.path}/access_pass_$visitorNumber.pdf';
        final file = File(path);
        await file.writeAsBytes(bytes);
      }

      Get.snackbar(
        'Success',
        'PDF Access Pass downloaded successfully!',
        messageText: const Text(
          'PDF Access Pass downloaded successfully!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        titleText: const SizedBox.shrink(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
        mainButton: TextButton(
          onPressed: () {
            OpenFilex.open(path!);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'OPEN',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

      // Auto open the PDF file immediately
      OpenFilex.open(path!);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download PDF Access Pass',
        messageText: const Text(
          'Failed to download PDF Access Pass',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        titleText: const SizedBox.shrink(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'checkin':
      case 'approved':
      case 'approve':
      case 'success':
        return const Color(0xFF00897B);
      case 'checkout':
        return const Color(0xFF3949AB);
      case 'available':
        return const Color(0xFF8E24AA);
      case 'waiting':
      case 'pending':
        return const Color(0xFFFB8C00);
      case 'denied':
      case 'deny':
      case 'rejected':
      case 'reject':
        return const Color(0xFFE53935);
      case 'quickaccess':
        return const Color(0xFFD81B60);
      case 'preregis':
      case 'praregis':
        return const Color(0xFF00B0FF);
      default:
        return const Color(0xFF546E7A);
    }
  }

  String _displayStatus(String status) {
    final lowerStatus = status.toLowerCase().trim();
    if (lowerStatus == 'available') {
      return 'Available';
    } else if (lowerStatus == 'pending' || lowerStatus == 'waiting') {
      return 'Pending';
    } else if (lowerStatus == 'undercreated') {
      return 'Under Created';
    } else if (lowerStatus == 'checkin') {
      return 'Checkin';
    } else if (lowerStatus == 'checkout') {
      return 'Checkout';
    } else if (lowerStatus == 'reject' ||
        lowerStatus == 'rejected' ||
        lowerStatus == 'denied' ||
        lowerStatus == 'deny') {
      return 'Rejected';
    } else if (lowerStatus == 'preregis' ||
        lowerStatus == 'praregis' ||
        lowerStatus == 'praregister') {
      return 'Praregis';
    } else if (lowerStatus == 'quickaccess') {
      return 'Quick Access';
    } else if (status.isNotEmpty) {
      return status[0].toUpperCase() + status.substring(1);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    // Fallback to _selectedGroupVisitor if it's loaded, otherwise use item
    final selectedItem = _selectedGroupVisitor ?? item;
    final isExpired = selectedItem.visitorPeriodEnd.isBefore(DateTime.now());
    final statusColor = _statusColor(selectedItem.visitorStatus);
    final isQuickAccess =
        selectedItem.flow.toLowerCase() == 'quickaccessvisit' ||
        selectedItem.visitorStatus.toLowerCase().trim() == 'quickaccess';

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(rw(context, 20)),
              topRight: Radius.circular(rw(context, 20)),
            ),
          ),
          child: Column(
            children: [
              // ── Drag handle ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.only(top: rh(context, 12)),
                child: Container(
                  width: rw(context, 40),
                  height: rh(context, 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(rw(context, 2)),
                  ),
                ),
              ),

              // ── Header ─────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 20),
                  vertical: rh(context, 14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(rw(context, 10)),
                      decoration: BoxDecoration(
                        color: const Color(0xFF005596).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(rw(context, 10)),
                      ),
                      child: const Icon(
                        Icons.person_pin_circle_outlined,
                        color: Color(0xFF005596),
                      ),
                    ),
                    hSpace(context, 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Detail',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: rfs(context, 16),
                              color: Colors.black87,
                            ),
                          ),
                          vSpace(context, 2),
                          Text(
                            'Agenda ${selectedItem.agenda.isEmpty ? '-' : selectedItem.agenda}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: rfs(context, 13),
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    hSpace(context, 8),
                    GestureDetector(
                      onTap: () {
                        final barcodeItems = _groupVisitorModels.isNotEmpty
                            ? _groupVisitorModels
                            : [selectedItem];
                        _downloadBarcodePdf([barcodeItems.first]);
                      },
                      child: Container(
                        width: rw(context, 32),
                        height: rw(context, 32),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F1FB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.download_rounded,
                          size: 16,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ),
                    hSpace(context, 8),
                    if (selectedItem.visitorStatus.isNotEmpty &&
                        selectedItem.visitorStatus.toLowerCase().trim() !=
                            'quickaccess') ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 10),
                          vertical: rh(context, 5),
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(rw(context, 20)),
                        ),
                        child: Text(
                          _displayStatus(selectedItem.visitorStatus),
                          style: TextStyle(
                            fontSize: rfs(context, 12),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      hSpace(context, 8),
                    ],
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 10),
                        vertical: rh(context, 5),
                      ),
                      decoration: BoxDecoration(
                        color: isExpired
                            ? const Color(0xFFE53935)
                            : const Color(0xFF43A047),
                        borderRadius: BorderRadius.circular(rw(context, 20)),
                      ),
                      child: Text(
                        isExpired ? 'Expired' : 'Active',
                        style: TextStyle(
                          fontSize: rfs(context, 12),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: Colors.grey.shade100),

              // ── Scrollable body ────────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(context, 20),
                    vertical: rh(context, 16),
                  ),
                  children: [
                    Builder(
                      builder: (context) {
                        List<Widget> buildInfoBlock(
                          AccessPassModel visitor, [
                          int? index,
                        ]) {
                          final expired = visitor.visitorPeriodEnd.isBefore(
                            DateTime.now(),
                          );
                          final sColor = _statusColor(visitor.visitorStatus);
                          final isQuickAccess =
                              visitor.flow.toLowerCase() ==
                                  'quickaccessvisit' ||
                              visitor.visitorStatus.toLowerCase().trim() ==
                                  'quickaccess';

                          return [
                            // 1. Visitor Information
                            _section(
                              context,
                              index != null
                                  ? 'Visitor Information ${index + 1}'
                                  : 'Visitor Information',
                              trailing: widget.isFullDetail
                                  ? null
                                  : GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (ctx) =>
                                              InvitationDetailSheet(
                                                item: widget.item,
                                                isFullDetail: true,
                                              ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'More',
                                            style: TextStyle(
                                              fontSize: rfs(context, 12),
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF005596),
                                            ),
                                          ),
                                          hSpace(context, 4),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: rw(context, 16),
                                            color: const Color(0xFF005596),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            _grid(
                              context,
                              sColor,
                              widget.isFullDetail
                                  ? [
                                      _SheetField(
                                        'Visitor Type',
                                        visitor.visitorTypeName.isEmpty
                                            ? '-'
                                            : visitor.visitorTypeName,
                                        Icons.badge_outlined,
                                      ),
                                      if (!isQuickAccess ||
                                          (visitor.visitorRole.isNotEmpty &&
                                              visitor.visitorRole.trim() !=
                                                  '-'))
                                        _SheetField(
                                          'Visitor Role',
                                          visitor.visitorRole.isEmpty
                                              ? '-'
                                              : visitor.visitorRole,
                                          Icons.work_outline,
                                        ),
                                      _SheetField(
                                        'Name',
                                        visitor.visitorName.isEmpty
                                            ? '-'
                                            : visitor.visitorName,
                                        Icons.person_outline,
                                      ),
                                      _SheetField(
                                        'Email',
                                        visitor.visitorEmail.isEmpty
                                            ? '-'
                                            : visitor.visitorEmail,
                                        Icons.email_outlined,
                                      ),
                                      _SheetField(
                                        'Phone',
                                        visitor.visitorPhone.isEmpty
                                            ? '-'
                                            : visitor.visitorPhone,
                                        Icons.phone_outlined,
                                      ),
                                      _SheetField(
                                        'Agenda',
                                        visitor.agenda.isEmpty
                                            ? '-'
                                            : visitor.agenda,
                                        Icons.event_note_outlined,
                                      ),
                                      _SheetField(
                                        'Organization',
                                        visitor.visitorOrganizationName.isEmpty
                                            ? '-'
                                            : visitor.visitorOrganizationName,
                                        Icons.business_outlined,
                                      ),
                                      if (visitor.flow.toLowerCase() !=
                                          'quickaccessvisit')
                                        _SheetField(
                                          'Identity ID',
                                          visitor.visitorIdentityId.isEmpty
                                              ? '-'
                                              : visitor.visitorIdentityId,
                                          Icons.credit_card_outlined,
                                        ),
                                      _SheetField(
                                        'Location',
                                        _loadingSite
                                            ? '...'
                                            : (visitor.sitePlaceName.isNotEmpty
                                                  ? visitor.sitePlaceName
                                                  : (_sitePlaceName.isEmpty
                                                        ? '-'
                                                        : _sitePlaceName)),
                                        Icons.location_on_outlined,
                                      ),
                                      _SheetField(
                                        'Invitation Code',
                                        visitor.invitationCode.isEmpty
                                            ? '-'
                                            : visitor.invitationCode,
                                        Icons.confirmation_number_outlined,
                                        isCode: true,
                                      ),
                                      _SheetField(
                                        'Visitor Number',
                                        visitor.visitorCode.isEmpty
                                            ? '-'
                                            : visitor.visitorCode,
                                        Icons.pin_outlined,
                                      ),
                                      _SheetField(
                                        'Group Name',
                                        visitor.groupName.isEmpty
                                            ? '-'
                                            : visitor.groupName,
                                        Icons.group_outlined,
                                      ),
                                      if (visitor.flow.toLowerCase() !=
                                          'quickaccessvisit')
                                        _SheetField(
                                          'Host',
                                          visitor.hostName.isEmpty
                                              ? '-'
                                              : visitor.hostName,
                                          Icons.person_outline,
                                        ),
                                      _SheetField(
                                        'Vehicle Type',
                                        visitor.vehicleType.isEmpty
                                            ? '-'
                                            : visitor.vehicleType,
                                        Icons.directions_car_outlined,
                                      ),
                                      _SheetField(
                                        'Vehicle Plate',
                                        visitor.vehiclePlateNumber.isEmpty
                                            ? '-'
                                            : visitor.vehiclePlateNumber,
                                        Icons.subtitles_outlined,
                                      ),
                                      if (visitor.flow.toLowerCase() ==
                                          'quickaccessvisit') ...[
                                        _SheetField(
                                          'Receiver Name',
                                          visitor.receiverName.isEmpty
                                              ? '-'
                                              : visitor.receiverName,
                                          Icons.person_outline,
                                        ),
                                        if (visitor.receiverPhone.isNotEmpty &&
                                            visitor.receiverPhone.trim() != '-')
                                          _SheetField(
                                            'Receiver Phone',
                                            visitor.receiverPhone.isEmpty
                                                ? '-'
                                                : visitor.receiverPhone,
                                            Icons.phone_outlined,
                                          ),
                                        _SheetField(
                                          'Receiver Email',
                                          visitor.receiverEmail.isEmpty
                                              ? '-'
                                              : visitor.receiverEmail,
                                          Icons.email_outlined,
                                        ),
                                      ],
                                    ]
                                  : [
                                      _SheetField(
                                        'Visitor Type',
                                        visitor.visitorTypeName.isEmpty
                                            ? '-'
                                            : visitor.visitorTypeName,
                                        Icons.badge_outlined,
                                      ),
                                      if (visitor.flow.toLowerCase() !=
                                          'quickaccessvisit')
                                        _SheetField(
                                          'Visitor Role',
                                          visitor.visitorRole.isEmpty
                                              ? '-'
                                              : visitor.visitorRole,
                                          Icons.work_outline,
                                        ),

                                      _SheetField(
                                        'Location',
                                        _loadingSite
                                            ? '...'
                                            : (visitor.sitePlaceName.isNotEmpty
                                                  ? visitor.sitePlaceName
                                                  : (_sitePlaceName.isEmpty
                                                        ? '-'
                                                        : _sitePlaceName)),
                                        Icons.location_on_outlined,
                                      ),
                                      _SheetField(
                                        'Group Name',
                                        visitor.groupName.isEmpty
                                            ? '-'
                                            : visitor.groupName,
                                        Icons.group_outlined,
                                      ),
                                      if (visitor.flow.toLowerCase() !=
                                          'quickaccessvisit')
                                        _SheetField(
                                          'Host',
                                          visitor.hostName.isEmpty
                                              ? '-'
                                              : visitor.hostName,
                                          Icons.person_outline,
                                        ),
                                      _SheetField(
                                        'Agenda',
                                        visitor.agenda.isEmpty
                                            ? '-'
                                            : visitor.agenda,
                                        Icons.event_note_outlined,
                                      ),
                                    ],
                              isExpired: expired,
                            ),
                            if (!widget.isFullDetail) ...[
                              vSpace(context, 16),
                              // 2. Visit Period
                              _section(context, 'Visit Period'),
                              // Start / End
                              Container(
                                padding: EdgeInsets.all(rw(context, 14)),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(
                                    rw(context, 10),
                                  ),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.login_outlined,
                                                size: rw(context, 14),
                                                color: Colors.green.shade600,
                                              ),
                                              hSpace(context, 4),
                                              Text(
                                                'Start',
                                                style: TextStyle(
                                                  fontSize: rfs(context, 12),
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          vSpace(context, 4),
                                          Text(
                                            DateFormat('dd MMMM yyyy').format(
                                              visitor.visitorPeriodStart,
                                            ),
                                            style: TextStyle(
                                              fontSize: rfs(context, 12),
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('HH:mm').format(
                                              visitor.visitorPeriodStart,
                                            ),
                                            style: TextStyle(
                                              fontSize: rfs(context, 12),
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: rh(context, 50),
                                      color: Colors.grey.shade300,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: rw(context, 12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.logout_outlined,
                                                  size: rw(context, 14),
                                                  color: expired
                                                      ? Colors.red.shade600
                                                      : Colors.grey.shade500,
                                                ),
                                                hSpace(context, 4),
                                                Text(
                                                  'End',
                                                  style: TextStyle(
                                                    fontSize: rfs(context, 12),
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            vSpace(context, 4),
                                            Text(
                                              DateFormat('dd MMMM yyyy').format(
                                                visitor.visitorPeriodEnd,
                                              ),
                                              style: TextStyle(
                                                fontSize: rfs(context, 12),
                                                fontWeight: FontWeight.w700,
                                                color: expired
                                                    ? Colors.red.shade600
                                                    : Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('HH:mm').format(
                                                visitor.visitorPeriodEnd,
                                              ),
                                              style: TextStyle(
                                                fontSize: rfs(context, 12),
                                                color: expired
                                                    ? Colors.red.shade400
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            vSpace(context, widget.isFullDetail ? 24 : 16),
                          ];
                        }

                        if (widget.isFullDetail) {
                          final barcodeItems = _groupVisitorModels.isNotEmpty
                              ? _groupVisitorModels
                              : [selectedItem];
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: barcodeItems
                                .asMap()
                                .entries
                                .expand(
                                  (e) => buildInfoBlock(
                                    e.value,
                                    barcodeItems.length > 1 ? e.key : null,
                                  ),
                                )
                                .toList(),
                          );
                        } else {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: buildInfoBlock(selectedItem),
                          );
                        }
                      },
                    ),

                    if (!widget.isFullDetail) ...[
                      Builder(
                        builder: (context) {
                          final barcodeItems = _groupVisitorModels.isNotEmpty
                              ? _groupVisitorModels
                              : [selectedItem];
                          final others = barcodeItems
                              .where((v) => v.id != selectedItem.id)
                              .toList();

                          if (others.isEmpty) return const SizedBox.shrink();

                          // Max 6 avatars shown inline; if more, show 5 + "More" button at slot 6
                          const int maxVisible = 6;
                          final bool hasMore = others.length > maxVisible;
                          final List<AccessPassModel> visibleOthers = hasMore
                              ? others.sublist(0, maxVisible - 1)
                              : others;
                          final int remaining =
                              others.length - visibleOthers.length;

                          final List<Color> avatarColors = [
                            const Color(0xFF1565C0),
                            const Color(0xFF00695C),
                            const Color(0xFFAD1457),
                            const Color(0xFF6A1B9A),
                            const Color(0xFF37474F),
                            const Color(0xFFE65100),
                            const Color(0xFF2E7D32),
                          ];

                          Widget buildAvatar(
                            AccessPassModel model,
                            int idx, {
                            bool isMore = false,
                          }) {
                            final initials = model.visitorName.isNotEmpty
                                ? model.visitorName[0].toUpperCase()
                                : 'V';
                            final avatarColor =
                                avatarColors[idx % avatarColors.length];
                            final firstName = model.visitorName.isNotEmpty
                                ? model.visitorName.trim().split(' ').first
                                : 'Visitor';

                            return GestureDetector(
                              onTap: () =>
                                  _showVisitorProfilePopup(context, model),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: rw(context, 28),
                                    backgroundColor: avatarColor.withValues(
                                      alpha: 0.15,
                                    ),
                                    child: Text(
                                      initials,
                                      style: TextStyle(
                                        color: avatarColor,
                                        fontSize: rfs(context, 15),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  vSpace(context, 4),
                                  SizedBox(
                                    width: rw(context, 62),
                                    child: Text(
                                      firstName,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: rfs(context, 11),
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          Widget buildMoreButton() {
                            return GestureDetector(
                              onTap: () {
                                // Open Instagram-style modal with all others
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) => _OthersVisitorSheet(
                                    visitors: others,
                                    avatarColors: avatarColors,
                                    onVisitorTap: (model) {
                                      _showVisitorProfilePopup(context, model);
                                    },
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: rw(context, 28),
                                    backgroundColor: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.more_horiz_rounded,
                                      color: Colors.grey.shade600,
                                      size: rw(context, 22),
                                    ),
                                  ),
                                  vSpace(context, 4),
                                  SizedBox(
                                    width: rw(context, 62),
                                    child: Text(
                                      '+$remaining more',
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: rfs(context, 11),
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _section(context, 'Others Visitor'),
                              if (_loadingGroupVisitors)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else
                                SizedBox(
                                  height: rh(context, 88),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              visibleOthers.length +
                                              (hasMore ? 1 : 0),
                                          separatorBuilder: (context, index) =>
                                              hSpace(context, 12),
                                          itemBuilder: (context, index) {
                                            if (hasMore &&
                                                index == visibleOthers.length) {
                                              return buildMoreButton();
                                            }
                                            return buildAvatar(
                                              visibleOthers[index],
                                              index,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              vSpace(context, 16),
                            ],
                          );
                        },
                      ),

                      if (!widget.isFullDetail) ...[
                        _section(context, 'Access Pass'),
                        (() {
                          final barcodeItems = _groupVisitorModels.isNotEmpty
                              ? _groupVisitorModels
                              : [selectedItem];
                          // Always show only the first visitor
                          final model = barcodeItems.first;

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: rw(context, 0),
                              vertical: rh(context, 4),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(rw(context, 16)),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  rw(context, 16),
                                ),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // QR Code Box
                                  Container(
                                    padding: EdgeInsets.all(rw(context, 10)),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        rw(context, 10),
                                      ),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: QrImageView(
                                      data: model.visitorNumber.isNotEmpty
                                          ? model.visitorNumber
                                          : 'N/A',
                                      version: QrVersions.auto,
                                      size: rw(context, 175),
                                    ),
                                  ),
                                  vSpace(context, 12),

                                  // Tracked / Accessible Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        model.canTrackBle == true
                                            ? 'Tracked'
                                            : 'Not Tracked',
                                        style: TextStyle(
                                          color: model.canTrackBle == true
                                              ? const Color(0xFF43A047)
                                              : const Color(0xFFE53935),
                                          fontSize: rfs(context, 11),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      hSpace(context, 16),
                                      Text(
                                        model.canAccess == true
                                            ? 'Accessible'
                                            : 'Not Accessible',
                                        style: TextStyle(
                                          color: model.canAccess == true
                                              ? const Color(0xFF43A047)
                                              : const Color(0xFFE53935),
                                          fontSize: rfs(context, 11),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  vSpace(context, 10),

                                  // Show this while visiting
                                  Text(
                                    'Show this while visiting',
                                    style: TextStyle(
                                      fontSize: rfs(context, 12),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  vSpace(context, 2),

                                  // ID
                                  Text(
                                    'ID : ${model.visitorNumber.isNotEmpty ? model.visitorNumber : '-'}',
                                    style: TextStyle(
                                      fontSize: rfs(context, 13),
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })(),
                        vSpace(context, 16),
                      ],

                      // ── Digital Invitation Card section ───────────────────
                      if (!widget.isFullDetail &&
                          widget.item.flow.toLowerCase() !=
                              'quickaccessvisit') ...[
                        StatefulBuilder(
                          builder: (context, setCardState) {
                            final cardItems = _groupVisitorModels.isNotEmpty
                                ? _groupVisitorModels
                                : [selectedItem];
                            int cardIndex = 0;
                            // One GlobalKey per card for RepaintBoundary capture
                            final cardKeys = List.generate(
                              cardItems.length,
                              (_) => GlobalKey(),
                            );

                            Future<void> downloadActiveCard() async {
                              try {
                                final key = cardKeys[cardIndex];
                                final boundary =
                                    key.currentContext?.findRenderObject()
                                        as RenderRepaintBoundary?;
                                if (boundary == null) return;

                                final image = await boundary.toImage(
                                  pixelRatio: 3.0,
                                );
                                final byteData = await image.toByteData(
                                  format: ui.ImageByteFormat.png,
                                );
                                if (byteData == null) return;
                                final pngBytes = byteData.buffer.asUint8List();

                                final model = cardItems[cardIndex];
                                final visitorNum =
                                    model.visitorNumber.isNotEmpty
                                    ? model.visitorNumber
                                    : 'invitation_card';

                                String? path;
                                bool saveSuccess = false;

                                if (Platform.isAndroid) {
                                  try {
                                    final dir = Directory(
                                      '/storage/emulated/0/Download',
                                    );
                                    if (await dir.exists()) {
                                      final testPath =
                                          '${dir.path}/visitor_card_$visitorNum.png';
                                      final file = File(testPath);
                                      await file.writeAsBytes(pngBytes);
                                      path = testPath;
                                      saveSuccess = true;
                                    }
                                  } catch (e) {
                                    debugPrint(
                                      'Failed to save visitor card PNG to public Download folder: $e',
                                    );
                                  }
                                }

                                if (!saveSuccess) {
                                  final dir =
                                      await getApplicationDocumentsDirectory();
                                  path =
                                      '${dir.path}/visitor_card_$visitorNum.png';
                                  final file = File(path);
                                  await file.writeAsBytes(pngBytes);
                                }

                                Get.snackbar(
                                  'Success',
                                  'Visitor Card berhasil diunduh!',
                                  messageText: const Text(
                                    'Visitor Card berhasil diunduh!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  titleText: const SizedBox.shrink(),
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 6),
                                  mainButton: TextButton(
                                    onPressed: () => OpenFilex.open(path!),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'BUKA',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );

                                // Auto open the Visitor Card file immediately
                                OpenFilex.open(path!);
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  'Gagal mengunduh Visitor Card',
                                  messageText: const Text(
                                    'Gagal mengunduh Visitor Card',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  titleText: const SizedBox.shrink(),
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            }

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _section(context, 'Digital Invitation Card'),
                                // Static single card — first visitor only
                                (() {
                                  final model = cardItems.first;
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: rw(context, 0),
                                    ),
                                    child: RepaintBoundary(
                                      key: cardKeys[0],
                                      child: _DigitalInvitationCard(
                                        name: model.visitorName.isNotEmpty
                                            ? model.visitorName
                                            : '-',
                                        visitorNumber:
                                            model.visitorNumber.isNotEmpty
                                            ? model.visitorNumber
                                            : '-',
                                      ),
                                    ),
                                  );
                                })(),
                              ],
                            );
                          },
                        ),
                        vSpace(context, 16),
                      ],
                    ],
                  ],
                ),
              ),

              // ── Close button ───────────────────────────────────────────
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    rw(context, 20),
                    0,
                    rw(context, 20),
                    rh(context, 16),
                  ),
                  child: SizedBox(
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _section(BuildContext context, String title, {Widget? trailing}) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 10)),
      child: Row(
        children: [
          Container(
            width: rw(context, 3),
            height: rh(context, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF005596),
              borderRadius: BorderRadius.circular(rw(context, 2)),
            ),
          ),
          hSpace(context, 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: rfs(context, 14),
                color: Colors.black87,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _grid(
    BuildContext context,
    Color statusColor,
    List<_SheetField> fields, {
    bool isExpired = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(rw(context, 10)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: List.generate(fields.length, (i) {
          final f = fields[i];
          final isLast = i == fields.length - 1;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 14),
                  vertical: rh(context, 10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      f.icon,
                      size: rw(context, 16),
                      color: Colors.grey.shade400,
                    ),
                    hSpace(context, 10),
                    SizedBox(
                      width: rw(context, 100),
                      child: Text(
                        f.label,
                        style: TextStyle(
                          fontSize: rfs(context, 12),
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: f.badgeColor != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: rw(context, 8),
                                    vertical: rh(context, 3),
                                  ),
                                  decoration: BoxDecoration(
                                    color: f.badgeColor,
                                    borderRadius: BorderRadius.circular(
                                      rw(context, 4),
                                    ),
                                  ),
                                  child: Text(
                                    f.value,
                                    style: TextStyle(
                                      fontSize: rfs(context, 12),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    f.value,
                                    style: TextStyle(
                                      fontSize: rfs(context, 12),
                                      fontWeight: FontWeight.w600,
                                      color: f.isCode
                                          ? (isExpired
                                                ? Colors.grey.shade400
                                                : const Color(0xFF005596))
                                          : Colors.black87,
                                    ),
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                if (f.isCode) ...[
                                  hSpace(context, 6),
                                  GestureDetector(
                                    onTap: () {
                                      if (isExpired) {
                                        Get.snackbar(
                                          'Info',
                                          'Invitation has expired, code cannot be copied.',
                                          snackPosition: SnackPosition.TOP,
                                          backgroundColor: Colors.red.shade600,
                                          colorText: Colors.white,
                                          duration: const Duration(seconds: 1),
                                          margin: EdgeInsets.all(
                                            rw(context, 10),
                                          ),
                                        );
                                        return;
                                      }
                                      Clipboard.setData(
                                        ClipboardData(text: f.value),
                                      );
                                      Get.snackbar(
                                        'Copied',
                                        'Copied to clipboard',
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                        duration: const Duration(seconds: 1),
                                        margin: EdgeInsets.all(rw(context, 10)),
                                      );
                                    },
                                    child: Icon(
                                      Icons.copy,
                                      size: rw(context, 14),
                                      color: isExpired
                                          ? Colors.grey.shade400
                                          : const Color(0xFF005596),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade200,
                  indent: rw(context, 14),
                  endIndent: rw(context, 14),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── _SheetField model ────────────────────────────────────────────────────────
class _SheetField {
  final String label;
  final String value;
  final IconData icon;
  final bool isCode;
  final Color? badgeColor;

  const _SheetField(
    this.label,
    this.value,
    this.icon, {
    this.isCode = false,
    this.badgeColor,
  });
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
  Worker? _listWorker;

  // Local Share Link filter state
  DateTime? startDateShare;
  DateTime? endDateShare;
  String? selectedGedungShare;
  String? selectedStatusShare;

  @override
  void initState() {
    super.initState();

    // Restore filter states from controller
    startDateShare = controller.startDateShare.value;
    endDateShare = controller.endDateShare.value;
    selectedGedungShare = controller.selectedSiteNameShare.value.isEmpty
        ? null
        : controller.selectedSiteNameShare.value;
    selectedStatusShare = controller.selectedStatusShare.value.isEmpty
        ? null
        : controller.selectedStatusShare.value;

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
  }

  @override
  void dispose() {
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

      Widget listWidget;
      if (controller.shareLinks.isEmpty) {
        final isIndonesian = Get.locale?.languageCode == 'id';
        listWidget = EmptyStateWidget(
          illustration: const ShareLinkIllustration(),
          icon: Icons.add_link_rounded,
          title: isIndonesian ? 'Belum ada share link' : 'No share links yet',
          subtitle: isIndonesian
              ? 'Buat share link untuk membagikan akses pendaftaran mandiri bagi tamu Anda, baik sekali pakai maupun berulang.'
              : 'Create share links to share self-registration access for your guests, either for one-time or recurring use.',
          buttonText: isIndonesian ? 'Buat Share Link' : 'Create Share Link',
          onButtonPressed: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const CreateShareLinkDialog(),
            ).then((_) => controller.fetchShareLinks());
          },
          tipsText: isIndonesian
              ? 'Info: Share link sangat cocok jika Anda ingin mengundang banyak orang tanpa memasukkan data satu per satu.'
              : 'Info: Share links are perfect if you want to invite many people without inputting data one by one.',
          showQuickActions: true,
          mode: 'share_link',
        );
      } else {
        listWidget = ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.all(rw(context, 16)),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.shareLinks.length,
          separatorBuilder: (_, index) => vSpace(context, 12),
          itemBuilder: (context, index) {
            final item = controller.shareLinks[index];
            return _SlidableDeleteCard(
              onDelete: () async {
                bool deleteConfirmed = false;
                await showDialog(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Delete Share Link'),
                    content: const Text(
                      'Are you sure you want to delete this share link?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          deleteConfirmed = false;
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          deleteConfirmed = true;
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (deleteConfirmed) {
                  final success = await controller.deleteShareLinkAction(
                    item['id']?.toString() ?? '',
                  );
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
                }
              },
              child: ShareLinkCard(
                item: item,
                no:
                    index +
                    1 +
                    (controller.shareLinkCurrentPage.value *
                        controller.shareLinkPageSize.value),
                onTap: () => ShareLinkDetailModal.show(context, item),
              ),
            );
          },
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter bar ──
          Padding(
            padding: EdgeInsets.only(
              left: rw(context, 20),
              right: rw(context, 20),
              top: rh(context, 16),
              bottom: rh(context, 6),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
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
                              initialStartDate: startDateShare,
                              initialEndDate: endDateShare,
                              initialSiteId:
                                  controller.selectedSiteIdShare.value,
                              initialStatus: selectedStatusShare,
                              showStatusFilter: false,
                              showSiteFilter: false,
                            ),
                          );

                      if (result != null) {
                        setState(() {
                          startDateShare = result['startDate'];
                          endDateShare = result['endDate'];
                          selectedGedungShare = result['siteName'];
                          selectedStatusShare = result['status'];
                        });
                        controller.setShareFilters(
                          start: startDateShare,
                          end: endDateShare,
                          siteId: result['siteId'],
                          siteName: result['siteName'],
                          status: result['status'],
                        );
                      }
                    },
                    child: _buildFilterChip(context, 'Filter'),
                  ),
                  if (selectedGedungShare != null) ...[
                    hSpace(context, 8),
                    _buildFilterValueChip(
                      context,
                      selectedGedungShare!,
                      onClear: () {
                        setState(() => selectedGedungShare = null);
                        controller.setShareFilters(
                          start: startDateShare,
                          end: endDateShare,
                          siteId: null,
                          siteName: null,
                          status: selectedStatusShare,
                        );
                      },
                    ),
                  ],
                  if (startDateShare != null || endDateShare != null) ...[
                    hSpace(context, 8),
                    _buildFilterValueChip(
                      context,
                      _formatDateRange(startDateShare, endDateShare),
                      onClear: () {
                        setState(() {
                          startDateShare = null;
                          endDateShare = null;
                        });
                        controller.setShareFilters(
                          start: null,
                          end: null,
                          siteId: controller.selectedSiteIdShare.value,
                          siteName: controller.selectedSiteNameShare.value,
                          status: selectedStatusShare,
                        );
                      },
                    ),
                  ],
                  if (selectedStatusShare != null &&
                      selectedStatusShare!.isNotEmpty) ...[
                    hSpace(context, 8),
                    _buildFilterValueChip(
                      context,
                      'Status: $selectedStatusShare',
                      onClear: () {
                        setState(() => selectedStatusShare = null);
                        controller.setShareFilters(
                          start: startDateShare,
                          end: endDateShare,
                          siteId: controller.selectedSiteIdShare.value,
                          siteName: controller.selectedSiteNameShare.value,
                          status: null,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  startDateShare = null;
                  endDateShare = null;
                  selectedGedungShare = null;
                  selectedStatusShare = null;
                });
                await controller.fetchShareLinks(
                  resetPage: true,
                  clearFilters: true,
                );
              },
              child: listWidget,
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

  // UI components extracted to ShareLinkCard and ShareLinkDetailModal
}

class _SlidableDeleteCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  const _SlidableDeleteCard({required this.child, required this.onDelete});

  @override
  State<_SlidableDeleteCard> createState() => _SlidableDeleteCardState();
}

class _SlidableDeleteCardState extends State<_SlidableDeleteCard> {
  double _dragExtent = 0.0;
  static const double _maxDrag = -84.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragExtent += details.primaryDelta!;
          if (_dragExtent > 0.0) _dragExtent = 0.0;
          if (_dragExtent < _maxDrag) _dragExtent = _maxDrag;
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          if (_dragExtent < _maxDrag / 2) {
            _dragExtent = _maxDrag;
          } else {
            _dragExtent = 0.0;
          }
        });
      },
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 72,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _dragExtent = 0.0;
                });
                widget.onDelete();
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete, color: Colors.white, size: 28),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.translationValues(_dragExtent, 0, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Digital Invitation Card Widget
// Data source: same as Barcode — from /visitor/transaction/{id}/visitors
// Displayed fields: visitorName, visitorNumber
// ─────────────────────────────────────────────────────────────────────────────
class _DigitalInvitationCard extends StatelessWidget {
  final String name;
  final String visitorNumber;

  const _DigitalInvitationCard({
    required this.name,
    required this.visitorNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rw(context, 20)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005596).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rw(context, 20)),
        child: SizedBox(
          width: double.infinity,
          height: rh(context, 190),
          child: Stack(
            children: [
              // ── Base gradient background ────────────────────────────────
              Positioned.fill(
                child: CustomPaint(painter: _CardGeometricPainter()),
              ),

              // ── Logo / brand chip top-left ──────────────────────────────
              Positioned(
                top: rh(context, 18),
                left: rw(context, 20),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: rw(context, 10),
                    vertical: rh(context, 4),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(rw(context, 6)),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'VISITOR CARD',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: rfs(context, 9),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              // ── Visitor Name ────────────────────────────────────────────
              Positioned(
                bottom: rh(context, 42),
                left: rw(context, 20),
                right: rw(context, 20),
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: rfs(context, 20),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // ── Visitor Number ──────────────────────────────────────────
              Positioned(
                bottom: rh(context, 20),
                left: rw(context, 20),
                right: rw(context, 20),
                child: Text(
                  visitorNumber,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: rfs(context, 13),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardGeometricPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ── Background base ───────────────────────────────────────────────────
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF005596),
          const Color(0xFF1976D2),
          const Color(0xFF0D47A1),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(20),
      ),
      bgPaint,
    );

    // ── Large diagonal accent strip (top-right, like BPJS green) ─────────
    final stripPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF42A5F5).withValues(alpha: 0.5),
          const Color(0xFF1565C0).withValues(alpha: 0.15),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final stripPath = Path()
      ..moveTo(size.width * 0.42, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.62)
      ..lineTo(size.width * 0.18, size.height)
      ..lineTo(size.width * 0.0, size.height * 0.55)
      ..close();
    canvas.drawPath(stripPath, stripPaint);

    // ── Secondary accent stripe (yellow-ish tint, like BPJS right edge) ──
    final accentPaint = Paint()
      ..color = const Color(0xFF64B5F6).withValues(alpha: 0.25);
    final accentPath = Path()
      ..moveTo(size.width * 0.70, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.35)
      ..close();
    canvas.drawPath(accentPath, accentPaint);

    // ── Bottom-left darker strip ──────────────────────────────────────────
    final darkPaint = Paint()
      ..color = const Color(0xFF003D6E).withValues(alpha: 0.55);
    final darkPath = Path()
      ..moveTo(0, size.height * 0.65)
      ..lineTo(size.width * 0.52, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(darkPath, darkPaint);

    // ── Subtle circle shimmer top-right ───────────────────────────────────
    final shimmerPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.82, size.height * 0.2),
              radius: size.width * 0.35,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.2),
      size.width * 0.35,
      shimmerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Others Visitor - Instagram-style Sheet ───────────────────────────────────

class _OthersVisitorSheet extends StatefulWidget {
  final List<AccessPassModel> visitors;
  final List<Color> avatarColors;
  final void Function(AccessPassModel) onVisitorTap;

  const _OthersVisitorSheet({
    required this.visitors,
    required this.avatarColors,
    required this.onVisitorTap,
  });

  @override
  State<_OthersVisitorSheet> createState() => _OthersVisitorSheetState();
}

class _OthersVisitorSheetState extends State<_OthersVisitorSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<AccessPassModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.visitors;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? widget.visitors
          : widget.visitors
                .where((v) => v.visitorName.toLowerCase().contains(q))
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sh = MediaQuery.of(context).size.height * 0.75;
    return Container(
      height: sh,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Handle ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // ── Title ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Text(
                  'All Visitors',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: rfs(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F51B5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF3F51B5).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    '${widget.visitors.length} people',
                    style: TextStyle(
                      color: const Color(0xFF3F51B5),
                      fontSize: rfs(context, 12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Search ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: TextStyle(color: Colors.grey.shade800),
                decoration: InputDecoration(
                  hintText: 'Search by name',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          // ── Divider ─────────────────────────────────────────────────────
          Container(height: 1, color: Colors.grey.shade100),
          // ── Grid ────────────────────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No visitors found',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: rfs(context, 14),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final model = _filtered[index];
                      final origIdx = widget.visitors.indexOf(model);
                      final color = widget
                          .avatarColors[origIdx % widget.avatarColors.length];
                      final initials = model.visitorName.isNotEmpty
                          ? model.visitorName[0].toUpperCase()
                          : 'V';
                      final firstName = model.visitorName.isNotEmpty
                          ? model.visitorName.trim().split(' ').first
                          : 'Visitor';

                      return GestureDetector(
                        onTap: () => widget.onVisitorTap(model),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: rw(context, 32),
                              backgroundColor: color.withValues(alpha: 0.15),
                              child: Text(
                                initials,
                                style: TextStyle(
                                  color: color,
                                  fontSize: rfs(context, 18),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              firstName,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final String tipsText;
  final bool showQuickActions;
  final Widget? illustration;
  final String mode;
  final VoidCallback? onDuplicateSuccess;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onButtonPressed,
    required this.tipsText,
    this.showQuickActions = false,
    this.illustration,
    this.mode = 'invitation',
    this.onDuplicateSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<InvitationController>()
        ? Get.find<InvitationController>()
        : Get.put(InvitationController());

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: rw(context, 20.0),
          vertical: rh(context, 16.0),
        ),
        child: Column(
          children: [
            // 1. Top Icon Illustration (balanced scale)
            Center(
              child: SizedBox(
                height: rh(context, 150),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: illustration ?? _buildDefaultIllustration(context),
                ),
              ),
            ),
            vSpace(context, 20),

            // 2. Title
            Text(
              title,
              style: TextStyle(
                color: Colors.black87,
                fontSize: rfs(context, 19),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            vSpace(context, 8),

            // 3. Subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(context, 14.0)),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: rfs(context, 12.5),
                  height: 1.45,
                ),
              ),
            ),
            vSpace(context, 20),

            // 4. Create Button
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 28),
                  vertical: rh(context, 12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rw(context, 12)),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: rw(context, 20)),
                  hSpace(context, 8),
                  Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: rfs(context, 14.5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            vSpace(context, 24),

            // 5. Quick Actions Section (Optional)
            if (showQuickActions) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: rfs(context, 16),
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              vSpace(context, 12),
              Row(
                children: [
                  Expanded(
                    child: Builder(
                      builder: (ctx) {
                        final isIndonesian = Get.locale?.languageCode == 'id';
                        final String cardTitle = isIndonesian
                            ? 'Scan QR Code'
                            : 'Scan QR Code';
                        final String cardSubtitle;
                        if (mode == 'share_link') {
                          cardSubtitle = isIndonesian
                              ? 'Pindai share link'
                              : 'Scan Share Link';
                        } else if (mode == 'quick_access') {
                          cardSubtitle = isIndonesian
                              ? 'Pindai quick access'
                              : 'Scan Quick Access';
                        } else {
                          cardSubtitle = isIndonesian
                              ? 'Pindai invitation'
                              : 'Scan Invitation';
                        }

                        return _buildQuickActionCard(
                          context: context,
                          title: cardTitle,
                          subtitle: cardSubtitle,
                          icon: Icons.qr_code_scanner_rounded,
                          color: const Color(0xFF7B1FA2),
                          bgColor: const Color(0xFFF3E5F5),
                          onTap: () async {
                            final scannedCode = await context.push<String>(
                              const ScanInvitationPage(),
                            );

                            if (scannedCode != null && scannedCode.isNotEmpty) {
                              final inviteCtrl =
                                  Get.isRegistered<InvitationController>()
                                  ? Get.find<InvitationController>()
                                  : Get.put(InvitationController());

                              if (mode == 'share_link') {
                                // Search only in Share Links
                                final matched = inviteCtrl.allShareLinks
                                    .firstWhereOrNull((item) {
                                      final itemId =
                                          item['id']?.toString() ?? '';
                                      final itemUrl =
                                          item['url']?.toString() ?? '';
                                      final itemShorten =
                                          item['shorten_url']?.toString() ?? '';
                                      final itemShort =
                                          item['short_url']?.toString() ?? '';

                                      final sLower = scannedCode.toLowerCase();
                                      return itemId.toLowerCase() == sLower ||
                                          itemUrl.toLowerCase() == sLower ||
                                          itemShorten.toLowerCase() == sLower ||
                                          itemShort.toLowerCase() == sLower ||
                                          sLower.contains(
                                            itemId.toLowerCase(),
                                          ) ||
                                          sLower.contains(
                                            itemUrl.toLowerCase(),
                                          ) ||
                                          sLower.contains(
                                            itemShorten.toLowerCase(),
                                          ) ||
                                          sLower.contains(
                                            itemShort.toLowerCase(),
                                          );
                                    });

                                if (matched != null) {
                                  ShareLinkDetailModal.show(context, matched);
                                } else {
                                  Get.snackbar(
                                    isIndonesian
                                        ? 'Share Link Tidak Ditemukan'
                                        : 'Share Link Not Found',
                                    isIndonesian
                                        ? 'Share link dengan kode/url "$scannedCode" tidak ditemukan.'
                                        : 'Share link with code/url "$scannedCode" was not found.',
                                    backgroundColor: Colors.red.shade100,
                                    colorText: Colors.red.shade900,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              } else {
                                // invitation or quick_access lookup
                                final isQuickAccessMode =
                                    mode == 'quick_access';

                                bool isMatch(AccessPassModel v) {
                                  final isQA =
                                      v.flow.toLowerCase() ==
                                      'quickaccessvisit';
                                  if (isQuickAccessMode != isQA) return false;

                                  final sLower = scannedCode.toLowerCase();
                                  return v.visitorNumber.toLowerCase() ==
                                          sLower ||
                                      v.visitorCode.toLowerCase() == sLower ||
                                      v.invitationCode.toLowerCase() ==
                                          sLower ||
                                      v.initialTrxCode.toLowerCase() ==
                                          sLower ||
                                      v.id.toLowerCase() == sLower ||
                                      v.transactionVisitorId.toLowerCase() ==
                                          sLower;
                                }

                                AccessPassModel? matched = inviteCtrl
                                    .allRawVisitors
                                    .firstWhereOrNull(isMatch);

                                // 2. If not found locally, search in sub-visitors cache
                                if (matched == null) {
                                  for (final subList
                                      in inviteCtrl
                                          .transactionVisitorsCache
                                          .values) {
                                    final found = subList.firstWhereOrNull(
                                      isMatch,
                                    );
                                    if (found != null) {
                                      matched = found;
                                      break;
                                    }
                                  }
                                }

                                // 3. Fallback: Search from backend API /api/visitor/transaction/dt
                                if (matched == null) {
                                  try {
                                    Get.dialog(
                                      const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.primary500,
                                              ),
                                        ),
                                      ),
                                      barrierDismissible: false,
                                    );

                                    final hive = HiveService();
                                    final user = hive.getUser();
                                    final token = user?.token;
                                    if (token != null) {
                                      final api = ApiService();
                                      final response = await api.getVisitorDt(
                                        token,
                                        search: scannedCode,
                                        length: 50,
                                      );

                                      if (Get.isDialogOpen ?? false) {
                                        Get.back();
                                      }

                                      if (response.data is Map &&
                                          (response.data['status'] ==
                                                  'success' ||
                                              response.data['status_code'] ==
                                                  200)) {
                                        final collection =
                                            response.data['collection']
                                                as List? ??
                                            [];
                                        for (final trx in collection) {
                                          final parentModel =
                                              AccessPassModel.fromJson(
                                                trx as Map<String, dynamic>,
                                              );
                                          if (isMatch(parentModel)) {
                                            matched = parentModel;
                                            break;
                                          }

                                          // Fetch sub-visitors for this transaction
                                          final subVisitorsRaw =
                                              await inviteCtrl
                                                  .fetchTransactionVisitors(
                                                    parentModel.id,
                                                  );
                                          final subVisitors = inviteCtrl
                                              .parseAndCacheSubVisitors(
                                                parentModel,
                                                subVisitorsRaw,
                                              );
                                          final foundSub = subVisitors
                                              .firstWhereOrNull(isMatch);
                                          if (foundSub != null) {
                                            matched = foundSub;
                                            break;
                                          }
                                        }
                                      }
                                    } else {
                                      if (Get.isDialogOpen ?? false) {
                                        Get.back();
                                      }
                                    }
                                  } catch (e) {
                                    debugPrint(
                                      'Fallback backend search error: $e',
                                    );
                                    if (Get.isDialogOpen ?? false) {
                                      Get.back();
                                    }
                                  }
                                }

                                if (matched != null) {
                                  showInvitationDetailSheet(context, matched);
                                } else {
                                  final String lookupType = isQuickAccessMode
                                      ? (isIndonesian
                                            ? 'Quick Access'
                                            : 'Quick Access')
                                      : (isIndonesian
                                            ? 'Undangan'
                                            : 'Invitation');

                                  Get.snackbar(
                                    isIndonesian
                                        ? '$lookupType Tidak Ditemukan'
                                        : '$lookupType Not Found',
                                    isIndonesian
                                        ? '$lookupType dengan kode/nomor "$scannedCode" tidak ditemukan.'
                                        : '$lookupType with code/number "$scannedCode" was not found.',
                                    backgroundColor: Colors.red.shade100,
                                    colorText: Colors.red.shade900,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
                  hSpace(context, 16),
                  Expanded(
                    child: Builder(
                      builder: (ctx) {
                        final isIndonesian = Get.locale?.languageCode == 'id';
                        final String dupTitle;
                        if (mode == 'share_link') {
                          dupTitle = isIndonesian
                              ? 'Duplikat Share Link'
                              : 'Duplicate Share Link';
                        } else if (mode == 'quick_access') {
                          dupTitle = isIndonesian
                              ? 'Duplikat Quick Access'
                              : 'Duplicate Quick Access';
                        } else {
                          dupTitle = isIndonesian
                              ? 'Duplikat Invitation'
                              : 'Duplicate Invitation';
                        }

                        return _buildQuickActionCard(
                          context: context,
                          title: dupTitle,
                          subtitle: isIndonesian
                              ? 'Gunakan yang lama'
                              : 'Use an old one',
                          icon: Icons.copy_all_rounded,
                          color: const Color(0xFFE65100),
                          bgColor: const Color(0xFFFFF3E0),
                          onTap: () {
                            if (mode == 'share_link') {
                              DuplicateSelectorSheet.show(
                                context: context,
                                title: dupTitle,
                                items: controller.allShareLinks,
                                dismissOnSelect: false,
                                badgeUnit: 'Share Link',
                                nameExtractor: (item) => item['agenda']?.toString() ?? 'Share Link',
                                searchMatcher: (item, query) {
                                  final agenda = item['agenda']?.toString() ?? '';
                                  final site = item['site_name']?.toString() ?? '';
                                  return agenda.toLowerCase().contains(query.toLowerCase()) ||
                                      site.toLowerCase().contains(query.toLowerCase());
                                },
                                  onSelected: (selectedItem) {
                                  showDialog<bool>(
                                    context: Get.context!,
                                    barrierDismissible: false,
                                    builder: (context) => CreateShareLinkDialog(
                                      duplicateData: selectedItem as Map<String, dynamic>,
                                    ),
                                  ).then((result) {
                                    controller.fetchShareLinks();
                                    if (result == true) {
                                      Get.back(); // Dismiss DuplicateSelectorSheet
                                    }
                                  });
                                },
                              );
                            } else if (mode == 'quick_access') {
                              final filtered = controller.allRawVisitors.where((item) {
                                return item.flow.toLowerCase() == 'quickaccessvisit' &&
                                    !(item.agenda.isEmpty &&
                                        item.hostName.isEmpty &&
                                        item.visitorTypeName.isEmpty);
                              }).toList();

                              filtered.sort((a, b) {
                                final dateA = a.invitationCreatedAt ?? a.visitorPeriodStart;
                                final dateB = b.invitationCreatedAt ?? b.visitorPeriodStart;
                                return dateB.compareTo(dateA);
                              });

                              DuplicateSelectorSheet.show(
                                context: context,
                                title: dupTitle,
                                items: filtered,
                                dismissOnSelect: false,
                                badgeUnit: 'Quick Access',
                                nameExtractor: (item) {
                                  final model = item as AccessPassModel;
                                  if (model.receiverName.isNotEmpty) {
                                    return model.receiverName;
                                  }
                                  return model.visitorName.isNotEmpty
                                      ? model.visitorName
                                      : (model.visitorTypeName.isNotEmpty
                                          ? model.visitorTypeName
                                          : 'Quick Access');
                                },
                                searchMatcher: (item, query) {
                                  final model = item as AccessPassModel;
                                  final name = model.visitorName.isNotEmpty
                                      ? model.visitorName
                                      : model.visitorTypeName;
                                  return name.toLowerCase().contains(query.toLowerCase()) ||
                                      model.receiverName.toLowerCase().contains(query.toLowerCase());
                                },
                                onSelected: (selectedItem) async {
                                  final model = selectedItem as AccessPassModel;
                                  List<Map<String, dynamic>>? subVisitors;

                                  // Show loading indicator
                                  showDialog(
                                    context: Get.context!,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  final String fetchId = model.id;
                                  subVisitors = await controller.fetchTransactionVisitors(fetchId);

                                  Get.back(); // Dismiss loading

                                  showDialog<bool>(
                                    context: Get.context!,
                                    barrierDismissible: false,
                                    builder: (context) => CreateQuickAccessDialog(
                                      duplicateData: model,
                                      subVisitors: subVisitors,
                                    ),
                                  ).then((result) {
                                    if (result == true) {
                                      Get.back(); // Dismiss DuplicateSelectorSheet
                                      controller.fetchOngoingInvitations(clearFilters: false);
                                    }
                                  });
                                },
                              );
                            } else {
                              final filtered = controller.allRawVisitors.where((item) {
                                final flowLower = item.flow.toLowerCase();
                                return flowLower != 'quickaccessvisit' &&
                                    !(item.agenda.isEmpty &&
                                        item.hostName.isEmpty &&
                                        item.visitorTypeName.isEmpty);
                              }).toList();

                              filtered.sort((a, b) {
                                final dateA = a.invitationCreatedAt ?? a.visitorPeriodStart;
                                final dateB = b.invitationCreatedAt ?? b.visitorPeriodStart;
                                return dateB.compareTo(dateA);
                              });

                              DuplicateSelectorSheet.show(
                                context: context,
                                title: dupTitle,
                                items: filtered,
                                dismissOnSelect: false,
                                badgeUnit: 'Invitation',
                                nameExtractor: (item) {
                                  final model = item as AccessPassModel;
                                  return model.visitorName.isNotEmpty
                                      ? model.visitorName
                                      : (model.agenda.isNotEmpty
                                          ? model.agenda
                                          : 'Invitation');
                                },
                                searchMatcher: (item, query) {
                                  final model = item as AccessPassModel;
                                  final name = model.visitorName.isNotEmpty
                                      ? model.visitorName
                                      : model.agenda;
                                  return name.toLowerCase().contains(query.toLowerCase());
                                },
                                onSelected: (selectedItem) async {
                                  final model = selectedItem as AccessPassModel;
                                  List<Map<String, dynamic>>? subVisitors;

                                  // Show loading indicator
                                  showDialog(
                                    context: Get.context!,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  final String fetchId = model.id;
                                  subVisitors = await controller.fetchTransactionVisitors(fetchId);

                                  Get.back(); // Dismiss loading

                                  final result = await showAddPraRegistrationDialog(
                                    Get.context!,
                                    duplicateData: model,
                                    subVisitors: subVisitors,
                                  );
                                  if (result == true) {
                                    Get.back(); // Dismiss DuplicateSelectorSheet
                                    onDuplicateSuccess?.call();
                                  }
                                },
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              vSpace(context, 24),
            ],

            // 6. Tips Box
            Container(
              padding: EdgeInsets.all(rw(context, 14)),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8FC),
                borderRadius: BorderRadius.circular(rw(context, 12)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: rw(context, 36),
                    height: rw(context, 36),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.primary500,
                      size: rw(context, 20),
                    ),
                  ),
                  hSpace(context, 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tipsText,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: rfs(context, 12.5),
                            color: const Color(0xFF005596),
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultIllustration(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: rw(context, 160),
          height: rw(context, 160),
          decoration: const BoxDecoration(
            color: Color(0xFFF4F8FC),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: rw(context, 110),
          height: rw(context, 110),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: rw(context, 48), color: AppColors.primary500),
        ),
        // Decorative elements
        Positioned(
          top: rw(context, 15),
          right: rw(context, 20),
          child: Transform.rotate(
            angle: -0.2,
            child: Icon(
              Icons.send_rounded,
              color: AppColors.primary500.withValues(alpha: 0.8),
              size: rw(context, 24),
            ),
          ),
        ),
        Positioned(
          bottom: rw(context, 25),
          left: rw(context, 15),
          child: const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
        ),
        Positioned(
          top: rw(context, 30),
          left: rw(context, 25),
          child: Icon(
            Icons.star_border_rounded,
            color: Colors.blue.shade300,
            size: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: rw(context, 14),
          vertical: rh(context, 14),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 12)),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: rw(context, 42),
              height: rw(context, 42),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: rw(context, 22)),
            ),
            vSpace(context, 10),
            title == 'Duplicate Quick Access' ||
                    title == 'Duplikat Quick Access'
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: rfs(context, 13),
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                    ),
                  )
                : Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: rfs(context, 13),
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            vSpace(context, 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: rfs(context, 11),
                color: Colors.grey.shade500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Custom Empty State Illustrations ────────────────────────────────────────

class InvitationIllustration extends StatelessWidget {
  const InvitationIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: rw(context, 260),
      height: rw(context, 200),
      child: CustomPaint(painter: _EnvelopeIllustrationPainter()),
    );
  }
}

class _EnvelopeIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);

    // 1. Draw irregular cloud background blob
    final bgPaint = Paint()
      ..color = const Color(0xFFEAF4FF)
      ..style = PaintingStyle.fill;

    final bgPath = Path()
      ..moveTo(center.dx - 80, center.dy - 30)
      ..cubicTo(
        center.dx - 120,
        center.dy - 60,
        center.dx - 40,
        center.dy - 120,
        center.dx,
        center.dy - 90,
      )
      ..cubicTo(
        center.dx + 40,
        center.dy - 120,
        center.dx + 120,
        center.dy - 60,
        center.dx + 80,
        center.dy - 10,
      )
      ..cubicTo(
        center.dx + 110,
        center.dy + 40,
        center.dx + 50,
        center.dy + 90,
        center.dx,
        center.dy + 70,
      )
      ..cubicTo(
        center.dx - 60,
        center.dy + 90,
        center.dx - 110,
        center.dy + 40,
        center.dx - 80,
        center.dy - 30,
      )
      ..close();
    canvas.drawPath(bgPath, bgPaint);

    // 2. Draw leaves
    _drawLeaf(
      canvas,
      center + const Offset(-75, -20),
      1.4,
      -0.6,
      const Color(0xFF8AD4FF),
    );
    _drawLeaf(
      canvas,
      center + const Offset(-85, 15),
      1.1,
      -1.1,
      const Color(0xFF5ABFFF),
    );

    _drawLeaf(
      canvas,
      center + const Offset(70, -30),
      1.4,
      0.6,
      const Color(0xFFA2E599),
    );
    _drawLeaf(
      canvas,
      center + const Offset(85, -5),
      1.1,
      1.1,
      const Color(0xFF7CD770),
    );
    _drawLeaf(
      canvas,
      center + const Offset(70, 25),
      0.9,
      1.5,
      const Color(0xFF53C645),
    );

    // 3. Envelope back
    final envBackPaint = Paint()
      ..color = const Color(0xFFE6EFFF)
      ..style = PaintingStyle.fill;
    final envOutlinePaint = Paint()
      ..color = const Color(0xFFC4DDFC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double envW = 110;
    const double envH = 75;
    final envRect = Rect.fromCenter(
      center: center + const Offset(0, 15),
      width: envW,
      height: envH,
    );

    final backPath = Path()
      ..moveTo(envRect.left, envRect.bottom)
      ..lineTo(envRect.left, envRect.top)
      ..lineTo(center.dx, envRect.top - 30)
      ..lineTo(envRect.right, envRect.top)
      ..lineTo(envRect.right, envRect.bottom)
      ..close();

    canvas.drawPath(backPath, envBackPaint);
    canvas.drawPath(backPath, envOutlinePaint);

    // 4. Card sticking out
    final cardRect = Rect.fromLTWH(center.dx - 40, center.dy - 35, 80, 70);
    final cardRRect = RRect.fromRectAndRadius(
      cardRect,
      const Radius.circular(8),
    );

    final cardPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final cardShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(cardRRect.shift(const Offset(0, 4)), cardShadowPaint);
    canvas.drawRRect(cardRRect, cardPaint);

    // Draw dashed border on card
    final dashBorderPaint = Paint()
      ..color = const Color(0xFFD0E3FA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    _drawDashedRRect(canvas, cardRRect, dashBorderPaint);

    // Draw user icon graphics on the card
    final contactColor = const Color(0xFF4FA0F9);
    final contactPaint = Paint()
      ..color = contactColor
      ..style = PaintingStyle.fill;

    // Person 1
    canvas.drawCircle(Offset(center.dx - 10, center.dy - 15), 6, contactPaint);
    final shoulder1 = Path()
      ..moveTo(center.dx - 22, center.dy - 2)
      ..quadraticBezierTo(
        center.dx - 22,
        center.dy - 10,
        center.dx - 10,
        center.dy - 10,
      )
      ..quadraticBezierTo(
        center.dx + 2,
        center.dy - 10,
        center.dx + 2,
        center.dy - 2,
      )
      ..close();
    canvas.drawPath(shoulder1, contactPaint);

    // Person 2
    final contactColor2 = const Color(0xFF81C3F8);
    final contactPaint2 = Paint()
      ..color = contactColor2
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx + 10, center.dy - 15), 6, contactPaint2);
    final shoulder2 = Path()
      ..moveTo(center.dx - 2, center.dy - 2)
      ..quadraticBezierTo(
        center.dx - 2,
        center.dy - 10,
        center.dx + 10,
        center.dy - 10,
      )
      ..quadraticBezierTo(
        center.dx + 22,
        center.dy - 10,
        center.dx + 22,
        center.dy - 2,
      )
      ..close();
    canvas.drawPath(shoulder2, contactPaint2);

    final linePaint = Paint()
      ..color = const Color(0xFFE2EFFD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 22, center.dy + 6, 44, 20),
        const Radius.circular(4),
      ),
      Paint()
        ..color = const Color(0xFFF0F6FF)
        ..style = PaintingStyle.fill,
    );
    canvas.drawLine(
      Offset(center.dx - 15, center.dy + 12),
      Offset(center.dx + 15, center.dy + 12),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx - 15, center.dy + 20),
      Offset(center.dx + 5, center.dy + 20),
      linePaint,
    );

    // 5. Envelope front flaps
    final envFlapPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final leftFlap = Path()
      ..moveTo(envRect.left, envRect.top)
      ..lineTo(center.dx, envRect.bottom - 10)
      ..lineTo(envRect.left, envRect.bottom)
      ..close();

    final rightFlap = Path()
      ..moveTo(envRect.right, envRect.top)
      ..lineTo(center.dx, envRect.bottom - 10)
      ..lineTo(envRect.right, envRect.bottom)
      ..close();

    canvas.drawPath(leftFlap, envFlapPaint);
    canvas.drawPath(leftFlap, envOutlinePaint);
    canvas.drawPath(rightFlap, envFlapPaint);
    canvas.drawPath(rightFlap, envOutlinePaint);

    final bottomFlap = Path()
      ..moveTo(envRect.left, envRect.bottom)
      ..lineTo(center.dx, envRect.bottom - 25)
      ..lineTo(envRect.right, envRect.bottom)
      ..close();

    canvas.drawPath(bottomFlap, envFlapPaint);
    canvas.drawPath(bottomFlap, envOutlinePaint);

    // 6. Dashed curve to paper plane
    final dashPaint = Paint()
      ..color = const Color(0xFF62A0EA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final pStart = Offset(center.dx + 25, center.dy - 35);
    final pControl = Offset(center.dx + 90, center.dy - 90);
    final pEnd = Offset(size.width - 20, 20);

    _drawDashedBezier(
      canvas,
      pStart,
      pControl,
      pEnd,
      dashPaint,
      dashWidth: 6,
      dashSpace: 6,
    );

    // 7. Large paper plane
    _drawPaperPlane(canvas, pEnd, 1.3, -0.4, const Color(0xFF1E88E5));

    // 8. Floating stars/sparkles
    _drawSparkle(
      canvas,
      Offset(center.dx - 60, center.dy - 60),
      6,
      const Color(0xFF4FC3F7),
    );
    _drawSparkle(
      canvas,
      Offset(center.dx + 50, center.dy - 80),
      5,
      const Color(0xFFFFF176),
    );
    _drawSparkle(
      canvas,
      Offset(center.dx + 90, center.dy + 30),
      5,
      const Color(0xFF81C784),
    );
    _drawSparkle(
      canvas,
      Offset(center.dx - 90, center.dy + 20),
      4,
      const Color(0xFFFFB74D),
    );
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint) {
    Path path = Path()..addRRect(rrect);
    Path dashPath = Path();
    const double dashWidth = 5.0;
    const double dashSpace = 4.0;
    double distance = 0.0;

    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
      distance = 0.0; // Reset for next metric
    }
    canvas.drawPath(dashPath, paint);
  }

  void _drawLeaf(
    Canvas canvas,
    Offset origin,
    double scale,
    double angle,
    Color color,
  ) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);
    canvas.scale(scale);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-12, -20, 0, -35)
      ..quadraticBezierTo(12, -20, 0, 0);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawPaperPlane(
    Canvas canvas,
    Offset origin,
    double scale,
    double angle,
    Color color,
  ) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);
    canvas.scale(scale);

    final mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final planePath = Path()
      ..moveTo(0, -18)
      ..lineTo(-20, 10)
      ..lineTo(-4, 2)
      ..close();
    final planeRightPath = Path()
      ..moveTo(0, -18)
      ..lineTo(4, 2)
      ..lineTo(20, 10)
      ..close();
    final planeFoldPath = Path()
      ..moveTo(-4, 2)
      ..lineTo(0, 10)
      ..lineTo(4, 2)
      ..close();

    canvas.drawPath(planePath, whitePaint);
    canvas.drawPath(planeRightPath, mainPaint);
    canvas.drawPath(planeFoldPath, shadowPaint);
    canvas.restore();
  }

  void _drawDashedBezier(
    Canvas canvas,
    Offset start,
    Offset control,
    Offset end,
    Paint paint, {
    double dashWidth = 5,
    double dashSpace = 5,
  }) {
    final Path path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    Path dashPath = Path();
    double distance = 0.0;

    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
      distance = 0.0;
    }
    canvas.drawPath(dashPath, paint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ShareLinkIllustration extends StatelessWidget {
  const ShareLinkIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: rw(context, 260),
      height: rw(context, 200),
      child: CustomPaint(painter: _ShareLinkIllustrationPainter()),
    );
  }
}

class _ShareLinkIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);

    // 1. Draw irregular cloud background blob
    final bgPaint = Paint()
      ..color = const Color(0xFFF3E5F5)
      ..style = PaintingStyle.fill;

    final bgPath = Path()
      ..moveTo(center.dx - 90, center.dy - 10)
      ..cubicTo(
        center.dx - 120,
        center.dy - 60,
        center.dx - 30,
        center.dy - 110,
        center.dx + 20,
        center.dy - 80,
      )
      ..cubicTo(
        center.dx + 70,
        center.dy - 110,
        center.dx + 130,
        center.dy - 40,
        center.dx + 90,
        center.dy + 20,
      )
      ..cubicTo(
        center.dx + 110,
        center.dy + 80,
        center.dx + 30,
        center.dy + 110,
        center.dx - 20,
        center.dy + 70,
      )
      ..cubicTo(
        center.dx - 80,
        center.dy + 100,
        center.dx - 130,
        center.dy + 50,
        center.dx - 90,
        center.dy - 10,
      )
      ..close();
    canvas.drawPath(bgPath, bgPaint);

    // 2. Links / Connected Nodes
    final nodeLinePaint = Paint()
      ..color = const Color(0xFFCE93D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center + const Offset(-40, 20),
      center + const Offset(-70, -20),
      nodeLinePaint,
    );
    canvas.drawLine(
      center + const Offset(40, -10),
      center + const Offset(80, 30),
      nodeLinePaint,
    );
    canvas.drawLine(
      center + const Offset(-30, -50),
      center + const Offset(20, -80),
      nodeLinePaint,
    );

    final nodePaint = Paint()
      ..color = const Color(0xFFAB47BC)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(-70, -20), 8, nodePaint);
    canvas.drawCircle(center + const Offset(80, 30), 10, nodePaint);
    canvas.drawCircle(center + const Offset(20, -80), 6, nodePaint);

    // 3. Central Document / Card
    final cardRect = Rect.fromCenter(center: center, width: 90, height: 110);
    final cardRRect = RRect.fromRectAndRadius(
      cardRect,
      const Radius.circular(12),
    );

    final cardPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final cardShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(cardRRect.shift(const Offset(0, 6)), cardShadowPaint);
    canvas.drawRRect(cardRRect, cardPaint);

    final cardBorderPaint = Paint()
      ..color = const Color(0xFFE1BEE7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(cardRRect, cardBorderPaint);

    // Document Lines
    final docLinePaint = Paint()
      ..color = const Color(0xFFF3E5F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center + const Offset(-25, -25),
      center + const Offset(25, -25),
      docLinePaint,
    );
    canvas.drawLine(
      center + const Offset(-25, -10),
      center + const Offset(25, -10),
      docLinePaint,
    );
    canvas.drawLine(
      center + const Offset(-25, 5),
      center + const Offset(0, 5),
      docLinePaint,
    );

    // 4. Large Link Icon
    final linkPaint = Paint()
      ..color = const Color(0xFF8E24AA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    final linkPath = Path()
      ..moveTo(center.dx - 15, center.dy + 35)
      ..lineTo(center.dx - 5, center.dy + 35)
      ..arcTo(
        Rect.fromCircle(center: center + const Offset(-5, 25), radius: 10),
        1.57,
        -3.14,
        false,
      )
      ..lineTo(center.dx + 5, center.dy + 15)
      ..moveTo(center.dx - 5, center.dy + 35)
      ..lineTo(center.dx + 5, center.dy + 35)
      ..arcTo(
        Rect.fromCircle(center: center + const Offset(5, 25), radius: 10),
        1.57,
        3.14,
        false,
      )
      ..lineTo(center.dx + 15, center.dy + 15);

    canvas.drawPath(linkPath, linkPaint);
    canvas.drawLine(
      center + const Offset(-6, 25),
      center + const Offset(6, 25),
      linkPaint,
    );

    // 5. Floating elements
    _drawSparkle(
      canvas,
      center + const Offset(-50, -60),
      7,
      const Color(0xFFFFB74D),
    );
    _drawSparkle(
      canvas,
      center + const Offset(50, -50),
      5,
      const Color(0xFFBA68C8),
    );
    _drawSparkle(
      canvas,
      center + const Offset(60, 40),
      6,
      const Color(0xFF64B5F6),
    );
    _drawSparkle(
      canvas,
      center + const Offset(-60, 40),
      4,
      const Color(0xFF81C784),
    );
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QuickAccessIllustration extends StatelessWidget {
  const QuickAccessIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: rw(context, 260),
      height: rw(context, 200),
      child: CustomPaint(painter: _QuickAccessIllustrationPainter()),
    );
  }
}

class _QuickAccessIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);

    // 1. Draw irregular cloud background blob
    final bgPaint = Paint()
      ..color = const Color(0xFFFFF3E0)
      ..style = PaintingStyle.fill;

    final bgPath = Path()
      ..moveTo(center.dx - 80, center.dy - 40)
      ..cubicTo(
        center.dx - 130,
        center.dy - 70,
        center.dx - 50,
        center.dy - 120,
        center.dx,
        center.dy - 90,
      )
      ..cubicTo(
        center.dx + 50,
        center.dy - 120,
        center.dx + 120,
        center.dy - 60,
        center.dx + 80,
        center.dy - 10,
      )
      ..cubicTo(
        center.dx + 130,
        center.dy + 50,
        center.dx + 40,
        center.dy + 120,
        center.dx,
        center.dy + 80,
      )
      ..cubicTo(
        center.dx - 50,
        center.dy + 120,
        center.dx - 120,
        center.dy + 60,
        center.dx - 80,
        center.dy - 40,
      )
      ..close();
    canvas.drawPath(bgPath, bgPaint);

    // 2. Background decorative cards
    final bgCardPaint = Paint()
      ..color = const Color(0xFFFFE0B2)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.3);
    final bgCardRect1 = Rect.fromCenter(
      center: const Offset(-20, -10),
      width: 90,
      height: 120,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgCardRect1, const Radius.circular(12)),
      bgCardPaint,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.2);
    final bgCardRect2 = Rect.fromCenter(
      center: const Offset(20, 10),
      width: 90,
      height: 120,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgCardRect2, const Radius.circular(12)),
      Paint()
        ..color = const Color(0xFFFFCC80)
        ..style = PaintingStyle.fill,
    );
    canvas.restore();

    // 3. Main Central Card (ID Card / Access Card)
    final cardRect = Rect.fromCenter(center: center, width: 100, height: 130);
    final cardRRect = RRect.fromRectAndRadius(
      cardRect,
      const Radius.circular(16),
    );

    final cardPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final cardShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(cardRRect.shift(const Offset(0, 8)), cardShadowPaint);
    canvas.drawRRect(cardRRect, cardPaint);

    // Top Card Header (Color Block)
    final headerPath = Path()
      ..moveTo(cardRect.left, cardRect.top + 35)
      ..lineTo(cardRect.right, cardRect.top + 35)
      ..lineTo(cardRect.right, cardRect.top + 16)
      ..quadraticBezierTo(
        cardRect.right,
        cardRect.top,
        cardRect.right - 16,
        cardRect.top,
      )
      ..lineTo(cardRect.left + 16, cardRect.top)
      ..quadraticBezierTo(
        cardRect.left,
        cardRect.top,
        cardRect.left,
        cardRect.top + 16,
      )
      ..close();
    canvas.drawPath(
      headerPath,
      Paint()
        ..color = const Color(0xFFF57C00)
        ..style = PaintingStyle.fill,
    );

    // Card Hole
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, cardRect.top + 12),
          width: 24,
          height: 6,
        ),
        const Radius.circular(4),
      ),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // 4. Large Lightning Bolt inside Card
    final boltPaint = Paint()
      ..color = const Color(0xFFFF9800)
      ..style = PaintingStyle.fill;
    final boltPath = Path()
      ..moveTo(center.dx + 5, center.dy - 10)
      ..lineTo(center.dx + 25, center.dy - 10)
      ..lineTo(center.dx - 5, center.dy + 35)
      ..lineTo(center.dx, center.dy + 10)
      ..lineTo(center.dx - 20, center.dy + 10)
      ..lineTo(center.dx + 10, center.dy - 35)
      ..close();
    canvas.drawPath(boltPath, boltPaint);

    // 5. Floating elements
    _drawSparkle(
      canvas,
      center + const Offset(-60, -50),
      7,
      const Color(0xFF4FC3F7),
    );
    _drawSparkle(
      canvas,
      center + const Offset(70, -60),
      6,
      const Color(0xFFE57373),
    );
    _drawSparkle(
      canvas,
      center + const Offset(60, 50),
      5,
      const Color(0xFF81C784),
    );
    _drawSparkle(
      canvas,
      center + const Offset(-70, 40),
      5,
      const Color(0xFFBA68C8),
    );
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
