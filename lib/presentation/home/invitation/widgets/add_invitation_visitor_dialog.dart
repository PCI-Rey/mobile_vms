// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/datasources/hive_service.dart';
import '../../../../data/models/access_pass_model.dart';

/// Helper model for picked file data (selfie / KTP)
class InvitationVisitorUploadedFile {
  final String name;
  final int sizeBytes;
  final String extension;
  final String localPath;
  final Uint8List? bytes;

  InvitationVisitorUploadedFile({
    required this.name,
    required this.sizeBytes,
    required this.extension,
    required this.localPath,
    this.bytes,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Type of upload feedback snackbar matching Create Invitation
enum UploadFeedbackType { upload, remove, retry }

/// Helper model for each visitor entry in Step 2 (Group)
class InvitationVisitorEntry {
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController orgCtrl = TextEditingController();
  final TextEditingController searchCtrl = TextEditingController();
  bool isSearchOpen = false;
  Map<String, dynamic>? selectedData;

  /// Arriving by vehicle: 'drop_off', 'parking', or 'no'
  String arrivingByVehicle = 'no';
  String vehicleType = 'Car';
  final TextEditingController licensePlateCtrl = TextEditingController();

  InvitationVisitorUploadedFile? selfieFile;
  InvitationVisitorUploadedFile? ktpFile;

  String? uploadedSelfieUrl;
  String? uploadedKtpUrl;

  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    orgCtrl.dispose();
    licensePlateCtrl.dispose();
    searchCtrl.dispose();
  }
}

/// Function to show Add Invitation Visitor Dialog
void showAddInvitationVisitorDialog(
  BuildContext context, {
  required AccessPassModel item,
  String? parentTransactionId,
  VoidCallback? onSuccess,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AddInvitationVisitorDialog(
      item: item,
      parentTransactionId: parentTransactionId,
      onSuccess: onSuccess,
    ),
  );
}

class AddInvitationVisitorDialog extends StatefulWidget {
  final AccessPassModel item;
  final String? parentTransactionId;
  final VoidCallback? onSuccess;

  const AddInvitationVisitorDialog({
    super.key,
    required this.item,
    this.parentTransactionId,
    this.onSuccess,
  });

  @override
  State<AddInvitationVisitorDialog> createState() =>
      _AddInvitationVisitorDialogState();
}

class _AddInvitationVisitorDialogState
    extends State<AddInvitationVisitorDialog> {
  final ApiService _api = ApiService();
  final HiveService _hive = HiveService();
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 1; // 1: Purpose Visit, 2: Visitor Information (Group)
  int _selectedVisitorIndex = 0; // Active visitor in Step 2 tabs
  bool _isLoadingForm = true;
  bool _isSubmitting = false;

  List<dynamic>? _rawSections;
  List<String> _vehicleTypeOptions = [
    'Car',
    'Motorcycle',
    'Bicycle',
    'Truck',
    'Bus',
  ];

  final List<InvitationVisitorEntry> _visitors = [];
  static List<Map<String, dynamic>> _cachedVisitors = [];
  List<Map<String, dynamic>> _allVisitors = [];
  bool _isLoadingVisitors = false;

  @override
  void initState() {
    super.initState();
    _visitors.add(InvitationVisitorEntry());
    if (_cachedVisitors.isNotEmpty) {
      _allVisitors = List.from(_cachedVisitors);
    }
    _fetchAddVisitorForm();
    _fetchVisitors();
  }

  Future<void> _fetchVisitors() async {
    final token = _hive.getUser()?.token ?? '';
    if (token.isEmpty) return;
    setState(() => _isLoadingVisitors = true);
    try {
      final response = await _api.getVisitors(token);
      final resData = response.data;
      if (resData is Map) {
        if (resData['status'] == 'success' ||
            resData['status_code'] == 200 ||
            response.statusCode == 200) {
          final rawList = resData['collection'] ?? resData['data'];
          if (rawList is List) {
            final parsed = rawList
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
            _cachedVisitors = parsed;
            if (mounted) {
              setState(() {
                _allVisitors = parsed;
              });
            }
          }
        }
      } else if (resData is List) {
        final parsed = resData
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _cachedVisitors = parsed;
        if (mounted) {
          setState(() {
            _allVisitors = parsed;
          });
        }
      }
      debugPrint('AddInvitationVisitorDialog: loaded ${_allVisitors.length} visitors');
    } catch (e) {
      debugPrint('AddInvitationVisitorDialog fetchVisitors error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingVisitors = false);
      }
    }
  }

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

  List<Map<String, dynamic>> _getFilteredVisitors(int index) {
    if (index >= _visitors.length) return [];
    final v = _visitors[index];
    final q = v.searchCtrl.text.toLowerCase().trim();
    if (q.isEmpty) return _allVisitors;
    return _allVisitors.where((item) {
      final name = (item['name'] ?? item['visitor_name'] ?? '').toString().toLowerCase();
      final email = (item['email'] ?? '').toString().toLowerCase();
      final phone = (item['phone'] ?? '').toString().toLowerCase();
      return name.contains(q) || email.contains(q) || phone.contains(q);
    }).toList();
  }

  void _onSelectVisitor(int index, Map<String, dynamic> item) {
    if (index >= _visitors.length) return;
    final v = _visitors[index];
    final selectedEmail = (item['email'] ?? '').toString().trim();
    if (selectedEmail.isNotEmpty &&
        widget.item.visitorEmail.trim().isNotEmpty &&
        selectedEmail.toLowerCase() == widget.item.visitorEmail.trim().toLowerCase()) {
      Get.snackbar(
        'Warning',
        'Visitor "$selectedEmail" is already registered as the main visitor of this invitation.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
    setState(() {
      v.selectedData = item;
      v.isSearchOpen = false;
      final fullName = (item['name'] ?? item['visitor_name'] ?? '').toString();
      v.searchCtrl.text = fullName;
      v.fullNameCtrl.text = fullName;
      v.emailCtrl.text = selectedEmail;
      v.phoneCtrl.text = (item['phone'] ?? '').toString();
      v.orgCtrl.text = _extractOrganizationName(
        item['Organization'] ?? item['organization'],
        item['company'],
      );
    });
  }

  void _onClearVisitorSearch(int index) {
    if (index >= _visitors.length) return;
    final v = _visitors[index];
    setState(() {
      v.selectedData = null;
      v.searchCtrl.clear();
      v.fullNameCtrl.clear();
      v.emailCtrl.clear();
      v.phoneCtrl.clear();
      v.orgCtrl.clear();
      v.isSearchOpen = false;
    });
  }

  @override
  void dispose() {
    for (final v in _visitors) {
      v.dispose();
    }
    super.dispose();
  }

  String _formVisitorTypeId = '';
  String _formSiteId = '';
  String _formTz = '';

  String get _transactionId {
    if (widget.parentTransactionId != null &&
        widget.parentTransactionId!.trim().isNotEmpty) {
      return widget.parentTransactionId!.trim();
    }
    if (widget.item.transactionVisitorId.trim().isNotEmpty) {
      return widget.item.transactionVisitorId.trim();
    }
    return widget.item.id.trim();
  }

  /// Fetch initial form schema from GET /api/visitor/add-visit/form/{id}
  Future<void> _fetchAddVisitorForm() async {
    setState(() => _isLoadingForm = true);
    final token = _hive.getUser()?.token ?? '';
    final trxId = _transactionId;

    debugPrint('[_fetchAddVisitorForm] Using trxId: $trxId');

    if (token.isEmpty || trxId.isEmpty) {
      if (mounted) setState(() => _isLoadingForm = false);
      return;
    }

    try {
      final res = await _api.getAddVisitorForm(token, trxId);
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data is Map<String, dynamic>
            ? res.data as Map<String, dynamic>
            : Map<String, dynamic>.from(res.data);

        final col = data['collection'] ?? data['data'] ?? data;
        if (col is Map) {
          final vt =
              (col['visitor_type_id'] ?? col['visitor_type'])?.toString() ?? '';
          if (vt.isNotEmpty) _formVisitorTypeId = vt;
          final sid =
              (col['site_id'] ?? col['registered_site'])?.toString() ?? '';
          if (sid.isNotEmpty) _formSiteId = sid;
          final tzVal = col['tz']?.toString() ?? '';
          if (tzVal.isNotEmpty) _formTz = tzVal;

          final sections =
              (col['section_page_visitor_types'] as List<dynamic>?) ??
              (col['question_page'] as List<dynamic>?) ??
              (col['sections'] as List<dynamic>?);

          if (sections != null && sections.isNotEmpty) {
            _rawSections = sections;
            _extractVehicleOptionsFromSections(sections);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching add visitor form: $e');
    }

    if (mounted) {
      setState(() => _isLoadingForm = false);
    }
  }

  void _extractVehicleOptionsFromSections(List<dynamic> sections) {
    for (final s in sections) {
      if (s is! Map) continue;
      final forms = [
        ...((s['visit_form'] as List<dynamic>?) ?? []),
        ...((s['pra_form'] as List<dynamic>?) ?? []),
        ...((s['form'] as List<dynamic>?) ?? []),
      ];
      for (final f in forms) {
        if (f is! Map) continue;
        final remarks = (f['remarks'] ?? '').toString().toLowerCase().trim();
        if (remarks == 'vehicle_type') {
          final multiOpts = f['multiple_option_fields'] as List<dynamic>?;
          if (multiOpts != null && multiOpts.isNotEmpty) {
            final opts = multiOpts
                .map((o) => (o['value'] ?? o['name'] ?? '').toString().trim())
                .where((val) => val.isNotEmpty)
                .toList();
            if (opts.isNotEmpty) {
              setState(() {
                _vehicleTypeOptions = opts;
                for (final v in _visitors) {
                  if (!_vehicleTypeOptions.contains(v.vehicleType)) {
                    v.vehicleType = _vehicleTypeOptions.first;
                  }
                }
              });
            }
          }
          return;
        }
      }
    }
  }

  String _formatOption(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }

  bool _isBicycle(String? type) {
    if (type == null) return false;
    final t = type.toLowerCase().trim();
    return t == 'bicycle' ||
        t == 'sepeda' ||
        t.contains('bicycle') ||
        t.contains('sepeda') ||
        t == 'bike';
  }

  String _formatDateTime(DateTime dt) {
    try {
      return DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return DateFormat('EEEE, dd MMMM yyyy, HH:mm').format(dt);
    }
  }

  void _addVisitorCard() {
    setState(() {
      final entry = InvitationVisitorEntry();
      if (_vehicleTypeOptions.isNotEmpty) {
        entry.vehicleType = _vehicleTypeOptions.first;
      }
      _visitors.add(entry);
      _selectedVisitorIndex = _visitors.length - 1;
    });
  }

  void _removeVisitorCard(int index) {
    if (_visitors.length <= 1) return;
    setState(() {
      final removed = _visitors.removeAt(index);
      removed.dispose();
      if (_selectedVisitorIndex >= _visitors.length) {
        _selectedVisitorIndex = _visitors.length - 1;
      }
    });
  }

  // ─── Dynamic Field Helpers from API Schema (_rawSections) ───
  bool _matchRemarks(String actual, String target) {
    final a = actual.toLowerCase().trim();
    final t = target.toLowerCase().trim();
    if (a == t) return true;
    switch (t) {
      case 'name':
        return a == 'fullname' || a == 'full_name';
      case 'phone':
        return a == 'phone_number' || a == 'phone_no';
      case 'organization':
        return a == 'company' || a == 'department';
      case 'is_driving':
        return a == 'driving' || a == 'is_vehicle';
      case 'vehicle_plate':
        return a == 'license_plate' ||
            a == 'plate_number' ||
            a == 'vehicle_plate_number';
      case 'selfie_image':
        return a == 'selfie' || a == 'face';
      case 'identity_image':
        return a == 'ktp' || a == 'identity_card' || a == 'identity';
      default:
        return false;
    }
  }

  Map<String, dynamic>? _findFieldConfig(String remarks) {
    if (_rawSections == null) return null;
    for (final s in _rawSections!) {
      if (s is! Map) continue;
      final forms = [
        ...((s['visit_form'] as List<dynamic>?) ?? []),
        ...((s['pra_form'] as List<dynamic>?) ?? []),
        ...((s['form'] as List<dynamic>?) ?? []),
      ];
      for (final f in forms) {
        if (f is! Map) continue;
        final r = (f['remarks'] ?? '').toString();
        if (_matchRemarks(r, remarks)) {
          return Map<String, dynamic>.from(f);
        }
      }
    }
    return null;
  }

  bool _isFieldEnabled(String remarks, {bool defaultVal = true}) {
    final cfg = _findFieldConfig(remarks);
    if (cfg == null) return defaultVal;
    final e = cfg['is_enable'];
    if (e == null) return defaultVal;
    if (e is bool) return e;
    if (e is num) return e == 1;
    final s = e.toString().toLowerCase().trim();
    return s != 'false' && s != '0';
  }

  bool _isFieldMandatory(String remarks, {bool defaultVal = false}) {
    final cfg = _findFieldConfig(remarks);
    if (cfg == null) return defaultVal;
    final m = cfg['mandatory'];
    if (m == null) return defaultVal;
    if (m is bool) return m;
    if (m is num) return m == 1;
    final s = m.toString().toLowerCase().trim();
    return s == 'true' || s == '1';
  }

  String _getFieldLabel(String remarks, String fallback) {
    final cfg = _findFieldConfig(remarks);
    if (cfg == null) return fallback;
    final longText = (cfg['long_display_text'] ?? '').toString().trim();
    if (longText.isNotEmpty && longText != '--') return longText;
    final shortName = (cfg['short_name'] ?? '').toString().trim();
    if (shortName.isNotEmpty && shortName != '--') return shortName;
    return fallback;
  }

  bool get _hasSelfieDocument {
    if (_rawSections == null) return true;
    for (final s in _rawSections!) {
      if (s is! Map) continue;
      final isDoc = s['is_document'] == true;
      final secName = (s['name'] ?? '').toString().toLowerCase();
      if (isDoc && (secName.contains('selfie') || secName.contains('face'))) {
        return true;
      }
      final forms = [
        ...((s['visit_form'] as List<dynamic>?) ?? []),
        ...((s['pra_form'] as List<dynamic>?) ?? []),
        ...((s['form'] as List<dynamic>?) ?? []),
      ];
      for (final f in forms) {
        if (f is! Map) continue;
        final r = (f['remarks'] ?? '').toString().toLowerCase();
        final ft = f['field_type'];
        if (r.contains('selfie') || r.contains('face') || ft == 10) return true;
      }
    }
    return false;
  }

  bool get _hasKtpDocument {
    if (_rawSections == null) return false;
    for (final s in _rawSections!) {
      if (s is! Map) continue;
      final isDoc = s['is_document'] == true;
      final secName = (s['name'] ?? '').toString().toLowerCase();
      if (isDoc &&
          (secName.contains('identity') ||
              secName.contains('ktp') ||
              secName.contains('card'))) {
        return true;
      }
      final forms = [
        ...((s['visit_form'] as List<dynamic>?) ?? []),
        ...((s['pra_form'] as List<dynamic>?) ?? []),
        ...((s['form'] as List<dynamic>?) ?? []),
      ];
      for (final f in forms) {
        if (f is! Map) continue;
        final r = (f['remarks'] ?? '').toString().toLowerCase();
        final ft = f['field_type'];
        if (r.contains('identity') || r.contains('ktp') || ft == 12) {
          return true;
        }
      }
    }
    return false;
  }

  bool _isVisitorValid(InvitationVisitorEntry v) {
    // Full Name
    if (_isFieldEnabled('name') &&
        _isFieldMandatory('name', defaultVal: true)) {
      if (v.fullNameCtrl.text.trim().isEmpty) return false;
    }

    // Email
    if (_isFieldEnabled('email')) {
      final email = v.emailCtrl.text.trim();
      final mandatory = _isFieldMandatory('email', defaultVal: true);
      if (mandatory && email.isEmpty) return false;
      if (email.isNotEmpty && !GetUtils.isEmail(email)) return false;
    }

    // Phone
    if (_isFieldEnabled('phone') &&
        _isFieldMandatory('phone', defaultVal: true)) {
      if (v.phoneCtrl.text.trim().isEmpty) return false;
    }

    // Organization
    if (_isFieldEnabled('organization') &&
        _isFieldMandatory('organization', defaultVal: true)) {
      if (v.orgCtrl.text.trim().isEmpty) return false;
    }

    // Vehicle
    if (v.arrivingByVehicle != 'no') {
      if (_isFieldEnabled('vehicle_type') &&
          _isFieldMandatory('vehicle_type', defaultVal: false)) {
        if (v.vehicleType.trim().isEmpty) return false;
      }
      if (!_isBicycle(v.vehicleType) &&
          _isFieldEnabled('vehicle_plate') &&
          _isFieldMandatory('vehicle_plate', defaultVal: false)) {
        if (v.licensePlateCtrl.text.trim().isEmpty) return false;
      }
    }

    // Selfie
    if (_hasSelfieDocument &&
        _isFieldMandatory('selfie_image', defaultVal: false)) {
      if (v.selfieFile == null &&
          (v.uploadedSelfieUrl == null || v.uploadedSelfieUrl!.isEmpty)) {
        return false;
      }
    }

    // KTP / Identity Card
    if (_hasKtpDocument &&
        _isFieldMandatory('identity_image', defaultVal: false)) {
      if (v.ktpFile == null &&
          (v.uploadedKtpUrl == null || v.uploadedKtpUrl!.isEmpty)) {
        return false;
      }
    }

    return true;
  }

  bool _isVisitorComplete(int index) {
    if (index >= _visitors.length) return false;
    return _isVisitorValid(_visitors[index]);
  }

  bool get _canSubmit {
    if (_visitors.isEmpty) return false;
    for (int i = 0; i < _visitors.length; i++) {
      if (!_isVisitorComplete(i)) return false;
    }
    return true;
  }

  void _showUploadSnackbar({
    required UploadFeedbackType type,
    required bool isKtp,
  }) {
    String message;
    switch (type) {
      case UploadFeedbackType.upload:
        message = isKtp
            ? 'KTP photo uploaded successfully'
            : 'Selfie photo uploaded successfully';
        break;
      case UploadFeedbackType.remove:
        message = isKtp
            ? 'KTP photo removed successfully'
            : 'Selfie photo removed successfully';
        break;
      case UploadFeedbackType.retry:
        message = isKtp
            ? 'KTP photo updated successfully'
            : 'Selfie photo updated successfully';
        break;
    }

    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  Future<bool> _pickImageDirect(
    int visitorIndex, {
    required bool isKtp,
    required bool fromCamera,
    bool isRetry = false,
  }) async {
    final visitor = _visitors[visitorIndex];

    try {
      final XFile? file = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (file == null) return false;

      final bytes = await file.readAsBytes();
      final size = bytes.length;
      if (size > 5 * 1024 * 1024) {
        Get.snackbar(
          'Error',
          'File size exceeds 5 MB',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      final ext = file.name.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(ext)) {
        Get.snackbar(
          'Error',
          'Only JPG, JPEG, and PNG formats are allowed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      final uploadedFile = InvitationVisitorUploadedFile(
        name: file.name,
        sizeBytes: size,
        extension: ext,
        localPath: file.path,
        bytes: bytes,
      );

      setState(() {
        if (isKtp) {
          visitor.ktpFile = uploadedFile;
        } else {
          visitor.selfieFile = uploadedFile;
        }
      });

      _showUploadSnackbar(
        type: isRetry ? UploadFeedbackType.retry : UploadFeedbackType.upload,
        isKtp: isKtp,
      );
      return true;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return false;
    }
  }

  bool _validateForm() {
    for (int i = 0; i < _visitors.length; i++) {
      final v = _visitors[i];
      final visitorNum = i + 1;

      if (_isFieldEnabled('name') &&
          _isFieldMandatory('name', defaultVal: true)) {
        if (v.fullNameCtrl.text.trim().isEmpty) {
          setState(() => _selectedVisitorIndex = i);
          Get.snackbar(
            'Validation Error',
            'Please enter full name for Visitor $visitorNum',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
      }

      if (_isFieldEnabled('email')) {
        final email = v.emailCtrl.text.trim();
        final mandatory = _isFieldMandatory('email', defaultVal: true);
        if (mandatory && email.isEmpty) {
          setState(() => _selectedVisitorIndex = i);
          Get.snackbar(
            'Validation Error',
            'Please enter email for Visitor $visitorNum',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
        if (email.isNotEmpty && !GetUtils.isEmail(email)) {
          setState(() => _selectedVisitorIndex = i);
          Get.snackbar(
            'Validation Error',
            'Please enter a valid email for Visitor $visitorNum',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
        if (email.isNotEmpty &&
            widget.item.visitorEmail.trim().isNotEmpty &&
            email.toLowerCase() ==
                widget.item.visitorEmail.trim().toLowerCase()) {
          setState(() => _selectedVisitorIndex = i);
          Get.snackbar(
            'Validation Error',
            'Email $email is already registered as the main visitor of this invitation. Please use a different email.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
          );
          return false;
        }
      }

      // Check duplicate emails across multiple visitors in this dialog
      final Set<String> seenEmails = {};
      for (int k = 0; k < _visitors.length; k++) {
        final currentEmail = _visitors[k].emailCtrl.text.trim().toLowerCase();
        if (currentEmail.isNotEmpty) {
          if (seenEmails.contains(currentEmail)) {
            setState(() => _selectedVisitorIndex = k);
            Get.snackbar(
              'Validation Error',
              'Duplicate email $currentEmail on Visitor ${k + 1}. Each visitor must have a unique email address.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 4),
            );
            return false;
          }
          seenEmails.add(currentEmail);
        }
      }

      if (_isFieldEnabled('phone') &&
          _isFieldMandatory('phone', defaultVal: true)) {
        if (v.phoneCtrl.text.trim().isEmpty) {
          setState(() => _selectedVisitorIndex = i);
          Get.snackbar(
            'Validation Error',
            'Please enter phone number for Visitor $visitorNum',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
      }

      if (_isFieldEnabled('organization') &&
          _isFieldMandatory('organization', defaultVal: true)) {
        if (v.orgCtrl.text.trim().isEmpty) {
          setState(() => _selectedVisitorIndex = i);
          Get.snackbar(
            'Validation Error',
            'Please enter department/organization for Visitor $visitorNum',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
      }

      if (v.arrivingByVehicle != 'no') {
        if (_isFieldEnabled('vehicle_type') &&
            _isFieldMandatory('vehicle_type', defaultVal: false)) {
          if (v.vehicleType.trim().isEmpty) {
            setState(() => _selectedVisitorIndex = i);
            Get.snackbar(
              'Validation Error',
              'Please select vehicle type for Visitor $visitorNum',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
            return false;
          }
        }
        if (!_isBicycle(v.vehicleType) &&
            _isFieldEnabled('vehicle_plate') &&
            _isFieldMandatory('vehicle_plate', defaultVal: false)) {
          if (v.licensePlateCtrl.text.trim().isEmpty) {
            setState(() => _selectedVisitorIndex = i);
            Get.snackbar(
              'Validation Error',
              'Please enter license plate number for Visitor $visitorNum',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
            return false;
          }
        }
      }

      if (_hasSelfieDocument &&
          _isFieldMandatory('selfie_image', defaultVal: false)) {
        if (v.selfieFile == null &&
            (v.uploadedSelfieUrl == null || v.uploadedSelfieUrl!.isEmpty)) {
          setState(() => _selectedVisitorIndex = i);
          Get.snackbar(
            'Validation Error',
            'Please take a selfie photo for Visitor $visitorNum',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
      }

      if (_hasKtpDocument &&
          _isFieldMandatory('identity_image', defaultVal: false)) {
        if (v.ktpFile == null &&
            (v.uploadedKtpUrl == null || v.uploadedKtpUrl!.isEmpty)) {
          setState(() => _selectedVisitorIndex = i);
          Get.snackbar(
            'Validation Error',
            'Please upload identity card (KTP) for Visitor $visitorNum',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return false;
        }
      }
    }
    return true;
  }

  /// Construct question_page for a visitor entry
  List<Map<String, dynamic>> _buildQuestionPagesForVisitor({
    required InvitationVisitorEntry visitor,
    required String startIso,
    required String endIso,
  }) {
    final isArriving = visitor.arrivingByVehicle != 'no';
    final isBicycle = _isBicycle(visitor.vehicleType);

    if (_rawSections != null && _rawSections!.isNotEmpty) {
      final List<Map<String, dynamic>> questionPages = [];

      for (var s in _rawSections!) {
        if (s is! Map) continue;
        final sec = Map<String, dynamic>.from(s);
        final secId = sec['id']?.toString() ?? '';
        final secSort = sec['sort'] ?? questionPages.length;
        final secName = sec['name']?.toString() ?? '';
        final secStatus = sec['status'] ?? 0;
        final isDoc = sec['is_document'] == true;
        final canMulti = sec['can_multiple_used'] ?? false;
        final selfOnly = sec['self_only'] ?? false;
        final foreignId = sec['foreign_id']?.toString() ?? '';

        final formListRaw =
            (sec['visit_form'] as List<dynamic>?) ??
            (sec['pra_form'] as List<dynamic>?) ??
            (sec['form'] as List<dynamic>?) ??
            [];

        final List<Map<String, dynamic>> builtFormList = [];

        for (var f in formListRaw) {
          if (f is! Map) continue;
          final field = Map<String, dynamic>.from(f);
          final remarks = (field['remarks'] ?? '')
              .toString()
              .toLowerCase()
              .trim();
          final fieldType = field['field_type'] ?? 1;
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
            if (remarks.contains('selfie') || fieldType == 10) {
              formItem['answer_file'] = visitor.uploadedSelfieUrl;
            } else if (remarks.contains('identity') ||
                remarks.contains('ktp') ||
                fieldType == 12) {
              formItem['answer_file'] = visitor.uploadedKtpUrl;
            } else {
              formItem['answer_file'] = null;
            }
          } else if (fieldType == 9 || fieldType == 4) {
            if (remarks == 'visitor_period_start') {
              formItem['answer_datetime'] = startIso;
            } else if (remarks == 'visitor_period_end') {
              formItem['answer_datetime'] = endIso;
            } else {
              formItem['answer_datetime'] = null;
            }
          } else {
            if (remarks == 'name') {
              formItem['answer_text'] = visitor.fullNameCtrl.text.trim();
            } else if (remarks == 'email') {
              formItem['answer_text'] = visitor.emailCtrl.text.trim();
            } else if (remarks == 'phone') {
              formItem['answer_text'] = visitor.phoneCtrl.text.trim();
            } else if (remarks == 'organization' || remarks == 'company') {
              formItem['answer_text'] = visitor.orgCtrl.text.trim();
            } else if (remarks == 'site_place' || remarks == 'destination') {
              formItem['answer_text'] = widget.item.siteId;
            } else if (remarks == 'host' || remarks == 'pic_host') {
              formItem['answer_text'] = widget.item.host;
            } else if (remarks == 'agenda') {
              formItem['answer_text'] = widget.item.agenda;
            } else if (remarks == 'is_driving') {
              formItem['answer_text'] = isArriving ? 'true' : 'false';
            } else if (remarks == 'vehicle_type') {
              formItem['answer_text'] = isArriving ? visitor.vehicleType : null;
            } else if (remarks == 'vehicle_plate') {
              formItem['answer_text'] = (isArriving && !isBicycle)
                  ? visitor.licensePlateCtrl.text.trim()
                  : null;
            } else {
              formItem['answer_text'] = '';
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
          if (foreignId.isNotEmpty) 'foreign_id': foreignId,
          'form': builtFormList,
        });
      }

      return questionPages;
    }

    // Fallback default structure if backend did not supply sections
    return [
      {
        'sort': 0,
        'name': 'General Information',
        'status': 1,
        'is_document': false,
        'can_multiple_used': false,
        'self_only': false,
        'form': [
          {
            'sort': 0,
            'short_name': 'Name',
            'long_display_text': 'Fullname',
            'field_type': 1,
            'is_primary': true,
            'is_enable': true,
            'mandatory': true,
            'remarks': 'name',
            'answer_text': visitor.fullNameCtrl.text.trim(),
          },
          {
            'sort': 1,
            'short_name': 'Email',
            'long_display_text': 'Email',
            'field_type': 1,
            'is_primary': false,
            'is_enable': true,
            'mandatory': true,
            'remarks': 'email',
            'answer_text': visitor.emailCtrl.text.trim(),
          },
          {
            'sort': 2,
            'short_name': 'Phone',
            'long_display_text': 'Phone Number',
            'field_type': 1,
            'is_primary': false,
            'is_enable': true,
            'mandatory': true,
            'remarks': 'phone',
            'answer_text': visitor.phoneCtrl.text.trim(),
          },
          {
            'sort': 3,
            'short_name': 'Organization',
            'long_display_text': 'Department / Organization',
            'field_type': 1,
            'is_primary': false,
            'is_enable': true,
            'mandatory': true,
            'remarks': 'organization',
            'answer_text': visitor.orgCtrl.text.trim(),
          },
          {
            'sort': 4,
            'short_name': 'Destination',
            'long_display_text': 'Destination',
            'field_type': 1,
            'is_primary': false,
            'is_enable': true,
            'mandatory': true,
            'remarks': 'destination',
            'answer_text': widget.item.siteId,
          },
          {
            'sort': 5,
            'short_name': 'Host',
            'long_display_text': 'Host',
            'field_type': 1,
            'is_primary': false,
            'is_enable': true,
            'mandatory': true,
            'remarks': 'host',
            'answer_text': widget.item.host,
          },
          {
            'sort': 6,
            'short_name': 'Agenda',
            'long_display_text': 'Agenda',
            'field_type': 1,
            'is_primary': false,
            'is_enable': true,
            'mandatory': true,
            'remarks': 'agenda',
            'answer_text': widget.item.agenda,
          },
          {
            'sort': 7,
            'short_name': 'Visit Start',
            'long_display_text': 'Visit Period Start',
            'field_type': 9,
            'is_primary': false,
            'is_enable': true,
            'mandatory': true,
            'remarks': 'visitor_period_start',
            'answer_datetime': startIso,
          },
          {
            'sort': 8,
            'short_name': 'Visit End',
            'long_display_text': 'Visit Period End',
            'field_type': 9,
            'is_primary': false,
            'is_enable': true,
            'mandatory': true,
            'remarks': 'visitor_period_end',
            'answer_datetime': endIso,
          },
          {
            'sort': 9,
            'short_name': 'Is Driving',
            'long_display_text': 'Arriving by vehicle',
            'field_type': 1,
            'is_primary': false,
            'is_enable': true,
            'mandatory': true,
            'remarks': 'is_driving',
            'answer_text': isArriving ? 'true' : 'false',
          },
          if (isArriving) ...[
            {
              'sort': 10,
              'short_name': 'Vehicle Type',
              'long_display_text': 'Vehicle Type',
              'field_type': 3,
              'is_primary': false,
              'is_enable': true,
              'mandatory': true,
              'remarks': 'vehicle_type',
              'answer_text': visitor.vehicleType,
            },
            if (!isBicycle)
              {
                'sort': 11,
                'short_name': 'Vehicle Plate',
                'long_display_text': 'License Plate Number',
                'field_type': 1,
                'is_primary': false,
                'is_enable': true,
                'mandatory': true,
                'remarks': 'vehicle_plate',
                'answer_text': visitor.licensePlateCtrl.text.trim(),
              },
          ],
        ],
      },
      if (visitor.uploadedSelfieUrl != null ||
          visitor.uploadedKtpUrl != null) ...[
        {
          'sort': 1,
          'name': 'Documents',
          'status': 1,
          'is_document': true,
          'can_multiple_used': false,
          'self_only': false,
          'form': [
            if (visitor.uploadedSelfieUrl != null)
              {
                'sort': 0,
                'short_name': 'Selfie',
                'long_display_text': 'Selfie Image',
                'field_type': 10,
                'is_primary': false,
                'is_enable': true,
                'mandatory': false,
                'remarks': 'selfie_image',
                'answer_file': visitor.uploadedSelfieUrl,
              },
            if (visitor.uploadedKtpUrl != null)
              {
                'sort': 1,
                'short_name': 'Identity',
                'long_display_text': 'Identity Image',
                'field_type': 12,
                'is_primary': false,
                'is_enable': true,
                'mandatory': false,
                'remarks': 'identity_image',
                'answer_file': visitor.uploadedKtpUrl,
              },
          ],
        },
      ],
    ];
  }

  /// Submit form to POST /api/visitor/add-visit
  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    final token = _hive.getUser()?.token ?? '';
    final user = _hive.getUser();

    // 1. Upload files for each visitor to CDN
    for (int i = 0; i < _visitors.length; i++) {
      final v = _visitors[i];

      if (v.selfieFile != null && v.selfieFile!.bytes != null) {
        try {
          final url = await _api.uploadCdnFile(
            v.selfieFile!.bytes!,
            v.selfieFile!.name,
            path: 'face',
          );
          v.uploadedSelfieUrl = url;
        } catch (e) {
          debugPrint('Error uploading selfie for Visitor ${i + 1}: $e');
        }
      }

      if (v.ktpFile != null && v.ktpFile!.bytes != null) {
        try {
          final url = await _api.uploadCdnFile(
            v.ktpFile!.bytes!,
            v.ktpFile!.name,
            path: 'face',
          );
          v.uploadedKtpUrl = url;
        } catch (e) {
          debugPrint('Error uploading KTP for Visitor ${i + 1}: $e');
        }
      }
    }

    // 2. Build ISO datetimes
    final startIso = widget.item.visitorPeriodStart
        .toUtc()
        .toIso8601String()
        .substring(0, 19);
    final endIso = widget.item.visitorPeriodEnd
        .toUtc()
        .toIso8601String()
        .substring(0, 19);

    // 3. Build data_visitor array
    final List<Map<String, dynamic>> dataVisitors = [];
    for (final v in _visitors) {
      final qPage = _buildQuestionPagesForVisitor(
        visitor: v,
        startIso: startIso,
        endIso: endIso,
      );
      final isArriving = v.arrivingByVehicle != 'no';
      final isBicycle = _isBicycle(v.vehicleType);
      dataVisitors.add({
        'question_page': qPage,
        'is_driving': isArriving,
        'vehicle_type': isArriving ? v.vehicleType : null,
        'vehicle_plate_number': (isArriving && !isBicycle)
            ? (v.licensePlateCtrl.text.trim().isNotEmpty
                  ? v.licensePlateCtrl.text.trim()
                  : null)
            : null,
      });
    }

    final firstVisitor = _visitors.first;
    final filledByName = (user?.fullname != null && user!.fullname!.isNotEmpty)
        ? user.fullname!
        : ((user?.username != null && user!.username!.isNotEmpty)
              ? user.username!
              : firstVisitor.fullNameCtrl.text.trim());
    final filledByEmail = (user?.email != null && user!.email!.isNotEmpty)
        ? user.email!
        : firstVisitor.emailCtrl.text.trim();
    final filledByPhone = (user?.phone != null && user!.phone!.isNotEmpty)
        ? user.phone!
        : firstVisitor.phoneCtrl.text.trim();

    final trxId = _transactionId;
    final resolvedVisitorType = _formVisitorTypeId.isNotEmpty
        ? _formVisitorTypeId
        : widget.item.visitorTypeId;
    final resolvedSiteId = _formSiteId.isNotEmpty
        ? _formSiteId
        : widget.item.siteId;
    final resolvedTz = _formTz.isNotEmpty
        ? _formTz
        : (widget.item.tz.isNotEmpty ? widget.item.tz : 'Asia/Jakarta');

    final isFirstArriving = firstVisitor.arrivingByVehicle != 'no';
    final isFirstBicycle = _isBicycle(firstVisitor.vehicleType);

    final payload = {
      'transaction_visitor_id': trxId,
      'visitor_type': resolvedVisitorType,
      'type_registered': 1,
      'is_group': widget.item.isGroup || _visitors.length > 1,
      'tz': resolvedTz,
      'registered_site': resolvedSiteId,
      'flow': widget.item.flow.isNotEmpty ? widget.item.flow : 'Invitation',
      'visitor_role': widget.item.visitorRole.isNotEmpty
          ? widget.item.visitorRole
          : 'Visitor',
      'is_self_registered': true,
      'filled_by_name': filledByName,
      'filled_by_email': filledByEmail,
      'filled_by_phone': filledByPhone,
      'filled_by_relationship': 'Self',
      'filled_by_relationship_name': 'Self',
      'is_driving': isFirstArriving,
      'vehicle_type': isFirstArriving ? firstVisitor.vehicleType : null,
      'vehicle_plate_number': (isFirstArriving && !isFirstBicycle)
          ? (firstVisitor.licensePlateCtrl.text.trim().isNotEmpty
                ? firstVisitor.licensePlateCtrl.text.trim()
                : null)
          : null,
      'data_visitor': dataVisitors,
    };

    try {
      debugPrint(
        '[_handleSubmit] Submitting payload with trxId=$trxId to POST /api/visitor/add-visit',
      );
      final response = await _api.submitAddVisitor(token, payload);

      final isSuccess =
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          (response.data is Map &&
              (response.data['status'] == 'success' ||
                  response.data['status_code'] == 200));

      if (isSuccess) {
        Navigator.pop(context, true);
        widget.onSuccess?.call();

        Get.snackbar(
          'Success',
          'Visitor added successfully!',
          backgroundColor: const Color(0xFF43A047),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      } else {
        String errorMsg =
            (response.data is Map &&
                (response.data['msg'] != null ||
                    response.data['message'] != null))
            ? (response.data['msg'] ?? response.data['message']).toString()
            : 'Failed to add visitor (${response.statusCode}). Please try again.';

        if (errorMsg.toLowerCase().contains('already been invited')) {
          errorMsg =
              'Visitor has already been invited: This visitor email has already been invited or registered for this visit. Please use a different email.';
        } else if (errorMsg.startsWith('Failed Message: ')) {
          errorMsg = errorMsg.replaceFirst('Failed Message: ', '');
        }

        Get.snackbar(
          'Error',
          errorMsg,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: rw(context, 16),
        vertical: rh(context, 20),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rw(context, 16)),
      ),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
          maxWidth: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Dialog Header (Title + Stepper) ──
            _buildDialogHeader(),

            // ── Scrollable Body ──
            Flexible(
              child: _isLoadingForm
                  ? _buildShimmerSkeleton()
                  : Container(
                      color: const Color(0xFFF8FAFC),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 16),
                          vertical: rh(context, 16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_currentStep == 1) ...[
                              _buildStep1PurposeVisit(),
                            ] else ...[
                              _buildStep2VisitorInformation(),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),

            // ── Bottom Action Bar ──
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  /// ─── Dialog Header: Title + Stepper (Matching Create Invitation) ───
  Widget _buildDialogHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Title Bar
          Padding(
            padding: EdgeInsets.fromLTRB(
              rw(context, 16),
              rh(context, 12),
              rw(context, 10),
              rh(context, 10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Visitor',
                    style: TextStyle(
                      fontSize: rfs(context, 16),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (!_isSubmitting) Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stepper: Bubbles & Connecting Lines
          Container(
            color: const Color(0xFFFAFCFF),
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 12),
              vertical: rh(context, 10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Step 1 Bubble
                    GestureDetector(
                      onTap: _currentStep > 1
                          ? () => setState(() => _currentStep = 1)
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentStep >= 1
                              ? AppColors.primary500
                              : const Color(0xFFCBD5E1),
                        ),
                        child: Center(
                          child: _currentStep > 1
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : Text(
                                  '1',
                                  style: TextStyle(
                                    fontSize: rfs(context, 12),
                                    fontWeight: _currentStep == 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    // Connector Line
                    Container(
                      width: rw(context, 36),
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: _currentStep >= 2
                          ? AppColors.primary500
                          : const Color(0xFFCBD5E1),
                    ),
                    // Step 2 Bubble
                    GestureDetector(
                      onTap: () {
                        setState(() => _currentStep = 2);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentStep == 2
                              ? AppColors.primary500
                              : const Color(0xFFCBD5E1),
                        ),
                        child: Center(
                          child: Text(
                            '2',
                            style: TextStyle(
                              fontSize: rfs(context, 12),
                              fontWeight: _currentStep == 2
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                vSpace(context, 8),
                // Current Step Title Indicator Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Step $_currentStep of 2: ${_currentStep == 1 ? "Purpose Visit" : "Visitor Information"}',
                    style: TextStyle(
                      fontSize: rfs(context, 12),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }

  /// ─── Step 1: Purpose Visit (Pre-filled & Read-only) ───
  Widget _buildStep1PurposeVisit() {
    final destination = widget.item.sitePlaceName.isNotEmpty
        ? widget.item.sitePlaceName
        : (widget.item.siteId.isNotEmpty ? widget.item.siteId : '-');
    final host = widget.item.hostName.isNotEmpty
        ? widget.item.hostName
        : (widget.item.host.isNotEmpty ? widget.item.host : '-');
    final agenda = widget.item.agenda.isNotEmpty ? widget.item.agenda : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Destination
        _buildFieldLabel(context, 'Destination'),
        vSpace(context, 6),
        _buildReadOnlyField(value: destination),
        vSpace(context, 14),

        // PIC Host
        _buildFieldLabel(context, 'PIC Host'),
        vSpace(context, 6),
        _buildReadOnlyField(value: host),
        vSpace(context, 14),

        // Agenda
        _buildFieldLabel(context, 'Agenda'),
        vSpace(context, 6),
        _buildReadOnlyField(value: agenda),
        vSpace(context, 14),

        // Visit Start & Visit End
        _buildFieldLabel(context, 'Visit Start'),
        vSpace(context, 6),
        _buildReadOnlyField(
          value: _formatDateTime(widget.item.visitorPeriodStart),
          trailingIcon: Icons.calendar_today_outlined,
        ),
        vSpace(context, 14),

        _buildFieldLabel(context, 'Visit End'),
        vSpace(context, 6),
        _buildReadOnlyField(
          value: _formatDateTime(widget.item.visitorPeriodEnd),
          trailingIcon: Icons.calendar_today_outlined,
        ),
        vSpace(context, 8),
      ],
    );
  }

  /// ─── Step 2: Visitor Information (Clean & Simple matching Create Invitation) ───
  Widget _buildStep2VisitorInformation() {
    final safeIndex = _selectedVisitorIndex < _visitors.length
        ? _selectedVisitorIndex
        : 0;
    final v = _visitors[safeIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Member Tabs + Add Button
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...List.generate(_visitors.length, (i) {
                final isSelected = safeIndex == i;
                final isComplete = _isVisitorComplete(i);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    showCheckmark: false,
                    avatar: isComplete
                        ? Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary500,
                          )
                        : null,
                    label: Text('Visitor ${i + 1}'),
                    selected: isSelected,
                    selectedColor: AppColors.primary500,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: rfs(context, 12),
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary500
                          : const Color(0xFFCBD5E1),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) {
                      setState(() => _selectedVisitorIndex = i);
                    },
                  ),
                );
              }),
              ActionChip(
                avatar: const Icon(
                  Icons.add,
                  size: 16,
                  color: AppColors.primary500,
                ),
                label: const Text('Add Visitor'),
                labelStyle: TextStyle(
                  color: AppColors.primary500,
                  fontWeight: FontWeight.w600,
                  fontSize: rfs(context, 12),
                ),
                backgroundColor: const Color(0xFFEFF6FF),
                side: const BorderSide(color: Color(0xFF93C5FD)),
                onPressed: _addVisitorCard,
              ),
            ],
          ),
        ),

        vSpace(context, 8),

        // Delete button if more than 1 member
        if (_visitors.length > 1)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error500,
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 6),
                  vertical: rh(context, 2),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              icon: Icon(
                Icons.delete_outline_rounded,
                size: rw(context, 14),
                color: AppColors.error500,
              ),
              label: Text(
                'Remove this Visitor',
                style: GoogleFonts.inter(
                  fontSize: rfs(context, 11.5),
                  fontWeight: FontWeight.w500,
                  color: AppColors.error500,
                ),
              ),
              onPressed: () => _removeVisitorCard(safeIndex),
            ),
          ),

        vSpace(context, 6),

        // Quick Search for current visitor matching Create Invitation
        _buildSearchBox(
          context,
          hint: _visitors.length > 1
              ? 'Search Visitor (Visitor ${safeIndex + 1})'
              : 'Search Visitor',
          controller: v.searchCtrl,
          isOpen: v.isSearchOpen,
          items: _getFilteredVisitors(safeIndex),
          isLoading: _isLoadingVisitors,
          onToggleOpen: () {
            setState(() {
              v.isSearchOpen = !v.isSearchOpen;
            });
          },
          onChanged: (val) {
            setState(() {
              v.isSearchOpen = true;
            });
          },
          onSelect: (item) {
            _onSelectVisitor(safeIndex, item);
          },
          onClear: () {
            _onClearVisitorSearch(safeIndex);
          },
        ),

        vSpace(context, 12),

        // Full Name
        if (_isFieldEnabled('name')) ...[
          _buildFieldLabel(
            context,
            _getFieldLabel('name', 'Full Name'),
            isRequired: _isFieldMandatory('name', defaultVal: true),
          ),
          vSpace(context, 6),
          _buildTextInputField(
            context,
            controller: v.fullNameCtrl,
            hintText: 'Enter full name',
            onChanged: (_) => setState(() {}),
          ),
          vSpace(context, 14),
        ],

        // Email
        if (_isFieldEnabled('email')) ...[
          _buildFieldLabel(
            context,
            _getFieldLabel('email', 'Email'),
            isRequired: _isFieldMandatory('email', defaultVal: true),
          ),
          vSpace(context, 6),
          _buildTextInputField(
            context,
            controller: v.emailCtrl,
            hintText: 'Enter email address',
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
          ),
          vSpace(context, 14),
        ],

        // Phone
        if (_isFieldEnabled('phone')) ...[
          _buildFieldLabel(
            context,
            _getFieldLabel('phone', 'Phone'),
            isRequired: _isFieldMandatory('phone', defaultVal: true),
          ),
          vSpace(context, 6),
          _buildTextInputField(
            context,
            controller: v.phoneCtrl,
            hintText: 'Enter phone number',
            keyboardType: TextInputType.phone,
            onChanged: (_) => setState(() {}),
          ),
          vSpace(context, 14),
        ],

        // Department / Organization / Company
        if (_isFieldEnabled('organization')) ...[
          _buildFieldLabel(
            context,
            _getFieldLabel(
              'organization',
              'Department / Organization / Company',
            ),
            isRequired: _isFieldMandatory('organization', defaultVal: true),
          ),
          vSpace(context, 6),
          _buildTextInputField(
            context,
            controller: v.orgCtrl,
            hintText: 'Enter department / organization / company',
            onChanged: (_) => setState(() {}),
          ),
          vSpace(context, 16),
        ],

        // Vehicle Info
        if (_isFieldEnabled('is_driving')) ...[
          _buildFieldLabel(
            context,
            _getFieldLabel('is_driving', 'Are you arriving by vehicle?'),
            isRequired: _isFieldMandatory('is_driving', defaultVal: true),
          ),
          vSpace(context, 6),
          Row(
            children: [
              _buildRadioOption(
                context,
                label: 'Yes',
                isSelected: v.arrivingByVehicle != 'no',
                onTap: () {
                  setState(() {
                    v.arrivingByVehicle = 'yes';
                    if (v.vehicleType.isEmpty &&
                        _vehicleTypeOptions.isNotEmpty) {
                      v.vehicleType = _vehicleTypeOptions.first;
                    }
                  });
                },
              ),
              hSpace(context, 20),
              _buildRadioOption(
                context,
                label: 'No',
                isSelected: v.arrivingByVehicle == 'no',
                onTap: () {
                  setState(() => v.arrivingByVehicle = 'no');
                },
              ),
            ],
          ),

          if (v.arrivingByVehicle != 'no') ...[
            if (_isFieldEnabled('vehicle_type')) ...[
              vSpace(context, 14),
              _buildFieldLabel(
                context,
                _getFieldLabel('vehicle_type', 'Vehicle Type'),
                isRequired: _isFieldMandatory(
                  'vehicle_type',
                  defaultVal: false,
                ),
              ),
              vSpace(context, 6),
              _buildDropdownField<String>(
                context,
                hintText: 'Select Vehicle Type',
                value: v.vehicleType.isNotEmpty
                    ? v.vehicleType
                    : (_vehicleTypeOptions.isNotEmpty
                          ? _vehicleTypeOptions.first
                          : null),
                items: _vehicleTypeOptions
                    .map(
                      (opt) => DropdownMenuItem<String>(
                        value: opt,
                        child: Text(_formatOption(opt)),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => v.vehicleType = val);
                  }
                },
              ),
            ],
            if (!_isBicycle(v.vehicleType) &&
                _isFieldEnabled('vehicle_plate')) ...[
              vSpace(context, 14),
              _buildFieldLabel(
                context,
                _getFieldLabel('vehicle_plate', 'License Plate Number'),
                isRequired: _isFieldMandatory(
                  'vehicle_plate',
                  defaultVal: false,
                ),
              ),
              vSpace(context, 6),
              _buildTextInputField(
                context,
                controller: v.licensePlateCtrl,
                hintText: 'e.g. B 1234 ABC',
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ],
          vSpace(context, 16),
        ],

        // Photos & Documents
        if (_hasSelfieDocument) ...[
          _buildFieldLabel(
            context,
            _getFieldLabel('selfie_image', 'Selfie Photo'),
            isRequired: _isFieldMandatory('selfie_image', defaultVal: false),
          ),
          vSpace(context, 6),
          if (v.selfieFile != null)
            _buildImagePreview(
              context,
              fileData: v.selfieFile!,
              onRemove: () {
                setState(() => v.selfieFile = null);
                _showUploadSnackbar(
                  type: UploadFeedbackType.remove,
                  isKtp: false,
                );
              },
              onRetake: () => _handlePhotoRetake(
                context,
                visitorIndex: safeIndex,
                isKtp: false,
              ),
            )
          else
            _buildUploadPlaceholder(
              context,
              title: 'Take Selfie or Choose File',
              onCamera: () =>
                  _pickImageDirect(safeIndex, isKtp: false, fromCamera: true),
              onGallery: () =>
                  _pickImageDirect(safeIndex, isKtp: false, fromCamera: false),
            ),
          vSpace(context, 14),
        ],

        if (_hasKtpDocument) ...[
          _buildFieldLabel(
            context,
            _getFieldLabel('identity_image', 'Identity Card / KTP (Optional)'),
            isRequired: _isFieldMandatory('identity_image', defaultVal: false),
          ),
          vSpace(context, 6),
          if (v.ktpFile != null)
            _buildImagePreview(
              context,
              fileData: v.ktpFile!,
              onRemove: () {
                setState(() => v.ktpFile = null);
                _showUploadSnackbar(
                  type: UploadFeedbackType.remove,
                  isKtp: true,
                );
              },
              onRetake: () => _handlePhotoRetake(
                context,
                visitorIndex: safeIndex,
                isKtp: true,
              ),
            )
          else
            _buildUploadPlaceholder(
              context,
              title: 'Take Identity (KTP) or Choose File',
              onCamera: () =>
                  _pickImageDirect(safeIndex, isKtp: true, fromCamera: true),
              onGallery: () =>
                  _pickImageDirect(safeIndex, isKtp: true, fromCamera: false),
            ),
          vSpace(context, 14),
        ],
      ],
    );
  }

  /// ─── Photo Retake Bottom Sheet ───
  Future<void> _handlePhotoRetake(
    BuildContext context, {
    required int visitorIndex,
    required bool isKtp,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rw(ctx, 20),
            vertical: rh(ctx, 16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              vSpace(ctx, 16),
              Text(
                isKtp ? 'Retake KTP Photo' : 'Retake Selfie Photo',
                style: GoogleFonts.inter(
                  fontSize: rfs(ctx, 15),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F2B48),
                ),
                textAlign: TextAlign.center,
              ),
              vSpace(ctx, 4),
              Text(
                'Select photo source',
                style: GoogleFonts.inter(
                  fontSize: rfs(ctx, 12),
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              vSpace(ctx, 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.primary500,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Camera',
                  style: GoogleFonts.inter(
                    fontSize: rfs(ctx, 13.5),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: AppColors.primary500,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Gallery',
                  style: GoogleFonts.inter(
                    fontSize: rfs(ctx, 13.5),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      _pickImageDirect(
        visitorIndex,
        isKtp: isKtp,
        fromCamera: source == ImageSource.camera,
        isRetry: true,
      );
    }
  }

  /// ─── Upload Placeholder (Matching Create Invitation) ───
  Widget _buildUploadPlaceholder(
    BuildContext context, {
    required String title,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    return Container(
      padding: EdgeInsets.all(rw(context, 18)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 36,
            color: Colors.blue.shade600,
          ),
          vSpace(context, 8),
          Text(
            title,
            style: TextStyle(
              fontSize: rfs(context, 13),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          vSpace(context, 4),
          Text(
            'Supports JPG, JPEG, and PNG only',
            style: TextStyle(
              fontSize: rfs(context, 11),
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w400,
            ),
          ),
          vSpace(context, 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.camera_alt, size: 16),
                label: const Text('Camera'),
                onPressed: onCamera,
              ),
              hSpace(context, 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary500,
                  side: const BorderSide(color: AppColors.primary500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.photo_library, size: 16),
                label: const Text('Gallery'),
                onPressed: onGallery,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ─── Image Preview (Matching Create Invitation) ───
  Widget _buildImagePreview(
    BuildContext context, {
    required InvitationVisitorUploadedFile fileData,
    required VoidCallback onRemove,
    required VoidCallback onRetake,
  }) {
    return Container(
      padding: EdgeInsets.all(rw(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: fileData.bytes != null
                ? Image.memory(
                    fileData.bytes!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : (fileData.localPath.isNotEmpty
                      ? Image.file(
                          File(fileData.localPath),
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(height: 160)),
          ),
          vSpace(context, 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileData.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      fileData.formattedSize,
                      style: TextStyle(
                        fontSize: rfs(context, 11),
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: AppColors.primary500,
                  size: 20,
                ),
                tooltip: 'Retake',
                onPressed: onRetake,
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
                tooltip: 'Remove',
                onPressed: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ─── Clean Radio Option (Matching Create Invitation) ───
  Widget _buildRadioOption(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 18,
            color: isSelected ? AppColors.primary500 : const Color(0xFF94A3B8),
          ),
          hSpace(context, 6),
          Text(
            label,
            style: TextStyle(
              fontSize: rfs(context, 13),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? AppColors.primary500
                  : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  /// ─── Dropdown Field (Matching Create Invitation with DropdownButton2) ───
  Widget _buildDropdownField<T>(
    BuildContext context, {
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
    IconData? prefixIcon,
  }) {
    final hasMatchingItem = items.any((i) => i.value == value);
    final resolvedValue = hasMatchingItem ? value : null;
    final isSelected =
        resolvedValue != null &&
        (resolvedValue is! String || (resolvedValue as String).isNotEmpty);

    return Container(
      height: rh(context, 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1),
          width: 1.2,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<T>(
          isExpanded: true,
          value: resolvedValue,
          hint: Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, size: 18, color: const Color(0xFF94A3B8)),
                hSpace(context, 8),
              ],
              Expanded(
                child: Text(
                  hintText ?? 'Select an option',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: rfs(context, 13),
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          selectedItemBuilder: (BuildContext context) {
            return items.map((item) {
              return Row(
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, size: 18, color: AppColors.primary500),
                    hSpace(context, 8),
                  ],
                  Expanded(
                    child: DefaultTextStyle(
                      style: GoogleFonts.inter(
                        fontSize: rfs(context, 13),
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: item.child,
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: items.map((item) {
            final isItemActive = item.value == resolvedValue;
            return DropdownMenuItem<T>(
              value: item.value,
              enabled: item.enabled,
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    Icon(
                      prefixIcon,
                      size: 18,
                      color: isItemActive
                          ? AppColors.primary500
                          : const Color(0xFF64748B),
                    ),
                    hSpace(context, 8),
                  ],
                  Expanded(
                    child: DefaultTextStyle(
                      style: GoogleFonts.inter(
                        fontSize: rfs(context, 13),
                        color: isItemActive
                            ? AppColors.primary500
                            : const Color(0xFF0F172A),
                        fontWeight: isItemActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: item.child,
                    ),
                  ),
                  if (isItemActive) ...[
                    const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.primary500,
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
          buttonStyleData: ButtonStyleData(
            height: rh(context, 48),
            padding: EdgeInsets.only(
              left: prefixIcon != null ? 0 : rw(context, 12),
              right: rw(context, 12),
            ),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B),
              size: 20,
            ),
            openMenuIcon: Icon(
              Icons.keyboard_arrow_up_rounded,
              color: AppColors.primary500,
              size: 20,
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: rh(context, 260),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            offset: const Offset(0, -4),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(4),
              thickness: WidgetStateProperty.all(4),
              thumbColor: WidgetStateProperty.all(const Color(0xFFCBD5E1)),
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            height: rh(context, 42),
            padding: EdgeInsets.symmetric(horizontal: rw(context, 12)),
          ),
        ),
      ),
    );
  }

  /// ─── Search Box Matching Create Invitation ───
  Widget _buildSearchBox(
    BuildContext context, {
    required String hint,
    required TextEditingController controller,
    required bool isOpen,
    required List<Map<String, dynamic>> items,
    required bool isLoading,
    required VoidCallback onToggleOpen,
    required ValueChanged<String> onChanged,
    required ValueChanged<Map<String, dynamic>> onSelect,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onTap: onToggleOpen,
            style: TextStyle(
              fontSize: rfs(context, 13),
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: rfs(context, 13),
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: rw(context, 38),
                minHeight: rh(context, 44),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(
                  left: rw(context, 12),
                  right: rw(context, 8),
                ),
                child: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
              ),
              suffixIconConstraints: BoxConstraints(
                minWidth: rw(context, 36),
                minHeight: rh(context, 44),
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: rw(context, 8)),
                child: controller.text.isNotEmpty
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                        onPressed: onClear,
                      )
                    : IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          size: 20,
                          color: const Color(0xFF64748B),
                        ),
                        onPressed: onToggleOpen,
                      ),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: rh(context, 12),
              ),
              border: InputBorder.none,
            ),
          ),
        ),

        // Search results dropdown overlay box
        if (isOpen) ...[
          vSpace(context, 4),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            elevation: 3,
            shadowColor: Colors.black.withValues(alpha: 0.12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: isLoading && items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      child: Center(
                        child: Text(
                          'Loading visitors...',
                          style: TextStyle(
                            fontSize: rfs(context, 12),
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    )
                  : items.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          child: Center(
                            child: Text(
                              controller.text.trim().isEmpty
                                  ? 'No visitors registered yet'
                                  : 'No visitors found matching "${controller.text.trim()}"',
                              style: TextStyle(
                                fontSize: rfs(context, 12),
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: items.take(15).length,
                          separatorBuilder: (_, index) =>
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (ctx, i) {
                            final it = items[i];
                            final name = (it['name'] ?? it['visitor_name'] ?? '').toString();
                            final email = (it['email'] ?? '').toString();
                            final phone = (it['phone'] ?? '').toString();

                            return ListTile(
                              dense: true,
                              title: Text(
                                name,
                                style: TextStyle(
                                  fontSize: rfs(ctx, 13),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              subtitle: Text(
                                email.isNotEmpty ? email : phone,
                                style: TextStyle(
                                  fontSize: rfs(ctx, 11),
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              onTap: () => onSelect(it),
                            );
                          },
                        ),
            ),
          ),
        ],
      ],
    );
  }

  /// ─── Standard Clean Text Input Field (No Prefix Icon, Matching Create Invitation) ───
  Widget _buildTextInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        onChanged: onChanged,
        style: TextStyle(fontSize: rfs(context, 13)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: rfs(context, 12.5),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: rw(context, 12),
            vertical: rh(context, 11),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  /// ─── Read-only Field Box for Step 1 ───
  Widget _buildReadOnlyField({required String value, IconData? trailingIcon}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 12),
        vertical: rh(context, 11),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: rfs(context, 13),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailingIcon != null) ...[
            hSpace(context, 8),
            Icon(
              trailingIcon,
              size: rw(context, 16),
              color: Colors.grey.shade500,
            ),
          ],
        ],
      ),
    );
  }

  /// ─── Field Label with Red Asterisk (Matching Create Invitation) ───
  Widget _buildFieldLabel(
    BuildContext context,
    String label, {
    bool isRequired = false,
  }) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: rfs(context, 12.5),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF334155),
        ),
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            : null,
      ),
    );
  }

  /// ─── Bottom Action Bar (Back / Next / Submit) ───
  Widget _buildBottomActionBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 20),
        vertical: rh(context, 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          OutlinedButton.icon(
            onPressed: _isSubmitting
                ? null
                : () {
                    if (_currentStep == 2) {
                      setState(() => _currentStep = 1);
                    } else {
                      Navigator.pop(context);
                    }
                  },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 16),
                vertical: rh(context, 10),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(
              Icons.arrow_back_rounded,
              size: rw(context, 16),
              color: Colors.grey.shade700,
            ),
            label: Text(
              _currentStep == 1 ? 'Cancel' : 'Back',
              style: TextStyle(
                fontSize: rfs(context, 13),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          // Next / Submit Button
          if (_currentStep == 1)
            ElevatedButton(
              onPressed: _isLoadingForm
                  ? null
                  : () => setState(() => _currentStep = 2),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 20),
                  vertical: rh(context, 10),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Next',
                    style: TextStyle(
                      fontSize: rfs(context, 13),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  hSpace(context, 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: rw(context, 16),
                    color: Colors.white,
                  ),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: (_isSubmitting || !_canSubmit) ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSubmit
                    ? AppColors.primary500
                    : const Color(0xFFCBD5E1),
                foregroundColor: _canSubmit
                    ? Colors.white
                    : const Color(0xFF94A3B8),
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                disabledForegroundColor: const Color(0xFF94A3B8),
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 24),
                  vertical: rh(context, 10),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_upload_rounded,
                          size: rw(context, 16),
                          color: Colors.white,
                        ),
                        hSpace(context, 8),
                        Text(
                          'Submitting...',
                          style: TextStyle(
                            fontSize: rfs(context, 13),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: rfs(context, 13),
                        fontWeight: FontWeight.bold,
                        color: _canSubmit
                            ? Colors.white
                            : const Color(0xFF94A3B8),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  /// ─── Shimmer Skeleton Loader (Strictly NO CircularProgressIndicator) ───
  Widget _buildShimmerSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: rw(context, 20),
          vertical: rh(context, 14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < 5; i++) ...[
              Container(
                width: rw(context, 120),
                height: rh(context, 14),
                color: Colors.white,
              ),
              vSpace(context, 6),
              Container(
                height: rh(context, 42),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              vSpace(context, 14),
            ],
          ],
        ),
      ),
    );
  }
}
