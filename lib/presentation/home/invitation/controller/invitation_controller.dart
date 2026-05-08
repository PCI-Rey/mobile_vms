import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/datasources/hive_service.dart';
import '../../../../data/models/access_pass_model.dart';

class InvitationController extends GetxController {
  final ApiService _api = ApiService();
  final HiveService _hive = HiveService();

  final RxList<AccessPassModel> allInvitations = <AccessPassModel>[].obs;
  final RxList<AccessPassModel> ongoingInvitations = <AccessPassModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isNewestFirst = true.obs; // Default: Terbaru di atas

  // Filter states
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxString selectedSiteId = ''.obs;
  final RxString selectedSiteName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOngoingInvitations();
  }

  void setFilters({
    DateTime? start,
    DateTime? end,
    String? siteId,
    String? siteName,
  }) {
    startDate.value = start;
    endDate.value = end;
    selectedSiteId.value = siteId ?? '';
    selectedSiteName.value = siteName ?? '';
    
    // Fetch data from server based on date range
    fetchOngoingInvitations(start: start, end: end);
  }

  void toggleSort() {
    isNewestFirst.value = !isNewestFirst.value;
    _applyFilters();
  }

  void _applyFilters() {
    List<AccessPassModel> filtered = List.from(allInvitations);

    // 1. Filter Berdasarkan Tanggal (Lokal)
    if (startDate.value != null) {
      filtered = filtered.where((item) {
        final itemDate = item.visitorPeriodStart;
        final start = DateTime(
          startDate.value!.year,
          startDate.value!.month,
          startDate.value!.day,
        );
        final date = DateTime(itemDate.year, itemDate.month, itemDate.day);
        return date.isAtSameMomentAs(start) || date.isAfter(start);
      }).toList();
    }

    if (endDate.value != null) {
      filtered = filtered.where((item) {
        final itemDate = item.visitorPeriodStart;
        final end = DateTime(
          endDate.value!.year,
          endDate.value!.month,
          endDate.value!.day,
        );
        final date = DateTime(itemDate.year, itemDate.month, itemDate.day);
        return date.isAtSameMomentAs(end) || date.isBefore(end);
      }).toList();
    }

    // 2. Filter Berdasarkan Gedung (Lokal)
    if (selectedSiteId.value.isNotEmpty || selectedSiteName.value.isNotEmpty) {
      filtered = filtered.where((item) {
        // Cek ID cocok ATAU Nama Gedung cocok
        return (selectedSiteId.value.isNotEmpty &&
                item.siteId == selectedSiteId.value) ||
            (selectedSiteName.value.isNotEmpty &&
                item.sitePlaceName == selectedSiteName.value);
      }).toList();
    }

    // 3. Sorting
    if (isNewestFirst.value) {
      filtered.sort(
        (a, b) => b.visitorPeriodStart.compareTo(a.visitorPeriodStart),
      );
    } else {
      filtered.sort(
        (a, b) => a.visitorPeriodStart.compareTo(b.visitorPeriodStart),
      );
    }

    ongoingInvitations.assignAll(filtered);
  }

  Future<void> fetchOngoingInvitations({
    bool isSilent = false,
    DateTime? start,
    DateTime? end,
  }) async {
    final user = _hive.getUser();
    final token = user?.token;

    if (token == null) return;

    if (!isSilent) isLoading.value = true;
    try {
      String? startStr;
      String? endStr;
      if (start != null) {
        startStr = DateFormat('yyyy-MM-dd').format(start);
      }
      if (end != null) {
        endStr = DateFormat('yyyy-MM-dd').format(end);
      }

      final response = await _api.getOngoingInvitation(
        token,
        startDate: startStr,
        endDate: endStr,
      );
      if (response.data['status'] == 'success') {
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        final newPasses = collection
            .map((e) => AccessPassModel.fromJson(e as Map<String, dynamic>))
            .toList();

        allInvitations.assignAll(newPasses);
        _applyFilters();
      }
    } catch (e) {
      debugPrint('fetchOngoingInvitations error: $e');
    } finally {
      if (!isSilent) isLoading.value = false;
    }
  }
  // ─── Share Link Data Masters ──────────────────────────────────────────

  final RxList<Map<String, dynamic>> hosts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> sites = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> visitorTypes =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingMasters = false.obs;

  Future<void> fetchMasterData() async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return;

    isLoadingMasters.value = true;
    try {
      await Future.wait([
        _fetchHosts(token),
        _fetchSites(token),
        _fetchVisitorTypes(token),
      ]);
    } finally {
      isLoadingMasters.value = false;
    }
  }

  Future<void> _fetchHosts(String token) async {
    try {
      final response = await _api.getHosts(token);
      if (response.data['status'] == 'success') {
        hosts.assignAll(
          List<Map<String, dynamic>>.from(response.data['collection']),
        );
      }
    } catch (e) {
      debugPrint('fetchHosts error: $e');
    }
  }

  Future<void> _fetchSites(String token) async {
    try {
      final response = await _api.getSitesWithToken(token);
      if (response.data['status'] == 'success') {
        sites.assignAll(
          List<Map<String, dynamic>>.from(response.data['collection']),
        );
      }
    } catch (e) {
      debugPrint('fetchSites error: $e');
    }
  }

  Future<void> _fetchVisitorTypes(String token) async {
    try {
      final response = await _api.getVisitorTypes(token);
      if (response.data['status'] == 'success') {
        visitorTypes.assignAll(
          List<Map<String, dynamic>>.from(response.data['collection']),
        );
      }
    } catch (e) {
      debugPrint('fetchVisitorTypes error: $e');
    }
  }

  // ─── Share Link Logic ───────────────────────────────────────────────────

  final RxList<dynamic> shareLinks = <dynamic>[].obs;
  final RxBool isShareLinkLoading = false.obs;

  // Pagination States
  final RxInt shareLinkCurrentPage = 0.obs;
  final RxInt shareLinkPageSize = 10.obs;
  final RxInt shareLinkTotalRecords = 0.obs;

  Future<void> fetchShareLinks({bool resetPage = false}) async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return;

    if (resetPage) shareLinkCurrentPage.value = 0;

    isShareLinkLoading.value = true;
    try {
      final start = shareLinkCurrentPage.value * shareLinkPageSize.value;
      final response = await _api.getShareLinkDt(
        token,
        start: start,
        length: shareLinkPageSize.value,
      );

      if (response.data['status'] == 'success' ||
          response.data['status_code'] == 200) {
        shareLinks.assignAll(
          response.data['collection'] as List<dynamic>? ?? [],
        );
        // Gunakan RecordsFiltered untuk pagination karena ini jumlah data yang benar-benar tersedia
        shareLinkTotalRecords.value =
            response.data['RecordsFiltered'] ??
            response.data['RecordsTotal'] ??
            0;
      }
    } catch (e) {
      debugPrint('fetchShareLinks error: $e');
    } finally {
      isShareLinkLoading.value = false;
    }
  }

  void nextShareLinkPage() {
    if ((shareLinkCurrentPage.value + 1) * shareLinkPageSize.value <
        shareLinkTotalRecords.value) {
      shareLinkCurrentPage.value++;
      fetchShareLinks();
    }
  }

  void prevShareLinkPage() {
    if (shareLinkCurrentPage.value > 0) {
      shareLinkCurrentPage.value--;
      fetchShareLinks();
    }
  }

  Future<bool> createShareLinkAction(
    Map<String, dynamic> body, {
    bool sendEmail = false,
  }) async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return false;

    try {
      final response = sendEmail
          ? await _api.createShareLinkAndEmail(token, body)
          : await _api.createShareLink(token, body);

      if (response.data['status'] == 'success' ||
          response.data['status_code'] == 200) {
        fetchShareLinks(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('createShareLinkAction error: $e');
      return false;
    }
  }

  Future<bool> deleteShareLinkAction(String id) async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return false;

    try {
      final response = await _api.deleteShareLink(token, id);
      if (response.data['status'] == 'success' ||
          response.data['status_code'] == 200) {
        fetchShareLinks(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('deleteShareLinkAction error: $e');
      return false;
    }
  }
}
