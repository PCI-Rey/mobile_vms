import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/datasources/hive_service.dart';
import '../../../../data/models/access_pass_model.dart';
import '../../../../data/models/approval_ticket_model.dart';

class InvitationController extends GetxController {
  final ApiService _api = ApiService();
  final HiveService _hive = HiveService();

  final RxList<AccessPassModel> allInvitations = <AccessPassModel>[].obs;
  final RxList<AccessPassModel> allRawVisitors = <AccessPassModel>[].obs;
  final RxList<AccessPassModel> ongoingInvitations = <AccessPassModel>[].obs;
  final RxList<AccessPassModel> quickAccessInvitations =
      <AccessPassModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isNewestFirst = true.obs; // Default: Terbaru di atas

  // Approval Ticket States
  final RxList<ApprovalTicketModel> approvalTickets =
      <ApprovalTicketModel>[].obs;
  final RxBool isApprovalLoading = false.obs;
  bool hasShownPendingPopup = false;
  Timer? _reminderTimer;
  Timer? _countdownTimer;
  final RxInt reminderCountdown = 0.obs;
  final RxSet<String> postponedTicketIds = <String>{}.obs;
  final RxMap<String, String> ticketVisitorNames = <String, String>{}.obs;
  final Set<String> _resolvedTickets = {};
  final Set<String> _pendingFetches = {};

  // Cache for fetchAllVisitors result to avoid repeated API calls
  List<AccessPassModel>? _cachedAllVisitors;
  Future<List<AccessPassModel>>? _allVisitorsFuture;

  /// Read-only access to the cache (null if not yet fetched).
  List<AccessPassModel>? get cachedAllVisitors => _cachedAllVisitors;

  void startReminderTimer(
    int minutes,
    String ticketId,
    VoidCallback onTrigger,
  ) {
    postponedTicketIds.add(ticketId);

    if (_reminderTimer == null) {
      reminderCountdown.value = minutes * 60;
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (reminderCountdown.value > 0) {
          reminderCountdown.value--;
        } else {
          timer.cancel();
        }
      });

      _reminderTimer = Timer(Duration(minutes: minutes), () {
        hasShownPendingPopup = false;
        reminderCountdown.value = 0;
        _countdownTimer?.cancel();
        _countdownTimer = null;
        _reminderTimer = null;
        onTrigger();
      });
    }
  }

  void cancelReminderTimer() {
    _reminderTimer?.cancel();
    _reminderTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    reminderCountdown.value = 0;
    postponedTicketIds.clear();
  }

  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final Rx<DateTime> selectedDashboardDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).obs;
  final RxString selectedSiteId = ''.obs;
  final RxString selectedSiteName = ''.obs;
  final RxString selectedStatus = ''.obs;

  // Share Link Tab filters
  final Rx<DateTime?> startDateShare = Rx<DateTime?>(null);
  final Rx<DateTime?> endDateShare = Rx<DateTime?>(null);
  final RxString selectedSiteIdShare = ''.obs;
  final RxString selectedSiteNameShare = ''.obs;
  final RxString selectedStatusShare = ''.obs;

  // Quick Access Tab filters
  final Rx<DateTime?> startDateQuick = Rx<DateTime?>(null);
  final Rx<DateTime?> endDateQuick = Rx<DateTime?>(null);
  final RxString selectedSiteIdQuick = ''.obs;
  final RxString selectedSiteNameQuick = ''.obs;
  final RxString selectedStatusQuick = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOngoingInvitations();
    fetchApprovalTickets();
    fetchMasterData();
  }

  @override
  void onClose() {
    _reminderTimer?.cancel();
    super.onClose();
  }

  void setFilters({
    DateTime? start,
    DateTime? end,
    String? siteId,
    String? siteName,
    String? status,
  }) {
    startDate.value = start;
    endDate.value = end;
    selectedSiteId.value = siteId ?? '';
    selectedSiteName.value = siteName ?? '';
    selectedStatus.value = status ?? '';
    _applyFilters();
  }

  void setQuickFilters({
    DateTime? start,
    DateTime? end,
    String? siteId,
    String? siteName,
    String? status,
  }) {
    startDateQuick.value = start;
    endDateQuick.value = end;
    selectedSiteIdQuick.value = siteId ?? '';
    selectedSiteNameQuick.value = siteName ?? '';
    selectedStatusQuick.value = status ?? '';
    _applyFilters();
  }

  void setShareFilters({
    DateTime? start,
    DateTime? end,
    String? siteId,
    String? siteName,
    String? status,
  }) {
    startDateShare.value = start;
    endDateShare.value = end;
    selectedSiteIdShare.value = siteId ?? '';
    selectedSiteNameShare.value = siteName ?? '';
    selectedStatusShare.value = status ?? '';
    _applyShareFilters();
  }

  void toggleSort() {
    isNewestFirst.value = !isNewestFirst.value;
    _applyFilters();
  }

  void _applyFilters() {
    // Split based on `flow` field from new /visitor/transaction/dt API:
    // flow == 'QuickAccessVisit' → Quick Access tab
    // everything else (Invitation, Praregister, etc.) → Invitation tab
    List<AccessPassModel> filtered = List.from(
      allInvitations.where(
        (item) => item.flow.toLowerCase() != 'quickaccessvisit' &&
                  !(item.agenda.isEmpty && item.hostName.isEmpty && item.visitorTypeName.isEmpty),
      ),
    );
    List<AccessPassModel> quickAccess = List.from(
      allInvitations.where(
        (item) => item.flow.toLowerCase() == 'quickaccessvisit' &&
                  !(item.agenda.isEmpty && item.hostName.isEmpty && item.visitorTypeName.isEmpty),
      ),
    );

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
        return (selectedSiteId.value.isNotEmpty &&
                item.siteId.toLowerCase() ==
                    selectedSiteId.value.toLowerCase()) ||
            (selectedSiteName.value.isNotEmpty &&
                item.sitePlaceName.toLowerCase() ==
                    selectedSiteName.value.toLowerCase());
      }).toList();
    }

    // Filter Berdasarkan Status (Lokal)
    if (selectedStatus.value.isNotEmpty) {
      filtered = filtered
          .where(
            (item) =>
                item.visitorStatus.toLowerCase() ==
                selectedStatus.value.toLowerCase(),
          )
          .toList();
    }

    // ─── Filter Quick Access (Lokal) ───
    if (startDateQuick.value != null) {
      quickAccess = quickAccess.where((item) {
        final itemDate = item.visitorPeriodStart;
        final start = DateTime(
          startDateQuick.value!.year,
          startDateQuick.value!.month,
          startDateQuick.value!.day,
        );
        final date = DateTime(itemDate.year, itemDate.month, itemDate.day);
        return date.isAtSameMomentAs(start) || date.isAfter(start);
      }).toList();
    }

    if (endDateQuick.value != null) {
      quickAccess = quickAccess.where((item) {
        final itemDate = item.visitorPeriodStart;
        final end = DateTime(
          endDateQuick.value!.year,
          endDateQuick.value!.month,
          endDateQuick.value!.day,
        );
        final date = DateTime(itemDate.year, itemDate.month, itemDate.day);
        return date.isAtSameMomentAs(end) || date.isBefore(end);
      }).toList();
    }

    if (selectedSiteIdQuick.value.isNotEmpty || selectedSiteNameQuick.value.isNotEmpty) {
      quickAccess = quickAccess.where((item) {
        return (selectedSiteIdQuick.value.isNotEmpty &&
                item.siteId.toLowerCase() ==
                    selectedSiteIdQuick.value.toLowerCase()) ||
            (selectedSiteNameQuick.value.isNotEmpty &&
                item.sitePlaceName.toLowerCase() ==
                    selectedSiteNameQuick.value.toLowerCase());
      }).toList();
    }

    if (selectedStatusQuick.value.isNotEmpty) {
      quickAccess = quickAccess.where((item) {
        final isExpired = DateTime.now().isAfter(item.visitorPeriodEnd);
        final uiStatus = isExpired ? 'Expired' : 'Active';
        return uiStatus.toLowerCase() == selectedStatusQuick.value.toLowerCase();
      }).toList();
    }

    // 3. Sorting
    final now = DateTime.now();
    int compareAccessPass(AccessPassModel a, AccessPassModel b) {
      final aExpired = now.isAfter(a.visitorPeriodEnd);
      final bExpired = now.isAfter(b.visitorPeriodEnd);
      if (aExpired != bExpired) {
        return aExpired ? 1 : -1;
      }
      return isNewestFirst.value
          ? b.visitorPeriodStart.compareTo(a.visitorPeriodStart)
          : a.visitorPeriodStart.compareTo(b.visitorPeriodStart);
    }

    filtered.sort(compareAccessPass);
    quickAccess.sort(compareAccessPass);

    ongoingInvitations.assignAll(filtered);
    quickAccessInvitations.assignAll(quickAccess);
  }

  Future<void> fetchOngoingInvitations({
    bool isSilent = false,
    bool clearFilters = false,
  }) async {
    if (clearFilters) {
      startDate.value = null;
      endDate.value = null;
      selectedSiteId.value = '';
      selectedSiteName.value = '';
      selectedStatus.value = '';

      startDateQuick.value = null;
      endDateQuick.value = null;
      selectedSiteIdQuick.value = '';
      selectedSiteNameQuick.value = '';
      selectedStatusQuick.value = '';
    }
    final user = _hive.getUser();
    final token = user?.token;

    if (token == null) return;

    if (!isSilent) isLoading.value = true;
    try {
      final response = await _api.getVisitorDt(
        token,
        draw: 1,
        start: 0,
        length: 500,
        search: '',
      );
      if (response.data['status'] == 'success' ||
          response.data['status_code'] == 200) {
        final collection = response.data['collection'] as List<dynamic>? ?? [];

        final List<AccessPassModel> allVisitors = collection.map((trx) {
          return AccessPassModel.fromJson(trx as Map<String, dynamic>);
        }).toList();

        allRawVisitors.assignAll(allVisitors);

        allInvitations.assignAll(allVisitors);
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
  final RxList<Map<String, dynamic>> visitorProviders =
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
        _fetchVisitorProviders(token),
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
      final response = await _api.getDropPoints(token);
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

  Future<void> _fetchVisitorProviders(String token) async {
    try {
      final response = await _api.getVisitorProviders(token);
      if (response.data['status'] == 'success' ||
          response.data['status_code'] == 200) {
        visitorProviders.assignAll(
          List<Map<String, dynamic>>.from(response.data['collection']),
        );
      }
    } catch (e) {
      debugPrint('fetchVisitorProviders error: $e');
    }
  }

  // ─── Share Link Logic ───────────────────────────────────────────────────

  final RxList<dynamic> shareLinks = <dynamic>[].obs;
  final RxList<dynamic> dashboardShareLinks = <dynamic>[].obs;
  final RxBool isShareLinkLoading = false.obs;

  Future<void> fetchDashboardShareLinks() async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return;

    try {
      final response = await _api.getShareLinkDt(
        token,
        start: 0,
        length: 500,
        sortColumn: 'created_at',
        sortDir: 'desc',
      );
      if (response.data['status'] == 'success' ||
          response.data['status_code'] == 200) {
        dashboardShareLinks.assignAll(
          response.data['collection'] as List<dynamic>? ?? [],
        );
      } else if (response.data['status'] == 'not_found' ||
          response.data['status_code'] == 404) {
        dashboardShareLinks.clear();
      }
    } catch (e) {
      debugPrint('fetchDashboardShareLinks error: $e');
    }
  }

  // Pagination States
  final RxInt shareLinkCurrentPage = 0.obs;
  final RxInt shareLinkPageSize = 10.obs;
  final RxInt shareLinkTotalRecords = 0.obs;
  final RxList<dynamic> allShareLinks = <dynamic>[].obs;

  Future<void> fetchShareLinks({bool resetPage = false, bool clearFilters = false}) async {
    if (clearFilters) {
      startDateShare.value = null;
      endDateShare.value = null;
      selectedSiteIdShare.value = '';
      selectedSiteNameShare.value = '';
      selectedStatusShare.value = '';
    }
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return;

    if (resetPage) shareLinkCurrentPage.value = 0;

    isShareLinkLoading.value = true;
    try {
      final response = await _api.getShareLinkDt(
        token,
        start: 0,
        length: 500, // Fetch a large number of items so we can filter and paginate locally
        sortColumn: 'created_at',
        sortDir: 'desc',
      );

      if (response.data['status'] == 'success' ||
          response.data['status_code'] == 200) {
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        allShareLinks.assignAll(collection);
        _applyShareFilters();
      } else if (response.data['status'] == 'not_found' ||
          response.data['status_code'] == 404) {
        allShareLinks.clear();
        _applyShareFilters();
      }
    } catch (e) {
      debugPrint('fetchShareLinks error: $e');
    } finally {
      isShareLinkLoading.value = false;
    }
  }

  void _applyShareFilters() {
    List<dynamic> filtered = List.from(allShareLinks);

    // 1. Filter Berdasarkan Tanggal (Lokal)
    if (startDateShare.value != null) {
      filtered = filtered.where((item) {
        final dateStr = item['visitor_period_start'];
        if (dateStr == null) return false;
        try {
          String normalized = dateStr.toString();
          if (!normalized.endsWith('Z') && !normalized.contains('+')) {
            normalized = '${normalized.replaceFirst(' ', 'T')}Z';
          }
          final itemDate = DateTime.parse(normalized).toLocal();
          final start = DateTime(
            startDateShare.value!.year,
            startDateShare.value!.month,
            startDateShare.value!.day,
          );
          final date = DateTime(itemDate.year, itemDate.month, itemDate.day);
          return date.isAtSameMomentAs(start) || date.isAfter(start);
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (endDateShare.value != null) {
      filtered = filtered.where((item) {
        final dateStr = item['visitor_period_start'];
        if (dateStr == null) return false;
        try {
          String normalized = dateStr.toString();
          if (!normalized.endsWith('Z') && !normalized.contains('+')) {
            normalized = '${normalized.replaceFirst(' ', 'T')}Z';
          }
          final itemDate = DateTime.parse(normalized).toLocal();
          final end = DateTime(
            endDateShare.value!.year,
            endDateShare.value!.month,
            endDateShare.value!.day,
          );
          final date = DateTime(itemDate.year, itemDate.month, itemDate.day);
          return date.isAtSameMomentAs(end) || date.isBefore(end);
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // 2. Filter Berdasarkan Gedung (Lokal)
    if (selectedSiteIdShare.value.isNotEmpty || selectedSiteNameShare.value.isNotEmpty) {
      filtered = filtered.where((item) {
        final itemSiteId = item['site_id']?.toString() ?? '';
        final itemSiteName = item['site_place_name']?.toString() ?? '';
        return (selectedSiteIdShare.value.isNotEmpty &&
                itemSiteId.toLowerCase() ==
                    selectedSiteIdShare.value.toLowerCase()) ||
            (selectedSiteNameShare.value.isNotEmpty &&
                itemSiteName.toLowerCase() ==
                    selectedSiteNameShare.value.toLowerCase());
      }).toList();
    }

    // 3. Filter Berdasarkan Status (Lokal - Active / Expired)
    if (selectedStatusShare.value.isNotEmpty) {
      filtered = filtered.where((item) {
        final expiredAtStr = item['expired_at'];
        DateTime? expiredAt;
        if (expiredAtStr != null) {
          String normalized = expiredAtStr.toString();
          if (!normalized.endsWith('Z') && !normalized.contains('+')) {
            normalized = '${normalized.replaceFirst(' ', 'T')}Z';
          }
          expiredAt = DateTime.tryParse(normalized)?.toLocal();
        }

        final int maxUsage = item['max_usage'] ?? 0;
        final int currentUsage = item['current_usage'] ?? 0;
        final bool isSingleUse = item['is_single_use'] == true;

        bool isExpired = false;
        if (expiredAt != null && expiredAt.isBefore(DateTime.now())) {
          isExpired = true;
        }
        if ((maxUsage > 0 && currentUsage >= maxUsage) || (isSingleUse && currentUsage >= 1)) {
          isExpired = true;
        }

        final String computedStatus = isExpired ? 'Expired' : 'Active';
        return computedStatus.toLowerCase() == selectedStatusShare.value.toLowerCase();
      }).toList();
    }

    // Sort: Active first, then by visitor_period_start / created_at / expired_at descending
    filtered.sort((a, b) {
      final aMap = Map<String, dynamic>.from(a as Map);
      final bMap = Map<String, dynamic>.from(b as Map);
      
      bool isExpiredLink(Map<String, dynamic> item) {
        final expiredAtStr = item['expired_at'];
        DateTime? expiredAt;
        if (expiredAtStr != null) {
          String normalized = expiredAtStr.toString();
          if (!normalized.endsWith('Z') && !normalized.contains('+')) {
            normalized = '${normalized.replaceFirst(' ', 'T')}Z';
          }
          expiredAt = DateTime.tryParse(normalized)?.toLocal();
        }
        final int maxUsage = item['max_usage'] ?? 0;
        final int currentUsage = item['current_usage'] ?? 0;
        final bool isSingleUse = item['is_single_use'] == true;
        if (expiredAt != null && expiredAt.isBefore(DateTime.now())) return true;
        if ((maxUsage > 0 && currentUsage >= maxUsage) || (isSingleUse && currentUsage >= 1)) return true;
        return false;
      }

      final aExpired = isExpiredLink(aMap);
      final bExpired = isExpiredLink(bMap);
      if (aExpired != bExpired) {
        return aExpired ? 1 : -1;
      }

      final dateStrA = aMap['visitor_period_start']?.toString() ??
          aMap['created_at']?.toString() ??
          aMap['expired_at']?.toString();
      final dateStrB = bMap['visitor_period_start']?.toString() ??
          bMap['created_at']?.toString() ??
          bMap['expired_at']?.toString();
      if (dateStrA == null && dateStrB == null) return 0;
      if (dateStrA == null) return 1;
      if (dateStrB == null) return -1;
      return dateStrB.compareTo(dateStrA);
    });

    // 4. Paginate
    shareLinkTotalRecords.value = filtered.length;
    final start = shareLinkCurrentPage.value * shareLinkPageSize.value;
    
    // Safety check start index
    int safeStart = start;
    if (safeStart >= filtered.length) {
      safeStart = 0;
      shareLinkCurrentPage.value = 0;
    }
    
    final pagedList = filtered.skip(safeStart).take(shareLinkPageSize.value).toList();
    shareLinks.assignAll(pagedList);
  }

  void nextShareLinkPage() {
    if ((shareLinkCurrentPage.value + 1) * shareLinkPageSize.value <
        shareLinkTotalRecords.value) {
      shareLinkCurrentPage.value++;
      _applyShareFilters();
    }
  }

  void prevShareLinkPage() {
    if (shareLinkCurrentPage.value > 0) {
      shareLinkCurrentPage.value--;
      _applyShareFilters();
    }
  }

  Future<Map<String, dynamic>?> createShareLinkAction(
    Map<String, dynamic> body, {
    bool sendEmail = false,
  }) async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return null;

    try {
      final response = sendEmail
          ? await _api.createShareLinkAndEmail(token, body)
          : await _api.createShareLink(token, body);

      if (response.data['status'] == 'success' ||
          response.data['status_code'] == 200) {
        await fetchShareLinks(resetPage: true); // Refresh list
        fetchDashboardShareLinks(); // Refresh dashboard list

        // Return the created item if available in response
        Map<String, dynamic>? createdItem;
        if (response.data['item'] != null) {
          createdItem = Map<String, dynamic>.from(response.data['item']);
        } else if (shareLinks.isNotEmpty) {
          createdItem = shareLinks.first;
        }

        // FCM notifications (create + expiry warning) dikirim oleh backend
        return createdItem ?? {}; // Success but no item data
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response != null) {
        debugPrint('createShareLinkAction error response: ${e.response?.data}');
        throw e.response?.data['message'] ??
            e.response?.data.toString() ??
            'Failed to create share link';
      }
      debugPrint('createShareLinkAction error: $e');
      throw 'Failed to create share link';
    }
  }

  Future<bool> sendEmailForExistingShareLinkAction(
    String id,
    List<String> emails,
  ) async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return false;

    try {
      final response = await _api.sendEmailForExistingShareLink(token, id, {
        'emails': emails,
      });
      if (response.data['status'] == 'success' ||
          response.data['status_code'] == 200) {
        return true;
      }
      return false;
    } catch (e) {
      if (e is DioException && e.response != null) {
        debugPrint(
          'sendEmailForExistingShareLinkAction error response: ${e.response?.data}',
        );
        throw e.response?.data['message'] ??
            e.response?.data.toString() ??
            'Failed to send email';
      }
      debugPrint('sendEmailForExistingShareLinkAction error: $e');
      throw 'Failed to send email';
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
        // Remove locally from lists immediately to ensure UI is updated instantly
        shareLinks.removeWhere((item) => item['id']?.toString() == id);
        dashboardShareLinks.removeWhere((item) => item['id']?.toString() == id);

        // Refetch after a small delay to ensure backend has completed the transaction
        Future.delayed(const Duration(milliseconds: 500), () {
          fetchShareLinks(resetPage: true);
          fetchDashboardShareLinks();
        });

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('deleteShareLinkAction error: $e');
      return false;
    }
  }

  Future<bool> createQuickAccessAction(Map<String, dynamic> body) async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return false;

    debugPrint('createQuickAccessAction payload: ${jsonEncode(body)}');

    try {
      final response = await _api.createQuickAccessVisit(token, body);
      debugPrint('createQuickAccessAction status code: ${response.statusCode}');
      debugPrint('createQuickAccessAction response data: ${response.data}');

      if (response.data is Map &&
          (response.data['status'] == 'success' ||
              response.data['status_code'] == 200)) {
        await fetchOngoingInvitations(clearFilters: true);
        return true;
      }

      // If not successful, check if response has an error message
      if (response.data is Map) {
        throw response.data['message'] ??
            response.data['msg'] ??
            'Failed to create quick access visit: ${response.data}';
      } else {
        throw 'Failed to create quick access visit: Status ${response.statusCode}';
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        debugPrint(
          'createQuickAccessAction error response: ${e.response?.data}',
        );
        throw e.response?.data['message'] ??
            e.response?.data['msg'] ??
            e.response?.data.toString() ??
            'Failed to create quick access visit';
      }
      debugPrint('createQuickAccessAction error: $e');
      if (e is String) rethrow;
      throw e.toString();
    }
  }

  // ─── Approval Ticket Action ──────────────────────────────────────────

  void fetchVisitorNameForTicket(ApprovalTicketModel ticket) {
    final entityId = ticket.entityId;
    final ticketId = ticket.approvalTicketId ?? ticket.ticketId;
    if (entityId == null || ticketId == null) return;
    if (_resolvedTickets.contains(ticketId)) return;
    if (_pendingFetches.contains(ticketId)) return;

    // Use placeholder first if not already set
    if (!ticketVisitorNames.containsKey(ticketId)) {
      ticketVisitorNames[ticketId] = ticket.hostName ?? 'Visitor';
    }

    _pendingFetches.add(ticketId);

    fetchTransactionVisitors(entityId)
        .then((visitors) {
          _pendingFetches.remove(ticketId);
          if (visitors.isNotEmpty) {
            final name =
                visitors.first['visitor_name']?.toString() ??
                visitors.first['name']?.toString() ??
                'Visitor';
            ticketVisitorNames[ticketId] = name;
            _resolvedTickets.add(ticketId);
          }
        })
        .catchError((e) {
          _pendingFetches.remove(ticketId);
          debugPrint('Error fetching visitor name for $ticketId: $e');
        });
  }

  Future<void> fetchApprovalTickets({bool isSilent = false}) async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return;

    if (!isSilent) isApprovalLoading.value = true;
    try {
      final response = await _api.getApprovalTickets(token);
      if (response.data['status'] == 'success' ||
          response.data['status_code'] == 200) {
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        debugPrint('fetchApprovalTickets raw collection: $collection');
        final newTickets = collection
            .map((e) => ApprovalTicketModel.fromJson(e as Map<String, dynamic>))
            .toList();

        if (!isSilent) {
          _resolvedTickets.clear();
          _pendingFetches.clear();
        }

        approvalTickets.assignAll(newTickets);

        for (final ticket in newTickets) {
          fetchVisitorNameForTicket(ticket);
        }
      }
    } catch (e) {
      debugPrint('fetchApprovalTickets error: $e');
    } finally {
      if (!isSilent) isApprovalLoading.value = false;
    }
  }

  Future<bool> approveTicketAction(
    String approvalTicketId,
    String actorId,
  ) async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return false;

    try {
      final response = await _api.approveTicket(
        token,
        approvalTicketId,
        actorId,
      );
      if (response.data['status'] == 'success' ||
          response.data['status_code'] == 200) {
        Get.snackbar(
          'Success',
          response.data['msg']?.toString() ?? 'Ticket approved successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchApprovalTickets(isSilent: true); // Refresh list
        return true;
      }
      Get.snackbar(
        'Failed',
        response.data['msg']?.toString() ?? 'Failed to approve ticket',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      debugPrint('approveTicketAction error: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> rejectTicketAction(
    String approvalTicketId,
    String actorId,
  ) async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return false;

    try {
      final response = await _api.rejectTicket(
        token,
        approvalTicketId,
        actorId,
      );
      if (response.data['status'] == 'success' ||
          response.data['status_code'] == 200) {
        Get.snackbar(
          'Success',
          response.data['msg']?.toString() ?? 'Ticket rejected successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchApprovalTickets(isSilent: true); // Refresh list
        return true;
      }
      Get.snackbar(
        'Failed',
        response.data['msg']?.toString() ?? 'Failed to reject ticket',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      debugPrint('rejectTicketAction error: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // ─── Transaction Visitors ────────────────────────────────────────────

  /// Fetch list of visitors for a transaction.
  /// [entityId] is the `entity_id` field from the approval ticket.
  Future<List<Map<String, dynamic>>> fetchTransactionVisitors(
    String entityId,
  ) async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return [];

    try {
      final response = await _api.getTransactionVisitors(token, entityId);
      if (response.statusCode != 200) {
        debugPrint(
          'fetchTransactionVisitors got status code ${response.statusCode}',
        );
        return [];
      }
      final data = response.data;
      if (data is Map &&
          (data['status'] == 'success' || data['status_code'] == 200)) {
        final raw = data['collection'] ?? data['data'] ?? data['visitors'];
        if (raw is List) {
          return raw.whereType<Map<String, dynamic>>().toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('fetchTransactionVisitors error: $e');
      return [];
    }
  }

  /// Fetch ALL individual non-QuickAccess visitors for "Others Visitor" section.
  ///
  /// Strategy:
  /// 1. GET /visitor/transaction/dt dengan length=1 → baca RecordsFiltered (total count)
  /// 2. GET /visitor/transaction/dt dengan length=total → dapat semua transaction IDs
  /// 3. Filter non-quickaccess
  /// 4. Batch call /visitor/transaction/{id}/visitors per 20 request paralel
  /// 5. Gabungkan + deduplicate by visitorNumber
  /// Returns cached visitors immediately on subsequent calls.
  Future<List<AccessPassModel>> fetchAllVisitors({bool forceRefresh = false}) async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return [];

    // Return cache immediately if available and no force refresh
    if (!forceRefresh && _cachedAllVisitors != null) {
      return _cachedAllVisitors!;
    }

    // If already fetching, wait for that future instead of starting a new one
    if (_allVisitorsFuture != null) {
      return _allVisitorsFuture!;
    }

    _allVisitorsFuture = _doFetchAllVisitors(token);
    try {
      final result = await _allVisitorsFuture!;
      _cachedAllVisitors = result;
      return result;
    } finally {
      _allVisitorsFuture = null;
    }
  }

  Future<List<AccessPassModel>> _doFetchAllVisitors(String token) async {
    try {
      // Step 1: Ambil total count
      final countResponse = await _api.getVisitorDt(token, length: 1);
      if (countResponse.statusCode != 200) return [];
      final countData = countResponse.data;
      if (countData is! Map) return [];

      final totalCount = (countData['RecordsFiltered'] ??
              countData['records_filtered'] ??
              countData['recordsFiltered'] ??
              50)
          as int;

      debugPrint('fetchAllVisitors: total transactions = $totalCount');

      // Step 2: Fetch semua transaksi
      final dtResponse = await _api.getVisitorDt(
        token,
        length: totalCount,
        sortDir: 'desc',
      );
      if (dtResponse.statusCode != 200) return [];
      final dtData = dtResponse.data;
      if (dtData is! Map) return [];
      if (dtData['status'] != 'success' && dtData['status_code'] != 200) {
        return [];
      }

      final rawTransactions = dtData['collection'] ?? dtData['data'];
      if (rawTransactions is! List) return [];

      // Step 3: Filter hanya non-quickaccess
      final transactions = rawTransactions
          .whereType<Map<String, dynamic>>()
          .where((t) =>
              (t['flow']?.toString() ?? '').toLowerCase() != 'quickaccessvisit')
          .toList();

      debugPrint(
        'fetchAllVisitors: ${transactions.length} non-quickaccess transactions',
      );

      // Step 4: Batch resolve visitor names (20 per batch)
      const batchSize = 20;
      final List<AccessPassModel> allVisitors = [];
      final Set<String> seen = {};

      for (int i = 0; i < transactions.length; i += batchSize) {
        final batch = transactions.skip(i).take(batchSize).toList();

        final batchResults = await Future.wait(
          batch.map((trx) async {
            final trxId =
                (trx['transaction_visitor_id'] ?? trx['id'])?.toString() ?? '';
            if (trxId.isEmpty) return <Map<String, dynamic>>[];

            try {
              final visitors = await fetchTransactionVisitors(trxId);
              final parentFlow = trx['flow']?.toString() ?? '';
              final parentSitePlaceName =
                  (trx['site_place_name'] ?? trx['host_organization_name'])
                          ?.toString() ??
                      '';
              final parentAgenda = trx['agenda']?.toString() ?? '';
              final parentHostName = trx['host_name']?.toString() ?? '';

              // Inject parent fields ke setiap visitor jika kosong
              for (final v in visitors) {
                if ((v['flow']?.toString() ?? '').isEmpty) {
                  v['flow'] = parentFlow;
                }
                if ((v['site_place_name']?.toString() ?? '').isEmpty) {
                  v['site_place_name'] = parentSitePlaceName;
                }
                if ((v['agenda']?.toString() ?? '').isEmpty) {
                  v['agenda'] = parentAgenda;
                }
                if ((v['host_name']?.toString() ?? '').isEmpty) {
                  v['host_name'] = parentHostName;
                }
              }
              return visitors;
            } catch (e) {
              debugPrint(
                'fetchAllVisitors - error for trxId $trxId: $e',
              );
              return <Map<String, dynamic>>[];
            }
          }),
        );

        // Step 5: Flatten + deduplicate
        for (final visitorMaps in batchResults) {
          for (final v in visitorMaps) {
            final model = AccessPassModel.fromJson(v);
            final key = model.visitorNumber.isNotEmpty
                ? model.visitorNumber
                : '${model.visitorName}_${model.visitorEmail}';
            if (key.isNotEmpty && !seen.contains(key)) {
              seen.add(key);
              allVisitors.add(model);
            }
          }
        }
      }

      debugPrint('fetchAllVisitors: resolved ${allVisitors.length} visitors');
      return allVisitors;
    } catch (e) {
      debugPrint('fetchAllVisitors error: $e');
      return [];
    }
  }

  /// Clear the cached visitor list (e.g., on pull-to-refresh).
  void clearAllVisitorsCache() {
    _cachedAllVisitors = null;
    _allVisitorsFuture = null;
  }

  /// POST approve-meetinghost. Returns true on success (no snackbar — caller handles UI).
  Future<bool> approveMeetingHostAction(
    String approvalTicketId,
    List<String> listTrxVisitorId,
  ) async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return false;

    try {
      final response = await _api.approveMeetingHost(
        token,
        approvalTicketId,
        listTrxVisitorId,
      );
      if (response.data is Map) {
        return response.data['status'] == 'success' ||
            response.data['status_code'] == 200;
      }
      return false;
    } catch (e) {
      debugPrint('approveMeetingHostAction error: $e');
      return false;
    }
  }

  /// Refactored Approve action that executes BOTH approve-meetinghost and approve endpoints.
  Future<bool> approveMeetingHostAndTicketsAction({
    required String approvalTicketId,
    required String actorId,
    required List<String> listTrxVisitorId,
  }) async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return false;

    try {
      isApprovalLoading.value = true;
      // 1. Call approve-meetinghost
      final responseHost = await _api.approveMeetingHost(
        token,
        approvalTicketId,
        listTrxVisitorId,
      );

      bool approveHostOk = false;
      if (responseHost.data is Map) {
        approveHostOk = responseHost.data['status'] == 'success' ||
            responseHost.data['status_code'] == 200;
      }

      if (!approveHostOk) {
        String errMsg = 'Gagal menyetujui host meeting.';
        if (responseHost.data is Map && responseHost.data['msg'] != null) {
          errMsg = responseHost.data['msg'].toString();
        }
        Get.snackbar(
          'Failed',
          errMsg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // 2. Call approve endpoint ONCE with the approvalTicketId and actorId
      final res = await _api.approveTicket(token, approvalTicketId, actorId);
      
      bool approveOk = false;
      if (res.data is Map) {
        approveOk = res.data['status'] == 'success' || res.data['status_code'] == 200;
      }

      if (approveOk) {
        Get.snackbar(
          'Success',
          'Berhasil menyetujui approval.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchApprovalTickets(isSilent: true);
        return true;
      }

      String errMsg = 'Gagal menyetujui ticket.';
      if (res.data is Map && res.data['msg'] != null) {
        errMsg = res.data['msg'].toString();
      }

      Get.snackbar(
        'Failed',
        errMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      debugPrint('approveMeetingHostAndTicketsAction error: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isApprovalLoading.value = false;
    }
  }

  /// Refactored Reject action that calls the workflow reject endpoint.
  Future<bool> rejectMeetingHostAction({
    required String approvalTicketId,
    required String actorId,
  }) async {
    final user = _hive.getUser();
    final token = user?.token;
    if (token == null) return false;

    try {
      isApprovalLoading.value = true;
      final res = await _api.rejectTicket(token, approvalTicketId, actorId);
      
      bool rejectOk = false;
      if (res.data is Map) {
        rejectOk = res.data['status'] == 'success' || res.data['status_code'] == 200;
      }

      if (rejectOk) {
        Get.snackbar(
          'Success',
          'Berhasil menolak approval.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchApprovalTickets(isSilent: true);
        return true;
      }

      String errMsg = 'Gagal menolak approval.';
      if (res.data is Map && res.data['msg'] != null) {
        errMsg = res.data['msg'].toString();
      }

      Get.snackbar(
        'Failed',
        errMsg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      debugPrint('rejectMeetingHostAction error: $e');
      return false;
    } finally {
      isApprovalLoading.value = false;
    }
  }
}
