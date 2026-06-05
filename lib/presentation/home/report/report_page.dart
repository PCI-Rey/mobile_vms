import 'package:flutter/material.dart';
import '../../../../presentation/home/report/widgets/stats_card.dart';
import '../../../../presentation/home/report/widgets/visitor_table.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../history/widgets/filter_bottom_sheet.dart';
import 'widgets/visitor_line_chart.dart';

class VisitorReportPage extends StatefulWidget {
  const VisitorReportPage({super.key});

  @override
  State<VisitorReportPage> createState() => _VisitorReportPageState();
}

class _VisitorReportPageState extends State<VisitorReportPage> {
  @override
  Widget build(BuildContext context) {
    // final statusCount = _calculateVisitorStatus();
    final List<String> filterOptions = ['Option 1', 'Option 2', 'Option 3'];
    String? selectedValue;
    DateTime? startDate;
    DateTime? endDate;
    String? selectedGedung;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Visitor Report',
          style: TextStyle(
            fontSize: rfs(context, 20),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(rw(context, 20.0)),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(rw(context, 16)),
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

                  hSpace(context, 10),

                  if (selectedGedung != null)
                    _buildFilterValueChip(
                      selectedGedung!,
                      onClear: () => setState(() => selectedGedung = null),
                    ),

                  hSpace(context, 10),

                  if (startDate != null || endDate != null)
                    _buildFilterValueChip(
                      _formatDateRange(startDate, endDate),
                      onClear: () => setState(() {
                        startDate = null;
                        endDate = null;
                      }),
                    ),
                  Container(
                    height: rh(context, 38),
                    padding: EdgeInsets.symmetric(horizontal: rw(context, 16)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(rw(context, 50)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedValue,
                        hint: const Text('Export'),
                        icon: Icon(
                          FontAwesomeIcons.chevronDown,
                          size: rw(context, 16),
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
                              style: TextStyle(fontSize: rfs(context, 14)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),

              vSpace(context, 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Batasi lebar maksimum container
                  double maxWidth = constraints.maxWidth > rw(context, 800)
                      ? rw(context, 800)
                      : constraints.maxWidth;
                  double sideMargin = (constraints.maxWidth - maxWidth) / 2;

                  final spacing = rw(context, 16.0);
                  final itemWidth =
                      ((maxWidth - spacing * 2) / 3).clamp(1.0, double.infinity);

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: sideMargin),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildSquareStatCard(context, 'Total Visitor', '100', itemWidth),
                        buildSquareStatCard(context, 'New Visitor', '30', itemWidth),
                        buildSquareStatCard(context, 'Returning', '70', itemWidth),
                      ],
                    ),
                  );
                },
              ),

              vSpace(context, 20),
              SizedBox(height: rh(context, 300), child: VisitorLineChart()),
              vSpace(context, 20),

              VisitorTable(),
              vSpace(context, 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      height: rh(context, 38),
      padding: EdgeInsets.symmetric(horizontal: rw(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(rw(context, 50)),
      ),
      child: Row(
        children: [
          Text(label),
          hSpace(context, 8),
          Icon(FontAwesomeIcons.chevronDown, size: rw(context, 14)),
        ],
      ),
    );
  }

  Widget _buildFilterValueChip(String label, {required VoidCallback onClear}) {
    return Container(
      height: rh(context, 38),
      padding: EdgeInsets.symmetric(horizontal: rw(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(rw(context, 50)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: rfs(context, 12))),
          hSpace(context, 8),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close, size: rw(context, 16)),
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

