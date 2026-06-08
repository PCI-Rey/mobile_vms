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
  final RxList<AccessPassModel> ongoingInvitations = <AccessPassModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isNewestFirst = true.obs; // Default: Terbaru di atas

  // Approval Ticket States
  final RxList<ApprovalTicketModel> approvalTickets =
      <ApprovalTicketModel>[].obs;
  final RxBool isApprovalLoading = false.obs;

  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxString selectedSiteId = ''.obs;
  final RxString selectedSiteName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOngoingInvitations();
    fetchApprovalTickets();
    fetchMasterData();
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
    _applyFilters();
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
    bool clearFilters = false,
  }) async {
    if (clearFilters) {
      startDate.value = null;
      endDate.value = null;
      selectedSiteId.value = '';
      selectedSiteName.value = '';
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

  Future<void> _fetchVisitorProviders(String token) async {
    try {
      final response = await _api.getVisitorProviders(token);
      if (response.data['status'] == 'success' || response.data['status_code'] == 200) {
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
        length: 3,
        sortColumn: 'id',
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
        sortColumn: 'id',
        sortDir: 'desc',
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
      } else if (response.data['status'] == 'not_found' ||
                 response.data['status_code'] == 404) {
        shareLinks.clear();
        shareLinkTotalRecords.value = 0;
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
      final response = await _api.sendEmailForExistingShareLink(
        token,
        id,
        {'emails': emails},
      );
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

    try {
      final response = await _api.createQuickAccessVisit(token, body);
      if (response.data['status'] == 'success' ||
          response.data['status_code'] == 200) {
        await fetchOngoingInvitations(clearFilters: true);
        return true;
      }
      return false;
    } catch (e) {
      if (e is DioException && e.response != null) {
        debugPrint('createQuickAccessAction error response: ${e.response?.data}');
        throw e.response?.data['message'] ??
            e.response?.data['msg'] ??
            e.response?.data.toString() ??
            'Failed to create quick access visit';
      }
      debugPrint('createQuickAccessAction error: $e');
      throw 'Failed to create quick access visit';
    }
  }

  // ─── Approval Ticket Action ──────────────────────────────────────────

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
        approvalTickets.assignAll(newTickets);
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
      final data = response.data;
      if (data['status'] == 'success' || data['status_code'] == 200) {
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
      return response.data['status'] == 'success' ||
          response.data['status_code'] == 200;
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

      final approveHostOk =
          responseHost.data['status'] == 'success' ||
          responseHost.data['status_code'] == 200;

      if (!approveHostOk) {
        Get.snackbar(
          'Failed',
          responseHost.data['msg']?.toString() ??
              'Gagal menyetujui host meeting.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // 2. Call approve endpoint ONCE with the approvalTicketId and actorId
      final res = await _api.approveTicket(token, approvalTicketId, actorId);
      final approveOk =
          res.data['status'] == 'success' || res.data['status_code'] == 200;

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

      Get.snackbar(
        'Failed',
        res.data['msg']?.toString() ?? 'Gagal menyetujui ticket.',
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
      if (res.data['status'] == 'success' || res.data['status_code'] == 200) {
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

      Get.snackbar(
        'Failed',
        res.data['msg']?.toString() ?? 'Gagal menolak approval.',
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
