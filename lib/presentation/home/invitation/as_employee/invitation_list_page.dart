import 'package:flutter/material.dart';
import '../../../../presentation/home/invitation/as_employee/specify_purpose_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/components/custom_card.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../../../core/core.dart';
import '../../../history/widgets/filter_bottom_sheet.dart';

class InvitationListPage extends StatefulWidget {
  const InvitationListPage({super.key});

  @override
  State<InvitationListPage> createState() => _InvitationListPageState();
}

class _InvitationListPageState extends State<InvitationListPage> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedGedung;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Invitation List"),
        leading: const BackButton(),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(rh(context, 1.0)),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(SpecifyPurposePage());
        },
        backgroundColor: AppColors.primary500,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(rw(context, 20.0)),
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
              ],
            ),

            CustomCard(
              image: const Icon(Icons.check, color: Colors.white),
              size: rw(context, 26),
              title: 'Kunjungan',
              subtitle: 'Gedung HQ',
              additional: 'Mon, 14 Jul 2025',
              additionalDesc: '10:00 - 12:00',
              backgroundIconColor: AppColors.success500,
            ),
            CustomCard(
              image: const Icon(Icons.close, color: Colors.white),
              size: rw(context, 26),
              title: 'Kunjungan',
              subtitle: 'Gedung HQ',
              additional: 'Mon, 14 Jul 2025',
              additionalDesc: '10:00 - 12:00',
              backgroundIconColor: AppColors.error500,
            ),
          ],
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