import 'package:flutter/material.dart';
import '../../../../data/datasources/dummy_data.dart';
import '../../../../presentation/home/report/widgets/stats_card.dart';
import '../../../../presentation/home/report/widgets/visitor_table.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/core.dart';
import '../../../data/datasources/agenda_datasource.dart';
import '../../history/widgets/filter_bottom_sheet.dart';
import 'widgets/visitor_line_chart.dart';

class VisitorReportPage extends StatefulWidget {
  const VisitorReportPage({super.key});

  @override
  State<VisitorReportPage> createState() => _VisitorReportPageState();
}

class _VisitorReportPageState extends State<VisitorReportPage> {
  Map<String, int> _calculateVisitorStatus() {
    int checkin = 0;
    int checkout = 0;
    int deny = 0;

    for (var agenda in dummyAgendas) {
      for (var visitor in agenda.visitors) {
        switch (visitor.status) {
          case 'checkin':
            checkin++;
            break;
          case 'checkout':
            checkout++;
            break;
          case 'deny':
            deny++;
            break;
        }
      }
    }

    return {'checkin': checkin, 'checkout': checkout, 'deny': deny};
  }

  @override
  Widget build(BuildContext context) {
    final statusCount = _calculateVisitorStatus();
    final List<String> filterOptions = ['Option 1', 'Option 2', 'Option 3'];
    String? selectedValue;
    DateTime? startDate;
    DateTime? endDate;
    String? selectedGedung;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Report'),
        leading: BackButton(),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedValue,
                        hint: const Text('Export'),
                        icon: const Icon(
                          FontAwesomeIcons.chevronDown,
                          size: 16,
                        ),
                        isExpanded: false,
                        isDense: true,
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value;
                          });
                        },
                        items: filterOptions.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),

              SpaceHeight(20),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Batasi lebar maksimum container
                  double maxWidth = constraints.maxWidth > 800
                      ? 800
                      : constraints.maxWidth;
                  double sideMargin = (constraints.maxWidth - maxWidth) / 2;

                  final spacing = 16.0;
                  final itemWidth = (maxWidth - spacing * 2) / 3;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: sideMargin),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildSquareStatCard('Total Visitor', '100', itemWidth),
                        buildSquareStatCard('New Visitor', '30', itemWidth),
                        buildSquareStatCard('Returning', '70', itemWidth),
                      ],
                    ),
                  );
                },
              ),

              SpaceHeight(20),
              SizedBox(height: 300, child: VisitorLineChart()),
              SpaceHeight(20),

              VisitorTable(),
              SpaceHeight(20),
            ],
          ),
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
