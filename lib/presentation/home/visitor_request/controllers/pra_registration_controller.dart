// ignore_for_file: unused_import, unused_local_variable, unused_element, use_build_context_synchronously, sized_box_for_whitespace, unnecessary_underscores, unnecessary_import, unnecessary_null_comparison, curly_braces_in_flow_control_structures, unused_element_parameter, deprecated_member_use
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/datasources/hive_service.dart';
import '../../../../data/models/visitor_type_model.dart';
import '../../../../data/models/visitor_type_detail_model.dart';
import '../../../../data/models/access_pass_model.dart';
import '../../invitation/controller/invitation_controller.dart';

// ─── Simple model for dropdown items (Employee, Host, Site) ──────────────────

class DropdownItem {
  final String id;
  final String name;
  DropdownItem({required this.id, required this.name});
}

// ─── Group Visitor Row Model ──────────────────────────────────────────────────

class GroupVisitorRow {
  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController organization = TextEditingController();
  final TextEditingController identityId = TextEditingController();

  final RxBool isEmployee = false.obs;
  final RxString selectedEmployeeId = ''.obs;
  final RxString selectedEmployeeName = ''.obs;
  final RxString selectedVisitorRole = ''.obs;

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
      identityId.text.trim().isNotEmpty &&
      selectedVisitorRole.value.trim().isNotEmpty;
}

// ─── Controller ───────────────────────────────────────────────────────────────

class PraRegistrationController extends GetxController {
  final _api = ApiService();
  final _hive = HiveService();

  final RxList<VisitorTypeModel> visitorTypes = <VisitorTypeModel>[].obs;
  final RxBool isLoadingTypes = false.obs;

  final RxString selectedVisitorTypeId = ''.obs;
  final RxString selectedVisitorTypeName = ''.obs;
  final Rx<VisitorTypeDetailModel?> formStructure = Rx<VisitorTypeDetailModel?>(
    null,
  );
  final RxBool isLoadingDetail = false.obs;

  final Rx<bool?> isGroup = Rx<bool?>(null);
  final RxBool isDuplicateMode = false.obs;

  // ── Visitor Role ──────────────────────────────────────────────────────────
  final RxString selectedVisitorRole = ''.obs;

  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final RxString organization = ''.obs;
  final RxString identityId = ''.obs;
  final RxBool isEmployee = false.obs;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final organizationCtrl = TextEditingController();
  final identityIdCtrl = TextEditingController();

  TextEditingController? getFieldController(String remarks) {
    switch (remarks) {
      case 'name':
        return nameCtrl;
      case 'email':
        return emailCtrl;
      case 'phone':
        return phoneCtrl;
      case 'organization':
        return organizationCtrl;
      case 'indentity_id':
        return identityIdCtrl;
      default:
        return null;
    }
  }

  final RxList<DropdownItem> employees = <DropdownItem>[].obs;
  final List<Map<String, dynamic>> _rawEmployees = <Map<String, dynamic>>[];
  final RxString selectedEmployeeId = ''.obs;
  final RxString selectedEmployeeName = ''.obs;
  final RxBool isLoadingEmployees = false.obs;
  final RxString employeeSearchQuery = ''.obs;

  List<Map<String, dynamic>> get filteredEmployees {
    final q = employeeSearchQuery.value.toLowerCase().trim();
    if (q.isEmpty) return _rawEmployees.toList();
    return _rawEmployees
        .where(
          (e) =>
              (e['name']?.toString() ?? '').toLowerCase().contains(q) &&
              (e['name']?.toString() ?? '').isNotEmpty,
        )
        .toList();
  }

  // ── Visitor Search ────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> allVisitors = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingVisitors = false.obs;
  final RxString visitorSearchQuery = ''.obs;

  List<Map<String, dynamic>> get filteredVisitors {
    final q = visitorSearchQuery.value.toLowerCase().trim();
    if (q.isEmpty) return allVisitors.toList();
    return allVisitors
        .where(
          (v) =>
              (v['name']?.toString() ?? '').toLowerCase().contains(q) &&
              (v['name']?.toString() ?? '').isNotEmpty,
        )
        .toList();
  }

  final RxList<DropdownItem> hosts = <DropdownItem>[].obs;
  final RxString selectedHostId = ''.obs;
  final RxBool isLoadingHosts = false.obs;
  final RxString agenda = ''.obs;
  final FocusNode agendaFocusNode = FocusNode();
  final RxList<DropdownItem> sites = <DropdownItem>[].obs;
  final RxString selectedSiteId = ''.obs;
  final RxString selectedSiteName = ''.obs;
  final RxBool isLoadingSites = false.obs;
  final Rx<DateTime?> visitStart = Rx<DateTime?>(null);
  final Rx<DateTime?> visitEnd = Rx<DateTime?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxInt currentStep = 0.obs;

  final RxString groupCode = ''.obs;
  final RxString groupName = ''.obs;
  final groupNameCtrl = TextEditingController();
  final RxList<GroupVisitorRow> groupVisitors = <GroupVisitorRow>[].obs;

  final RxInt formUpdateTrigger = 0.obs;

  @override
  void onInit() {
    super.onInit();
    resetFields();
    fetchVisitorTypes();
    fetchVisitors();
    fetchEmployees();
    fetchHosts();
    fetchSites();

    // Listen to hosts change to resolve name to UUID
    ever(hosts, (_) => _resolveHostNameFromList());
  }

  void _resolveHostNameFromList() {
    final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    if (selectedHostId.value.isNotEmpty && !uuidRegex.hasMatch(selectedHostId.value)) {
      final matched = hosts.firstWhereOrNull(
        (h) => h.name.toLowerCase().trim() == selectedHostId.value.toLowerCase().trim(),
      );
      if (matched != null) {
        selectedHostId.value = matched.id;
        
        // Also update form field answerText
        for (var section in formStructure.value?.sectionPageVisitorTypes ?? <SectionPageVisitorType>[]) {
          for (var field in section.praForm) {
            if (field.remarks.toLowerCase() == 'host') {
              field.answerText = matched.id;
            }
          }
        }
      }
    }
  }

  @override
  void onClose() {
    resetFields();
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    organizationCtrl.dispose();
    identityIdCtrl.dispose();
    groupNameCtrl.dispose();
    agendaFocusNode.dispose();
    super.onClose();
  }

  void resetFields() {
    isDuplicateMode.value = false;
    selectedVisitorTypeId.value = '';
    selectedVisitorTypeName.value = '';
    formStructure.value = null;
    isGroup.value = null;
    name.value = '';
    email.value = '';
    phone.value = '';
    organization.value = '';
    identityId.value = '';
    isEmployee.value = false;
    selectedEmployeeId.value = '';
    selectedEmployeeName.value = '';
    selectedVisitorRole.value = '';
    nameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    organizationCtrl.clear();
    identityIdCtrl.clear();
    groupName.value = '';
    groupNameCtrl.clear();
    groupVisitors.clear();
    selectedHostId.value = '';
    selectedSiteId.value = '';
    selectedSiteName.value = '';
    visitStart.value = null;
    visitEnd.value = null;
    agenda.value = '';
    currentStep.value = 0;
  }

  Future<void> autofillFromAccessPass(
    AccessPassModel model, {
    List<Map<String, dynamic>>? subVisitors,
  }) async {
    // 1. Reset
    resetFields();
    isDuplicateMode.value = true;

    // 2. Set Visitor Type
    selectedVisitorTypeId.value = model.visitorTypeId;
    selectedVisitorTypeName.value = model.visitorTypeName;
    await fetchFormStructure(model.visitorTypeId);

    // 3. Set Group status
    final hasGroupFlag = model.isGroup ||
        model.groupName.isNotEmpty ||
        (subVisitors != null && subVisitors.length > 1);
    isGroup.value = hasGroupFlag;
    if (hasGroupFlag) {
      groupName.value = '';
      groupNameCtrl.clear();
      groupCode.value = _generateGroupCode(); // Generate new group code for duplicate
      groupVisitors.clear();
      if (subVisitors != null && subVisitors.isNotEmpty) {
        for (final sub in subVisitors) {
          final row = GroupVisitorRow();
          row.fullName.text = sub['visitor_name']?.toString() ?? sub['name']?.toString() ?? '';
          row.email.text = sub['visitor_email']?.toString() ?? sub['email']?.toString() ?? '';
          row.phone.text = sub['visitor_phone']?.toString() ?? sub['phone']?.toString() ?? '';
          row.organization.text = sub['visitor_organization_name']?.toString() ?? sub['organization']?.toString() ?? '';
          row.identityId.text = sub['visitor_identity_id']?.toString() ?? sub['identity_id']?.toString() ?? '';
          row.selectedVisitorRole.value =
              sub['visitor_role']?.toString() ?? model.visitorRole;
          groupVisitors.add(row);
        }
      } else {
        // Fallback: add parent visitor info
        final row = GroupVisitorRow();
        row.fullName.text = model.visitorName;
        row.email.text = model.visitorEmail;
        row.phone.text = model.visitorPhone;
        row.organization.text = model.visitorOrganizationName;
        row.identityId.text = model.visitorIdentityId;
        row.selectedVisitorRole.value = model.visitorRole;
        groupVisitors.add(row);
      }
    } else {
      // 4. Set Single Visitor Info
      if (subVisitors != null && subVisitors.isNotEmpty) {
        final sub = subVisitors.first;
        nameCtrl.text = sub['visitor_name']?.toString() ?? model.visitorName;
        emailCtrl.text = sub['visitor_email']?.toString() ?? model.visitorEmail;
        phoneCtrl.text = sub['visitor_phone']?.toString() ?? model.visitorPhone;
        organizationCtrl.text = sub['visitor_organization_name']?.toString() ?? model.visitorOrganizationName;
        identityIdCtrl.text = sub['visitor_identity_id']?.toString() ?? model.visitorIdentityId;
        selectedVisitorRole.value = sub['visitor_role']?.toString() ?? model.visitorRole;
      } else {
        nameCtrl.text = model.visitorName;
        emailCtrl.text = model.visitorEmail;
        phoneCtrl.text = model.visitorPhone;
        organizationCtrl.text = model.visitorOrganizationName;
        identityIdCtrl.text = model.visitorIdentityId;
        selectedVisitorRole.value = model.visitorRole;
      }

      name.value = nameCtrl.text;
      email.value = emailCtrl.text;
      phone.value = phoneCtrl.text;
      organization.value = organizationCtrl.text;
      identityId.value = identityIdCtrl.text;
    }

    // 5. Set Purpose & Details (Step 2)
    agenda.value = model.agenda;

    final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

    selectedSiteId.value = '';
    selectedSiteName.value = '';

    // Resolve host UUID/Name
    String hostIdVal = model.host;
    if (!uuidRegex.hasMatch(hostIdVal) && hostIdVal.isNotEmpty) {
      final matched = hosts.firstWhereOrNull(
        (h) => h.name.toLowerCase().trim() == hostIdVal.toLowerCase().trim(),
      );
      if (matched != null) {
        hostIdVal = matched.id;
      } else {
        // Match using name from sub-visitor details if model.host is empty or a different name
        final hostNameVal = model.hostName;
        if (hostNameVal.isNotEmpty) {
          final matchedByName = hosts.firstWhereOrNull(
            (h) => h.name.toLowerCase().trim() == hostNameVal.toLowerCase().trim(),
          );
          if (matchedByName != null) {
            hostIdVal = matchedByName.id;
          } else {
            hostIdVal = hostNameVal;
          }
        }
      }
    }
    selectedHostId.value = hostIdVal;

    // Set Dates too
    visitStart.value = model.visitorPeriodStart;
    visitEnd.value = model.visitorPeriodEnd;

    // Set formStructure answers
    for (var section in formStructure.value?.sectionPageVisitorTypes ??
        <SectionPageVisitorType>[]) {
      for (var field in section.praForm) {
        final rem = field.remarks.toLowerCase();
        if (rem == 'name') field.answerText = name.value;
        if (rem == 'email') field.answerText = email.value;
        if (rem == 'phone') field.answerText = phone.value;
        if (rem == 'organization' || rem == 'company') {
          field.answerText = organization.value;
        }
        if (rem == 'identity_id' || rem == 'indentity_id') {
          field.answerText = identityId.value;
        }
        if (rem == 'visitor_role') field.answerText = selectedVisitorRole.value;
        if (rem == 'host') field.answerText = selectedHostId.value;
        if (rem == 'site_place') field.answerText = selectedSiteId.value;
        if (rem == 'agenda') field.answerText = agenda.value;
        if (rem == 'visitor_period_start') {
          final iso = model.visitorPeriodStart
              .toIso8601String()
              .replaceAll(RegExp(r'\.\d+'), '');
          field.answerText = iso;
          field.answerDatetime = iso;
        }
        if (rem == 'visitor_period_end') {
          final iso = model.visitorPeriodEnd
              .toIso8601String()
              .replaceAll(RegExp(r'\.\d+'), '');
          field.answerText = iso;
          field.answerDatetime = iso;
        }
      }
    }

    updateForm();
  }

  String? get _token => _hive.getUser()?.token;

  Future<void> fetchVisitorTypes() async {
    final token = _token;
    if (token == null) return;
    isLoadingTypes.value = true;
    try {
      final response = await _api.getVisitorTypes(token);
      if (response.data['status'] == 'success') {
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        visitorTypes.value = collection
            .map((e) => VisitorTypeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('fetchVisitorTypes error: $e');
    } finally {
      isLoadingTypes.value = false;
    }
  }

  Future<void> onSelectVisitorType(String id, String typeName) async {
    selectedVisitorTypeId.value = id;
    selectedVisitorTypeName.value = typeName;
    formStructure.value = null;
    await fetchFormStructure(id);
  }

  Future<void> fetchFormStructure(String id) async {
    final token = _token;
    if (token == null || id.isEmpty) return;
    isLoadingDetail.value = true;
    try {
      final response = await _api.getVisitorTypeById(token, id);
      if (response.data['status'] == 'success') {
        final collection =
            response.data['collection'] as Map<String, dynamic>? ?? {};
        final structure = VisitorTypeDetailModel.fromJson(collection);
        for (var section in structure.sectionPageVisitorTypes) {
          for (var field in section.praForm) {
            if (field.remarks.toLowerCase() == 'is_employee') {
              final noOption = field.multipleOptionFields.firstWhereOrNull(
                (opt) =>
                    opt.name.toLowerCase() == 'no' ||
                    opt.value.toLowerCase() == 'no' ||
                    opt.value == '0' ||
                    opt.value == 'false',
              );
              if (noOption != null) {
                field.answerText = noOption.value;
              } else {
                field.answerText = 'No';
              }
              isEmployee.value = false;
            }
          }
        }
        formStructure.value = structure;
        // Auto-select the visitor role if there is only one available
        if (structure.visitorRoles.length == 1 &&
            selectedVisitorRole.value.isEmpty) {
          selectedVisitorRole.value = structure.visitorRoles.first.role;
          // Also set the answerText on the visitor_role field if present
          for (var section in structure.sectionPageVisitorTypes) {
            for (var field in section.praForm) {
              if (field.remarks.toLowerCase() == 'visitor_role') {
                field.answerText = structure.visitorRoles.first.role;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('fetchFormStructure error: $e');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> fetchVisitors() async {
    final token = _token;
    if (token == null) return;
    isLoadingVisitors.value = true;
    try {
      final response = await _api.getVisitors(token);
      if (response.data['status'] == 'success') {
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        allVisitors.value = collection
            .where((e) => e is Map && (e['name']?.toString() ?? '').isNotEmpty)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      debugPrint('fetchVisitors error: $e');
    } finally {
      isLoadingVisitors.value = false;
    }
  }

  /// Auto-fill single visitor fields from a selected visitor map.
  void autofillSingleFromVisitor(Map<String, dynamic> v) {
    final n = v['name']?.toString() ?? '';
    final e = v['email']?.toString() ?? '';
    final p = v['phone']?.toString() ?? '';
    final o = v['organization']?.toString() ?? '';
    final id = v['identity_id']?.toString() ?? '';

    nameCtrl.text = n;
    emailCtrl.text = e;
    phoneCtrl.text = p;
    organizationCtrl.text = o;
    identityIdCtrl.text = id;

    name.value = n;
    email.value = e;
    phone.value = p;
    organization.value = o;
    identityId.value = id;

    for (var section
        in formStructure.value?.sectionPageVisitorTypes ??
            <SectionPageVisitorType>[]) {
      for (var field in section.praForm) {
        final rem = field.remarks.toLowerCase();
        if (rem == 'name') field.answerText = n;
        if (rem == 'email') field.answerText = e;
        if (rem == 'phone') field.answerText = p;
        if (rem == 'organization' || rem == 'company') field.answerText = o;
        if (rem == 'identity_id' || rem == 'indentity_id')
          field.answerText = id;
      }
    }
    updateForm();
  }

  /// Auto-fill a group visitor row from a selected visitor map.
  void autofillGroupVisitorFromVisitor(
    GroupVisitorRow row,
    Map<String, dynamic> v,
  ) {
    row.fullName.text = v['name']?.toString() ?? '';
    row.email.text = v['email']?.toString() ?? '';
    row.phone.text = v['phone']?.toString() ?? '';
    row.organization.text = v['organization']?.toString() ?? '';
    row.identityId.text = v['identity_id']?.toString() ?? '';
    updateForm();
  }

  Future<void> fetchEmployees() async {
    final token = _token;
    if (token == null) return;
    isLoadingEmployees.value = true;
    try {
      final response = await _api.getEmployees(token);
      if (response.data['status'] == 'success') {
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        _rawEmployees.clear();
        _rawEmployees.addAll(
          collection.map(
            (e) => Map<String, dynamic>.from(jsonDecode(jsonEncode(e)) as Map),
          ),
        );
        employees.value = collection
            .map(
              (e) => DropdownItem(
                id: e['id']?.toString() ?? '',
                name: e['name']?.toString() ?? '',
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('fetchEmployees error: $e');
    } finally {
      isLoadingEmployees.value = false;
    }
  }

  void toggleEmployeeMode(bool value) {
    isEmployee.value = value;
    clearStep1Fields();
  }

  void clearStep1Fields() {
    selectedVisitorTypeId.value = '';
    selectedVisitorTypeName.value = '';
    isGroup.value = null;
    name.value = '';
    email.value = '';
    phone.value = '';
    organization.value = '';
    identityId.value = '';
    isEmployee.value = false;
    selectedEmployeeId.value = '';
    selectedEmployeeName.value = '';
    selectedVisitorRole.value = '';
    nameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    organizationCtrl.clear();
    identityIdCtrl.clear();
    groupVisitors.clear();
    groupName.value = '';
    groupNameCtrl.clear();
    groupCode.value = '';
    for (var section
        in formStructure.value?.sectionPageVisitorTypes ??
            <SectionPageVisitorType>[]) {
      for (var field in section.praForm) {
        field.answerText = '';
        field.answerDatetime = '';
        if (field.remarks.toLowerCase() == 'is_employee')
          field.answerText = 'No';
      }
    }
    clearStep2Fields();
    updateForm();
  }

  void clearVisitorFormInputs() {
    name.value = '';
    email.value = '';
    phone.value = '';
    organization.value = '';
    identityId.value = '';
    isEmployee.value = false;
    selectedEmployeeId.value = '';
    selectedEmployeeName.value = '';
    selectedVisitorRole.value = '';
    nameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    organizationCtrl.clear();
    identityIdCtrl.clear();

    // Clear answerText of form fields in single mode
    for (var section
        in formStructure.value?.sectionPageVisitorTypes ??
            <SectionPageVisitorType>[]) {
      for (var field in section.praForm) {
        final rem = field.remarks.toLowerCase();
        if (rem == 'name' ||
            rem == 'email' ||
            rem == 'phone' ||
            rem == 'organization' ||
            rem == 'indentity_id' ||
            rem == 'identity_id' ||
            rem == 'visitor_role') {
          field.answerText = '';
        }
      }
    }
    updateForm();
  }

  void clearStep2Fields() {
    selectedHostId.value = '';
    selectedSiteId.value = '';
    visitStart.value = null;
    visitEnd.value = null;
    agenda.value = '';
    for (var section
        in formStructure.value?.sectionPageVisitorTypes ??
            <SectionPageVisitorType>[]) {
      for (var field in section.praForm) {
        final rem = field.remarks.toLowerCase();
        if (rem != 'name' &&
            rem != 'email' &&
            rem != 'phone' &&
            rem != 'organization' &&
            rem != 'identity_id' &&
            rem != 'is_employee') {
          field.answerText = '';
          field.answerDatetime = '';
        }
      }
    }
    updateForm();
  }

  void onEmployeeSelected(String employeeId) {
    selectedEmployeeId.value = employeeId;
    final emp = _rawEmployees.firstWhereOrNull(
      (e) => e['id'].toString() == employeeId,
    );
    if (emp != null) {
      selectedEmployeeName.value = emp['name']?.toString() ?? '';

      String empOrg = '';
      final orgData =
          emp['organization'] ??
          emp['Organization'] ??
          emp['organization_name'] ??
          emp['company'] ??
          emp['department'] ??
          emp['office'];
      if (orgData != null) {
        if (orgData is Map) {
          empOrg =
              orgData['name']?.toString() ?? orgData['code']?.toString() ?? '';
        } else {
          empOrg = orgData.toString();
        }
      }

      nameCtrl.text = emp['name']?.toString() ?? '';
      emailCtrl.text = emp['email']?.toString() ?? '';
      phoneCtrl.text = emp['phone']?.toString() ?? '';
      organizationCtrl.text = empOrg;
      identityIdCtrl.text = emp['identity_id']?.toString() ?? '';
      name.value = nameCtrl.text;
      email.value = emailCtrl.text;
      phone.value = phoneCtrl.text;
      organization.value = organizationCtrl.text;
      identityId.value = identityIdCtrl.text;
      for (var section
          in formStructure.value?.sectionPageVisitorTypes ??
              <SectionPageVisitorType>[]) {
        for (var field in section.praForm) {
          final rem = field.remarks.toLowerCase();
          if (rem == 'name') field.answerText = name.value;
          if (rem == 'email') field.answerText = email.value;
          if (rem == 'phone') field.answerText = phone.value;
          if (rem == 'organization' || rem == 'company')
            field.answerText = organization.value;
          if (rem == 'identity_id' || rem == 'indentity_id')
            field.answerText = identityId.value;
        }
      }
      updateForm();
    }
  }

  void onGroupEmployeeSelected(GroupVisitorRow row, String employeeId) {
    row.selectedEmployeeId.value = employeeId;
    final emp = _rawEmployees.firstWhereOrNull(
      (e) => e['id'].toString() == employeeId,
    );
    if (emp != null) {
      row.selectedEmployeeName.value = emp['name']?.toString() ?? '';

      String empOrg = '';
      final orgData =
          emp['organization'] ??
          emp['Organization'] ??
          emp['organization_name'] ??
          emp['company'] ??
          emp['department'] ??
          emp['office'];
      if (orgData != null) {
        if (orgData is Map) {
          empOrg =
              orgData['name']?.toString() ?? orgData['code']?.toString() ?? '';
        } else {
          empOrg = orgData.toString();
        }
      }

      row.fullName.text = emp['name']?.toString() ?? '';
      row.email.text = emp['email']?.toString() ?? '';
      row.phone.text = emp['phone']?.toString() ?? '';
      row.organization.text = empOrg;
      row.identityId.text = emp['identity_id']?.toString() ?? '';
      updateForm();
    }
  }

  Future<void> fetchHosts() async {
    final token = _token;
    if (token == null) return;
    isLoadingHosts.value = true;
    try {
      final response = await _api.getHosts(token);
      if (response.data['status'] == 'success') {
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        hosts.value = collection
            .map(
              (e) => DropdownItem(
                id: e['id']?.toString() ?? '',
                name: e['name']?.toString() ?? '',
              ),
            )
            .toList();

        // If selectedHostId is set to a name instead of UUID, match by name!
        if (selectedHostId.value.isNotEmpty &&
            !selectedHostId.value.contains('-')) {
          final matched = hosts.firstWhereOrNull(
            (h) => h.name.toLowerCase().trim() ==
                selectedHostId.value.toLowerCase().trim(),
          );
          if (matched != null) {
            selectedHostId.value = matched.id;
            
            // Also update the answerText on the host field if formStructure is loaded
            for (var section in formStructure.value?.sectionPageVisitorTypes ?? <SectionPageVisitorType>[]) {
              for (var field in section.praForm) {
                if (field.remarks.toLowerCase() == 'host') {
                  field.answerText = matched.id;
                }
              }
            }
          }
        }
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
        final collection = response.data['collection'] as List<dynamic>? ?? [];
        final filteredCollection = collection.where((e) {
          if (e is Map) {
            final isDropPoint = e['is_drop_point'];
            final name = e['name']?.toString().toLowerCase() ?? '';
            if (isDropPoint == true ||
                isDropPoint.toString() == 'true' ||
                name == 'drop point') {
              return false;
            }
          }
          return true;
        }).toList();
        sites.value = filteredCollection
            .map(
              (e) => DropdownItem(
                id: e['id']?.toString() ?? '',
                name: e['name']?.toString() ?? '',
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('fetchSites error: $e');
    } finally {
      isLoadingSites.value = false;
    }
  }

  bool isStepValid(int step) {
    if (step == 0) {
      bool basic =
          selectedVisitorTypeId.value.isNotEmpty && isGroup.value != null;
      if (isGroup.value == true)
        return basic && groupName.value.trim().isNotEmpty;
      return basic;
    } else if (step == 1) {
      if (isGroup.value == true) {
        if (groupVisitors.isEmpty) return false;
        return groupVisitors.every((v) => v.isValid);
      } else {
        // Check hardcoded primary fields
        final primaryFieldsValid =
            name.value.trim().isNotEmpty &&
            email.value.trim().isNotEmpty &&
            phone.value.trim().isNotEmpty &&
            organization.value.trim().isNotEmpty &&
            identityId.value.trim().isNotEmpty &&
            selectedVisitorRole.value.trim().isNotEmpty;

        if (!primaryFieldsValid) return false;

        // Also check any additional mandatory API form fields
        // (fields not covered by the hardcoded checks above)
        const handledRemarks = {
          'name', 'email', 'phone', 'organization', 'company',
          'identity_id', 'indentity_id', 'visitor_role',
          'is_employee', 'employee_name', 'employee',
          // Step 2 fields — skip them in step 1 validation
          'host', 'site_place', 'agenda',
          'visitor_period_start', 'visitor_period_end',
        };

        for (final section
            in formStructure.value?.sectionPageVisitorTypes ??
                <SectionPageVisitorType>[]) {
          for (final field in section.praForm) {
            if (!field.isEnable) continue;
            if (!field.mandatory) continue;
            final rem = field.remarks.toLowerCase();
            if (handledRemarks.contains(rem)) continue;
            // This is an extra mandatory field — ensure it has an answer
            if (field.answerText.trim().isEmpty) return false;
          }
        }

        return true;
      }
    } else if (step == 2) {
      return selectedHostId.value.isNotEmpty &&
          agenda.value.trim().isNotEmpty &&
          selectedSiteId.value.isNotEmpty &&
          visitStart.value != null &&
          visitEnd.value != null;
    }
    return true;
  }

  void goToStep(int targetStep) {
    if (isGroup.value == true && groupName.value.trim().isEmpty && targetStep > 0) {
      return;
    }
    if (!isDuplicateMode.value) {
      if (targetStep > currentStep.value) {
        for (int i = currentStep.value; i < targetStep; i++) {
          if (!isStepValid(i)) return;
        }
      }
    }
    if (currentStep.value == 0 && targetStep >= 1 && isGroup.value == true) {
      if (groupVisitors.isEmpty) addGroupVisitor();
      if (groupCode.value.isEmpty) groupCode.value = _generateGroupCode();
    }
    currentStep.value = targetStep;
  }

  void nextStep() {
    if (currentStep.value < 2) {
      if (currentStep.value == 0 && isGroup.value == true && groupName.value.trim().isEmpty) {
        return;
      }
      if (!isDuplicateMode.value && !isStepValid(currentStep.value)) return;
      if (currentStep.value == 0 && isGroup.value == true) {
        if (groupVisitors.isEmpty) addGroupVisitor();
        if (groupCode.value.isEmpty) groupCode.value = _generateGroupCode();
      }
      currentStep.value++;
    }
  }

  void prevStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  bool validateCurrentStep() {
    final _ = formUpdateTrigger.value;
    return isStepValid(currentStep.value);
  }

  bool get isStep1Valid => isStepValid(0);
  bool get isStep2Valid => isStepValid(1);
  bool get isStep3Valid =>
      selectedHostId.value.isNotEmpty &&
      agenda.value.trim().isNotEmpty &&
      selectedSiteId.value.isNotEmpty &&
      visitStart.value != null &&
      visitEnd.value != null;

  void updateForm() => formUpdateTrigger.value++;

  String _generateGroupCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void initGroupMode() {
    groupCode.value = _generateGroupCode();
    groupName.value = '';
    groupNameCtrl.clear();
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
    if (groupVisitors.length <= 1) return;
    groupVisitors[index].dispose();
    groupVisitors.removeAt(index);
    updateForm();
  }

  Future<bool> submitForm() async {
    final token = _token;
    if (token == null) {
      _showError('Sesi berakhir. Silakan login kembali.');
      return false;
    }
    final detail = formStructure.value;
    if (detail == null) {
      _showError('Struktur form belum dimuat sempurna.');
      return false;
    }
    isSubmitting.value = true;
    try {
      String deviceTz = 'Asia/Jakarta';
      try {
        // Use UTC offset to derive timezone string (no external package needed)
        final offset = DateTime.now().timeZoneOffset;
        final hours = offset.inHours;
        if (hours == 7) {
          deviceTz = 'Asia/Jakarta';
        } else if (hours == 8) {
          deviceTz = 'Asia/Makassar';
        } else if (hours == 9) {
          deviceTz = 'Asia/Jayapura';
        }
      } catch (e) {
        debugPrint('Timezone error: $e');
      }

      dev.log('[SUBMIT] Starting submission flow...', name: 'PraReg');

      Map<String, dynamic> body;
      final resolvedRole = selectedVisitorRole.value.isNotEmpty
          ? selectedVisitorRole.value
          : 'Visitor';

      // ── Build question_page for Single (used in data_visitor) ──────────
      final questionPage = detail.sectionPageVisitorTypes.map((section) {
        final form = section.praForm.where((f) => f.isEnable).map((f) {
          String answerText = '';
          String answerDatetime = '';
          final isDateTimeField =
              f.fieldType == 4 ||
              f.fieldType == 9 ||
              f.remarks == 'visitor_period_start' ||
              f.remarks == 'visitor_period_end';

          if (f.remarks == 'visitor_period_start' && visitStart.value != null) {
            answerDatetime = visitStart.value!
                .toUtc()
                .toIso8601String()
                .substring(0, 19);
          } else if (f.remarks == 'visitor_period_end' &&
              visitEnd.value != null) {
            answerDatetime = visitEnd.value!
                .toUtc()
                .toIso8601String()
                .substring(0, 19);
          } else if (isDateTimeField) {
            answerDatetime = f.answerDatetime;
          } else {
            answerText = _answerTextForRemarks(f.remarks, f);
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
            'multiple_option_fields': f.multipleOptionFields
                .map((o) => o.toJson())
                .toList(),
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

      if (isGroup.value == true) {
        // ── GROUP MODE ─────────────────────────────────────────────────────
        // The first visitor is the parent transaction payload in list_group
        final parentVisitor = groupVisitors.first;
        final parentRole = parentVisitor.selectedVisitorRole.value.isNotEmpty
            ? parentVisitor.selectedVisitorRole.value
            : 'Visitor';
        
        final parentAnswers = {
          'name': parentVisitor.fullName.text.trim(),
          'email': parentVisitor.email.text.trim(),
          'phone': parentVisitor.phone.text.trim(),
          'organization': parentVisitor.organization.text.trim(),
          'indentity_id': parentVisitor.identityId.text.trim(),
          'is_employee': parentVisitor.isEmployee.value.toString(),
          'employee_name': parentVisitor.isEmployee.value ? parentVisitor.selectedEmployeeId.value : '',
          'employee': parentVisitor.isEmployee.value ? parentVisitor.selectedEmployeeId.value : '',
          'visitor_role': parentRole,
        };

        final parentQp = detail.sectionPageVisitorTypes.map((section) {
          final form = section.praForm.where((f) => f.isEnable).map((f) {
            String answerText = '';
            String answerDatetime = '';
            final isDateTimeField = f.fieldType == 4 ||
                f.fieldType == 9 ||
                f.remarks == 'visitor_period_start' ||
                f.remarks == 'visitor_period_end';

            if (f.remarks == 'visitor_period_start' && visitStart.value != null) {
              answerDatetime = visitStart.value!.toUtc().toIso8601String().substring(0, 19);
            } else if (f.remarks == 'visitor_period_end' && visitEnd.value != null) {
              answerDatetime = visitEnd.value!.toUtc().toIso8601String().substring(0, 19);
            } else if (isDateTimeField) {
              answerDatetime = f.answerDatetime;
            } else {
              answerText = _answerTextForRemarksInGroup(f.remarks, f, parentAnswers);
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
              'multiple_option_fields': f.multipleOptionFields.map((o) => o.toJson()).toList(),
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

        final List<dynamic> dataVisitorList = [
          {'question_page': parentQp}
        ];

        // Append remaining visitors nested inside the parent's data_visitor array
        for (int i = 1; i < groupVisitors.length; i++) {
          final visitor = groupVisitors[i];
          final visitorRole = visitor.selectedVisitorRole.value.isNotEmpty
              ? visitor.selectedVisitorRole.value
              : 'Visitor';
          final visitorAnswers = {
            'name': visitor.fullName.text.trim(),
            'email': visitor.email.text.trim(),
            'phone': visitor.phone.text.trim(),
            'organization': visitor.organization.text.trim(),
            'indentity_id': visitor.identityId.text.trim(),
            'is_employee': visitor.isEmployee.value.toString(),
            'employee_name': visitor.isEmployee.value ? visitor.selectedEmployeeId.value : '',
            'employee': visitor.isEmployee.value ? visitor.selectedEmployeeId.value : '',
            'visitor_role': visitorRole,
          };

          final memberQp = detail.sectionPageVisitorTypes.map((section) {
            final form = section.praForm.where((f) => f.isEnable).map((f) {
              String answerText = '';
              String answerDatetime = '';
              final isDateTimeField = f.fieldType == 4 ||
                  f.fieldType == 9 ||
                  f.remarks == 'visitor_period_start' ||
                  f.remarks == 'visitor_period_end';

              if (f.remarks == 'visitor_period_start' && visitStart.value != null) {
                answerDatetime = visitStart.value!.toUtc().toIso8601String().substring(0, 19);
              } else if (f.remarks == 'visitor_period_end' && visitEnd.value != null) {
                answerDatetime = visitEnd.value!.toUtc().toIso8601String().substring(0, 19);
              } else if (isDateTimeField) {
                answerDatetime = f.answerDatetime;
              } else {
                answerText = _answerTextForRemarksInGroup(f.remarks, f, visitorAnswers);
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
                'multiple_option_fields': f.multipleOptionFields.map((o) => o.toJson()).toList(),
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

          dataVisitorList.add({
            'question_page': memberQp
          });
        }

        final Map<String, dynamic> parentObject = {
          'visitor_type': selectedVisitorTypeId.value,
          'is_group': true,
          'type_registered': 1,
          'tz': deviceTz,
          'flow': 'Praregister',
          'visitor_role': parentRole,
          if (selectedSiteId.value.isNotEmpty) 'registered_site': selectedSiteId.value,
          'group_code': groupCode.value,
          'group_name': groupName.value.trim(),
          'data_visitor': dataVisitorList,
        };

        body = {
          'list_group': [parentObject]
        };
        debugPrint("test: $body");
      } else {
        // ── SINGLE MODE ────────────────────────────────────────────────────
        body = {
          'visitor_type': selectedVisitorTypeId.value,
          'type_registered': 0,
          'is_group': false,
          'tz': deviceTz,
          'flow': 'Praregister',
          'visitor_role': resolvedRole,
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

      // Guard: server may return a raw String on internal errors instead of JSON
      final rawData = response.data;
      if (rawData is! Map) {
        debugPrint('Unexpected response type: ${rawData.runtimeType}');
        _showError('Server error. Silakan coba beberapa saat lagi.');
        return false;
      }

      final data = rawData;
      final status = data['status']?.toString() ?? '';
      final collectionMap = data['collection'] is Map
          ? data['collection'] as Map
          : null;
      final transactionStatus =
          collectionMap?['transaction_status']?.toString() ?? '';

      if (status == 'success' || transactionStatus == 'UnderCreated') {
        final msg = data['msg']?.toString() ?? 'Registrasi berhasil!';
        Get.snackbar(
          'Sukses',
          msg,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // Auto Refresh Invitation List if available
        if (Get.isRegistered<InvitationController>()) {
          final invCtrl = Get.find<InvitationController>();
          invCtrl.fetchOngoingInvitations(isSilent: true);
          invCtrl.triggerActivityRefresh();
        }

        return true;
      } else {
        final msg = data['msg']?.toString() ?? 'Terjadi kesalahan.';
        _showError(msg);
        return false;
      }
    } catch (e) {
      debugPrint('submitForm error: $e');
      _showError('Gagal mengirim pendaftaran.');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  String _answerTextForRemarks(String remarks, VisitFormField field) {
    switch (remarks.toLowerCase()) {
      case 'visitor_role':
        return selectedVisitorRole.value.isNotEmpty
            ? selectedVisitorRole.value
            : field.answerText;
      case 'name':
        return name.value;
      case 'email':
        return email.value;
      case 'phone':
        return phone.value;
      case 'organization':
      case 'company':
        return organization.value;
      case 'identity_id':
      case 'indentity_id':
        return identityId.value;
      case 'is_employee':
        final target = isEmployee.value ? 'yes' : 'no';
        final opt = field.multipleOptionFields.firstWhereOrNull(
          (o) =>
              o.name.toLowerCase() == target || o.value.toLowerCase() == target,
        );
        return opt?.value ?? (isEmployee.value ? 'Yes' : 'No');
      case 'employee_name':
      case 'employee':
        return selectedEmployeeId.value;
      case 'agenda':
        return agenda.value;
      default:
        return field.answerText;
    }
  }

  String _answerTextForRemarksInGroup(
    String remarks,
    VisitFormField field,
    Map<String, String> answers,
  ) {
    switch (remarks.toLowerCase()) {
      case 'visitor_role':
        return answers['visitor_role'] ?? '';
      case 'name':
        return answers['name'] ?? '';
      case 'email':
        return answers['email'] ?? '';
      case 'phone':
        return answers['phone'] ?? '';
      case 'organization':
      case 'company':
        return answers['organization'] ?? '';
      case 'identity_id':
      case 'indentity_id':
        return answers['indentity_id'] ?? '';
      case 'is_employee':
        final isEmp = answers['is_employee'] == 'true';
        final target = isEmp ? 'yes' : 'no';
        final opt = field.multipleOptionFields.firstWhereOrNull(
          (o) =>
              o.name.toLowerCase() == target || o.value.toLowerCase() == target,
        );
        return opt?.value ?? (isEmp ? 'Yes' : 'No');
      case 'employee_name':
      case 'employee':
        return answers['employee'] ?? '';
      case 'agenda':
        return agenda.value;
      default:
        return field.answerText;
    }
  }

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
