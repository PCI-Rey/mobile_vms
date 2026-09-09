// ignore_for_file: unused_import, unused_local_variable, unused_element, use_build_context_synchronously, sized_box_for_whitespace, unnecessary_underscores, unnecessary_import, unnecessary_null_comparison, curly_braces_in_flow_control_structures, unused_element_parameter, deprecated_member_use
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/datasources/hive_service.dart';
import '../../../../data/models/visitor_type_model.dart';
import '../../../../data/models/visitor_type_detail_model.dart';
import '../../../../data/models/access_pass_model.dart';
import '../../invitation/controller/invitation_controller.dart';
import '../../../auth/controller/user_controller.dart';

// ─── Simple model for dropdown items (Employee, Host, Site) ──────────────────

class DropdownItem {
  final String id;
  final String name;
  DropdownItem({required this.id, required this.name});
}

/// Uploaded file model for Selfie and KTP
class UploadedFileData {
  final String name;
  final int sizeBytes;
  final String extension;
  final String? localPath;
  final Uint8List? bytes;

  UploadedFileData({
    required this.name,
    required this.sizeBytes,
    required this.extension,
    this.localPath,
    this.bytes,
  });

  String get sizeFormatted {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Group mode visitor entry model matching dekstop_tablet_vms Walk In
class GroupWalkInVisitorEntry {
  final String id = UniqueKey().toString();
  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController orgCtrl = TextEditingController();
  final TextEditingController identityCtrl = TextEditingController();
  final Map<String, TextEditingController> extraControllers = {};

  final RxBool isSearchOpen = false.obs;
  Map<String, dynamic>? selectedData;
  final RxString role = ''.obs;
  final RxBool isEmployee = false.obs;

  // Vehicle data
  final RxBool isDriving = false.obs;
  final RxString vehicleType = ''.obs;
  final TextEditingController vehiclePlateCtrl = TextEditingController();

  // Documents (Selfie & KTP)
  final Rx<UploadedFileData?> selfieImage = Rx<UploadedFileData?>(null);
  final Rx<UploadedFileData?> ktpImage = Rx<UploadedFileData?>(null);

  void dispose() {
    searchCtrl.dispose();
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    orgCtrl.dispose();
    identityCtrl.dispose();
    vehiclePlateCtrl.dispose();
    for (final c in extraControllers.values) {
      c.dispose();
    }
  }

  bool get isValid =>
      fullNameCtrl.text.trim().isNotEmpty &&
      emailCtrl.text.trim().isNotEmpty &&
      emailCtrl.text.contains('@') &&
      phoneCtrl.text.trim().isNotEmpty &&
      orgCtrl.text.trim().isNotEmpty &&
      identityCtrl.text.trim().isNotEmpty;
}

// ─── Controller ───────────────────────────────────────────────────────────────

class PraRegistrationController extends GetxController {
  final _api = ApiService();
  final _hive = HiveService();

  // ── Step Navigation ────────────────────────────────────────────────────────
  // 1: User Type (Visitor Type & Status Single/Group)
  // 2: Visitor Information
  // 3: Purpose Visit
  // 4: Vehicle/Parking Information (Dynamic)
  // 5: Selfie Image (Dynamic)
  // 6: Upload Identity (KTP) (Dynamic)
  final RxInt currentStep = 1.obs;
  final RxInt maxStepReached = 1.obs;
  final RxBool isSubmitting = false.obs;
  final RxInt formUpdateTrigger = 0.obs;

  // ── Step 1: User Type ─────────────────────────────────────────────────────
  final RxList<VisitorTypeModel> visitorTypes = <VisitorTypeModel>[].obs;
  final RxBool isLoadingTypes = false.obs;
  final RxString selectedVisitorTypeId = ''.obs;
  final RxString selectedVisitorTypeName = ''.obs;
  final Rx<VisitorTypeDetailModel?> formStructure = Rx<VisitorTypeDetailModel?>(null);
  final Rx<Map<String, dynamic>?> visitorTypeRawDetail = Rx<Map<String, dynamic>?>(null);
  final RxBool isLoadingDetail = false.obs;

  final Rx<bool?> isGroup = Rx<bool?>(null); // false = Single, true = Group
  final RxString groupCode = ''.obs;
  final RxString groupName = ''.obs;
  final groupNameCtrl = TextEditingController();

  // ── Step 2: Single Mode ───────────────────────────────────────────────────
  final singleSearchCtrl = TextEditingController();
  final RxBool singleIsSearchOpen = false.obs;
  final Rx<Map<String, dynamic>?> singleSelectedData = Rx<Map<String, dynamic>?>(null);

  final Rx<bool?> isEmployee = Rx<bool?>(false);
  final RxString selectedEmployeeId = ''.obs;
  final RxString selectedEmployeeName = ''.obs;
  final RxString selectedVisitorRole = ''.obs;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final organizationCtrl = TextEditingController();
  final identityIdCtrl = TextEditingController();
  final Map<String, TextEditingController> singleExtraControllers = {};

  // ── Step 2: Group Mode ────────────────────────────────────────────────────
  final RxList<GroupWalkInVisitorEntry> groupVisitors = <GroupWalkInVisitorEntry>[].obs;
  final RxInt selectedGroupMemberIndex = 0.obs;

  // ── Step 3: Purpose Visit ─────────────────────────────────────────────────
  final RxList<DropdownItem> sites = <DropdownItem>[].obs;
  final RxString selectedSiteId = ''.obs;
  final RxString selectedSiteName = ''.obs;
  final RxBool isLoadingSites = false.obs;

  final RxList<DropdownItem> hosts = <DropdownItem>[].obs;
  final RxString selectedHostId = ''.obs;
  final RxString selectedHostName = ''.obs;
  final RxBool isLoadingHosts = false.obs;

  final List<String> agendaOptions = [
    'Meeting',
    'Presentation',
    'Visit',
    'Training',
    'Report',
    'Others',
  ];
  final RxString selectedAgenda = 'Meeting'.obs;
  final otherAgendaCtrl = TextEditingController();
  final Map<String, TextEditingController> purposeExtraControllers = {};

  final Rx<DateTime?> visitStart = Rx<DateTime?>(null);
  final Rx<DateTime?> visitEnd = Rx<DateTime?>(null);

  // ── Step 4: Vehicle Information (Dynamic) ─────────────────────────────────
  final RxBool isDriving = false.obs;
  final RxString vehicleType = ''.obs;
  final vehiclePlateCtrl = TextEditingController();

  // ── Step 5 & 6: Documents (Dynamic) ───────────────────────────────────────
  final Rx<UploadedFileData?> selfieImage = Rx<UploadedFileData?>(null);
  final Rx<UploadedFileData?> ktpImage = Rx<UploadedFileData?>(null);

  // ── Dependencies Data ─────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _rawEmployees = <Map<String, dynamic>>[];
  final RxList<DropdownItem> employees = <DropdownItem>[].obs;
  final RxBool isLoadingEmployees = false.obs;
  final RxString employeeSearchQuery = ''.obs;

  final RxList<Map<String, dynamic>> allVisitors = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingVisitors = false.obs;
  final RxString visitorSearchQuery = ''.obs;

  final RxBool isDuplicateMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    resetFields();
    fetchVisitorTypes();
    fetchVisitors();
    fetchEmployees();
    fetchHosts();
    fetchSites();
  }

  @override
  void onClose() {
    groupNameCtrl.dispose();
    singleSearchCtrl.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    organizationCtrl.dispose();
    identityIdCtrl.dispose();
    for (final c in singleExtraControllers.values) {
      c.dispose();
    }
    for (final v in groupVisitors) {
      v.dispose();
    }
    otherAgendaCtrl.dispose();
    for (final c in purposeExtraControllers.values) {
      c.dispose();
    }
    vehiclePlateCtrl.dispose();
    super.onClose();
  }

  String? get _token {
    final hiveToken = _hive.getUser()?.token;
    if (hiveToken != null && hiveToken.isNotEmpty) return hiveToken;
    if (Get.isRegistered<UserController>()) {
      final userCtrlToken = UserController.to.user.value?.token;
      if (userCtrlToken != null && userCtrlToken.isNotEmpty) return userCtrlToken;
    }
    return null;
  }

  String _generateGroupCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void resetFields() {
    currentStep.value = 1;
    maxStepReached.value = 1;

    selectedVisitorTypeId.value = '';
    selectedVisitorTypeName.value = '';
    visitorTypeRawDetail.value = null;
    formStructure.value = null;

    isGroup.value = null;
    groupCode.value = _generateGroupCode();
    groupName.value = '';
    groupNameCtrl.clear();

    singleSearchCtrl.clear();
    singleIsSearchOpen.value = false;
    singleSelectedData.value = null;

    isEmployee.value = false;
    selectedEmployeeId.value = '';
    selectedEmployeeName.value = '';
    selectedVisitorRole.value = '';

    nameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    organizationCtrl.clear();
    identityIdCtrl.clear();
    for (final c in singleExtraControllers.values) {
      c.clear();
    }

    for (final v in groupVisitors) {
      v.dispose();
    }
    groupVisitors.clear();
    final firstEntry = GroupWalkInVisitorEntry();
    groupVisitors.add(firstEntry);
    selectedGroupMemberIndex.value = 0;

    selectedSiteId.value = '';
    selectedSiteName.value = '';
    selectedHostId.value = '';
    selectedHostName.value = '';
    selectedAgenda.value = 'Meeting';
    otherAgendaCtrl.clear();
    for (final c in purposeExtraControllers.values) {
      c.clear();
    }
    visitStart.value = null;
    visitEnd.value = null;

    isDriving.value = false;
    vehicleType.value = '';
    vehiclePlateCtrl.clear();

    selfieImage.value = null;
    ktpImage.value = null;
    isDuplicateMode.value = false;
  }

  void updateForm() {
    formUpdateTrigger.value++;
  }

  bool get hasUserTypeAndStatusSelected =>
      selectedVisitorTypeId.value.isNotEmpty && isGroup.value != null;

  // ── Dynamic Step List Generation (Exact match to dekstop_tablet_vms) ──────
  List<String> get dynamicStepTitles {
    // If on Step 1 and Visitor Type / Status is not selected yet, only show Step 1
    if (currentStep.value == 1 && !hasUserTypeAndStatusSelected) {
      return ['User Type'];
    }

    final titles = ['User Type', 'Visitor Information', 'Purpose Visit'];
    final sections = visitorTypeRawDetail.value?['section_page_visitor_types'] as List<dynamic>?;

    if (sections != null && sections.isNotEmpty) {
      bool hasVehicle = false;
      bool hasSelfie = false;
      bool hasKtp = false;

      for (var s in sections) {
        if (s is! Map) continue;
        final sec = Map<String, dynamic>.from(s);
        final name = (sec['name'] ?? '').toString().toLowerCase();
        final isDoc = sec['is_document'] == true;

        if (name.contains('vehicle') ||
            name.contains('parking') ||
            sec['sort'] == 2) {
          hasVehicle = true;
        } else if (isDoc && (name.contains('selfie') || sec['sort'] == 3)) {
          hasSelfie = true;
        } else if (isDoc &&
            (name.contains('ktp') ||
                name.contains('identity') ||
                sec['sort'] == 4)) {
          hasKtp = true;
        }
      }

      if (hasVehicle) titles.add('Vehicle/Parking Information');
      if (hasSelfie) titles.add('Selfie Image');
      if (hasKtp) titles.add('Upload Identity (KTP)');
    }

    return titles;
  }

  int get maxSteps => dynamicStepTitles.length;

  bool get hasVehicleStep => dynamicStepTitles.contains('Vehicle/Parking Information');
  bool get hasSelfieStep => dynamicStepTitles.contains('Selfie Image');
  bool get hasKtpStep => dynamicStepTitles.contains('Upload Identity (KTP)');

  int get vehicleStepIndex => dynamicStepTitles.indexOf('Vehicle/Parking Information') + 1;
  int get selfieStepIndex => dynamicStepTitles.indexOf('Selfie Image') + 1;
  int get ktpStepIndex => dynamicStepTitles.indexOf('Upload Identity (KTP)') + 1;

  // ── Roles & Options Helpers ───────────────────────────────────────────────
  List<String> getRolesForSelectedType() {
    final rolesRaw = (visitorTypeRawDetail.value?['visitor_roles']) as List<dynamic>?;
    if (rolesRaw != null && rolesRaw.isNotEmpty) {
      final roles = rolesRaw
          .map((r) => (r['role'] ?? '').toString())
          .where((r) => r.isNotEmpty)
          .toSet()
          .toList();
      if (roles.isNotEmpty) return roles;
    }
    return [];
  }

  String getDefaultVisitorRole() {
    final roles = getRolesForSelectedType();
    if (roles.isNotEmpty) return roles.first;
    return 'Visitor';
  }

  List<String> getVehicleTypeOptions() {
    final sectionsRaw = visitorTypeRawDetail.value?['section_page_visitor_types'] as List<dynamic>?;
    if (sectionsRaw != null && sectionsRaw.isNotEmpty) {
      for (final s in sectionsRaw) {
        if (s is! Map) continue;
        final sec = Map<String, dynamic>.from(s);
        final forms = [
          ...((sec['visit_form'] as List<dynamic>?) ?? []),
          ...((sec['pra_form'] as List<dynamic>?) ?? []),
        ];
        for (final f in forms) {
          if (f is! Map) continue;
          final field = Map<String, dynamic>.from(f);
          final remarks = (field['remarks'] ?? '').toString().toLowerCase().trim();
          if (remarks == 'vehicle_type') {
            final multipleOptions = field['multiple_option_fields'] as List<dynamic>?;
            if (multipleOptions != null && multipleOptions.isNotEmpty) {
              return multipleOptions
                  .map((opt) => (opt['value'] ?? opt['name'] ?? '').toString())
                  .where((v) => v.isNotEmpty)
                  .toList();
            }
          }
        }
      }
    }
    return ['Car', 'Motorcycle', 'Bicycle', 'Truck', 'Bus'];
  }

  bool isBicycle(String? type) {
    if (type == null) return false;
    final t = type.toLowerCase().trim();
    return t == 'bicycle' || t == 'sepeda' || t.contains('bicycle') || t.contains('sepeda') || t == 'bike';
  }

  // ── Autofill helpers for Search Visitor / Employee ────────────────────────
  String _extractOrganizationName(dynamic rawOrg, [dynamic rawCompany]) {
    if (rawOrg is Map) {
      final name = rawOrg['name'] ?? rawOrg['code'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString().trim();
      }
    } else if (rawOrg is String && rawOrg.trim().isNotEmpty) {
      if (rawOrg.startsWith('{') && rawOrg.contains('name:')) {
        final match = RegExp(r'name:\s*([^,}]+)').firstMatch(rawOrg);
        if (match != null) return match.group(1)?.trim() ?? rawOrg.trim();
      }
      return rawOrg.trim();
    }

    if (rawCompany is Map) {
      final name = rawCompany['name'] ?? rawCompany['code'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString().trim();
      }
    } else if (rawCompany is String && rawCompany.trim().isNotEmpty) {
      return rawCompany.trim();
    }

    return '';
  }

  void onSingleSelect(Map<String, dynamic> item) {
    singleSelectedData.value = item;
    singleIsSearchOpen.value = false;
    final fullName = (item['name'] ?? item['visitor_name'] ?? '').toString();
    singleSearchCtrl.text = fullName;
    nameCtrl.text = fullName;
    emailCtrl.text = (item['email'] ?? '').toString();
    phoneCtrl.text = (item['phone'] ?? '').toString();
    organizationCtrl.text = _extractOrganizationName(
      item['Organization'] ?? item['organization'],
      item['company'],
    );
    identityIdCtrl.text = (item['identity_id'] ?? item['indentity_id'] ?? '').toString();
    updateForm();
  }

  void clearSingle() {
    singleSelectedData.value = null;
    singleSearchCtrl.clear();
    nameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    organizationCtrl.clear();
    identityIdCtrl.clear();
    for (final c in singleExtraControllers.values) {
      c.clear();
    }
    updateForm();
  }

  void onGroupSelect(int index, Map<String, dynamic> item) {
    if (index >= groupVisitors.length) return;
    final v = groupVisitors[index];
    v.selectedData = item;
    v.isSearchOpen.value = false;
    final fullName = (item['name'] ?? item['visitor_name'] ?? '').toString();
    v.searchCtrl.text = fullName;
    v.fullNameCtrl.text = fullName;
    v.emailCtrl.text = (item['email'] ?? '').toString();
    v.phoneCtrl.text = (item['phone'] ?? '').toString();
    v.orgCtrl.text = _extractOrganizationName(
      item['Organization'] ?? item['organization'],
      item['company'],
    );
    v.identityCtrl.text = (item['identity_id'] ?? item['indentity_id'] ?? '').toString();
    updateForm();
  }

  void clearGroup(int index) {
    if (index >= groupVisitors.length) return;
    final v = groupVisitors[index];
    v.selectedData = null;
    v.searchCtrl.clear();
    v.fullNameCtrl.clear();
    v.emailCtrl.clear();
    v.phoneCtrl.clear();
    v.orgCtrl.clear();
    v.identityCtrl.clear();
    for (final c in v.extraControllers.values) {
      c.clear();
    }
    updateForm();
  }

  void addGroupVisitor() {
    final entry = GroupWalkInVisitorEntry();
    final defaultRole = getDefaultVisitorRole();
    entry.role.value = defaultRole;
    groupVisitors.add(entry);
    selectedGroupMemberIndex.value = groupVisitors.length - 1;
    updateForm();
  }

  void removeGroupVisitor(int index) {
    if (groupVisitors.length <= 1) return;
    final entry = groupVisitors.removeAt(index);
    entry.dispose();
    if (selectedGroupMemberIndex.value >= groupVisitors.length) {
      selectedGroupMemberIndex.value = groupVisitors.length - 1;
    }
    updateForm();
  }

  // ── Image Picking (Selfie & KTP) ──────────────────────────────────────────
  Future<void> pickImage({
    required bool isKtp,
    required bool fromCamera,
    int? groupIndex,
  }) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final size = bytes.length;
      if (size > 5 * 1024 * 1024) {
        _showError('Ukuran file melebihi 5 MB');
        return;
      }
      final ext = file.name.split('.').last.toLowerCase();
      final uploadData = UploadedFileData(
        name: file.name,
        sizeBytes: size,
        extension: ext,
        localPath: file.path,
        bytes: bytes,
      );

      if (groupIndex != null && groupIndex < groupVisitors.length) {
        if (isKtp) {
          groupVisitors[groupIndex].ktpImage.value = uploadData;
        } else {
          groupVisitors[groupIndex].selfieImage.value = uploadData;
        }
      } else {
        if (isKtp) {
          ktpImage.value = uploadData;
        } else {
          selfieImage.value = uploadData;
        }
      }
      updateForm();
    } catch (e) {
      debugPrint('pickImage error: $e');
      _showError('Gagal memilih gambar.');
    }
  }

  void removeImage({required bool isKtp, int? groupIndex}) {
    if (groupIndex != null && groupIndex < groupVisitors.length) {
      if (isKtp) {
        groupVisitors[groupIndex].ktpImage.value = null;
      } else {
        groupVisitors[groupIndex].selfieImage.value = null;
      }
    } else {
      if (isKtp) {
        ktpImage.value = null;
      } else {
        selfieImage.value = null;
      }
    }
    updateForm();
  }

  // ── Step Validation Checkers ──────────────────────────────────────────────
  bool get isStep1Valid {
    if (selectedVisitorTypeId.value.isEmpty || isGroup.value == null) return false;
    if (isGroup.value == true) {
      return groupName.value.trim().isNotEmpty && groupVisitors.isNotEmpty;
    }
    return true;
  }

  bool get isStep2Valid {
    if (isGroup.value == true) {
      if (groupVisitors.isEmpty) return false;
      for (final v in groupVisitors) {
        if (!v.isValid) return false;
      }
      return true;
    } else {
      if (isEmployee.value == null) return false;
      if (nameCtrl.text.trim().isEmpty) return false;
      if (emailCtrl.text.trim().isEmpty || !emailCtrl.text.contains('@')) return false;
      if (phoneCtrl.text.trim().isEmpty) return false;
      if (organizationCtrl.text.trim().isEmpty) return false;
      if (identityIdCtrl.text.trim().isEmpty) return false;
      return true;
    }
  }

  bool get isStep3Valid {
    if (selectedSiteId.value.isEmpty) return false;
    if (selectedHostId.value.isEmpty) return false;
    if (selectedAgenda.value.isEmpty) return false;
    if (selectedAgenda.value == 'Others' && otherAgendaCtrl.text.trim().isEmpty) {
      return false;
    }
    if (visitStart.value == null || visitEnd.value == null) return false;
    if (visitEnd.value!.isBefore(visitStart.value!) ||
        visitEnd.value!.isAtSameMomentAs(visitStart.value!)) {
      return false;
    }
    return true;
  }

  bool get isStep4Valid {
    if (isGroup.value == true) {
      for (final v in groupVisitors) {
        if (v.isDriving.value) {
          if (v.vehicleType.value.isEmpty) return false;
          if (!isBicycle(v.vehicleType.value) && v.vehiclePlateCtrl.text.trim().isEmpty) {
            return false;
          }
        }
      }
      return true;
    } else {
      if (isDriving.value) {
        if (vehicleType.value.isEmpty) return false;
        if (!isBicycle(vehicleType.value) && vehiclePlateCtrl.text.trim().isEmpty) {
          return false;
        }
      }
      return true;
    }
  }

  bool get isStep5Valid => true;
  bool get isStep6Valid => true;

  bool isStepValid(int step) {
    if (step == 1) return isStep1Valid;
    if (step == 2) return isStep2Valid;
    if (step == 3) return isStep3Valid;
    if (step == 4) return isStep4Valid;
    if (step == 5) return isStep5Valid;
    if (step == 6) return isStep6Valid;
    return true;
  }

  bool get isCurrentStepValid => isStepValid(currentStep.value);

  bool canJumpToStep(int step) {
    if (currentStep.value == step) return false;
    if (step > maxSteps) return false;
    if (step == 1) return true;
    if (step == 2) return isStep1Valid;
    if (step == 3) return isStep1Valid && isStep2Valid;
    if (step == 4) return isStep1Valid && isStep2Valid && isStep3Valid;
    if (step == 5) return isStep1Valid && isStep2Valid && isStep3Valid && isStep4Valid;
    if (step == 6) return isStep1Valid && isStep2Valid && isStep3Valid && isStep4Valid && isStep5Valid;
    return false;
  }

  void goToStep(int step) {
    if (canJumpToStep(step)) {
      if (step > maxStepReached.value) {
        maxStepReached.value = step;
      }
      currentStep.value = step;
    }
  }

  void nextStep() {
    if (!isCurrentStepValid) return;
    final next = currentStep.value + 1;
    if (next <= maxSteps) {
      if (next > maxStepReached.value) {
        maxStepReached.value = next;
      }
      currentStep.value = next;
    }
  }

  void prevStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  // ── Data Fetching ─────────────────────────────────────────────────────────
  Future<void> fetchVisitorTypes() async {
    final token = _token;
    if (token == null) {
      debugPrint('fetchVisitorTypes: Bearer token is null');
      isLoadingTypes.value = false;
      updateForm();
      return;
    }
    isLoadingTypes.value = true;
    try {
      final response = await _api.getVisitorTypes(token);
      final resData = response.data;
      if (resData is Map) {
        final rawList = resData['collection'] ?? resData['data'];
        if (rawList is List) {
          visitorTypes.value = rawList
              .whereType<Map>()
              .map((e) => VisitorTypeModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      } else if (resData is List) {
        visitorTypes.value = resData
            .whereType<Map>()
            .map((e) => VisitorTypeModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('fetchVisitorTypes error: $e');
    } finally {
      isLoadingTypes.value = false;
      updateForm();
    }
  }

  Future<void> onSelectVisitorType(String id, String typeName) async {
    selectedVisitorTypeId.value = id;
    selectedVisitorTypeName.value = typeName;
    visitorTypeRawDetail.value = null;
    formStructure.value = null;
    updateForm();
    await fetchFormStructure(id);
    updateForm();
  }

  Future<void> fetchFormStructure(String id) async {
    final token = _token;
    if (token == null || id.isEmpty) return;
    isLoadingDetail.value = true;
    try {
      final response = await _api.getVisitorTypeById(token, id);
      if (response.data['status'] == 'success') {
        final collection = response.data['collection'] as Map<String, dynamic>? ?? {};
        visitorTypeRawDetail.value = collection;
        final structure = VisitorTypeDetailModel.fromJson(collection);
        formStructure.value = structure;

        // Reset single / group sub-states according to new type detail
        final defaultRole = getDefaultVisitorRole();
        selectedVisitorRole.value = defaultRole;
        for (final v in groupVisitors) {
          v.role.value = defaultRole;
        }
      }
    } catch (e) {
      debugPrint('fetchFormStructure error: $e');
    } finally {
      isLoadingDetail.value = false;
      updateForm();
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
        allVisitors.value = collection.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      debugPrint('fetchVisitors error: $e');
    } finally {
      isLoadingVisitors.value = false;
      updateForm();
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
        _rawEmployees.addAll(collection.map((e) => Map<String, dynamic>.from(e as Map)));
        employees.value = collection
            .map((e) => DropdownItem(id: e['id']?.toString() ?? '', name: e['name']?.toString() ?? ''))
            .where((item) => item.name.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('fetchEmployees error: $e');
    } finally {
      isLoadingEmployees.value = false;
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
            .map((e) => DropdownItem(id: e['id']?.toString() ?? '', name: e['name']?.toString() ?? ''))
            .where((item) => item.name.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('fetchHosts error: $e');
    } finally {
      isLoadingHosts.value = false;
      updateForm();
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
        sites.value = collection
            .map((e) => DropdownItem(id: e['id']?.toString() ?? '', name: e['name']?.toString() ?? ''))
            .where((item) => item.name.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('fetchSites error: $e');
    } finally {
      isLoadingSites.value = false;
      updateForm();
    }
  }

  List<Map<String, dynamic>> get filteredEmployees {
    final q = singleSearchCtrl.text.toLowerCase().trim();
    if (q.isEmpty) return _rawEmployees.toList();
    return _rawEmployees
        .where((e) => (e['name']?.toString() ?? '').toLowerCase().contains(q))
        .toList();
  }

  List<Map<String, dynamic>> get filteredVisitors {
    final q = singleSearchCtrl.text.toLowerCase().trim();
    if (q.isEmpty) return allVisitors.toList();
    return allVisitors
        .where((v) => (v['name']?.toString() ?? '').toLowerCase().contains(q))
        .toList();
  }

  // ── Dynamic Question Page Builder (Exact match to dekstop_tablet_vms) ─────
  Future<List<Map<String, dynamic>>> _buildDynamicQuestionPage({
    required String name,
    required String email,
    required String phone,
    required String org,
    required String identity,
    required bool isEmployee,
    required String? role,
    required String employeeId,
    required Map<String, TextEditingController> extraCtrls,
    required String hostId,
    required String agenda,
    required String siteId,
    required DateTime? start,
    required DateTime? end,
    required bool isDriving,
    required String? vehicleType,
    required String vehiclePlate,
    required UploadedFileData? selfieImage,
    required UploadedFileData? ktpImage,
  }) async {
    final startIso = start?.toUtc().toIso8601String().substring(0, 19);
    final endIso = end?.toUtc().toIso8601String().substring(0, 19);

    // Upload Selfie Image to CDN if present
    String? uploadedSelfiePath;
    if (selfieImage != null && selfieImage.bytes != null) {
      uploadedSelfiePath = await _api.uploadCdnFile(
        selfieImage.bytes!,
        selfieImage.name,
        path: 'face',
      );
    }

    // Upload KTP Image to CDN if present
    String? uploadedKtpPath;
    if (ktpImage != null && ktpImage.bytes != null) {
      uploadedKtpPath = await _api.uploadCdnFile(
        ktpImage.bytes!,
        ktpImage.name,
        path: 'face',
      );
    }

    final sectionsRaw = visitorTypeRawDetail.value?['section_page_visitor_types'] as List<dynamic>?;

    if (sectionsRaw != null && sectionsRaw.isNotEmpty) {
      final List<Map<String, dynamic>> questionPages = [];

      for (var s in sectionsRaw) {
        if (s is! Map) continue;
        final sec = Map<String, dynamic>.from(s);
        final secId = sec['id']?.toString() ?? '';
        final secSort = sec['sort'] ?? 0;
        final secName = sec['name']?.toString() ?? '';
        final secStatus = sec['status'] ?? 0;
        final isDoc = sec['is_document'] == true;
        final canMulti = sec['can_multiple_used'] ?? false;
        final selfOnly = sec['self_only'] ?? false;
        final foreignId = sec['foreign_id']?.toString() ?? '';

        final formListRaw = (sec['visit_form'] as List<dynamic>?) ??
            (sec['pra_form'] as List<dynamic>?) ??
            (sec['form'] as List<dynamic>?) ??
            [];

        final List<Map<String, dynamic>> builtFormList = [];

        for (var f in formListRaw) {
          if (f is! Map) continue;
          final field = Map<String, dynamic>.from(f);
          final remarks = (field['remarks'] ?? '').toString().toLowerCase().trim();
          final fieldType = field['field_type'] ?? 0;
          final customFieldId = field['custom_field_id']?.toString() ?? '';
          final shortName = field['short_name']?.toString() ?? '';
          final longText = field['long_display_text']?.toString() ?? '';
          final isPrimary = field['is_primary'] ?? false;
          final isEnable = field['is_enable'] ?? true;
          final mandatory = field['mandatory'] ?? false;
          final multiOpts = field['multiple_option_fields'] ?? [];
          final vFormType = field['visitor_form_type'] ?? 1;

          Map<String, dynamic> formItem = {
            'sort': field['sort'] ?? builtFormList.length,
            'short_name': shortName,
            'long_display_text': longText,
            'field_type': fieldType,
            'is_primary': isPrimary,
            'is_enable': isEnable,
            'mandatory': mandatory,
            'remarks': remarks,
            if (customFieldId.isNotEmpty) 'custom_field_id': customFieldId,
            'multiple_option_fields': multiOpts,
            'visitor_form_type': vFormType,
          };

          if (isDoc || fieldType == 10 || fieldType == 12 || fieldType == 11) {
            // Document section (Selfie / KTP)
            if (remarks.contains('selfie') || fieldType == 10) {
              formItem['answer_file'] = uploadedSelfiePath;
            } else if (remarks.contains('identity') || remarks.contains('ktp') || fieldType == 12) {
              formItem['answer_file'] = uploadedKtpPath;
            } else {
              formItem['answer_file'] = null;
            }
          } else if (fieldType == 9 || fieldType == 4) {
            // Date Time fields
            if (remarks == 'visitor_period_start') {
              formItem['answer_datetime'] = startIso;
            } else if (remarks == 'visitor_period_end') {
              formItem['answer_datetime'] = endIso;
            } else {
              formItem['answer_datetime'] = null;
            }
          } else {
            // Text / Dropdown / Radio fields
            if (remarks == 'name') {
              formItem['answer_text'] = name;
            } else if (remarks == 'email') {
              formItem['answer_text'] = email;
            } else if (remarks == 'phone') {
              formItem['answer_text'] = phone;
            } else if (remarks == 'organization' || remarks == 'company') {
              formItem['answer_text'] = org;
            } else if (remarks == 'identity_id' || remarks == 'indentity_id') {
              formItem['answer_text'] = identity;
            } else if (remarks == 'is_employee') {
              formItem['answer_text'] = isEmployee ? 'true' : 'false';
            } else if (remarks == 'employee') {
              formItem['answer_text'] = employeeId;
            } else if (remarks == 'visitor_role' || remarks == 'role') {
              formItem['answer_text'] = role ?? '';
            } else if (remarks == 'site_place' || remarks == 'destination') {
              formItem['answer_text'] = siteId;
            } else if (remarks == 'host' || remarks == 'pic_host') {
              formItem['answer_text'] = hostId;
            } else if (remarks == 'agenda') {
              formItem['answer_text'] = agenda;
            } else if (remarks == 'is_driving') {
              formItem['answer_text'] = isDriving ? 'true' : 'false';
            } else if (remarks == 'vehicle_type') {
              formItem['answer_text'] = isDriving ? (vehicleType?.isNotEmpty == true ? vehicleType : null) : null;
            } else if (remarks == 'vehicle_plate') {
              formItem['answer_text'] = (!isDriving || isBicycle(vehicleType))
                  ? null
                  : (vehiclePlate.trim().isNotEmpty ? vehiclePlate.trim() : null);
            } else {
              formItem['answer_text'] = extraCtrls[remarks]?.text.trim() ?? '';
            }
          }

          builtFormList.add(formItem);
        }

        questionPages.add({
          if (secId.isNotEmpty) 'id': secId,
          'sort': secSort,
          'name': secName,
          'status': secStatus,
          'is_document': isDoc,
          'can_multiple_used': canMulti,
          'self_only': selfOnly,
          'foreign_id': foreignId,
          'form': builtFormList,
        });
      }

      return questionPages;
    }

    return [];
  }

  // ── SUBMIT FORM ───────────────────────────────────────────────────────────
  Future<bool> submitForm() async {
    final token = _token;
    if (token == null) {
      _showError('Autentikasi gagal. Silakan login kembali.');
      return false;
    }

    isSubmitting.value = true;
    try {
      final visitorTypeId = selectedVisitorTypeId.value;
      final siteId = selectedSiteId.value;
      final hostId = selectedHostId.value;
      final resolvedAgenda = selectedAgenda.value == 'Others'
          ? otherAgendaCtrl.text.trim()
          : selectedAgenda.value;
      final resolvedRole = selectedVisitorRole.value.isNotEmpty
          ? selectedVisitorRole.value
          : getDefaultVisitorRole();

      Map<String, dynamic> body;

      if (isGroup.value == true) {
        // Group Mode -> POST /api/operator-invitation/new-visit-group
        final List<Map<String, dynamic>> dataVisitors = [];

        final primaryVisitor = groupVisitors.isNotEmpty ? groupVisitors.first : null;
        final primaryName = primaryVisitor?.fullNameCtrl.text.trim() ?? '';
        final primaryEmail = primaryVisitor?.emailCtrl.text.trim() ?? '';
        final primaryPhone = primaryVisitor?.phoneCtrl.text.trim() ?? '';

        for (final v in groupVisitors) {
          final memberEmployeeId = (v.isEmployee.value == true)
              ? (v.selectedData?['id'] ?? v.selectedData?['employee_id'] ?? '').toString()
              : '';

          final memberQuestionPages = await _buildDynamicQuestionPage(
            name: v.fullNameCtrl.text.trim(),
            email: v.emailCtrl.text.trim(),
            phone: v.phoneCtrl.text.trim(),
            org: v.orgCtrl.text.trim(),
            identity: v.identityCtrl.text.trim(),
            isEmployee: v.isEmployee.value == true,
            role: v.role.value.isNotEmpty ? v.role.value : resolvedRole,
            employeeId: memberEmployeeId,
            extraCtrls: v.extraControllers,
            hostId: hostId,
            agenda: resolvedAgenda,
            siteId: siteId,
            start: visitStart.value,
            end: visitEnd.value,
            isDriving: v.isDriving.value,
            vehicleType: v.vehicleType.value,
            vehiclePlate: v.vehiclePlateCtrl.text.trim(),
            selfieImage: v.selfieImage.value,
            ktpImage: v.ktpImage.value,
          );

          dataVisitors.add({'question_page': memberQuestionPages});
        }

        final groupObject = {
          'visitor_type': visitorTypeId,
          'is_group': true,
          'type_registered': 1,
          'tz': 'Asia/Jakarta',
          if (siteId.isNotEmpty) 'registered_site': siteId,
          'group_code': groupCode.value,
          'group_name': groupName.value.trim(),
          'is_self_registered': false,
          'filled_by_name': primaryName,
          'filled_by_email': primaryEmail,
          'filled_by_phone': primaryPhone,
          'filled_by_relationship': 'Other',
          'filled_by_relationship_name': 'Other',
          'flow': 'Invitation',
          'visitor_role': groupVisitors.first.role.value.isNotEmpty ? groupVisitors.first.role.value : resolvedRole,
          'data_visitor': dataVisitors,
        };

        body = {
          'list_group': [groupObject],
        };
      } else {
        // Single Mode -> POST /api/operator-invitation/new-visit
        final singleEmployeeId = (isEmployee.value == true)
            ? (singleSelectedData.value?['id'] ?? singleSelectedData.value?['employee_id'] ?? '').toString()
            : '';

        final singleQuestionPages = await _buildDynamicQuestionPage(
          name: nameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          org: organizationCtrl.text.trim(),
          identity: identityIdCtrl.text.trim(),
          isEmployee: isEmployee.value == true,
          role: resolvedRole,
          employeeId: singleEmployeeId,
          extraCtrls: singleExtraControllers,
          hostId: hostId,
          agenda: resolvedAgenda,
          siteId: siteId,
          start: visitStart.value,
          end: visitEnd.value,
          isDriving: isDriving.value,
          vehicleType: vehicleType.value,
          vehiclePlate: vehiclePlateCtrl.text.trim(),
          selfieImage: selfieImage.value,
          ktpImage: ktpImage.value,
        );

        body = {
          'visitor_type': visitorTypeId,
          'type_registered': 1,
          'is_group': false,
          'tz': 'Asia/Jakarta',
          if (siteId.isNotEmpty) 'registered_site': siteId,
          'flow': 'Invitation',
          'visitor_role': resolvedRole,
          'data_visitor': [
            {'question_page': singleQuestionPages},
          ],
        };
      }

      dev.log('=== SUBMIT PAYLOAD ===\n${jsonEncode(body)}', name: 'Invitation');

      final response = (isGroup.value == true)
          ? await _api.submitNewVisitGroup(token, body)
          : await _api.submitNewVisit(token, body);

      debugPrint('=== SUBMIT RESPONSE ===');
      debugPrint(jsonEncode(response.data));

      final rawData = response.data;
      if (rawData is! Map) {
        _showError(Get.locale?.languageCode == 'id'
            ? 'Format respon server tidak sesuai.'
            : 'Server error: Invalid response format.');
        return false;
      }

      final data = rawData;
      final status = data['status']?.toString().toLowerCase() ?? '';
      final statusCode = data['status_code'] ?? response.statusCode;
      final collectionMap = data['collection'] is Map ? data['collection'] as Map : null;
      final transactionStatus = collectionMap?['transaction_status']?.toString() ?? '';

      // Determine success:
      // Must not be explicitly 'error' or 'failed', and matches standard success criteria
      final isNotExplicitError = status != 'error' && status != 'failed';
      final isSuccess = isNotExplicitError &&
          (status == 'success' ||
              statusCode == 200 ||
              statusCode == 201 ||
              transactionStatus == 'UnderCreated');

      if (isSuccess) {
        final successMsg = data['msg']?.toString() ??
            data['message']?.toString() ??
            (Get.locale?.languageCode == 'id'
                ? 'Undangan berhasil dibuat!'
                : 'Invitation created successfully!');
        if (!isDuplicateMode.value) {
          Get.snackbar(
            Get.locale?.languageCode == 'id' ? 'Sukses' : 'Success',
            successMsg,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }

        // Auto Refresh Invitation List & activity counts if available
        if (Get.isRegistered<InvitationController>()) {
          final invCtrl = Get.find<InvitationController>();
          invCtrl.fetchOngoingInvitations(isSilent: true);
          invCtrl.fetchVisitorTodayCount();
          invCtrl.triggerActivityRefresh();
        }

        return true;
      } else {
        // Extract error message safely from various backend conventions
        String? errorMsg;
        if (data['msg'] != null && data['msg'].toString().trim().isNotEmpty) {
          errorMsg = data['msg'].toString();
        } else if (data['message'] != null && data['message'].toString().trim().isNotEmpty) {
          errorMsg = data['message'].toString();
        } else if (data['error'] != null && data['error'].toString().trim().isNotEmpty) {
          errorMsg = data['error'].toString();
        } else if (data['errors'] != null) {
          if (data['errors'] is Map) {
            final errMap = data['errors'] as Map;
            final firstKey = errMap.keys.firstOrNull;
            if (firstKey != null) {
              final val = errMap[firstKey];
              if (val is List && val.isNotEmpty) {
                errorMsg = val.first.toString();
              } else {
                errorMsg = val.toString();
              }
            }
          } else if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
            errorMsg = (data['errors'] as List).first.toString();
          }
        }

        final lowerMsg = (errorMsg ?? '').toLowerCase();
        final isBlocked = lowerMsg.contains('block') || lowerMsg.contains('blacklist');

        if (isBlocked) {
          _showError(Get.locale?.languageCode == 'id'
              ? 'Pengunjung tidak dapat didaftarkan: Satu atau lebih pengunjung sedang diblokir atau masuk daftar hitam (blacklist) di sistem.'
              : 'Cannot submit invitation: One or more visitors are currently blocked or blacklisted in the system.');
        } else {
          _showError(errorMsg ??
              (Get.locale?.languageCode == 'id'
                  ? 'Terjadi kesalahan saat memproses undangan.'
                  : 'An error occurred while processing the invitation.'));
        }
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

  // ── Autofill for Duplicate ────────────────────────────────────────────────
  Future<void> autofillFromAccessPass(
    AccessPassModel model, {
    List<Map<String, dynamic>>? subVisitors,
  }) async {
    resetFields();
    isDuplicateMode.value = true;

    selectedVisitorTypeId.value = model.visitorTypeId;
    selectedVisitorTypeName.value = model.visitorTypeName;
    await fetchFormStructure(model.visitorTypeId);

    final hasGroupFlag = model.isGroup || model.groupName.isNotEmpty || (subVisitors != null && subVisitors.length > 1);
    isGroup.value = hasGroupFlag;

    if (hasGroupFlag) {
      groupName.value = '';
      groupNameCtrl.clear();
      groupCode.value = _generateGroupCode();
      groupVisitors.clear();
      if (subVisitors != null && subVisitors.isNotEmpty) {
        for (final sub in subVisitors) {
          final row = GroupWalkInVisitorEntry();
          row.fullNameCtrl.text = sub['visitor_name']?.toString() ?? sub['name']?.toString() ?? '';
          row.emailCtrl.text = sub['visitor_email']?.toString() ?? sub['email']?.toString() ?? '';
          row.phoneCtrl.text = sub['visitor_phone']?.toString() ?? sub['phone']?.toString() ?? '';
          row.orgCtrl.text = sub['visitor_organization_name']?.toString() ?? sub['organization']?.toString() ?? '';
          row.identityCtrl.text = sub['visitor_identity_id']?.toString() ?? sub['identity_id']?.toString() ?? '';
          row.role.value = sub['visitor_role']?.toString() ?? model.visitorRole;
          groupVisitors.add(row);
        }
      }
    } else {
      nameCtrl.text = model.visitorName;
      emailCtrl.text = model.visitorEmail;
      phoneCtrl.text = model.visitorPhone;
      organizationCtrl.text = model.visitorOrganizationName;
      identityIdCtrl.text = model.visitorIdentityId;
      selectedVisitorRole.value = model.visitorRole;
    }

    selectedAgenda.value = model.agenda.isNotEmpty ? model.agenda : 'Meeting';
    selectedSiteId.value = model.sitePlaceId ?? model.siteId;
    selectedSiteName.value = model.sitePlaceName;
    selectedHostId.value = model.host;
    visitStart.value = model.visitorPeriodStart;
    visitEnd.value = model.visitorPeriodEnd;

    currentStep.value = 1;
    maxStepReached.value = 1;
    updateForm();
  }

  void _showError(String message) {
    Get.snackbar(
      Get.locale?.languageCode == 'id' ? 'Peringatan' : 'Warning',
      message,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }
}
