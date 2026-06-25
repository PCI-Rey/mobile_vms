import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../scan_ticket_page.dart';

class GuestParkingPage extends StatefulWidget {
  const GuestParkingPage({super.key});

  @override
  State<GuestParkingPage> createState() => _GuestParkingPageState();
}

class _GuestParkingPageState extends State<GuestParkingPage> with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  late TabController _tabController;
  final Set<String> _openedBlockers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_selectedTabIndex != _tabController.index) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
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
          'Parking',
          style: TextStyle(
            fontSize: rfs(context, 24),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(rh(context, 1.0)),
          child: Container(color: AppColors.grey300, height: rh(context, 1.0)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Standard Tab Bar
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
                    Tab(text: 'Reserved'),
                    Tab(text: 'Non Reserved'),
                  ],
                ),
              ),
            ),

            // Scrollable Content using TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Reserved Tab Content
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(rw(context, 16), rh(context, 16), rw(context, 16), 0),
                    child: Column(
                      children: [
                        // Title: Your Reservations
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Your Reservations",
                            style: TextStyle(
                              fontSize: rfs(context, 16),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E3A59),
                            ),
                          ),
                        ),
                        vSpace(context, 12),

                        // List of dummy reservations
                        ...dummyReservations.map((res) => _buildReservationCard(context, res)),

                        vSpace(context, 24),
                        const Divider(),
                        vSpace(context, 16),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "You don't have been reserved?",
                            style: TextStyle(
                              fontSize: rfs(context, 16),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E3A59),
                            ),
                          ),
                        ),
                        vSpace(context, 16),

                        // Option 1: Scan QR Code
                        _buildActionTile(
                          context,
                          icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary500),
                          label: 'Scan QR Code',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ScanTicketPage()),
                            );
                          },
                        ),
                        vSpace(context, 12),

                        // Option 2: Showing QR Code
                        _buildActionTile(
                          context,
                          icon: const Icon(Icons.qr_code, color: AppColors.primary500),
                          label: 'Showing QR Code',
                          onTap: () {
                            _showQRCodeBottomSheet(context);
                          },
                        ),
                        vSpace(context, 12),

                        // Option 3: Press to Reserve
                        _buildActionTile(
                          context,
                          icon: const Icon(Icons.touch_app, color: AppColors.primary500),
                          label: 'Press to Reserve',
                          onTap: () {
                            Get.snackbar(
                              'Success',
                              'Reserved successfully',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                            );
                          },
                        ),

                        // Extra space untuk memberikan jarak ke bottom
                        vSpace(context, 24),
                      ],
                    ),
                  ),

                  // Non Reserved Tab Content
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(rw(context, 16), rh(context, 16), rw(context, 16), 0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Your Permanent Parking Spot",
                            style: TextStyle(
                              fontSize: rfs(context, 16),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E3A59),
                            ),
                          ),
                        ),
                        vSpace(context, 12),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(rw(context, 16)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(rw(context, 12)),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Employee: Endru",
                                style: TextStyle(
                                  fontSize: rfs(context, 16),
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF2E3A59),
                                ),
                              ),
                              vSpace(context, 4),
                              Text(
                                "Assigned Slot: Slot C1",
                                style: TextStyle(
                                  fontSize: rfs(context, 14),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              vSpace(context, 16),
                              Container(
                                padding: EdgeInsets.all(rw(context, 12)),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(rw(context, 12)),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: QrImageView(
                                  data: 'PARK-ENDRU-C1',
                                  version: QrVersions.auto,
                                  size: rw(context, 140),
                                ),
                              ),
                              vSpace(context, 8),
                              Text(
                                'PARK-ENDRU-C1',
                                style: TextStyle(
                                  fontSize: rfs(context, 14),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E3A59),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        vSpace(context, 20),
                        _buildActionTile(
                          context,
                          icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary500),
                          label: 'Scan Barcode',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ScanTicketPage()),
                            );
                          },
                        ),
                        vSpace(context, 16),
                        StatefulBuilder(
                          builder: (context, setButtonState) {
                            final isBlockerOpen = _openedBlockers.contains('Slot C1');
                            return Button.filled(
                              onPressed: () {
                                setButtonState(() {
                                  if (isBlockerOpen) {
                                    _openedBlockers.remove('Slot C1');
                                    Get.snackbar(
                                      'Success',
                                      'Parking Blocker has been closed',
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.TOP,
                                    );
                                  } else {
                                    _openedBlockers.add('Slot C1');
                                    Get.snackbar(
                                      'Success',
                                      'Parking Blocker has been opened',
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.TOP,
                                    );
                                  }
                                });
                                setState(() {});
                              },
                              label: isBlockerOpen ? 'Close Parking Blocker' : 'Open Parking Blocker',
                              color: isBlockerOpen ? AppColors.error500 : AppColors.primary600,
                              height: 46.0,
                              borderRadius: 8.0,
                              fontSize: 14.0,
                            );
                          },
                        ),
                        vSpace(context, 24),
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

  Widget _buildReservationCard(BuildContext context, ParkingReservationDummy res) {
    return Container(
      margin: EdgeInsets.only(bottom: rh(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showReservationDetailBottomSheet(context, res),
          borderRadius: BorderRadius.circular(rw(context, 12)),
          child: Padding(
            padding: EdgeInsets.all(rw(context, 16)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(rw(context, 10)),
                  decoration: const BoxDecoration(
                    color: AppColors.primary50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_parking_rounded,
                    color: AppColors.primary500,
                    size: 20,
                  ),
                ),
                hSpace(context, 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        res.agenda,
                        style: TextStyle(
                          fontSize: rfs(context, 14),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E3A59),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      vSpace(context, 4),
                      Text(
                        '${res.date} • ${res.time}',
                        style: TextStyle(
                          fontSize: rfs(context, 12),
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                hSpace(context, 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: rw(context, 10), vertical: rh(context, 6)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.circular(rw(context, 20)),
                    border: Border.all(color: const Color(0xFFBDD0F7)),
                  ),
                  child: Text(
                    res.slot,
                    style: TextStyle(
                      fontSize: rfs(context, 11),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReservationDetailBottomSheet(BuildContext context, ParkingReservationDummy res) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isBlockerOpen = _openedBlockers.contains(res.slot);
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(rw(context, 24)),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 24),
              vertical: rh(context, 20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: rw(context, 40),
                    height: rh(context, 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(rw(context, 2)),
                    ),
                  ),
                ),
                vSpace(context, 20),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(rw(context, 8)),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF4FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.event_seat_rounded,
                        color: AppColors.primary500,
                        size: 20,
                      ),
                    ),
                    hSpace(context, 10),
                    Text(
                      'Reservation Detail',
                      style: TextStyle(
                        fontSize: rfs(context, 18),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E3A59),
                      ),
                    ),
                  ],
                ),
                vSpace(context, 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(rw(context, 16)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(rw(context, 12)),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem(context, 'Agenda', res.agenda),
                      const Divider(),
                      _buildDetailItem(context, 'Date', res.date),
                      const Divider(),
                      _buildDetailItem(context, 'Time Range', res.time),
                      const Divider(),
                      _buildDetailItem(context, 'Parking Area', res.area),
                      const Divider(),
                      _buildDetailItem(context, 'Parking Slot', res.slot),
                      const Divider(),
                      _buildDetailItem(context, 'Host Name', res.host),
                      const Divider(),
                      _buildDetailItem(context, 'Status', res.status, isStatus: true),
                      const Divider(),
                      vSpace(context, 8),
                      Text(
                        'View Parking',
                        style: TextStyle(
                          fontSize: rfs(context, 13),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      vSpace(context, 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(rw(context, 8)),
                        child: Container(
                          width: double.infinity,
                          height: rh(context, 150),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(rw(context, 8)),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Assets.images.parkingSlot.image(
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                vSpace(context, 16),
                Button.filled(
                  onPressed: () {
                    setModalState(() {
                      if (isBlockerOpen) {
                        _openedBlockers.remove(res.slot);
                        Get.snackbar(
                          'Success',
                          'Parking Blocker has been closed',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                      } else {
                        _openedBlockers.add(res.slot);
                        Get.snackbar(
                          'Success',
                          'Parking Blocker has been opened',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                      }
                    });
                    setState(() {});
                  },
                  label: isBlockerOpen ? 'Close Parking Blocker' : 'Open Parking Blocker',
                  color: isBlockerOpen ? AppColors.error500 : AppColors.primary600,
                  height: 46.0,
                  borderRadius: 8.0,
                  fontSize: 14.0,
                ),
                vSpace(context, 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value, {bool isStatus = false}) {
    Color badgeBg = const Color(0xFFE8F5E9);
    Color badgeText = const Color(0xFF2E7D32);
    if (value == 'Designated') {
      badgeBg = const Color(0xFFE3F2FD);
      badgeText = const Color(0xFF1565C0);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: rh(context, 8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: rw(context, 110),
            child: Text(
              label,
              style: TextStyle(
                fontSize: rfs(context, 13),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Expanded(
            child: isStatus
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: rw(context, 8), vertical: rh(context, 4)),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(rw(context, 12)),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: rfs(context, 11),
                          fontWeight: FontWeight.bold,
                          color: badgeText,
                        ),
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: rfs(context, 13),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E3A59),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 10)),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(rw(context, 10)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 16),
              vertical: rh(context, 14),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(rw(context, 8)),
                  decoration: BoxDecoration(
                    color: AppColors.primary50.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: icon,
                ),
                hSpace(context, 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: rfs(context, 15),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E3A59),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: rw(context, 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQRCodeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(rw(context, 24)),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: rw(context, 24),
          vertical: rh(context, 20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: rw(context, 40),
                height: rh(context, 4),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(rw(context, 2)),
                ),
              ),
            ),
            vSpace(context, 20),
            Text(
              'Your Parking QR Code',
              style: TextStyle(
                fontSize: rfs(context, 18),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E3A59),
              ),
            ),
            vSpace(context, 16),
            Container(
              padding: EdgeInsets.all(rw(context, 16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rw(context, 16)),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary500.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: 'PARK-DUMMY-12345',
                version: QrVersions.auto,
                size: rw(context, 180),
              ),
            ),
            vSpace(context, 12),
            Text(
              'PARK-DUMMY-12345',
              style: TextStyle(
                fontSize: rfs(context, 20),
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
                letterSpacing: 2.5,
              ),
            ),
            vSpace(context, 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: rw(context, 12),
                  color: Colors.grey.shade400,
                ),
                hSpace(context, 4),
                Text(
                  'Show this code to the officer',
                  style: TextStyle(
                    fontSize: rfs(context, 12),
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            vSpace(context, 20),
          ],
        ),
      ),
    );
  }
}

class ParkingReservationDummy {
  final String agenda;
  final String date;
  final String time;
  final String slot;
  final String area;
  final String host;
  final String status;

  ParkingReservationDummy({
    required this.agenda,
    required this.date,
    required this.time,
    required this.slot,
    required this.area,
    required this.host,
    required this.status,
  });
}

final List<ParkingReservationDummy> dummyReservations = [
  ParkingReservationDummy(
    agenda: 'Meeting with Google Client',
    date: 'Mon, 19 Jul 2025',
    time: '10:00 - 13:00',
    slot: 'Slot A1',
    area: 'Parking Area A',
    host: 'John Doe',
    status: 'Reserved',
  ),
  ParkingReservationDummy(
    agenda: 'Interview Candidate - UI/UX Designer',
    date: 'Tue, 20 Jul 2025',
    time: '14:00 - 16:00',
    slot: 'Slot B3',
    area: 'Parking Area B',
    host: 'Jane Smith',
    status: 'Reserved',
  ),
  ParkingReservationDummy(
    agenda: 'Weekly Sync VMS Development',
    date: 'Wed, 21 Jul 2025',
    time: '09:00 - 11:00',
    slot: 'Slot A3',
    area: 'Parking Area A',
    host: 'Alex Johnson',
    status: 'Reserved',
  ),
];