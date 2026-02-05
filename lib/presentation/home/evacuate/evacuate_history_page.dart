import 'package:flutter/material.dart';
import '../../../../presentation/home/evacuate/widgets/evacuate_alert_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/core.dart';
import '../../history/widgets/filter_bottom_sheet.dart';

class EvacuateHistoryPage extends StatefulWidget {
  const EvacuateHistoryPage({super.key});

  @override
  State<EvacuateHistoryPage> createState() => _EvacuateHistoryPageState();
}

class _EvacuateHistoryPageState extends State<EvacuateHistoryPage> {
  final List<String> filterOptions = ['Option 1', 'Option 2', 'Option 3'];
  String? selectedValue;
  final List<Map<String, dynamic>> dummyAlarms = [
    {
      'visitorName': 'John Doe',
      'alarmDescription': 'Visitor entered restricted area',
      'location': 'Gedung A - Lantai 2',
      'date': 'Mon, 14 Juli 2025',
      'timeRange': '10.00 - 12.00',
      'status': AlertStatus.done,
    },
    {
      'visitorName': 'Jane Smith',
      'alarmDescription': 'Exceeded time limit',
      'location': 'Gedung B - Ruang Meeting',
      'date': 'Tue, 15 Juli 2025',
      'timeRange': '13.00 - 14.00',
      'status': AlertStatus.done,
    },
    {
      'visitorName': 'Albert Lee',
      'alarmDescription': 'Unauthorized access attempt',
      'location': 'Gedung C - Server Room',
      'date': 'Wed, 16 Juli 2025',
      'timeRange': '09.00 - 10.00',
      'status': AlertStatus.done,
    },
    {
      'visitorName': 'Emily Chan',
      'alarmDescription': 'Visitor lingered too long',
      'location': 'Gedung D - Lobby',
      'date': 'Thu, 17 Juli 2025',
      'timeRange': '15.00 - 16.30',
      'status': AlertStatus.done,
    },
  ];

  DateTime? startDate;
  DateTime? endDate;
  String? selectedGedung;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Evacuate History'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
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
                      });
                    }
                  },
                  child: _buildFilterChip('Filter'),
                ),

                const SizedBox(width: 10),

                if (selectedGedung != null)
                  _buildFilterValueChip(
                    selectedGedung!,
                    onClear: () => setState(() => selectedGedung = null),
                  ),

                const SizedBox(width: 10),

                if (startDate != null || endDate != null)
                  _buildFilterValueChip(
                    _formatDateRange(startDate, endDate),
                    onClear: () => setState(() {
                      startDate = null;
                      endDate = null;
                    }),
                  ),
              ],
            ),
            const SpaceHeight(20),
            Expanded(
              child: ListView.builder(
                itemCount: dummyAlarms.length,
                itemBuilder: (context, index) {
                  final alarm = dummyAlarms[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: EvacuateAlertCard(
                      visitorName: alarm['visitorName'],
                      alarmDescription: alarm['alarmDescription'],
                      location: alarm['location'],
                      date: alarm['date'],
                      timeRange: alarm['timeRange'],
                      status: alarm['status'],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
        children: [
          Text(label),
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
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 16),
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
