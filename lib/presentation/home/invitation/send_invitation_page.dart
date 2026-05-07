import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/invitation_controller.dart';
import '../../../../presentation/home/visitor_request/add_pra_registration_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/components/custom_card.dart';
import '../../../core/core.dart';
import '../../history/widgets/filter_bottom_sheet.dart';

class SendInvitationPage extends StatefulWidget {
  const SendInvitationPage({super.key});

  @override
  State<SendInvitationPage> createState() => _SendInvitationPageState();
}

class _SendInvitationPageState extends State<SendInvitationPage> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedGedung;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Send Invitation",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(),
        actions: [
          // Tombol Share Link
          IconButton(
            onPressed: () {
              // TODO: Implement share link logic
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.grey300),
              ),
              child: const Icon(Icons.link, color: AppColors.grey600, size: 20),
            ),
          ),
          // Tombol Tambah +
          IconButton(
            onPressed: () {
              showAddPraRegistrationDialog(context);
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
      body: RefreshIndicator(
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
                    final isCheckout = item.visitorStatus
                        .toLowerCase()
                        .contains('checkout');
                    final isCheckin = item.visitorStatus.toLowerCase().contains(
                      'checkin',
                    );
                    final isPreregis = item.visitorStatus
                        .toLowerCase()
                        .contains('preregis');
                    final isDone = item.isPraregisterDone;

                    // Tentukan Ikon dan Warna berdasarkan 4 Status
                    IconData statusIcon;
                    Color statusColor;

                    if (isCheckout) {
                      // 1. Sudah Check Out
                      statusIcon = Icons.cancel;
                      statusColor = AppColors.success500; // Hijau
                    } else if (isCheckin) {
                      // 2. Sudah Check In
                      statusIcon = Icons.check_circle;
                      statusColor = AppColors.success500; // Hijau
                    } else if (isPreregis && isDone) {
                      // 3. Sudah Isi Form (Preregis Selesai)
                      statusIcon = Icons.fact_check;
                      statusColor = Colors.grey; // Hijau
                    } else {
                      // 4. Belum Isi Form (Preregis Pending)
                      statusIcon = Icons.assignment_late;
                      statusColor = Colors.grey; // Abu-abu (Ikut tabel backend)
                    }

                    return CustomCard(
                      image: Icon(statusIcon, color: Colors.white),
                      size: 26,
                      title: item.visitorName,
                      subtitle: item.sitePlaceName.isNotEmpty
                          ? item.sitePlaceName
                          : item.groupName,
                      additional: DateFormat(
                        'EEE, dd MMM yyyy',
                      ).format(item.visitorPeriodStart),
                      additionalDesc:
                          '${DateFormat('HH:mm').format(item.visitorPeriodStart)} - ${DateFormat('HH:mm').format(item.visitorPeriodEnd)}',
                      backgroundIconColor: statusColor,
                      // Additional info like invitation code
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
                    );
                  },
                );
              }),
            ],
          ),
        ),
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
          const Icon(FontAwesomeIcons.chevronDown, size: 12, color: Colors.grey),
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
