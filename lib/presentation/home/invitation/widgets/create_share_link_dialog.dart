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

  // Form States (Aligned with Web CreateLinkDialog: required fields have no switch buttons)
  String? selectedVisitorTypeId;
  Map<String, dynamic>? selectedVisitorTypeData;

  DateTime? visitStart;

  // Visit End is optional with toggle switch
  bool isVisitEndEnabled = false;
  DateTime? visitEnd;

  String? selectedExpiredMinutes = '30';

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
        selectedVisitorTypeId = vTypeVal;
        selectedVisitorTypeData = controller.visitorTypes.firstWhereOrNull(
          (vt) => (vt['id']?.toString() ?? '') == vTypeVal,
        );
      }

      // 2. Expiry & Quota limits
      final expiredVal = (data['expired_number'] ?? 0).toString();
      if (expiredVal != '0' && expiredVal.isNotEmpty) {
        selectedExpiredMinutes = expiredVal;
      }

      final maxUsage = data['max_usage'] as int? ?? 0;
      isSingleUse = data['is_single_use'] == true || maxUsage == 1;
      if (maxUsage > 0 || isSingleUse) {
        quotaCtrl.text = maxUsage.toString();
      }

      // 3. Visit Start & End
      final startVal = data['visitor_period_start']?.toString();
      if (startVal != null && startVal.isNotEmpty && startVal != 'null') {
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
    return selectedVisitorTypeId != null ||
        visitStart != null ||
        (isVisitEndEnabled && visitEnd != null) ||
        (selectedExpiredMinutes != null && selectedExpiredMinutes != '30') ||
        (quotaCtrl.text.trim().isNotEmpty && quotaCtrl.text.trim() != '0') ||
        isSingleUse;
  }

  bool get _isRemiseOrCit {
    final data = selectedVisitorTypeData ??
        (selectedVisitorTypeId != null
            ? controller.visitorTypes.firstWhereOrNull(
                (vt) => (vt['id']?.toString() ?? '') == selectedVisitorTypeId,
              )
            : null);
    if (data == null) return false;

    final name = (data['name'] ?? '').toString().toLowerCase();
    final category = (data['visitor_category'] ??
            data['category'] ??
            data['visitor_category_name'] ??
            data['type'] ??
            '')
        .toString()
        .toLowerCase();
    final code = (data['code'] ?? '').toString().toLowerCase();

    return name.contains('remise') ||
        name.contains('remnise') ||
        name.contains('cit') ||
        category.contains('remise') ||
        category.contains('remnise') ||
        category.contains('cit') ||
        code.contains('remise') ||
        code.contains('remnise') ||
        code.contains('cit');
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
                          hasData ? 'Yes, Discard' : 'Yes, Close',
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
        insetPadding: EdgeInsets.symmetric(
          horizontal: rw(context, 16),
          vertical: rh(context, 24),
        ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create Link Invitation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: rfs(context, 17),
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        if (await _showExitConfirmation()) {
                          if (mounted) navigator.pop();
                        }
                      },
                    ),
                  ],
                ),
                vSpace(context, 8),
                const Divider(height: 1),
                vSpace(context, 16),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Visitor Type * (Required, no switch button)
                        _buildFormField(
                          label: 'Visitor Type',
                          isRequired: true,
                          input: Obx(() => _buildDropdown(
                            hint: 'Select Visitor Type',
                            value: selectedVisitorTypeId,
                            items: controller.visitorTypes
                                .map<Map<String, dynamic>>((vt) => {
                                      'id': vt['id']?.toString() ?? '',
                                      'name': vt['name']?.toString() ?? '',
                                    })
                                .toList(),
                            enabled: true,
                            onChanged: (v) => setState(() {
                              selectedVisitorTypeId = v;
                              selectedVisitorTypeData = controller.visitorTypes.firstWhereOrNull(
                                (vt) => (vt['id']?.toString() ?? '') == v,
                              );
                              if (_isRemiseOrCit) {
                                selectedExpiredMinutes = '99999999';
                              } else if (selectedExpiredMinutes == '99999999') {
                                selectedExpiredMinutes = '30';
                              }
                            }),
                          )),
                        ),

                        // 2. Visit Start * (Required, no switch button)
                        _buildFormField(
                          label: 'Visit Start',
                          isRequired: true,
                          input: _buildDateTimePicker(
                            value: visitStart,
                            enabled: true,
                            onTap: () => _pickDateTime(true),
                            onClear: () => setState(() => visitStart = null),
                          ),
                        ),

                        // 3. Visit End (Optional with toggle switch, matching web)
                        _buildFormField(
                          label: 'Visit End',
                          isRequired: false,
                          trailing: Transform.scale(
                            scale: 0.7,
                            child: Switch(
                              value: isVisitEndEnabled,
                              onChanged: (v) => setState(() {
                                isVisitEndEnabled = v;
                                if (!v) visitEnd = null;
                              }),
                              activeTrackColor: const Color(0xFF005596).withValues(alpha: 0.5),
                              activeThumbColor: const Color(0xFF005596),
                            ),
                          ),
                          input: _buildDateTimePicker(
                            value: visitEnd,
                            enabled: isVisitEndEnabled,
                            onTap: () => _pickDateTime(false),
                            onClear: () => setState(() => visitEnd = null),
                          ),
                        ),

                        // 4. Expired Link * (Required, no switch button)
                        _buildFormField(
                          label: 'Expired Link',
                          isRequired: true,
                          input: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDropdown(
                                hint: 'Select Expired Link',
                                value: _isRemiseOrCit ? '99999999' : selectedExpiredMinutes,
                                items: _isRemiseOrCit
                                    ? [
                                        {'id': '99999999', 'name': '99999999'},
                                        ...expiryOptions,
                                      ]
                                    : expiryOptions,
                                enabled: !_isRemiseOrCit,
                                onChanged: !_isRemiseOrCit
                                    ? (v) => setState(() => selectedExpiredMinutes = v)
                                    : (_) {},
                              ),
                              if (_isRemiseOrCit) ...[
                                vSpace(context, 4),
                                Text(
                                  'Note: Must be set to H-1 from the visit start time.',
                                  style: TextStyle(
                                    fontSize: rfs(context, 11),
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // 5. Visitor Quota Limit * (Required, no switch button)
                        _buildFormField(
                          label: 'Visitor Quota Limit',
                          isRequired: true,
                          input: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                hint: '0',
                                controller: quotaCtrl,
                                enabled: !isSingleUse,
                                keyboardType: TextInputType.number,
                              ),
                              vSpace(context, 4),
                              Text(
                                'Enter the maximum number of visitors allowed.',
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
                                    fontSize: rfs(context, 13.5),
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
                                    fontSize: rfs(context, 12.5),
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

  Widget _buildFormField({
    required String label,
    required Widget input,
    bool isRequired = true,
    Widget? trailing,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 16.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rfs(context, 13),
                    color: Colors.black87,
                  ),
                  children: [
                    if (isRequired)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          vSpace(context, 6),
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
      for (final i in items) {
        if ((i['id']?.toString().toLowerCase() ?? '') == value.toLowerCase()) {
          selectedName = i['name']?.toString();
          break;
        }
      }
      selectedName ??= value;
    }

    return TextFormField(
      readOnly: true,
      enabled: enabled,
      controller: TextEditingController(text: selectedName),
      style: TextStyle(fontSize: rfs(context, 13)),
      decoration: _inputDecoration(enabled: enabled).copyWith(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: rfs(context, 13)),
        suffixIcon: Icon(
          enabled ? Icons.keyboard_arrow_down_rounded : Icons.lock_outline,
          color: Colors.grey,
          size: enabled ? 22 : 18,
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
                      item['name']?.toString() ?? '',
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
        hintText: 'EEEE, DD MMMM YYYY, hh:mm',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: rfs(context, 13)),
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
                color: Colors.grey.shade500,
                size: rw(context, 18),
              ),
      ),
      onTap: enabled ? onTap : null,
    );
  }

  InputDecoration _inputDecoration({required bool enabled}) {
    return InputDecoration(
      filled: true,
      fillColor: enabled ? const Color(0xFFF8FAFC) : Colors.grey.shade100,
      contentPadding: EdgeInsets.symmetric(horizontal: rw(context, 12), vertical: rh(context, 12)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rw(context, 10)),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rw(context, 10)),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
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
    // 1. Visitor Type check (Required)
    if (selectedVisitorTypeId == null || selectedVisitorTypeId!.isEmpty) {
      Get.snackbar(
        'Required',
        'Visitor Type is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(rw(context, 12)),
      );
      return;
    }

    // 2. Visit Start check (Required)
    if (visitStart == null) {
      Get.snackbar(
        'Required',
        'Visit Start is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(rw(context, 12)),
      );
      return;
    }

    // 3. Visit End check (Optional - only check order if both visitStart and visitEnd are present)
    if (isVisitEndEnabled && visitEnd != null && visitStart != null && visitEnd!.isBefore(visitStart!)) {
      Get.snackbar(
        'Invalid Date',
        'Visit End cannot be before Visit Start',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(rw(context, 12)),
      );
      return;
    }

    // 4. Expired Link check (Required)
    final effectiveExpiredMinutes = _isRemiseOrCit ? '99999999' : selectedExpiredMinutes;
    if (effectiveExpiredMinutes == null || effectiveExpiredMinutes.isEmpty || effectiveExpiredMinutes == '0') {
      Get.snackbar(
        'Required',
        'Expired Link is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(rw(context, 12)),
      );
      return;
    }

    // 5. Visitor Quota Limit check (Required)
    final quotaValue = int.tryParse(quotaCtrl.text.trim());
    if (!isSingleUse && (quotaCtrl.text.trim().isEmpty || quotaValue == null || quotaValue < 0)) {
      Get.snackbar(
        'Required',
        'Visitor Quota Limit is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(rw(context, 12)),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // 6. Email Input Prompt if "Create Link And Send Email"
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

    // 7. Construct Payload (Identical to Web H() in CreateLinkDialog)
    final dynamic hostVal = selectedVisitorTypeData != null
        ? selectedVisitorTypeData!['pre_host_id']
        : null;
    final dynamic siteVal = selectedVisitorTypeData != null
        ? selectedVisitorTypeData!['pre_site_id']
        : null;
    final dynamic agendaVal = selectedVisitorTypeData != null
        ? selectedVisitorTypeData!['pre_agenda']
        : null;
    final String? vTypeVal = selectedVisitorTypeId;

    final Map<String, dynamic> body = {
      'host': (hostVal != null && hostVal.toString().isNotEmpty) ? hostVal : null,
      'site_id': (siteVal != null && siteVal.toString().isNotEmpty) ? siteVal : null,
      'visitor_type_id': vTypeVal,
      'agenda': (agendaVal != null && agendaVal.toString().isNotEmpty) ? agendaVal : null,
      'visitor_period_start': visitStart?.toUtc().toIso8601String().substring(0, 19),
      'visitor_period_end': (isVisitEndEnabled && visitEnd != null)
          ? visitEnd!.toUtc().toIso8601String().substring(0, 19)
          : null,
      'expired_number': _isRemiseOrCit
          ? 99999999
          : (int.tryParse(selectedExpiredMinutes ?? '30') ?? 30),
      'max_usage': isSingleUse ? 1 : (int.tryParse(quotaCtrl.text.trim()) ?? 0),
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
