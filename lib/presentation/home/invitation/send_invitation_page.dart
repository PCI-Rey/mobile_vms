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
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_tabController.index == 1) {
        controller.fetchShareLinks(resetPage: true);
      }
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
                  setState(() {
                    startDate = null;
                    endDate = null;
                    selectedGedung = null;
                  });
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
                    controller.fetchOngoingInvitations(clearFilters: true);
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
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
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
                _buildInvitationTab(),
                _buildShareLinkTab(),
                _buildQuickAccessTab(),
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
                            showStatusFilter: false,
                          ),
                        );

                    if (result != null) {
                      setState(() {
                        startDate = result['startDate'];
                        endDate = result['endDate'];
                        selectedGedung = result['siteName'];
                        selectedStatus = result['status'];
                      });
                      inviteCtrl.setFilters(
                        start: startDate,
                        end: endDate,
                        siteId: result['siteId'],
                        siteName: result['siteName'],
                        status: result['status'],
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
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 20.0),
                          vertical: rw(context, 40.0),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: rw(context, 48),
                              color: Colors.grey[400],
                            ),
                            vSpace(context, 16),
                            Text(
                              'No Invitation Found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: rfs(context, 16),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            vSpace(context, 8),
                            Text(
                              "Tap the '+' button at the top right to create a new invitation",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: rfs(context, 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                                    '${index + 1}',
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
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 20.0),
                          vertical: rw(context, 40.0),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.flash_on_rounded,
                              size: rw(context, 48),
                              color: Colors.grey[400],
                            ),
                            vSpace(context, 16),
                            Text(
                              'No Quick Access Visit Found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: rfs(context, 16),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            vSpace(context, 8),
                            Text(
                              "Tap the '+' button at the top right to create a new quick access",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: rfs(context, 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                                    '${index + 1}',
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
      ],
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
    return 'Dari ${format.format(start)}';
  } else {
    return 'Sampai ${format.format(end!)}';
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
      final String fetchId = widget.item.transactionVisitorId.isNotEmpty
          ? widget.item.transactionVisitorId
          : widget.item.id;
      final list = await controller.fetchTransactionVisitors(fetchId);

      final parentFlow = widget.item.flow;
      final parentSiteId = widget.item.siteId;
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
                        color: const PdfColor(1.0, 1.0, 1.0, 0.18),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                        border: pw.Border.all(
                          color: const PdfColor(1.0, 1.0, 1.0, 0.4),
                          width: 1,
                        ),
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
        final isQuickAccess = model.flow.toLowerCase() == 'quickaccessvisit' ||
            model.visitorStatus.toLowerCase().trim() == 'quickaccess';
        final List<MapEntry<String, String>> fields = [
          MapEntry('Visitor Type', model.visitorTypeName),
          if (!isQuickAccess || (model.visitorRole.isNotEmpty && model.visitorRole.trim() != '-'))
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
            if (model.receiverPhone.isNotEmpty && model.receiverPhone.trim() != '-')
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
                            model.canTrackBle == true ? 'Tracked' : 'Not Tracked',
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
        'PDF Access Pass berhasil diunduh!',
        messageText: const Text(
          'PDF Access Pass berhasil diunduh!',
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
              'BUKA',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengunduh PDF Access Pass',
        messageText: const Text(
          'Gagal mengunduh PDF Access Pass',
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
                          final isQuickAccess = visitor.flow.toLowerCase() == 'quickaccessvisit' ||
                              visitor.visitorStatus.toLowerCase().trim() == 'quickaccess';

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
                                      if (!isQuickAccess || (visitor.visitorRole.isNotEmpty && visitor.visitorRole.trim() != '-'))
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
                                         if (visitor.receiverPhone.isNotEmpty && visitor.receiverPhone.trim() != '-')
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
              Padding(
                padding: EdgeInsets.fromLTRB(
                  rw(context, 20),
                  0,
                  rw(context, 20),
                  rh(context, 24),
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
  Timer? _timer;
  Worker? _listWorker;

  // Local Share Link filter state
  DateTime? startDateShare;
  DateTime? endDateShare;
  String? selectedGedungShare;
  String? selectedStatusShare;

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

      Widget listWidget;
      if (controller.shareLinks.isEmpty) {
        listWidget = Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: rw(context, 20.0)),
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
                    'No Share Links Found',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: rfs(context, 16),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  vSpace(context, 8),
                  Text(
                    "Tap the '+' button at the top right to create a new share link",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: rfs(context, 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
