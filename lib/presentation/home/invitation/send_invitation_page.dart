import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
          "Create Invitation",
          style: TextStyle(
            fontSize: rfs(context, 20),
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
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary600,
              unselectedLabelColor: Colors.grey.shade500,
              indicatorColor: AppColors.primary600,
              indicatorWeight: 2.5,
              labelStyle: TextStyle(
                fontSize: rfs(context, 14),
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: rfs(context, 14),
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Invitation'),
                Tab(text: 'Share Link'),
                Tab(text: 'Quick Access'),
              ],
            ),
          ),

          // ── Content Area ──────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildInvitationTab(), _buildShareLinkTab(), _buildQuickAccessTab()],
            ),
          ),
        ],
      ),
    );
  }

  bool _isQuickAccessItem(AccessPassModel item) {
    final str = '${item.visitorStatus} ${item.visitorTypeName} ${item.visitorRole} ${item.agenda}'.toLowerCase();
    return str.contains('quick') && (str.contains('access') || str.contains('acess') || str.contains('acesss'));
  }

  Widget _buildInvitationTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Filter bar ─────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rw(context, 20),
            vertical: rh(context, 10),
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
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        Container(height: 1, color: const Color(0xFFF0F0F0)),

        // ── List ──────────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
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
                    
                    final listToShow = inviteCtrl.ongoingInvitations
                        .where((item) => !_isQuickAccessItem(item))
                        .toList();

                    if (inviteCtrl.isLoading.value && listToShow.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(rw(context, 40.0)),
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (listToShow.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(rw(context, 40.0)),
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
                      separatorBuilder: (context, index) => vSpace(context, 10),
                      itemBuilder: (context, index) {
                        final item = inviteCtrl.ongoingInvitations[index];
                        final now = DateTime.now();
                        final isExpired = item.visitorPeriodEnd.isBefore(now);
                        final isPraregis = item.isPraregisterDone;
                        final jenis = isPraregis ? 'Praregis' : 'Invitation';
                        final jenisColor = isPraregis

                            ? const Color(0xFF005596)
                            : const Color(0xFF6D4C41);

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
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Top bar: No + badges ──────────────────
                                Container(
                                  margin: EdgeInsets.fromLTRB(
                                    rw(context, 14),
                                    rh(context, 10),
                                    rw(context, 14),
                                    0,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: rw(context, 12),
                                    vertical: rh(context, 10),
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF005596).withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(rw(context, 10)),
                                    border: Border.all(
                                      color: const Color(0xFF005596).withValues(alpha: 0.18),
                                    ),
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
                                            fontSize: rfs(context, 11),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      hSpace(context, 10),
                                      Expanded(
                                        child: Text(
                                          item.visitorName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: rfs(context, 14),
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      hSpace(context, 6),
                                      // Jenis badge
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: rw(context, 7),
                                          vertical: rh(context, 3),
                                        ),
                                        decoration: BoxDecoration(
                                          color: jenisColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(rw(context, 20)),
                                          border: Border.all(color: jenisColor.withValues(alpha: 0.4)),
                                        ),
                                        child: Text(
                                          jenis,
                                          style: TextStyle(
                                            fontSize: rfs(context, 10),
                                            fontWeight: FontWeight.w600,
                                            color: jenisColor,
                                          ),
                                        ),
                                      ),
                                      hSpace(context, 6),
                                      // Expired badge
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: rw(context, 7),
                                          vertical: rh(context, 3),
                                        ),
                                        decoration: BoxDecoration(
                                          color: isExpired
                                              ? Colors.red.withValues(alpha: 0.1)
                                              : Colors.green.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(rw(context, 20)),
                                          border: Border.all(
                                            color: isExpired
                                                ? Colors.red.withValues(alpha: 0.4)
                                                : Colors.green.withValues(alpha: 0.4),
                                          ),
                                        ),
                                        child: Text(
                                          isExpired ? 'Expired' : 'Active',
                                          style: TextStyle(
                                            fontSize: rfs(context, 10),
                                            fontWeight: FontWeight.w600,
                                            color: isExpired ? Colors.red.shade700 : Colors.green.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ── Body: info rows ───────────────────────
                                Container(
                                  margin: EdgeInsets.fromLTRB(
                                    rw(context, 14),
                                    rh(context, 8),
                                    rw(context, 14),
                                    rh(context, 12),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: rw(context, 12),
                                    vertical: rh(context, 10),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(rw(context, 10)),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    children: [
                                      // Row 1: Visitor Type + Invitation Code
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
                                              Icons.confirmation_number_outlined,
                                              'Invitation Code',
                                              item.invitationCode.isEmpty ? '-' : item.invitationCode,
                                              color: const Color(0xFF005596),
                                              trailing: GestureDetector(
                                                onTap: () {
                                                  if (isExpired) {
                                                    Get.snackbar(
                                                      'Info',
                                                      'Invitation has expired, code cannot be copied.',
                                                      snackPosition: SnackPosition.TOP,
                                                      backgroundColor: Colors.red.shade600,
                                                      colorText: Colors.white,
                                                    );
                                                    return;
                                                  }
                                                  if (item.invitationCode.isNotEmpty) {
                                                    Clipboard.setData(ClipboardData(
                                                        text: item.invitationCode));
                                                    Get.snackbar(
                                                      'Copied',
                                                      'Invitation Code copied to clipboard',
                                                      snackPosition: SnackPosition.TOP,
                                                      backgroundColor: Colors.green,
                                                      colorText: Colors.white,
                                                      duration: const Duration(seconds: 1),
                                                    );
                                                  }
                                                },
                                                child: Icon(
                                                  Icons.copy,
                                                  size: rw(context, 14),
                                                  color: isExpired
                                                      ? Colors.grey.shade400
                                                      : const Color(0xFF005596),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      vSpace(context, 8),
                                      // Row 2: Organization + Host
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildCardField(
                                              context,
                                              Icons.business_outlined,
                                              'Organization',
                                              item.visitorOrganizationName.isEmpty
                                                  ? '-'
                                                  : item.visitorOrganizationName,
                                            ),
                                          ),
                                          hSpace(context, 8),
                                          Expanded(
                                            child: _buildCardField(
                                              context,
                                              Icons.person_outline,
                                              'Host',
                                              item.hostName.isEmpty ? '-' : item.hostName,
                                            ),
                                          ),
                                        ],
                                      ),
                                      vSpace(context, 8),
                                      // Row 3: Period Start + Period End
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildCardField(
                                              context,
                                              Icons.login_outlined,
                                              'Period Start',
                                              DateFormat('dd MMM yy HH:mm')
                                                  .format(item.visitorPeriodStart),
                                            ),
                                          ),
                                          hSpace(context, 8),
                                          Expanded(
                                            child: _buildCardField(
                                              context,
                                              Icons.logout_outlined,
                                              'Period End',
                                              DateFormat('dd MMM yy HH:mm')
                                                  .format(item.visitorPeriodEnd),
                                              color: isExpired ? Colors.red.shade600 : null,
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
                ],
              ),
            ),
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
        Expanded(
          child: RefreshIndicator(
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
                    
                    final listToShow = inviteCtrl.ongoingInvitations
                        .where((item) => _isQuickAccessItem(item))
                        .toList();

                    if (inviteCtrl.isLoading.value && listToShow.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(rw(context, 40.0)),
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (listToShow.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(rw(context, 40.0)),
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
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: listToShow.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = listToShow[index];
                        final isExpired =
                            DateTime.now().isAfter(item.visitorPeriodEnd);

                        return GestureDetector(
                          onTap: () {},
                          child: Container(
                            margin: EdgeInsets.only(bottom: rh(context, 16)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(rw(context, 12)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Column(
                              children: [
                                // TOP ROW
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: rw(context, 16),
                                    vertical: rh(context, 12),
                                  ),
                                  decoration: BoxDecoration(
                                    color: isExpired
                                        ? Colors.red.shade50
                                        : AppColors.primary50,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(rw(context, 12)),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(rw(context, 6)),
                                            decoration: BoxDecoration(
                                              color: isExpired
                                                  ? Colors.red.shade100
                                                  : AppColors.primary100,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.flash_on,
                                              size: rw(context, 16),
                                              color: isExpired
                                                  ? Colors.red.shade700
                                                  : AppColors.primary700,
                                            ),
                                          ),
                                          hSpace(context, 10),
                                          Text(
                                            'Quick Access',
                                            style: TextStyle(
                                              fontSize: rfs(context, 14),
                                              fontWeight: FontWeight.w600,
                                              color: isExpired
                                                  ? Colors.red.shade900
                                                  : AppColors.primary900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: rw(context, 10),
                                          vertical: rh(context, 4),
                                        ),
                                        decoration: BoxDecoration(
                                          color: isExpired
                                              ? Colors.red.withValues(alpha: 0.1)
                                              : Colors.green.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(rw(context, 20)),
                                          border: Border.all(
                                            color: isExpired
                                                ? Colors.red.withValues(alpha: 0.4)
                                                : Colors.green.withValues(alpha: 0.4),
                                          ),
                                        ),
                                        child: Text(
                                          isExpired ? 'Expired' : 'Active',
                                          style: TextStyle(
                                            fontSize: rfs(context, 10),
                                            fontWeight: FontWeight.w600,
                                            color: isExpired ? Colors.red.shade700 : Colors.green.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // DETAILS
                                Padding(
                                  padding: EdgeInsets.all(rw(context, 16)),
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
                                              'Visitor Name',
                                              item.visitorName,
                                            ),
                                          ),
                                          hSpace(context, 8),
                                          Expanded(
                                            child: _buildCardField(
                                              context,
                                              Icons.business_outlined,
                                              'Organization',
                                              item.visitorOrganizationName.isEmpty
                                                  ? '-'
                                                  : item.visitorOrganizationName,
                                            ),
                                          ),
                                        ],
                                      ),
                                      vSpace(context, 8),
                                      // Row 2: Location + Host
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildCardField(
                                              context,
                                              Icons.location_on_outlined,
                                              'Location',
                                              item.sitePlaceName.isEmpty
                                                  ? '-'
                                                  : item.sitePlaceName,
                                            ),
                                          ),
                                          hSpace(context, 8),
                                          Expanded(
                                            child: _buildCardField(
                                              context,
                                              Icons.assignment_ind_outlined,
                                              'Host',
                                              item.hostName.isEmpty ? '-' : item.hostName,
                                            ),
                                          ),
                                        ],
                                      ),
                                      vSpace(context, 8),
                                      // Row 3: Period Start + Period End
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildCardField(
                                              context,
                                              Icons.login_outlined,
                                              'Period Start',
                                              DateFormat('dd MMM yy HH:mm')
                                                  .format(item.visitorPeriodStart),
                                            ),
                                          ),
                                          hSpace(context, 8),
                                          Expanded(
                                            child: _buildCardField(
                                              context,
                                              Icons.logout_outlined,
                                              'Period End',
                                              DateFormat('dd MMM yy HH:mm')
                                                  .format(item.visitorPeriodEnd),
                                              color: isExpired ? Colors.red.shade600 : null,
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
                ],
              ),
            ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: rw(context, 13), color: Colors.grey.shade400),
        hSpace(context, 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: rfs(context, 10),
                  color: Colors.grey.shade500,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.w600,
                        color: color ?? Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  if (trailing != null) ...[
                    hSpace(context, 4),
                    trailing,
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInvitationDetailSheet(AccessPassModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _InvitationDetailSheet(item: item),
    );
  }


  Widget _buildFilterChip(BuildContext context, String label) {
    return Container(
      height: rh(context, 32),
      padding: EdgeInsets.symmetric(horizontal: rw(context, 12)),
      decoration: BoxDecoration(
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

// ─── _SheetField model ────────────────────────────────────────────────────────
// ─── _InvitationDetailSheet ─────────────────────────────────────────────────
class _InvitationDetailSheet extends StatefulWidget {
  final AccessPassModel item;
  const _InvitationDetailSheet({required this.item});

  @override
  State<_InvitationDetailSheet> createState() => _InvitationDetailSheetState();
}

class _InvitationDetailSheetState extends State<_InvitationDetailSheet> {
  String _sitePlaceName = '';
  bool _loadingSite = true;

  @override
  void initState() {
    super.initState();
    _fetchSiteDetail();
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
    } catch (e) {
      debugPrint('fetchSiteDetail error: $e');
    }
    if (mounted) setState(() => _loadingSite = false);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'checkin':    return const Color(0xFF00897B);
      case 'checkout':   return const Color(0xFF3949AB);
      case 'available':  return const Color(0xFF43A047);
      case 'waiting':    return const Color(0xFFFB8C00);
      case 'denied':     return const Color(0xFFE53935);
      case 'quickaccess':return const Color(0xFF8E24AA);
      default:           return const Color(0xFF546E7A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isExpired = item.visitorPeriodEnd.isBefore(DateTime.now());
    final statusColor = _statusColor(item.visitorStatus);

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
                      child: Text(
                        item.visitorName,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: rfs(context, 16),
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 10),
                        vertical: rh(context, 5),
                      ),
                      decoration: BoxDecoration(
                        color: isExpired
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(rw(context, 20)),
                        border: Border.all(
                          color: isExpired
                              ? Colors.red.withValues(alpha: 0.5)
                              : Colors.green.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        isExpired ? 'Expired' : 'Active',
                        style: TextStyle(
                          fontSize: rfs(context, 11),
                          fontWeight: FontWeight.w700,
                          color: isExpired
                              ? Colors.red.shade700
                              : Colors.green.shade700,
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
                    // 1. Visitor Information
                    _section(context, 'Visitor Information'),
                    _grid(context, statusColor, [
                      _SheetField('Visitor Type',
                          item.visitorTypeName.isEmpty ? '-' : item.visitorTypeName,
                          Icons.badge_outlined),
                      _SheetField('Visitor Role',
                          item.visitorRole.isEmpty ? '-' : item.visitorRole,
                          Icons.work_outline),
                      _SheetField('Name',
                          item.visitorName.isEmpty ? '-' : item.visitorName,
                          Icons.person_outline),
                      _SheetField('Email',
                          item.visitorEmail.isEmpty ? '-' : item.visitorEmail,
                          Icons.email_outlined),
                      _SheetField('Phone',
                          item.visitorPhone.isEmpty ? '-' : item.visitorPhone,
                          Icons.phone_outlined),
                      _SheetField('Organization',
                          item.visitorOrganizationName.isEmpty ? '-' : item.visitorOrganizationName,
                          Icons.business_outlined),
                      _SheetField('Identity ID',
                          item.visitorIdentityId.isEmpty ? '-' : item.visitorIdentityId,
                          Icons.credit_card_outlined),
                    ], isExpired: isExpired),

                    vSpace(context, 16),

                    // 2. Invitation Information (tanpa "Type")
                    _section(context, 'Invitation Information'),
                    _grid(context, statusColor, [
                      _SheetField('Invitation Code',
                          item.invitationCode.isEmpty ? '-' : item.invitationCode,
                          Icons.confirmation_number_outlined,
                          isCode: true),
                      _SheetField('Visitor Code',
                          item.visitorCode.isEmpty ? '-' : item.visitorCode,
                          Icons.pin_outlined),
                      _SheetField('Group Name',
                          item.groupName.isEmpty ? '-' : item.groupName,
                          Icons.group_outlined),
                      _SheetField('Visitor Status',
                          item.visitorStatus.isEmpty ? '-' : item.visitorStatus,
                          Icons.info_outline,
                          badgeColor: statusColor),
                      _SheetField('Agenda',
                          item.agenda.isEmpty ? '-' : item.agenda,
                          Icons.event_note_outlined),
                      _SheetField('Host',
                          item.hostName.isEmpty ? '-' : item.hostName,
                          Icons.person_outline),
                      _SheetField('Vehicle Type',
                          item.vehicleType.isEmpty ? '-' : item.vehicleType,
                          Icons.directions_car_outlined),
                      _SheetField('Vehicle Plate',
                          item.vehiclePlateNumber.isEmpty ? '-' : item.vehiclePlateNumber,
                          Icons.subtitles_outlined),
                    ], isExpired: isExpired),

                    vSpace(context, 16),

                    // 3. Visit Period
                    _section(context, 'Visit Period'),

                    // Registered Site (async)
                    _SheetFieldRow(
                      context: context,
                      icon: Icons.location_on_outlined,
                      label: 'Registered Site',
                      value: _loadingSite ? '...' : (_sitePlaceName.isEmpty ? '-' : _sitePlaceName),
                    ),
                    vSpace(context, 8),

                    // Start / End
                    Container(
                      padding: EdgeInsets.all(rw(context, 14)),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(rw(context, 10)),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Icon(Icons.login_outlined,
                                      size: rw(context, 14),
                                      color: Colors.green.shade600),
                                  hSpace(context, 4),
                                  Text('Start',
                                      style: TextStyle(
                                          fontSize: rfs(context, 11),
                                          color: Colors.grey.shade500)),
                                ]),
                                vSpace(context, 4),
                                Text(
                                  DateFormat('dd MMM yyyy').format(item.visitorPeriodStart),
                                  style: TextStyle(
                                      fontSize: rfs(context, 13),
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87),
                                ),
                                Text(
                                  DateFormat('HH:mm').format(item.visitorPeriodStart),
                                  style: TextStyle(
                                      fontSize: rfs(context, 12),
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: rh(context, 50), color: Colors.grey.shade300),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: rw(context, 12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Icon(Icons.logout_outlined,
                                        size: rw(context, 14),
                                        color: isExpired ? Colors.red.shade600 : Colors.grey.shade500),
                                    hSpace(context, 4),
                                    Text('End',
                                        style: TextStyle(
                                            fontSize: rfs(context, 11),
                                            color: Colors.grey.shade500)),
                                  ]),
                                  vSpace(context, 4),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(item.visitorPeriodEnd),
                                    style: TextStyle(
                                        fontSize: rfs(context, 13),
                                        fontWeight: FontWeight.w700,
                                        color: isExpired ? Colors.red.shade600 : Colors.black87),
                                  ),
                                  Text(
                                    DateFormat('HH:mm').format(item.visitorPeriodEnd),
                                    style: TextStyle(
                                        fontSize: rfs(context, 12),
                                        color: isExpired ? Colors.red.shade400 : Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    vSpace(context, 24),
                  ],
                ),
              ),

              // ── Close button ───────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                    rw(context, 20), 0, rw(context, 20), rh(context, 24)),
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

  Widget _section(BuildContext context, String title) {
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
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: rfs(context, 13),
                  color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _grid(BuildContext context, Color statusColor, List<_SheetField> fields, {bool isExpired = false}) {
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
                    horizontal: rw(context, 14), vertical: rh(context, 10)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(f.icon, size: rw(context, 16), color: Colors.grey.shade400),
                    hSpace(context, 10),
                    SizedBox(
                      width: rw(context, 100),
                      child: Text(f.label,
                          style: TextStyle(
                              fontSize: rfs(context, 12),
                              color: Colors.grey.shade500)),
                    ),
                    Expanded(
                      child: f.badgeColor != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: rw(context, 8),
                                      vertical: rh(context, 3)),
                                  decoration: BoxDecoration(
                                    color: f.badgeColor,
                                    borderRadius: BorderRadius.circular(rw(context, 4)),
                                  ),
                                  child: Text(f.value,
                                      style: TextStyle(
                                          fontSize: rfs(context, 11),
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(f.value,
                                      style: TextStyle(
                                          fontSize: rfs(context, 13),
                                          fontWeight: FontWeight.w600,
                                          color: f.isCode
                                              ? const Color(0xFF005596)
                                              : Colors.black87),
                                      textAlign: TextAlign.end,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2),
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
                                          margin: EdgeInsets.all(rw(context, 10)),
                                        );
                                        return;
                                      }
                                      Clipboard.setData(
                                          ClipboardData(text: f.value));
                                      Get.snackbar('Copied',
                                          'Copied to clipboard',
                                          snackPosition: SnackPosition.TOP,
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                          duration: const Duration(seconds: 1),
                                          margin: EdgeInsets.all(rw(context, 10)));
                                    },
                                    child: Icon(Icons.copy,
                                        size: rw(context, 14),
                                        color: isExpired ? Colors.grey.shade300 : Colors.grey.shade400),
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
                    endIndent: rw(context, 14)),
            ],
          );
        }),
      ),
    );
  }
}

/// Single-row field for Registered Site with full-width bordered container
class _SheetFieldRow extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String label;
  final String value;

  const _SheetFieldRow({
    required this.context,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: rw(ctx, 14), vertical: rh(ctx, 12)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(rw(ctx, 10)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: rw(ctx, 16), color: Colors.grey.shade400),
          hSpace(ctx, 10),
          SizedBox(
            width: rw(ctx, 100),
            child: Text(label,
                style: TextStyle(
                    fontSize: rfs(ctx, 12), color: Colors.grey.shade500)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: rfs(ctx, 13),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
