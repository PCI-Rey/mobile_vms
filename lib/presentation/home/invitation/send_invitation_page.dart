import 'package:flutter/material.dart';
import '../../../../presentation/home/invitation/add_invitation_page.dart';
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
        title: const Text("Send Invitation"),
        leading: BackButton(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AddInvitationPage());
        },
        backgroundColor: AppColors.primary500,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
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

            CustomCard(
              image: Icon(Icons.check, color: Colors.white),
              size: 26,
              title: 'Kunjungan',
              subtitle: 'Gedung HQ',
              additional: 'Mon, 14 Jul 2025',
              additionalDesc: '10:00 - 12:00',
              backgroundIconColor: AppColors.success500,
            ),
            CustomCard(
              image: Icon(Icons.close, color: Colors.white),
              size: 26,
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
