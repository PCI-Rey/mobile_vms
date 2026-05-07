import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/datasources/hive_service.dart';
import '../../../core/core.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedGedung;
  final List<Map<String, String>> gedungList = [];
  bool isLoadingGedung = false;

  @override
  void initState() {
    super.initState();
    _fetchGedung();
  }

  Future<void> _fetchGedung() async {
    if (!mounted) return;
    setState(() => isLoadingGedung = true);
    try {
      final hive = HiveService();
      final token = hive.getUser()?.token;
      if (token != null) {
        final api = ApiService();
        final response = await api.getSitesWithToken(token);
        if (!mounted) return;
        if (response.data['status'] == 'success') {
          final collection =
              response.data['collection'] as List<dynamic>? ?? [];
          setState(() {
            gedungList.clear();
            for (var item in collection) {
              gedungList.add({
                'id': item['id']?.toString() ?? '',
                'name': item['name']?.toString() ?? '',
              });
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetchGedung: $e');
    } finally {
      if (mounted) {
        setState(() => isLoadingGedung = false);
      }
    }
  }

  void _showGedungSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Gedung',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: gedungList.length,
                  itemBuilder: (context, index) {
                    final item = gedungList[index];
                    return ListTile(
                      title: Text(item['name'] ?? ''),
                      trailing: selectedGedung == item['id']
                          ? const Icon(Icons.check, color: AppColors.primary500)
                          : null,
                      onTap: () {
                        setState(() => selectedGedung = item['id']);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Padding bottom sesuai dengan keyboard height
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Rentang Tanggal
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        locale: const Locale('id', 'ID'),
                      );
                      if (picked != null) {
                        setState(() => startDate = picked);
                      }
                    },
                    child: FilterDateBox(
                      title: "Dari Tanggal",
                      value: startDate != null
                          ? DateFormat(
                              'dd MMM yyyy',
                              'id_ID',
                            ).format(startDate!)
                          : "Pilih tanggal",
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          locale: const Locale('id', 'ID'),
                        );
                        if (picked != null) {
                          setState(() => endDate = picked);
                        }
                      },
                      child: FilterDateBox(
                        title: "Sampai Tanggal",
                        value: endDate != null
                            ? DateFormat(
                                'dd MMM yyyy',
                                'id_ID',
                              ).format(endDate!)
                            : "Pilih tanggal",
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Searchable Dropdown Gedung
            isLoadingGedung
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
                    onTap: () => _showGedungSelection(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Gedung", style: TextStyles.subtitle2),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffF2F8FD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                gedungList.firstWhereOrNull(
                                      (e) => e['id'] == selectedGedung,
                                    )?['name'] ??
                                    'Pilih Gedung',
                                style: TextStyle(
                                  color: selectedGedung == null
                                      ? Colors.grey
                                      : Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  final selectedSite = gedungList.firstWhereOrNull(
                    (e) => e['id'] == selectedGedung,
                  );
                  Navigator.pop(context, {
                    'startDate': startDate,
                    'endDate': endDate,
                    'siteId': selectedGedung,
                    'siteName': selectedSite?['name'],
                  });
                },
                child: const Text(
                  'Pasang filter',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterDateBox extends StatelessWidget {
  final String title;
  final String value;

  const FilterDateBox({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xffF2F8FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
