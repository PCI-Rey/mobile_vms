import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/datasources/hive_service.dart';
import '../../../../data/models/visitor_type_model.dart';
import '../../../../data/models/visitor_type_detail_model.dart';
import '../../invitation/controller/invitation_controller.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

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

  final RxList<VisitorTypeModel> visitorTypes = <VisitorTypeModel>[].obs;
  final RxBool isLoadingTypes = false.obs;

  final RxString selectedVisitorTypeId = ''.obs;
  final RxString selectedVisitorTypeName = ''.obs;
  final Rx<VisitorTypeDetailModel?> formStructure = Rx<VisitorTypeDetailModel?>(null);
  final RxBool isLoadingDetail = false.obs;

  final Rx<bool?> isGroup = Rx<bool?>(null);

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
      case 'name': return nameCtrl;
      case 'email': return emailCtrl;
      case 'phone': return phoneCtrl;
      case 'organization': return organizationCtrl;
      case 'indentity_id': return identityIdCtrl;
      default: return null;
    }
  }

  final RxList<DropdownItem> employees = <DropdownItem>[].obs;
  final List<Map<String, dynamic>> _rawEmployees = <Map<String, dynamic>>[]; 
  final RxString selectedEmployeeId = ''.obs;
  final RxString selectedEmployeeName = ''.obs;
  final RxBool isLoadingEmployees = false.obs;

  final RxList<DropdownItem> hosts = <DropdownItem>[].obs;
  final RxString selectedHostId = ''.obs;
  final RxBool isLoadingHosts = false.obs;
  final RxString agenda = ''.obs;
  final RxList<DropdownItem> sites = <DropdownItem>[].obs;
  final RxString selectedSiteId = ''.obs;
  final RxBool isLoadingSites = false.obs;
  final Rx<DateTime?> visitStart = Rx<DateTime?>(null);
  final Rx<DateTime?> visitEnd = Rx<DateTime?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxInt currentStep = 0.obs;

  final RxString groupCode = ''.obs;
  final RxString groupName = ''.obs;
  final RxList<GroupVisitorRow> groupVisitors = <GroupVisitorRow>[].obs;

  final RxInt formUpdateTrigger = 0.obs;

  @override
  void onInit() {
    super.onInit();
    resetFields();
    fetchVisitorTypes();
    fetchEmployees();
    fetchHosts();
    fetchSites();
  }

  @override
  void onClose() {
    resetFields();
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    organizationCtrl.dispose();
    identityIdCtrl.dispose();
    super.onClose();
  }

  void resetFields() {
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
    nameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    organizationCtrl.clear();
    identityIdCtrl.clear();
    groupVisitors.clear();
    selectedHostId.value = '';
    selectedSiteId.value = '';
    visitStart.value = null;
    visitEnd.value = null;
    agenda.value = '';
    currentStep.value = 0;
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
        final collection = response.data['collection'] as Map<String, dynamic>? ?? {};
        final structure = VisitorTypeDetailModel.fromJson(collection);
        for (var section in structure.sectionPageVisitorTypes) {
          for (var field in section.praForm) {
            if (field.remarks.toLowerCase() == 'is_employee') {
              final noOption = field.multipleOptionFields.firstWhereOrNull(
                (opt) => opt.name.toLowerCase() == 'no' || 
                         opt.value.toLowerCase() == 'no' || 
                         opt.value == '0' || 
                         opt.value == 'false'
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
      }
    } catch (e) {
      debugPrint('fetchFormStructure error: $e');
    } finally {
      isLoadingDetail.value = false;
    }
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
        _rawEmployees.addAll(collection.map((e) => Map<String, dynamic>.from(jsonDecode(jsonEncode(e)) as Map)));
        employees.value = collection
            .map((e) => DropdownItem(id: e['id']?.toString() ?? '', name: e['name']?.toString() ?? ''))
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
    nameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    organizationCtrl.clear();
    identityIdCtrl.clear();
    groupVisitors.clear();
    groupName.value = '';
    groupCode.value = '';
    for (var section in formStructure.value?.sectionPageVisitorTypes ?? <SectionPageVisitorType>[]) {
      for (var field in section.praForm) {
        field.answerText = '';
        field.answerDatetime = '';
        if (field.remarks.toLowerCase() == 'is_employee') field.answerText = 'No';
      }
    }
    clearStep2Fields();
    updateForm();
  }

  void clearStep2Fields() {
    selectedHostId.value = '';
    selectedSiteId.value = '';
    visitStart.value = null;
    visitEnd.value = null;
    agenda.value = '';
    for (var section in formStructure.value?.sectionPageVisitorTypes ?? <SectionPageVisitorType>[]) {
      for (var field in section.praForm) {
        final rem = field.remarks.toLowerCase();
        if (rem != 'name' && rem != 'email' && rem != 'phone' && rem != 'organization' && rem != 'identity_id' && rem != 'is_employee') {
          field.answerText = '';
          field.answerDatetime = '';
        }
      }
    }
    updateForm();
  }

  void onEmployeeSelected(String employeeId) {
    selectedEmployeeId.value = employeeId;
    final emp = _rawEmployees.firstWhereOrNull((e) => e['id'].toString() == employeeId);
    if (emp != null) {
      selectedEmployeeName.value = emp['name']?.toString() ?? '';
      
      String empOrg = '';
      final orgData = emp['organization'] ?? emp['Organization'] ?? emp['organization_name'] ?? emp['company'] ?? emp['department'] ?? emp['office'];
      if (orgData != null) {
        if (orgData is Map) {
          empOrg = orgData['name']?.toString() ?? orgData['code']?.toString() ?? '';
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
      for (var section in formStructure.value?.sectionPageVisitorTypes ?? <SectionPageVisitorType>[]) {
        for (var field in section.praForm) {
          final rem = field.remarks.toLowerCase();
          if (rem == 'name') field.answerText = name.value;
          if (rem == 'email') field.answerText = email.value;
          if (rem == 'phone') field.answerText = phone.value;
          if (rem == 'organization' || rem == 'company') field.answerText = organization.value;
          if (rem == 'identity_id' || rem == 'indentity_id') field.answerText = identityId.value;
        }
      }
      updateForm();
    }
  }

  void onGroupEmployeeSelected(GroupVisitorRow row, String employeeId) {
    row.selectedEmployeeId.value = employeeId;
    final emp = _rawEmployees.firstWhereOrNull((e) => e['id'].toString() == employeeId);
    if (emp != null) {
      row.selectedEmployeeName.value = emp['name']?.toString() ?? '';
      
      String empOrg = '';
      final orgData = emp['organization'] ?? emp['Organization'] ?? emp['organization_name'] ?? emp['company'] ?? emp['department'] ?? emp['office'];
      if (orgData != null) {
        if (orgData is Map) {
          empOrg = orgData['name']?.toString() ?? orgData['code']?.toString() ?? '';
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
        hosts.value = collection.map((e) => DropdownItem(id: e['id']?.toString() ?? '', name: e['name']?.toString() ?? '')).toList();
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
        sites.value = collection.map((e) => DropdownItem(id: e['id']?.toString() ?? '', name: e['name']?.toString() ?? '')).toList();
      }
    } catch (e) {
      debugPrint('fetchSites error: $e');
    } finally {
      isLoadingSites.value = false;
    }
  }

  bool isStepValid(int step) {
    if (step == 0) {
      bool basic = selectedVisitorTypeId.value.isNotEmpty && isGroup.value != null;
      if (isGroup.value == true) return basic && groupName.value.trim().isNotEmpty;
      return basic;
    } else if (step == 1) {
      if (isGroup.value == true) {
        if (groupVisitors.isEmpty) return false;
        return groupVisitors.every((v) => v.isValid);
      } else {
        return name.value.trim().isNotEmpty && email.value.trim().isNotEmpty && phone.value.trim().isNotEmpty && organization.value.trim().isNotEmpty && identityId.value.trim().isNotEmpty;
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
    if (targetStep > currentStep.value) {
      for (int i = currentStep.value; i < targetStep; i++) {
        if (!isStepValid(i)) return;
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
      if (!isStepValid(currentStep.value)) return;
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
  bool get isStep3Valid => selectedHostId.value.isNotEmpty && agenda.value.trim().isNotEmpty && selectedSiteId.value.isNotEmpty && visitStart.value != null && visitEnd.value != null;

  void updateForm() => formUpdateTrigger.value++;

  String _generateGroupCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void initGroupMode() {
    groupCode.value = _generateGroupCode();
    groupName.value = '';
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
        final tzInfo = await FlutterTimezone.getLocalTimezone();
        deviceTz = tzInfo.identifier;
      } catch (e) {
        debugPrint('Timezone error: $e');
      }

      dev.log('[SUBMIT] Starting submission flow...', name: 'PraReg');

      Map<String, dynamic> body;
      const resolvedRole = 'Visitor';

      // ── Build question_page for Single (used in data_visitor) ──────────
      final questionPage = detail.sectionPageVisitorTypes.map((section) {
        final form = section.praForm.where((f) => f.isEnable).map((f) {
          String answerText = '';
          String answerDatetime = '';
          final isDateTimeField = f.fieldType == 4 ||
              f.fieldType == 9 ||
              f.remarks == 'visitor_period_start' ||
              f.remarks == 'visitor_period_end';

          if (f.remarks == 'visitor_period_start' && visitStart.value != null) {
            answerDatetime =
                visitStart.value!.toUtc().toIso8601String().substring(0, 19);
          } else if (f.remarks == 'visitor_period_end' &&
              visitEnd.value != null) {
            answerDatetime =
                visitEnd.value!.toUtc().toIso8601String().substring(0, 19);
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

      if (isGroup.value == true) {
        // ── GROUP MODE ─────────────────────────────────────────────────────
        // Map each visitor to their own entry in list_group to ensure server processes all of them
        final List<Map<String, dynamic>> listGroup = groupVisitors.map((visitor) {
          final visitorAnswers = {
            'name': visitor.fullName.text.trim(),
            'email': visitor.email.text.trim(),
            'phone': visitor.phone.text.trim(),
            'organization': visitor.organization.text.trim(),
            'indentity_id': visitor.identityId.text.trim(),
            'is_employee': visitor.isEmployee.value.toString(),
            'employee_name': visitor.isEmployee.value ? visitor.selectedEmployeeId.value : '',
            'employee': visitor.isEmployee.value ? visitor.selectedEmployeeId.value : '',
          };

          final qp = detail.sectionPageVisitorTypes.map((section) {
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

          return {
            'visitor_type': selectedVisitorTypeId.value,
            'is_group': true,
            'type_registered': 1,
            'tz': deviceTz,
            'flow': 'Praregister',
            if (selectedSiteId.value.isNotEmpty) 'registered_site': selectedSiteId.value,
            'group_code': groupCode.value,
            'group_name': groupName.value.trim(),
            'data_visitor': [
              {'question_page': qp}
            ],
          };
        }).toList();

        body = {'list_group': listGroup};
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
      final collectionMap =
          data['collection'] is Map ? data['collection'] as Map : null;
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
          Get.find<InvitationController>().fetchOngoingInvitations(isSilent: true);
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
      case 'name': return name.value;
      case 'email': return email.value;
      case 'phone': return phone.value;
      case 'organization':
      case 'company': return organization.value;
      case 'identity_id':
      case 'indentity_id': return identityId.value;
      case 'is_employee':
        final target = isEmployee.value ? 'yes' : 'no';
        final opt = field.multipleOptionFields.firstWhereOrNull(
          (o) => o.name.toLowerCase() == target || o.value.toLowerCase() == target
        );
        return opt?.value ?? (isEmployee.value ? 'Yes' : 'No');
      case 'employee_name':
      case 'employee': return selectedEmployeeId.value;
      case 'agenda': return agenda.value;
      default: return field.answerText;
    }
  }

  String _answerTextForRemarksInGroup(String remarks, VisitFormField field, Map<String, String> answers) {
    switch (remarks.toLowerCase()) {
      case 'name': return answers['name'] ?? '';
      case 'email': return answers['email'] ?? '';
      case 'phone': return answers['phone'] ?? '';
      case 'organization':
      case 'company': return answers['organization'] ?? '';
      case 'identity_id':
      case 'indentity_id': return answers['indentity_id'] ?? '';
      case 'is_employee':
        final isEmp = answers['is_employee'] == 'true';
        final target = isEmp ? 'yes' : 'no';
        final opt = field.multipleOptionFields.firstWhereOrNull(
          (o) => o.name.toLowerCase() == target || o.value.toLowerCase() == target
        );
        return opt?.value ?? (isEmp ? 'Yes' : 'No');
      case 'employee_name':
      case 'employee': return answers['employee'] ?? '';
      case 'agenda': return agenda.value;
      default: return field.answerText;
    }
  }

  void _showError(String msg) {
    Get.snackbar('Error', msg, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
  }
}
