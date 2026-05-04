import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/datasources/hive_service.dart';
import '../../../../data/models/visitor_type_model.dart';
import '../../../../data/models/visitor_type_detail_model.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

// ─── Simple model for dropdown items (Employee, Host, Site) ──────────────────

class DropdownItem {
  final String id;
  final String name;
  DropdownItem({required this.id, required this.name});
}

// ─── Group Visitor Row Model ──────────────────────────────────────────────────

/// Represents one visitor row in group registration mode.
class GroupVisitorRow {
  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController organization = TextEditingController();
  final TextEditingController identityId = TextEditingController();

  // Employee fields — mirrors single-visitor "Are you Employee?" logic
  final RxBool isEmployee = false.obs;
  final RxString selectedEmployeeId = ''.obs;
  final RxString selectedEmployeeName = ''.obs;

  void dispose() {
    fullName.dispose();
    email.dispose();
    phone.dispose();
    organization.dispose();
    identityId.dispose();
  }

  bool get isValid =>
      fullName.text.trim().isNotEmpty &&
      email.text.trim().isNotEmpty &&
      phone.text.trim().isNotEmpty &&
      organization.text.trim().isNotEmpty &&
      identityId.text.trim().isNotEmpty;
}

// ─── Controller ───────────────────────────────────────────────────────────────

class PraRegistrationController extends GetxController {
  final _api = ApiService();
  final _hive = HiveService();

  // ─── State ────────────────────────────────────────────────────────────────

  // Step 0 – Visitor Type list
  final RxList<VisitorTypeModel> visitorTypes = <VisitorTypeModel>[].obs;
  final RxBool isLoadingTypes = false.obs;

  // Step 0 – selected type + form structure
  final RxString selectedVisitorTypeId = ''.obs;
  final RxString selectedVisitorTypeName = ''.obs;
  final Rx<VisitorTypeDetailModel?> formStructure =
      Rx<VisitorTypeDetailModel?>(null);
  final RxBool isLoadingDetail = false.obs;

  // Step 0 – single/group
  final Rx<bool?> isGroup = Rx<bool?>(null);

  // Step 1 – Visitor Information (bound directly to form fields via answerText)
  // These are separate observables for validation purposes.
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final RxString organization = ''.obs;
  final RxString identityId = ''.obs;
  final RxBool isEmployee = false.obs;

  // Step 1 – Employee dropdown (for "Employee Name" field)
  final RxList<DropdownItem> employees = <DropdownItem>[].obs;
  final RxString selectedEmployeeId = ''.obs;
  final RxBool isLoadingEmployees = false.obs;

  // Step 2 – Purpose Visit
  final RxList<DropdownItem> hosts = <DropdownItem>[].obs;
  final RxString selectedHostId = ''.obs;
  final RxBool isLoadingHosts = false.obs;

  final RxString agenda = ''.obs;

  final RxList<DropdownItem> sites = <DropdownItem>[].obs;
  final RxString selectedSiteId = ''.obs;
  final RxBool isLoadingSites = false.obs;

  final Rx<DateTime?> visitStart = Rx<DateTime?>(null);
  final Rx<DateTime?> visitEnd = Rx<DateTime?>(null);

  // Shared
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxInt currentStep = 0.obs;

  // Group mode
  final RxString groupCode = ''.obs;
  final RxString groupName = ''.obs;
  final RxList<GroupVisitorRow> groupVisitors = <GroupVisitorRow>[].obs;

  // Trigger for UI reactivity on manual field updates
  final RxInt formUpdateTrigger = 0.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // FIX: Fetch all supporting data upfront per spec.
    fetchVisitorTypes();
    fetchEmployees();
    fetchHosts();
    fetchSites();
  }

  // ─── Token helper ─────────────────────────────────────────────────────────

  String? get _token => _hive.getUser()?.token;

  // ─── Step 0: Visitor Types ────────────────────────────────────────────────

  Future<void> fetchVisitorTypes() async {
    final token = _token;
    if (token == null) return;

    isLoadingTypes.value = true;
    try {
      final response = await _api.getVisitorTypes(token);
      if (response.data['status'] == 'success') {
        final collection =
            response.data['collection'] as List<dynamic>? ?? [];
        visitorTypes.value = collection
            .map((e) => VisitorTypeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _showError(response.data['msg']?.toString() ?? 'Gagal memuat visitor type');
      }
    } catch (e) {
      debugPrint('fetchVisitorTypes error: $e');
      _showError('Gagal memuat visitor type');
    } finally {
      isLoadingTypes.value = false;
    }
  }

  Future<void> onSelectVisitorType(String id, String typeName) async {
    selectedVisitorTypeId.value = id;
    selectedVisitorTypeName.value = typeName;
    formStructure.value = null;
    // FIX: Only fetch form structure after user picks visitor type.
    await fetchFormStructure(id);
  }

  Future<void> fetchFormStructure(String id) async {
    final token = _token;
    if (token == null || id.isEmpty) return;

    isLoadingDetail.value = true;
    try {
      final response = await _api.getVisitorTypeById(token, id);
      dev.log('=== FORM STRUCTURE RESPONSE ===\n${jsonEncode(response.data)}', name: 'PraReg');
      if (response.data['status'] == 'success') {
        final collection =
            response.data['collection'] as Map<String, dynamic>? ?? {};
        formStructure.value = VisitorTypeDetailModel.fromJson(collection);
      } else {
        _showError(response.data['msg']?.toString() ?? 'Gagal memuat form');
      }
    } catch (e) {
      debugPrint('fetchFormStructure error: $e');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  // ─── Step 1: Employees ────────────────────────────────────────────────────

  Future<void> fetchEmployees() async {
    final token = _token;
    if (token == null) return;

    isLoadingEmployees.value = true;
    try {
      final response = await _api.getEmployees(token);
      if (response.data['status'] == 'success') {
        final collection =
            response.data['collection'] as List<dynamic>? ?? [];
        // Use UUID 'id' as the identifier — this is the primary key the backend expects.
        // 'person_id' is the badge/card number, NOT the DB primary key.
        employees.value = collection
            .map((e) => DropdownItem(
                  id: e['id']?.toString() ?? '',
                  name: e['name']?.toString() ?? '',
                ))
            .toList();
        dev.log('[EMPLOYEE] Loaded ${employees.length} employees. First id=${employees.firstOrNull?.id}', name: 'PraReg');
      }
    } catch (e) {
      debugPrint('fetchEmployees error: $e');
    } finally {
      isLoadingEmployees.value = false;
    }
  }

  // ─── Step 2: Hosts & Sites ───────────────────────────────────────────────

  Future<void> fetchHosts() async {
    final token = _token;
    if (token == null) return;

    isLoadingHosts.value = true;
    try {
      final response = await _api.getHosts(token);
      if (response.data['status'] == 'success') {
        final collection =
            response.data['collection'] as List<dynamic>? ?? [];
        hosts.value = collection
            .map((e) => DropdownItem(
                  id: e['id']?.toString() ?? '',
                  name: e['name']?.toString() ?? '',
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('fetchHosts error: $e');
    } finally {
      isLoadingHosts.value = false;
    }
  }

  Future<void> fetchSites() async {
    final token = _token;
    if (token == null) return;

    isLoadingSites.value = true;
    try {
      final response = await _api.getSitesWithToken(token);
      if (response.data['status'] == 'success') {
        final collection =
            response.data['collection'] as List<dynamic>? ?? [];
        sites.value = collection
            .map((e) => DropdownItem(
                  id: e['id']?.toString() ?? '',
                  name: e['name']?.toString() ?? '',
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('fetchSites error: $e');
    } finally {
      isLoadingSites.value = false;
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void nextStep() {
    if (isLoadingDetail.value) return;
    if (currentStep.value < 2) currentStep.value++;
  }

  void prevStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  void updateForm() {
    formUpdateTrigger.value++;
  }

  // ─── Group Management ─────────────────────────────────────────────────────

  String _generateGroupCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void initGroupMode() {
    groupCode.value = _generateGroupCode();
    groupName.value = '';
    // Start with 1 empty visitor row
    for (final v in groupVisitors) {
      v.dispose();
    }
    groupVisitors.clear();
    groupVisitors.add(GroupVisitorRow());
  }

  void addGroupVisitor() {
    groupVisitors.add(GroupVisitorRow());
    updateForm();
  }

  void removeGroupVisitor(int index) {
    if (groupVisitors.length <= 1) return; // keep at least 1
    groupVisitors[index].dispose();
    groupVisitors.removeAt(index);
    updateForm();
  }

  // ─── Validation ───────────────────────────────────────────────────────────

  // Step 0: visitor type selected AND form loaded AND single/group chosen
  bool get isStep1Valid =>
      selectedVisitorTypeId.value.isNotEmpty && formStructure.value != null;

  // Step 1: core visitor fields filled
  bool get isStep2Valid =>
      name.value.trim().isNotEmpty &&
      email.value.trim().isNotEmpty &&
      phone.value.trim().isNotEmpty &&
      organization.value.trim().isNotEmpty;

  // Step 2: host, agenda, site, and dates all filled
  bool get isStep3Valid =>
      selectedHostId.value.isNotEmpty &&
      agenda.value.trim().isNotEmpty &&
      selectedSiteId.value.isNotEmpty &&
      visitStart.value != null &&
      visitEnd.value != null;

  /// Legacy validator used by _BottomNav (step 0 handled separately)
  bool validateCurrentStep() {
    // Ensure reactivity by reading observables here (inside Obx context)
    final _ = formUpdateTrigger.value;

    switch (currentStep.value) {
      case 0:
        return isStep1Valid && isGroup.value != null;

      case 1:
        if (isGroup.value == true) {
          // Group mode: all visitor rows must be valid + group name filled
          return groupName.value.trim().isNotEmpty &&
              groupVisitors.isNotEmpty &&
              groupVisitors.every((v) => v.isValid);
        }
        // Single mode: validate ALL mandatory enabled fields from form structure
        final detail1 = formStructure.value;
        if (detail1 == null) return false;
        final sections1 = detail1.sectionPageVisitorTypes;
        final visitorSection = sections1.firstWhereOrNull(
              (s) => s.name.toLowerCase().contains('visitor'),
            ) ?? sections1.firstOrNull;
        if (visitorSection == null) return false;
        for (final f in visitorSection.praForm) {
          if (!f.isEnable || !f.mandatory) continue;
          // Skip date/time fields checked separately
          final isDateTime = f.fieldType == 4 ||
              f.fieldType == 9 ||
              f.remarks == 'visitor_period_start' ||
              f.remarks == 'visitor_period_end';
          if (isDateTime) {
            if (f.answerDatetime.isEmpty) return false;
          } else {
            // For is_employee: always has a default 'false', so skip mandatory check
            if (f.remarks == 'is_employee') continue;
            if (f.answerText.trim().isEmpty) return false;
          }
        }
        return true;

      case 2:
        // Validate ALL mandatory enabled fields from purpose visit section
        final detail2 = formStructure.value;
        if (detail2 == null) return false;
        // Core Purpose Visit observables
        if (selectedHostId.value.isEmpty) return false;
        if (agenda.value.trim().isEmpty) return false;
        if (selectedSiteId.value.isEmpty) return false;
        if (visitStart.value == null) return false;
        if (visitEnd.value == null) return false;
        return true;

      default:
        return true;
    }
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<bool> submitForm() async {
    final token = _token;
    if (token == null) {
      _showError('Token tidak ditemukan. Silakan login kembali.');
      return false;
    }

    final detail = formStructure.value;
    if (detail == null) {
      _showError('Data form tidak lengkap.');
      return false;
    }

    isSubmitting.value = true;
    try {
      // Get device timezone, fallback to Asia/Jakarta
      String deviceTz = 'Asia/Jakarta';
      try {
        final tzInfo = await FlutterTimezone.getLocalTimezone();
        deviceTz = tzInfo.identifier;
      } catch (e) {
        debugPrint('Timezone detection failed, using fallback: $e');
      }

      // Build question_page from pra_form (not visit_form).
      // Match remarks to controller values per spec.
      // Log all field remarks so we can trace what's being sent
      dev.log('[SUBMIT] All form field remarks:', name: 'PraReg');
      for (final section in detail.sectionPageVisitorTypes) {
        for (final f in section.praForm.where((f) => f.isEnable)) {
          dev.log('  remarks="${f.remarks}" shortName="${f.shortName}" fieldType=${f.fieldType} answerText="${f.answerText}"', name: 'PraReg');
        }
      }
      dev.log('[SUBMIT] selectedEmployeeId="${selectedEmployeeId.value}" isEmployee=${isEmployee.value}', name: 'PraReg');

      final questionPage = detail.sectionPageVisitorTypes.map((section) {
        final form = section.praForm.where((f) => f.isEnable).map((f) {
          final isDateTimeField =
              f.fieldType == 4 || f.fieldType == 9 ||
              f.remarks == 'visitor_period_start' ||
              f.remarks == 'visitor_period_end';

          // Build answer based on remarks
          String answerText = '';
          String answerDatetime = '';

          if (f.remarks == 'visitor_period_start' && visitStart.value != null) {
            // Send as UTC — backend interprets UTC and displays in local timezone
            answerDatetime =
                visitStart.value!.toUtc().toIso8601String().substring(0, 19);
            answerText = '';
          } else if (f.remarks == 'visitor_period_end' &&
              visitEnd.value != null) {
            answerDatetime =
                visitEnd.value!.toUtc().toIso8601String().substring(0, 19);
            answerText = '';
          } else if (isDateTimeField) {
            // General date/datetime field – use what was stored
            answerDatetime = f.answerDatetime;
            answerText = '';
          } else {
            // All other text/dropdown fields – match by remarks
            answerText = _answerTextForRemarks(f.remarks, f);
            answerDatetime = '';
          }

          final Map<String, dynamic> json = {
            'sort': f.sort,
            'short_name': f.shortName,
            'long_display_text': f.longDisplayText,
            'field_type': f.fieldType,
            'is_primary': f.isPrimary,
            'is_enable': f.isEnable,
            'mandatory': f.mandatory,
            'remarks': f.remarks,
            'custom_field_id': f.customFieldId,
            'multiple_option_fields':
                f.multipleOptionFields.map((o) => o.toJson()).toList(),
            'visitor_form_type': f.visitorFormType,
          };

          // FIX: Only include answer_datetime if it's non-empty (backend rejects "")
          if (answerDatetime.isNotEmpty) {
            json['answer_datetime'] = answerDatetime;
            json['answer_text'] = ''; // datetime fields must have empty answer_text
          } else {
            json['answer_text'] = answerText; // text fields don't need answer_datetime
          }

          // Image/file fields use answer_file instead
          if ([10, 11, 12].contains(f.fieldType)) {
            json['answer_file'] = f.answerText;
            json.remove('answer_text');
            json.remove('answer_datetime');
          }

          return json;
        }).toList();

        return {
          'id': section.id,
          'sort': section.sort,
          'name': section.name,
          'status': 0, // FIX: spec says status: 0
          'is_document': section.isDocument,
          'can_multiple_used': section.canMultipleUsed,
          'self_only': false,
          'foreign_id': section.foreignId,
          'form': form,
        };
      }).toList();

      // visitor_role: backend only accepts "Visitor" — "Employee" causes format error.
      // Employee context is communicated via is_employee form field + employee person_id.
      const resolvedRole = 'Visitor';

      final Map<String, dynamic> body;

      if (isGroup.value == true) {
        // Build one question_page per visitor row
        final dataVisitors = groupVisitors.map((visitor) {
          final visitorAnswers = {
            'name': visitor.fullName.text.trim(),
            'email': visitor.email.text.trim(),
            'phone': visitor.phone.text.trim(),
            'organization': visitor.organization.text.trim(),
            'indentity_id': visitor.identityId.text.trim(),
            // Employee fields — send UUID if user chose "Yes", else 'false'
            'is_employee': visitor.isEmployee.value.toString(),
            'employee_name': visitor.isEmployee.value
                ? visitor.selectedEmployeeId.value
                : '',
            'employee': visitor.isEmployee.value
                ? visitor.selectedEmployeeId.value
                : '',
          };

          final qp = detail.sectionPageVisitorTypes.map((section) {
            final form = section.praForm.where((f) => f.isEnable).map((f) {
              final isDateTimeField =
                  f.fieldType == 4 || f.fieldType == 9 ||
                  f.remarks == 'visitor_period_start' ||
                  f.remarks == 'visitor_period_end';

              String answerText = '';
              String answerDatetime = '';

              if (f.remarks == 'visitor_period_start' && visitStart.value != null) {
                answerDatetime = visitStart.value!.toUtc().toIso8601String().substring(0, 19);
              } else if (f.remarks == 'visitor_period_end' && visitEnd.value != null) {
                answerDatetime = visitEnd.value!.toUtc().toIso8601String().substring(0, 19);
              } else if (isDateTimeField) {
                answerDatetime = f.answerDatetime;
              } else {
                // Use visitor-specific answers, fall back to form field
                answerText = visitorAnswers[f.remarks] ?? _answerTextForRemarks(f.remarks, f);
              }

              final Map<String, dynamic> json = {
                'sort': f.sort,
                'short_name': f.shortName,
                'long_display_text': f.longDisplayText,
                'field_type': f.fieldType,
                'is_primary': f.isPrimary,
                'is_enable': f.isEnable,
                'mandatory': f.mandatory,
                'remarks': f.remarks,
                'custom_field_id': f.customFieldId,
                'multiple_option_fields':
                    f.multipleOptionFields.map((o) => o.toJson()).toList(),
                'visitor_form_type': f.visitorFormType,
              };

              if (answerDatetime.isNotEmpty) {
                json['answer_datetime'] = answerDatetime;
                json['answer_text'] = '';
              } else {
                json['answer_text'] = answerText;
              }

              if ([10, 11, 12].contains(f.fieldType)) {
                json['answer_file'] = f.answerText;
                json.remove('answer_text');
                json.remove('answer_datetime');
              }
              return json;
            }).toList();

            return {
              'id': section.id,
              'sort': section.sort,
              'name': section.name,
              'status': 0,
              'is_document': section.isDocument,
              'can_multiple_used': section.canMultipleUsed,
              'self_only': false,
              'foreign_id': section.foreignId,
              'form': form,
            };
          }).toList();

          return {'question_page': qp};
        }).toList();

        body = {
          'list_group': [
            {
              'visitor_type': selectedVisitorTypeId.value,
              'is_group': true,
              'type_registered': 1,
              'tz': deviceTz,
              if (selectedSiteId.value.isNotEmpty)
                'registered_site': selectedSiteId.value,
              'group_code': groupCode.value,
              'group_name': groupName.value.trim(),
              'data_visitor': dataVisitors,
            }
          ],
        };
      } else {
        body = {
          'visitor_type': selectedVisitorTypeId.value,
          'type_registered': 0,
          'is_group': false,
          'tz': deviceTz,
          'flow': 'Praregister',
          'visitor_role': resolvedRole,
          // Only include registered_site if user actually selected one
          if (selectedSiteId.value.isNotEmpty)
            'registered_site': selectedSiteId.value,
          'data_visitor': [
            {'question_page': questionPage},
          ],
        };
      }

      dev.log('=== SUBMIT PAYLOAD ===\n${jsonEncode(body)}', name: 'PraReg');

      final response = (isGroup.value == true)
          ? await _api.submitNewPraInviteGroup(token, body)
          : await _api.submitNewPraInvite(token, body);

      debugPrint('=== SUBMIT RESPONSE ===');
      debugPrint(jsonEncode(response.data));

      final data = response.data;
      final status = data['status']?.toString() ?? '';
      // FIX: collection can be List (on error) or Map (on success) — cast safely
      final collectionMap =
          data['collection'] is Map ? data['collection'] as Map : null;
      final transactionStatus =
          collectionMap?['transaction_status']?.toString() ?? '';

      // FIX: Success = transaction_status == "UnderCreated" per spec
      if (status == 'success' || transactionStatus == 'UnderCreated') {
        final msg = data['msg']?.toString() ?? 'Registrasi berhasil!';
        Get.snackbar(
          'Sukses',
          msg,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        final msg = data['msg']?.toString() ?? 'Terjadi kesalahan.';
        _showError(msg);
        return false;
      }
    } catch (e) {
      debugPrint('submitForm error: $e');
      _showError(e.toString());
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Maps a form field's remarks to the correct controller observable value.
  String _answerTextForRemarks(String remarks, VisitFormField field) {
    switch (remarks) {
      case 'name':
        return name.value;
      case 'email':
        return email.value;
      case 'phone':
        return phone.value;
      case 'organization':
        return organization.value;
      case 'indentity_id': // typo is intentional — matches backend key
        return identityId.value;
      case 'host':
        // FIX: Send the host ID (not the name) for the dropdown field
        return selectedHostId.value;
      case 'agenda':
        return agenda.value;
      case 'site_place':
        // FIX: Send the site ID for the dropdown field
        return selectedSiteId.value;
      case 'employee_name':
      case 'employee':
        // Send the selected employee ID (UUID) for the employee dropdown field.
        // field.answerText is set to the UUID when user selects from dropdown.
        dev.log('[SUBMIT] employee remarks="$remarks" → selectedEmployeeId="${selectedEmployeeId.value}", field.answerText="${field.answerText}"', name: 'PraReg');
        // Prefer the dedicated observable; fallback to field.answerText if set
        final empId = selectedEmployeeId.value.isNotEmpty
            ? selectedEmployeeId.value
            : field.answerText;
        dev.log('[SUBMIT] Final employee value sent: "$empId"', name: 'PraReg');
        return empId;
      case 'is_employee':
        // Send 'true'/'false' string based on observable
        return isEmployee.value.toString();
      default:
        // For any other field, fall back to what was typed directly
        return field.answerText;
    }
  }

  // ─── Reset ────────────────────────────────────────────────────────────────

  void resetForm() {
    selectedVisitorTypeId.value = '';
    selectedVisitorTypeName.value = '';
    formStructure.value = null;
    isGroup.value = null;
    currentStep.value = 0;
    formUpdateTrigger.value = 0;

    // Step 1
    name.value = '';
    email.value = '';
    phone.value = '';
    organization.value = '';
    identityId.value = '';
    isEmployee.value = false;
    selectedEmployeeId.value = '';

    // Group
    groupCode.value = '';
    groupName.value = '';
    for (final v in groupVisitors) {
      v.dispose();
    }
    groupVisitors.clear();

    // Step 2
    selectedHostId.value = '';
    agenda.value = '';
    selectedSiteId.value = '';
    visitStart.value = null;
    visitEnd.value = null;
  }

  // ─── Unsaved changes check ─────────────────────────────────────────────────

  bool get hasUnsavedChanges {
    if (selectedVisitorTypeId.value.isNotEmpty) return true;
    if (isGroup.value != null) return true;
    if (name.value.isNotEmpty || email.value.isNotEmpty) return true;
    if (selectedHostId.value.isNotEmpty) return true;
    if (visitStart.value != null) return true;

    // Also check raw form fields (for any typed-in data not mapped above)
    final detail = formStructure.value;
    if (detail != null) {
      for (var section in detail.sectionPageVisitorTypes) {
        for (var field in section.praForm) {
          if (field.answerText.trim().isNotEmpty ||
              field.answerDatetime.isNotEmpty) {
            return true;
          }
        }
      }
    }

    return false;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _showError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
