import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/core.dart';
import '../controller/invitation_controller.dart';

class CreateShareLinkDialog extends StatefulWidget {
  const CreateShareLinkDialog({super.key});

  @override
  State<CreateShareLinkDialog> createState() => _CreateShareLinkDialogState();
}

class _CreateShareLinkDialogState extends State<CreateShareLinkDialog> {
  final InvitationController controller = Get.find<InvitationController>();
  final _formKey = GlobalKey<FormState>();

  // Form States & Toggles
  bool isHostEnabled = false;
  String? selectedHostId;

  bool isSiteEnabled = false;
  String? selectedSiteId;

  bool isVisitorTypeEnabled = false;
  String? selectedVisitorTypeId;

  bool isAgendaEnabled = false;
  String? selectedAgendaOption;
  final TextEditingController agendaCtrl = TextEditingController();
  final FocusNode agendaFocusNode = FocusNode();

  final List<Map<String, dynamic>> agendaOptions = [
    {'id': 'Meeting', 'name': 'Meeting'},
    {'id': 'Presentation', 'name': 'Presentation'},
    {'id': 'Visit', 'name': 'Visit'},
    {'id': 'Training', 'name': 'Training'},
    {'id': 'Report', 'name': 'Report'},
    {'id': 'Other', 'name': 'Other'},
  ];

  bool isVisitStartEnabled = false;
  DateTime? visitStart;

  bool isVisitEndEnabled = false;
  DateTime? visitEnd;

  bool isExpiredEnabled = false;
  String? selectedExpiredMinutes = '0';

  bool isQuotaEnabled = false;
  final TextEditingController quotaCtrl = TextEditingController(text: '0');

  bool isSingleUse = false;

  final List<Map<String, dynamic>> expiryOptions = [
    {'id': '0', 'name': 'No Expired'},
    {'id': '5', 'name': '5 Min'},
    {'id': '30', 'name': '30 Min'},
    {'id': '60', 'name': '1 Hour'},
    {'id': '300', 'name': '5 Hour'},
    {'id': '1440', 'name': '1 Day'},
    {'id': '10080', 'name': '7 Days'},
    {'id': '43200', 'name': '30 Days'},
    {'id': '129600', 'name': '3 Month'},
    {'id': '259200', 'name': '6 Month'},
    {'id': '525600', 'name': '1 Year'},
  ];

  @override
  void initState() {
    super.initState();
    controller.fetchMasterData();
  }

  @override
  void dispose() {
    agendaCtrl.dispose();
    quotaCtrl.dispose();
    agendaFocusNode.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    return selectedHostId != null ||
        selectedSiteId != null ||
        selectedVisitorTypeId != null ||
        selectedAgendaOption != null ||
        agendaCtrl.text.isNotEmpty ||
        visitStart != null ||
        visitEnd != null ||
        (selectedExpiredMinutes != null && selectedExpiredMinutes != '0') ||
        (quotaCtrl.text.isNotEmpty && quotaCtrl.text != '0') ||
        isSingleUse == true;
  }

  Future<bool> _showExitConfirmation() async {
    if (!_hasChanges()) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Discard Progress?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to close this form? Your progress will be lost.',
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, Discard',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldExit = await _showExitConfirmation();
        if (shouldExit && mounted) {
          navigator.pop();
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                      child: Text(
                        'Create Share Link Registration',
                        textAlign: TextAlign.center,
                        style: TextStyles.headline5.copyWith(fontSize: 18),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        if (await _showExitConfirmation()) {
                          if (mounted) navigator.pop();
                        }
                      },
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldRow(
                          label: 'Agenda',
                          isEnabled: isAgendaEnabled,
                          onToggle: (v) => setState(() => isAgendaEnabled = v),
                          input: Column(
                            children: [
                              _buildDropdown(
                                hint: 'Pilih Agenda',
                                value: selectedAgendaOption,
                                items: agendaOptions,
                                enabled: isAgendaEnabled,
                                onChanged: (v) => setState(() {
                                  selectedAgendaOption = v;
                                  if (v != 'Other') {
                                    agendaCtrl.text = v ?? '';
                                  } else {
                                    agendaCtrl.text = '';
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          agendaFocusNode.requestFocus();
                                        });
                                  }
                                }),
                              ),
                              if (isAgendaEnabled &&
                                  selectedAgendaOption == 'Other') ...[
                                const SizedBox(height: 8),
                                _buildTextField(
                                  hint: 'Ketik agenda lainnya...',
                                  controller: agendaCtrl,
                                  enabled: isAgendaEnabled,
                                  focusNode: agendaFocusNode,
                                ),
                              ],
                            ],
                          ),
                        ),
                        _buildFieldRow(
                          label: 'Host',
                          isEnabled: isHostEnabled,
                          onToggle: (v) => setState(() => isHostEnabled = v),
                          input: Obx(() {
                            final hosts = controller.hosts.toList();
                            if (hosts.length == 1) {
                              final single = hosts.first;
                              // Always auto-set the value so it's ready when submitted
                              if (selectedHostId != single['id']?.toString()) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) {
                                    setState(
                                      () => selectedHostId = single['id']
                                          ?.toString(),
                                    );
                                  }
                                });
                              }
                              // Show name only when toggle is ON, otherwise show empty
                              return TextFormField(
                                readOnly: true,
                                enabled: false,
                                controller: TextEditingController(
                                  text: isHostEnabled
                                      ? (single['name']?.toString() ?? '')
                                      : '',
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isHostEnabled
                                      ? Colors.black87
                                      : Colors.transparent,
                                ),
                                decoration:
                                    _inputDecoration(
                                      enabled: isHostEnabled,
                                    ).copyWith(
                                      hintText: 'Select Host',
                                      hintStyle: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                              );
                            }
                            return _buildDropdown(
                              hint: 'Select Host',
                              value: selectedHostId,
                              items: controller.hosts,
                              enabled: isHostEnabled,
                              onChanged: (v) =>
                                  setState(() => selectedHostId = v),
                            );
                          }),
                        ),
                        _buildFieldRow(
                          label: 'Site',
                          isEnabled: isSiteEnabled,
                          onToggle: (v) => setState(() => isSiteEnabled = v),
                          input: _buildDropdown(
                            hint: 'Select Site',
                            value: selectedSiteId,
                            items: controller.sites,
                            enabled: isSiteEnabled,
                            onChanged: (v) =>
                                setState(() => selectedSiteId = v),
                          ),
                        ),
                        _buildFieldRow(
                          label: 'Visitor Type',
                          isEnabled: isVisitorTypeEnabled,
                          onToggle: (v) =>
                              setState(() => isVisitorTypeEnabled = v),
                          input: _buildDropdown(
                            hint: 'Select Visitor Type',
                            value: selectedVisitorTypeId,
                            items: controller.visitorTypes,
                            enabled: isVisitorTypeEnabled,
                            onChanged: (v) =>
                                setState(() => selectedVisitorTypeId = v),
                          ),
                        ),
                        _buildFieldRow(
                          label: 'Visit Start',
                          isEnabled: isVisitStartEnabled,
                          onToggle: (v) =>
                              setState(() => isVisitStartEnabled = v),
                          input: _buildDateTimePicker(
                            value: visitStart,
                            enabled: isVisitStartEnabled,
                            onTap: () => _pickDateTime(true),
                          ),
                        ),
                        _buildFieldRow(
                          label: 'Visit End',
                          isEnabled: isVisitEndEnabled,
                          onToggle: (v) =>
                              setState(() => isVisitEndEnabled = v),
                          input: _buildDateTimePicker(
                            value: visitEnd,
                            enabled: isVisitEndEnabled,
                            onTap: () => _pickDateTime(false),
                          ),
                        ),
                        _buildFieldRow(
                          label: 'Expired Link',
                          isEnabled: isExpiredEnabled,
                          onToggle: (v) => setState(() => isExpiredEnabled = v),
                          input: _buildDropdown(
                            hint: 'Pilih Expired Link',
                            value: selectedExpiredMinutes,
                            items: expiryOptions,
                            enabled: isExpiredEnabled,
                            onChanged: (v) =>
                                setState(() => selectedExpiredMinutes = v),
                          ),
                        ),
                        _buildFieldRow(
                          label: 'Visitor Quota Limit',
                          isEnabled: isSingleUse ? true : isQuotaEnabled,
                          onToggle: isSingleUse
                              ? (v) {} // Disable toggle if single use is active
                              : (v) => setState(() => isQuotaEnabled = v),
                          input: _buildTextField(
                            hint: '0',
                            controller: quotaCtrl,
                            enabled: isSingleUse ? false : isQuotaEnabled,
                            keyboardType: TextInputType.number,
                          ),
                        ),

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
                              activeTrackColor: AppColors.primary500.withValues(alpha: 0.5),
                              activeThumbColor: AppColors.primary500,
                            ),
                            Text(
                              'Single Use Link',
                              style: TextStyles.subtitle2,
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Text(
                            'Enable this option to allow the link to be used only once.',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: Button.filled(
                                onPressed: () => _submit(false),
                                label: 'Create Link',
                                color: AppColors.primary500,
                                height: 48,
                                borderRadius: 12,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Button.outlined(
                                onPressed: () => _submit(true),
                                label: 'Create & Send Email',
                                borderColor: AppColors.primary500,
                                textColor: AppColors.primary500,
                                height: 48,
                                borderRadius: 12,
                                fontSize: 14,
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyles.subtitle2,
              ),
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: isEnabled,
                  onChanged: onToggle,
                  activeTrackColor: AppColors.primary500.withValues(alpha: 0.5),
                  activeThumbColor: AppColors.primary500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
      final selectedItem = items.firstWhere(
        (i) => i['id'].toString() == value,
        orElse: () => {},
      );
      selectedName = selectedItem['name'];
    }

    return TextFormField(
      readOnly: true,
      enabled: enabled,
      controller: TextEditingController(text: selectedName),
      style: TextStyles.bodyMedium,
      decoration: _inputDecoration(enabled: enabled).copyWith(
        hintText: hint,
        hintStyle: TextStyles.bodyMedium.copyWith(color: AppColors.grey400),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title.replaceAll('Select ', 'Pilih '),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
                  final isSelected = item['id'].toString() == currentValue;
                  return ListTile(
                    title: Text(
                      item['name'] ?? '',
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary500
                            : AppColors.grey800,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.primary500)
                        : null,
                    onTap: () {
                      onSelected(item['id'].toString());
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
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
    FocusNode? focusNode,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      focusNode: focusNode,
      style: TextStyles.bodyMedium,
      decoration: _inputDecoration(enabled: enabled).copyWith(
        hintText: hint,
        hintStyle: TextStyles.bodyMedium.copyWith(color: AppColors.grey400),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required DateTime? value,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final displayValue = value != null
        ? DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id').format(value.toLocal())
        : '';
    final controller = TextEditingController(text: displayValue);

    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      style: TextStyles.bodyMedium,
      decoration: _inputDecoration(enabled: enabled).copyWith(
        hintText: 'Pilih Tanggal dan Waktu',
        hintStyle: TextStyles.bodyMedium.copyWith(color: AppColors.grey400),
        suffixIcon: const Icon(
          Icons.calendar_today_outlined,
          color: Colors.grey,
          size: 18,
        ),
      ),
      onTap: enabled ? onTap : null,
    );
  }

  InputDecoration _inputDecoration({required bool enabled}) {
    return InputDecoration(
      filled: true,
      fillColor: enabled ? Colors.white : AppColors.grey100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey200),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.grey100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
      ),
    );
  }

  Future<void> _pickDateTime(bool isStart) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary500),
        ),
        child: child!,
      ),
    );

    if (date != null && mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF005596)),
          ),
          child: child!,
        ),
      );

      if (time != null && mounted) {
        setState(() {
          final dt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (isStart) {
            visitStart = dt;
          } else {
            visitEnd = dt;
          }
        });
      }
    }
  }

  Future<void> _submit(bool sendEmail) async {
    // Validation
    if (!isHostEnabled &&
        !isSiteEnabled &&
        !isVisitorTypeEnabled &&
        !isAgendaEnabled &&
        !isVisitStartEnabled &&
        !isVisitEndEnabled) {
      Get.snackbar(
        'Required',
        'Please enable and fill at least one information field to create link invitation',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    List<String> missingFields = [];
    if (isHostEnabled && selectedHostId == null) missingFields.add('Host');
    if (isSiteEnabled && selectedSiteId == null) missingFields.add('Site');
    if (isVisitorTypeEnabled && selectedVisitorTypeId == null) {
      missingFields.add('Visitor Type');
    }
    if (isAgendaEnabled && agendaCtrl.text.trim().isEmpty) {
      missingFields.add('Agenda');
    }
    if (isVisitStartEnabled && visitStart == null) {
      missingFields.add('Visit Start');
    }
    if (isVisitEndEnabled && visitEnd == null) missingFields.add('Visit End');

    if (missingFields.isNotEmpty) {
      String fieldNames = missingFields.join(', ');
      Get.snackbar(
        'Missing Information',
        '$fieldNames must be filled to create link invitation',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    String? email;
    if (sendEmail) {
      email = await _showEmailDialog();
      if (email == null) return; // Cancelled
    }

    final Map<String, dynamic> body = {
      if (isHostEnabled) 'host': selectedHostId,
      if (isSiteEnabled) 'site_id': selectedSiteId,
      if (isVisitorTypeEnabled) 'visitor_type_id': selectedVisitorTypeId,
      if (isAgendaEnabled)
        'agenda': selectedAgendaOption == 'Other'
            ? agendaCtrl.text
            : selectedAgendaOption,
      if (isVisitStartEnabled && visitStart != null)
        'visitor_period_start': visitStart!.toUtc().toIso8601String().substring(
          0,
          19,
        ),
      if (isVisitEndEnabled && visitEnd != null)
        'visitor_period_end': visitEnd!.toUtc().toIso8601String().substring(
          0,
          19,
        ),
      if (isExpiredEnabled)
        'expired_number': int.tryParse(selectedExpiredMinutes ?? '0') ?? 0,
      if (isQuotaEnabled) 'max_usage': int.tryParse(quotaCtrl.text) ?? 0,
      'is_single_use': isSingleUse,
      if (email != null) 'email': email,
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
        Get.snackbar(
          'Success',
          'Share link created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        if (mounted) {
          Navigator.pop(context); // Close Create dialog
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
        margin: const EdgeInsets.all(12),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Send Invitation Link',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF2E3A59),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Via Email',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF005596),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Please enter a valid email address of the recipient.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: tempEmailCtrl,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Email',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF005596)),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
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
            icon: const Icon(Icons.send, color: Colors.white, size: 18),
            label: const Text(
              'Send',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005596),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
