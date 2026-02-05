import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/core.dart';
import '../../history/widgets/filter_bottom_sheet.dart';
import 'controller/approval_controller.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedGedung;
  VisitorStatus? selectedStatus;
  late final ApprovalController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ApprovalController>()) {
      controller = Get.find<ApprovalController>();
    } else {
      controller = Get.put(ApprovalController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Approval'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter section - fixed at top
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter chips row with horizontal scroll if needed
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
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
                                builder: (context) => const FilterBottomSheet(),
                              );

                          if (result != null) {
                            setState(() {
                              startDate = result['startDate'];
                              endDate = result['endDate'];
                              selectedGedung = result['gedung'];
                              selectedStatus = result['status'];
                            });

                            // Apply filter to controller
                            controller.loadApprovalsWithFilter(
                              startDate: startDate,
                              endDate: endDate,
                              gedung: selectedGedung,
                              status: selectedStatus,
                            );
                          }
                        },
                        child: _buildFilterChip('Filter'),
                      ),

                      const SizedBox(width: 10),

                      if (selectedGedung != null) ...[
                        _buildFilterValueChip(
                          selectedGedung!,
                          onClear: () {
                            setState(() => selectedGedung = null);
                            _applyFilters();
                          },
                        ),
                        const SizedBox(width: 10),
                      ],

                      if (selectedStatus != null) ...[
                        _buildFilterValueChip(
                          _getStatusLabel(selectedStatus!),
                          onClear: () {
                            setState(() => selectedStatus = null);
                            _applyFilters();
                          },
                        ),
                        const SizedBox(width: 10),
                      ],

                      if (startDate != null || endDate != null) ...[
                        _buildFilterValueChip(
                          _formatDateRange(startDate, endDate),
                          onClear: () {
                            setState(() {
                              startDate = null;
                              endDate = null;
                            });
                            _applyFilters();
                          },
                        ),
                        const SizedBox(width: 10),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Add divider between filter and content
          Container(height: 1, color: AppColors.grey200),

          // Scrollable content area
          Expanded(child: _buildApprovalsList()),
        ],
      ),
    );
  }

  void _applyFilters() {
    controller.loadApprovalsWithFilter(
      startDate: startDate,
      endDate: endDate,
      gedung: selectedGedung,
      status: selectedStatus,
    );
  }

  Widget _buildApprovalsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value != null) {
        return _buildErrorState(controller.errorMessage.value!);
      }

      final approvals = controller.filteredApprovals;

      if (approvals.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () async {
          controller.refreshApprovals();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(20.0),
          itemCount: approvals.length,
          itemBuilder: (context, index) {
            final approval = approvals[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: VisitorCard(
                status: approval.status,
                visitorName: approval.visitorName,
                companyName: approval.companyName,
                destination: approval.destination,
                date: approval.date,
                timeRange: approval.timeRange,
                avatar: Assets.images.avaPerson1.image(height: 40),
                onDeny: approval.status == VisitorStatus.pending
                    ? () {
                        _showConfirmationDialog(
                          context,
                          'Deny Approval',
                          'Apakah Anda yakin ingin menolak pengunjung ini?',
                          () => controller.denyVisitor(approval.id),
                        );
                      }
                    : null,
                onApprove: approval.status == VisitorStatus.pending
                    ? () {
                        _showConfirmationDialog(
                          context,
                          'Approve Visitor',
                          'Apakah Anda yakin ingin menyetujui pengunjung ini?',
                          () => controller.approveVisitor(approval.id),
                        );
                      }
                    : null,
              ),
            );
          },
        ),
      );
    });
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Terjadi Kesalahan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              controller.loadApprovals();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.approval, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Belum ada approval pengunjung',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Approval pengunjung akan muncul di sini',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          const Icon(FontAwesomeIcons.chevronDown, size: 14),
        ],
      ),
    );
  }

  Widget _buildFilterValueChip(String label, {required VoidCallback onClear}) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        border: Border.all(color: AppColors.primary200),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary700,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.primary200,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 12, color: AppColors.primary700),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '';
    final format = DateFormat('dd/MM/yy'); // Shortened format for chips
    if (start != null && end != null) {
      return '${format.format(start)} - ${format.format(end)}';
    } else if (start != null) {
      return 'Dari ${format.format(start)}';
    } else {
      return 'Sampai ${format.format(end!)}';
    }
  }

  String _getStatusLabel(VisitorStatus status) {
    switch (status) {
      case VisitorStatus.pending:
        return 'Pending';
      case VisitorStatus.approved:
        return 'Approved';
      case VisitorStatus.denied:
        return 'Denied';
      case VisitorStatus.checkedIn:
        return 'Checked In';
      default:
        return status.toString().split('.').last;
    }
  }
}

// Note: Use the existing VisitorCard widget from your components
// The VisitorCard widget should be imported from your components library
