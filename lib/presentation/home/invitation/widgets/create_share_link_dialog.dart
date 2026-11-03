import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/components/custom_date_time_picker.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../controller/invitation_controller.dart';

class CreateShareLinkDialog extends StatefulWidget {
  final Map<String, dynamic>? duplicateData;
  const CreateShareLinkDialog({super.key, this.duplicateData});

  @override
  State<CreateShareLinkDialog> createState() => _CreateShareLinkDialogState();
}

class _CreateShareLinkDialogState extends State<CreateShareLinkDialog> {
  final InvitationController controller = Get.find<InvitationController>();
  final _formKey = GlobalKey<FormState>();
  bool _success = false;

  // Form States & Toggles (Aligned with Web: CreateLinkDialog)
  bool isVisitorTypeEnabled = false;
  String? selectedVisitorTypeId;
  Map<String, dynamic>? selectedVisitorTypeData;

  bool isVisitStartEnabled = false;
  DateTime? visitStart;

  bool isVisitEndEnabled = false;
  DateTime? visitEnd;

  bool isExpiredEnabled = false;
  String? selectedExpiredMinutes = '30';

  bool isQuotaEnabled = false;
  final TextEditingController quotaCtrl = TextEditingController(text: '0');

  bool isSingleUse = false;

  // Web Expired Link Options: 30 Min, 1 Hour, 3 Hour, 1 Day
  final List<Map<String, dynamic>> expiryOptions = [
    {'id': '30', 'name': '30 Min'},
    {'id': '60', 'name': '1 Hour'},
    {'id': '180', 'name': '3 Hour'},
    {'id': '1440', 'name': '1 Day'},
  ];

  @override
  void initState() {
    super.initState();
    controller.fetchMasterData();
    if (widget.duplicateData != null) {
      final data = widget.duplicateData!;

      // 1. Visitor Type
      dynamic vTypeRaw = data['visitor_type_id'] ?? data['visitor_type'];
      String vTypeVal = '';
      if (vTypeRaw != null) {
        if (vTypeRaw is Map) {
          vTypeVal = (vTypeRaw['id'] ?? vTypeRaw['visitor_type_id'] ?? '').toString();
        } else {
          vTypeVal = vTypeRaw.toString();
        }
      }
      if (vTypeVal.isNotEmpty && vTypeVal != 'null') {
        isVisitorTypeEnabled = true;
        selectedVisitorTypeId = vTypeVal;
        selectedVisitorTypeData = controller.visitorTypes.firstWhereOrNull(
          (vt) => (vt['id']?.toString() ?? '') == vTypeVal,
        );
      }

      // 2. Expiry & Quota limits
      final expiredVal = (data['expired_number'] ?? 0).toString();
      if (expiredVal != '0' && expiredVal.isNotEmpty) {
        isExpiredEnabled = true;
        selectedExpiredMinutes = expiredVal;
      }

      final maxUsage = data['max_usage'] as int? ?? 0;
      isSingleUse = data['is_single_use'] == true || maxUsage == 1;
      if (maxUsage > 0 || isSingleUse) {
        isQuotaEnabled = true;
        quotaCtrl.text = maxUsage.toString();
      }

      // 3. Visit Start & End
      final startVal = data['visitor_period_start']?.toString();
      if (startVal != null && startVal.isNotEmpty && startVal != 'null') {
        isVisitStartEnabled = true;
        String normalized = startVal;
        if (!normalized.endsWith('Z') && !normalized.contains('+')) {
          normalized = '${normalized.replaceFirst(' ', 'T')}Z';
        }
        visitStart = DateTime.tryParse(normalized)?.toLocal();
      }

      final endVal = data['visitor_period_end']?.toString();
      if (endVal != null && endVal.isNotEmpty && endVal != 'null') {
        isVisitEndEnabled = true;
        String normalized = endVal;
        if (!normalized.endsWith('Z') && !normalized.contains('+')) {
          normalized = '${normalized.replaceFirst(' ', 'T')}Z';
        }
        visitEnd = DateTime.tryParse(normalized)?.toLocal();
      }
    }
  }

  @override
  void dispose() {
    quotaCtrl.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    return isVisitorTypeEnabled ||
        isVisitStartEnabled ||
        isVisitEndEnabled ||
        isExpiredEnabled ||
        (isQuotaEnabled && quotaCtrl.text.trim().isNotEmpty && quotaCtrl.text.trim() != '0') ||
        isSingleUse;
  }

  Future<bool> _showExitConfirmation() async {
    final hasData = _hasChanges();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rw(context, 20)),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: rw(context, 32),
          vertical: rh(context, 24),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            rw(context, 20),
            rh(context, 24),
            rw(context, 20),
            rh(context, 20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: rw(context, 54),
                height: rw(context, 54),
                decoration: BoxDecoration(
                  color: hasData ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasData ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
                  size: rw(context, 28),
                  color: hasData ? const Color(0xFFDC2626) : const Color(0xFF475569),
                ),
              ),
              SizedBox(height: rh(context, 16)),
              Text(
                hasData ? 'Discard Progress?' : 'Close Form?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: rfs(context, 18),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: rh(context, 8)),
              Text(
                hasData
                    ? 'You have unsaved changes. Are you sure you want to discard them?'
                    : 'Are you sure you want to close this form?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: rfs(context, 13),
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              SizedBox(height: rh(context, 22)),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: rh(context, 42),
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          backgroundColor: const Color(0xFFF8FAFC),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(rw(context, 10)),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'No',
                          style: TextStyle(
                            fontSize: rfs(context, 14),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: rw(context, 12)),
                  Expanded(
                    child: SizedBox(
                      height: rh(context, 42),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(rw(context, 10)),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          hasData ? 'Yes, Continue' : 'Yes, Close',
                          style: TextStyle(
                            fontSize: rfs(context, 14),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _success,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_success && mounted) {
          Navigator.of(context).pop();
          return;
        }
        final navigator = Navigator.of(context);
        final shouldExit = await _showExitConfirmation();
        if (shouldExit && mounted) {
          navigator.pop();
        }
      },
      child: Dialog(
        insetPadding: EdgeInsets.all(rw(context, 16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rw(context, 16))),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(rw(context, 20)),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Create Link Invitation',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: rfs(context, 17),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          if (await _showExitConfirmation()) {
                            if (mounted) navigator.pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(),
                vSpace(context, 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Visitor Type
                        _buildFieldRow(
                          label: 'Visitor Type',
                          isEnabled: isVisitorTypeEnabled,
                          onToggle: (v) => setState(() {
                            isVisitorTypeEnabled = v;
                            if (!v) {
                              selectedVisitorTypeId = null;
                              selectedVisitorTypeData = null;
                            }
                          }),
                          input: Obx(() => _buildDropdown(
                            hint: 'Select Visitor Type',
                            value: selectedVisitorTypeId,
                            items: controller.visitorTypes
                                .map<Map<String, dynamic>>((vt) => {
                                      'id': vt['id']?.toString() ?? '',
                                      'name': vt['name']?.toString() ?? '',
                                    })
                                .toList(),
                            enabled: isVisitorTypeEnabled,
                            onChanged: (v) => setState(() {
                              selectedVisitorTypeId = v;
                              selectedVisitorTypeData = controller.visitorTypes.firstWhereOrNull(
                                (vt) => (vt['id']?.toString() ?? '') == v,
                              );
                            }),
                          )),
                        ),

                        // 2. Visit Start
                        _buildFieldRow(
                          label: 'Visit Start',
                          isEnabled: isVisitStartEnabled,
                          onToggle: (v) => setState(() {
                            isVisitStartEnabled = v;
                            if (!v) visitStart = null;
                          }),
                          input: _buildDateTimePicker(
                            value: visitStart,
                            enabled: isVisitStartEnabled,
                            onTap: () => _pickDateTime(true),
                            onClear: () => setState(() => visitStart = null),
                          ),
                        ),

                        // 3. Visit End
                        _buildFieldRow(
                          label: 'Visit End',
                          isEnabled: isVisitEndEnabled,
                          onToggle: (v) => setState(() {
                            isVisitEndEnabled = v;
                            if (!v) visitEnd = null;
                          }),
                          input: _buildDateTimePicker(
                            value: visitEnd,
                            enabled: isVisitEndEnabled,
                            onTap: () => _pickDateTime(false),
                            onClear: () => setState(() => visitEnd = null),
                          ),
                        ),

                        // 4. Expired Link
                        _buildFieldRow(
                          label: 'Expired Link',
                          isEnabled: isExpiredEnabled,
                          onToggle: (v) => setState(() {
                            isExpiredEnabled = v;
                            if (v) {
                              selectedExpiredMinutes ??= '30';
                            }
                          }),
                          input: _buildDropdown(
                            hint: 'Select Expired Link',
                            value: selectedExpiredMinutes,
                            items: expiryOptions,
                            enabled: isExpiredEnabled,
                            onChanged: (v) => setState(() => selectedExpiredMinutes = v),
                          ),
                        ),

                        // 5. Visitor Quota Limit
                        _buildFieldRow(
                          label: 'Visitor Quota Limit',
                          isEnabled: isQuotaEnabled,
                          onToggle: (v) => setState(() {
                            isQuotaEnabled = v;
                            if (!v && !isSingleUse) quotaCtrl.text = '0';
                          }),
                          input: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                hint: '0',
                                controller: quotaCtrl,
                                enabled: isQuotaEnabled && !isSingleUse,
                                keyboardType: TextInputType.number,
                              ),
                              vSpace(context, 4),
                              Text(
                                'Enter the maximum number of visitors allowed',
                                style: TextStyle(
                                  fontSize: rfs(context, 11),
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 6. Single Use Link
                        Row(
                          children: [
                            Switch(
                              value: isSingleUse,
                              onChanged: (v) => setState(() {
                                isSingleUse = v;
                                if (v) {
                                  isQuotaEnabled = true;
                                  quotaCtrl.text = '1';
                                }
                              }),
                              activeTrackColor: const Color(0xFF005596).withValues(alpha: 0.5),
                              activeThumbColor: const Color(0xFF005596),
                            ),
                            Text(
                              'Single Use Link',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: rfs(context, 13),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: rw(context, 12)),
                          child: Text(
                            'Enable this option to allow the link to be used only once. After the first use, the link will become inactive.',
                            style: TextStyle(
                              fontSize: rfs(context, 11),
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),

                        vSpace(context, 24),

                        // Action Buttons: Create Link & Create Link And Send Email
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF005596),
                                  padding: EdgeInsets.symmetric(vertical: rh(context, 14)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(rw(context, 8)),
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: rfs(context, 14),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () => _submit(false),
                                child: const Text(
                                  'Create Link',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            hSpace(context, 12),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF005596)),
                                  padding: EdgeInsets.symmetric(vertical: rh(context, 14)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(rw(context, 8)),
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: rfs(context, 13),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () => _submit(true),
                                child: const Text(
                                  'Create Link And Send Email',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF005596)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldRow({
    required String label,
    required bool isEnabled,
    required Function(bool) onToggle,
    required Widget input,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 16.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: rfs(context, 13),
                ),
              ),
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: isEnabled,
                  onChanged: onToggle,
                  activeTrackColor: const Color(0xFF005596).withValues(alpha: 0.5),
                  activeThumbColor: const Color(0xFF005596),
                ),
              ),
            ],
          ),
          vSpace(context, 4),
          input,
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<Map<String, dynamic>> items,
    required bool enabled,
    required Function(String?) onChanged,
  }) {
    String? selectedName;
    if (value != null) {
      final selectedItem = items.firstWhereOrNull(
        (i) => (i['id']?.toString().toLowerCase() ?? '') == value.toLowerCase(),
      );
      selectedName = selectedItem?['name']?.toString();
    }

    return TextFormField(
      readOnly: true,
      enabled: enabled,
      controller: TextEditingController(text: selectedName),
      style: TextStyle(fontSize: rfs(context, 13)),
      decoration: _inputDecoration(enabled: enabled).copyWith(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey, fontSize: rfs(context, 13)),
        suffixIcon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.grey,
        ),
      ),
      onTap: enabled
          ? () => _showSelectionBottomSheet(hint, items, value, onChanged)
          : null,
    );
  }

  void _showSelectionBottomSheet(
    String title,
    List<Map<String, dynamic>> items,
    String? currentValue,
    Function(String?) onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(rw(context, 20))),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            vSpace(context, 12),
            Container(
              width: rw(context, 40),
              height: rh(context, 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(rw(context, 2)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(rw(context, 16.0)),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: rfs(context, 16),
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item['id'].toString().toLowerCase() ==
                      currentValue?.toLowerCase();
                  return ListTile(
                    title: Text(
                      item['name'] ?? '',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF005596) : Colors.black87,
                        fontSize: rfs(context, 14),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF005596))
                        : null,
                    onTap: () {
                      onSelected(item['id']?.toString());
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            vSpace(context, 24),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    required bool enabled,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: rfs(context, 13)),
      decoration: _inputDecoration(enabled: enabled).copyWith(hintText: hint),
    );
  }

  Widget _buildDateTimePicker({
    required DateTime? value,
    required bool enabled,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final displayValue = value != null
        ? DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'en').format(value.toLocal())
        : '';
    final controller = TextEditingController(text: displayValue);

    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      style: TextStyle(fontSize: rfs(context, 13)),
      decoration: _inputDecoration(enabled: enabled).copyWith(
        hintText: 'Select Date and Time',
        hintStyle: TextStyle(color: Colors.grey, fontSize: rfs(context, 13)),
        suffixIcon: enabled && value != null
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.grey,
                  size: rw(context, 18),
                ),
              )
            : Icon(
                Icons.calendar_today_outlined,
                color: Colors.grey,
                size: rw(context, 18),
              ),
      ),
      onTap: enabled ? onTap : null,
    );
  }

  InputDecoration _inputDecoration({required bool enabled}) {
    return InputDecoration(
      filled: true,
      fillColor: enabled ? Colors.white : Colors.grey.shade100,
      contentPadding: EdgeInsets.symmetric(horizontal: rw(context, 12), vertical: rh(context, 12)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rw(context, 10)),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rw(context, 10)),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rw(context, 10)),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rw(context, 10)),
        borderSide: const BorderSide(color: Color(0xFF005596), width: 1.5),
      ),
    );
  }

  Future<void> _pickDateTime(bool isStart) async {
    final initialDate = isStart ? visitStart : visitEnd;

    final dt = await showAppDateTimePicker(
      context,
      initialDate: initialDate,
      minDateTime: !isStart ? visitStart : null,
      maxDateTime: isStart ? visitEnd : null,
      referenceStartDateTime: !isStart ? visitStart : null,
      quickHourPresets: !isStart ? const [2, 5] : null,
      title: isStart ? 'Select Visit Start' : 'Select Visit End',
      withTime: true,
    );

    if (dt != null && mounted) {
      if (!isStart && visitStart != null && dt.isBefore(visitStart!)) {
        Get.snackbar(
          'Invalid Time',
          'Visit End cannot be earlier than Visit Start',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(rw(context, 12)),
        );
        return;
      }

      if (isStart && visitEnd != null && dt.isAfter(visitEnd!)) {
        Get.snackbar(
          'Invalid Time',
          'Visit Start cannot be later than Visit End',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(rw(context, 12)),
        );
        return;
      }

      setState(() {
        if (isStart) {
          visitStart = dt;
        } else {
          visitEnd = dt;
        }
      });
    }
  }

  Future<void> _submit(bool sendEmail) async {
    // 1. Quota Validation
    final quotaValue = int.tryParse(quotaCtrl.text.trim());
    if (isQuotaEnabled &&
        !isSingleUse &&
        (quotaCtrl.text.trim().isEmpty || quotaValue == null || quotaValue < 1)) {
      Get.snackbar(
        'Required',
        'Visitor Quota Limit is required and must be at least 1',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(rw(context, 12)),
      );
      return;
    }

    // 2. Missing Enabled Information Check
    List<String> missingFields = [];
    if (isVisitorTypeEnabled && selectedVisitorTypeId == null) {
      missingFields.add('Visitor Type');
    }
    if (isVisitStartEnabled && visitStart == null) {
      missingFields.add('Visit Start');
    }
    if (isVisitEndEnabled && visitEnd == null) {
      missingFields.add('Visit End');
    }
    if (isExpiredEnabled && (selectedExpiredMinutes == null || selectedExpiredMinutes == '0')) {
      missingFields.add('Expired Link');
    }

    if (missingFields.isNotEmpty) {
      String fieldNames = missingFields.join(', ');
      Get.snackbar(
        'Missing Information',
        '$fieldNames must be filled to create link invitation',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(rw(context, 12)),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // 3. Email Input Prompt if "Create Link And Send Email"
    String? email;
    if (sendEmail) {
      email = await _showEmailDialog();
      if (email == null) return; // Cancelled
    }

    // Ensure visitor type details are resolved from controller
    if (selectedVisitorTypeData == null && selectedVisitorTypeId != null) {
      selectedVisitorTypeData = controller.visitorTypes.firstWhereOrNull(
        (vt) => (vt['id']?.toString() ?? '') == selectedVisitorTypeId,
      );
    }

    // 4. Construct Payload matching Web H() in CreateLinkDialog
    final dynamic hostVal = isVisitorTypeEnabled && selectedVisitorTypeData != null
        ? selectedVisitorTypeData!['pre_host_id']
        : null;
    final dynamic siteVal = isVisitorTypeEnabled && selectedVisitorTypeData != null
        ? selectedVisitorTypeData!['pre_site_id']
        : null;
    final dynamic agendaVal = isVisitorTypeEnabled && selectedVisitorTypeData != null
        ? selectedVisitorTypeData!['pre_agenda']
        : null;
    final String? vTypeVal = isVisitorTypeEnabled ? selectedVisitorTypeId : null;

    final Map<String, dynamic> body = {
      'host': (hostVal != null && hostVal.toString().isNotEmpty) ? hostVal : null,
      'site_id': (siteVal != null && siteVal.toString().isNotEmpty) ? siteVal : null,
      'visitor_type_id': vTypeVal,
      'agenda': (agendaVal != null && agendaVal.toString().isNotEmpty) ? agendaVal : null,
      'visitor_period_start': isVisitStartEnabled && visitStart != null
          ? visitStart!.toUtc().toIso8601String().substring(0, 19)
          : null,
      'visitor_period_end': isVisitEndEnabled && visitEnd != null
          ? visitEnd!.toUtc().toIso8601String().substring(0, 19)
          : null,
      'expired_number': isExpiredEnabled
          ? (int.tryParse(selectedExpiredMinutes ?? '0') ?? 0)
          : 0,
      'max_usage': isQuotaEnabled
          ? (isSingleUse ? 1 : (int.tryParse(quotaCtrl.text.trim()) ?? 0))
          : 0,
      'is_single_use': isSingleUse,
      if (email != null && email.isNotEmpty) 'emails': [email],
      'tz': 'Asia/Jakarta',
    };

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final newItem = await controller.createShareLinkAction(
        body,
        sendEmail: sendEmail,
      );

      if (!mounted) return;
      Get.back(); // Close loading

      if (newItem != null) {
        setState(() {
          _success = true;
        });
        if (widget.duplicateData == null) {
          Get.snackbar(
            'Success',
            sendEmail ? 'Success send share link' : 'Share link created successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              Navigator.of(context).pop(true); // Close Create dialog
            }
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(rw(context, 12)),
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<String?> _showEmailDialog() async {
    final TextEditingController tempEmailCtrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rw(context, 16))),
        titlePadding: EdgeInsets.fromLTRB(rw(context, 20), rh(context, 16), rw(context, 12), 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Send Invitation Link',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: rfs(context, 18),
                color: const Color(0xFF2E3A59),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.grey, size: rw(context, 24)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send Via Email',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF005596),
                fontSize: rfs(context, 14),
              ),
            ),
            vSpace(context, 4),
            Text(
              'Please enter a valid email address of the recipient.',
              style: TextStyle(fontSize: rfs(context, 12), color: Colors.grey),
            ),
            vSpace(context, 20),
            TextFormField(
              controller: tempEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              enableSuggestions: false,
              style: TextStyle(fontSize: rfs(context, 14)),
              decoration: InputDecoration(
                hintText: 'Email',
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: rw(context, 16),
                  vertical: rh(context, 14),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(rw(context, 8)),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(rw(context, 8)),
                  borderSide: const BorderSide(color: Color(0xFF005596)),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: EdgeInsets.fromLTRB(0, 0, rw(context, 16), rh(context, 16)),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              if (tempEmailCtrl.text.trim().isNotEmpty) {
                Navigator.pop(context, tempEmailCtrl.text.trim());
              } else {
                Get.snackbar(
                  'Required',
                  'Please enter an email address',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              }
            },
            icon: Icon(Icons.send, color: Colors.white, size: rw(context, 18)),
            label: const Text(
              'Send',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005596),
              padding: EdgeInsets.symmetric(horizontal: rw(context, 20), vertical: rh(context, 12)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rw(context, 8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
