import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/datasources/hive_service.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../../core/core.dart';

class FilterBottomSheet extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialSiteId;
  final String? initialStatus;
  final bool showStatusFilter;
  final bool showSiteFilter;
  final List<String>? customStatusList;
  final String? filterMode;

  const FilterBottomSheet({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.initialSiteId,
    this.initialStatus,
    this.showStatusFilter = false,
    this.showSiteFilter = true,
    this.customStatusList,
    this.filterMode,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedGedung;
  String? selectedStatus;
  late final List<String> statusList;
  final List<Map<String, String>> gedungList = [];
  bool isLoadingGedung = false;

  @override
  void initState() {
    super.initState();
    // Set initial values from widget
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    selectedGedung = widget.initialSiteId;
    selectedStatus = widget.initialStatus;
    statusList = widget.customStatusList ?? ['Praregis', 'Checkin', 'Checkout'];
    _fetchGedung();
  }

  Future<void> _fetchGedung() async {
    final localSites = HiveService().getSites();
    if (localSites.isNotEmpty) {
      setState(() {
        gedungList.clear();
        gedungList.addAll(localSites);
      });
      // Silent fetch in background to keep data updated and save to Hive silently
      _fetchGedungInBackground();
      return;
    }

    if (!mounted) return;
    setState(() => isLoadingGedung = true);
    await _fetchGedungFromApi();
  }

  Future<void> _fetchGedungFromApi() async {
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
          final newList = <Map<String, String>>[];
          for (var item in collection) {
            newList.add({
              'id': item['id']?.toString() ?? '',
              'name': item['name']?.toString() ?? '',
            });
          }
          await hive.saveSites(newList);
          setState(() {
            gedungList.clear();
            gedungList.addAll(newList);
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

  Future<void> _fetchGedungInBackground() async {
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
          final newList = <Map<String, String>>[];
          for (var item in collection) {
            newList.add({
              'id': item['id']?.toString() ?? '',
              'name': item['name']?.toString() ?? '',
            });
          }
          await hive.saveSites(newList);
          if (mounted) {
            setState(() {
              gedungList.clear();
              gedungList.addAll(newList);
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetchGedungInBackground: $e');
    }
  }

  void _showGedungSelection(BuildContext context) {
    // Filter the gedungList based on the filterMode
    final filteredGedungList = gedungList.where((item) {
      final name = item['name'] ?? '';
      final lowerName = name.toLowerCase().trim();
      final mode = widget.filterMode;
      
      if (mode == 'invitation') {
        return lowerName != 'drop point';
      } else if (mode == 'quick_access') {
        return lowerName == 'drop point';
      }
      return true;
    }).toList();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rw(context, 20)),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(rw(context, 20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Building',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: rfs(context, 18),
                ),
              ),
              vSpace(context, 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredGedungList.length,
                  itemBuilder: (context, index) {
                    final item = filteredGedungList[index];
                    final name = item['name'] ?? '';
                    
                    return ListTile(
                      title: Text(
                        name,
                        style: const TextStyle(color: Colors.black87),
                      ),
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

  void _showStatusSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rw(context, 20)),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(rw(context, 20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: rfs(context, 18),
                ),
              ),
              vSpace(context, 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: statusList.length,
                  itemBuilder: (context, index) {
                    final item = statusList[index];
                    return ListTile(
                      title: Text(item),
                      trailing: selectedStatus == item
                          ? const Icon(Icons.check, color: AppColors.primary500)
                          : null,
                      onTap: () {
                        setState(() => selectedStatus = item);
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
        padding: EdgeInsets.only(
          left: rw(context, 20),
          right: rw(context, 20),
          top: rw(context, 20),
          bottom: rw(context, 20) + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(rw(context, 20)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rfs(context, 18),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            vSpace(context, 20),

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
                        locale: const Locale('en', 'US'),
                      );
                      if (picked != null) {
                        setState(() => startDate = picked);
                      }
                    },
                    child: FilterDateBox(
                      title: "Start Date",
                      isRequired: endDate != null,
                      value: startDate != null
                          ? DateFormat(
                              'dd MMMM yyyy',
                              'en_US',
                            ).format(startDate!)
                          : "Select date",
                      isPlaceholder: startDate == null,
                    ),
                  ),
                ),
                hSpace(context, 16),
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
                          locale: const Locale('en', 'US'),
                        );
                        if (picked != null) {
                          setState(() => endDate = picked);
                        }
                      },
                      child: FilterDateBox(
                        title: "End Date",
                        isRequired: startDate != null,
                        value: endDate != null
                            ? DateFormat(
                                'dd MMMM yyyy',
                                'en_US',
                              ).format(endDate!)
                            : "Select date",
                        isPlaceholder: endDate == null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            vSpace(context, 16),

            // Searchable Dropdown Gedung
            if (widget.showSiteFilter) ...[
              isLoadingGedung
                  ? const Center(child: CircularProgressIndicator())
                  : GestureDetector(
                      onTap: () => _showGedungSelection(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Building", style: TextStyles.subtitle2),
                          vSpace(context, 6),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: rw(context, 12),
                              vertical: rh(context, 16),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffF2F8FD),
                              borderRadius: BorderRadius.circular(rw(context, 8)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                               Text(
                                   gedungList.firstWhereOrNull(
                                         (e) => e['id'] == selectedGedung,
                                       )?['name'] ??
                                       'Select Building',
                                  style: TextStyle(
                                    color: selectedGedung == null ||
                                            selectedGedung!.isEmpty
                                        ? Colors.grey
                                        : Colors.black,
                                    fontSize: rfs(context, 14),
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
            ],

            if (widget.showStatusFilter) ...[
              vSpace(context, 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Status", style: TextStyles.subtitle2),
                  vSpace(context, 6),
                  GestureDetector(
                    onTap: () => _showStatusSelection(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 12),
                        vertical: rh(context, 16),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffF2F8FD),
                        borderRadius: BorderRadius.circular(rw(context, 8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedStatus?.isNotEmpty == true
                                ? selectedStatus!
                                : 'Select Status',
                            style: TextStyle(
                              color:
                                  selectedStatus == null ||
                                      selectedStatus!.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: rfs(context, 14),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],

            vSpace(context, 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  padding: EdgeInsets.symmetric(vertical: rh(context, 14)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(rw(context, 8)),
                  ),
                ),
                onPressed: () {
                  if (startDate != null && endDate == null) {
                    Get.snackbar(
                      'Validation Error',
                      'Please select "End Date"',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                      margin: EdgeInsets.all(rw(context, 10)),
                    );
                    return;
                  }
                  if (startDate == null && endDate != null) {
                    Get.snackbar(
                      'Validation Error',
                      'Please select "Start Date"',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                      margin: EdgeInsets.all(rw(context, 10)),
                    );
                    return;
                  }

                  final selectedSite = gedungList.firstWhereOrNull(
                    (e) => e['id'] == selectedGedung,
                  );
                  Navigator.pop(context, {
                    'startDate': startDate,
                    'endDate': endDate,
                    'siteId': selectedGedung,
                    'siteName': selectedSite?['name'],
                    'status': selectedStatus,
                  });
                },
                child: const Text(
                  'Apply filter',
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
  final bool isRequired;
  final bool isPlaceholder;

  const FilterDateBox({
    super.key,
    required this.title,
    required this.value,
    this.isRequired = false,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyles.subtitle2,
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: rfs(context, 14),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        vSpace(context, 6),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: rw(context, 12),
            vertical: rh(context, 14),
          ),
          decoration: BoxDecoration(
            color: const Color(0xffF2F8FD),
            borderRadius: BorderRadius.circular(rw(context, 8)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: rfs(context, 14),
              color: isPlaceholder ? Colors.grey : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
