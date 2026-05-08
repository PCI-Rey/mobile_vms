import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  int? expiredMinutes;

  bool isQuotaEnabled = false;
  final TextEditingController quotaCtrl = TextEditingController(text: '0');

  bool isSingleUse = false;

  final List<Map<String, dynamic>> expiryOptions = [
    {'label': '10 Minutes', 'value': 10},
    {'label': '30 Minutes', 'value': 30},
    {'label': '1 Hour', 'value': 60},
    {'label': '1 Day', 'value': 1440},
    {'label': '1 Week', 'value': 10080},
    {'label': 'No Expired', 'value': 0},
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
        (expiredMinutes != null && expiredMinutes != 0) ||
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
        title: const Text('Discard Progress?', style: TextStyle(fontWeight: FontWeight.bold)),
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
            child: const Text('Yes, Discard', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 40),
                      const Expanded(
                        child: Text(
                          'Create Link Invitation',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

                  _buildFieldRow(
                    label: 'Host',
                    isEnabled: isHostEnabled,
                    onToggle: (v) => setState(() => isHostEnabled = v),
                    input: _buildDropdown(
                      hint: 'Select Host',
                      value: selectedHostId,
                      items: controller.hosts,
                      enabled: isHostEnabled,
                      onChanged: (v) => setState(() => selectedHostId = v),
                    ),
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
                      onChanged: (v) => setState(() => selectedSiteId = v),
                    ),
                  ),
                  _buildFieldRow(
                    label: 'Visitor Type',
                    isEnabled: isVisitorTypeEnabled,
                    onToggle: (v) => setState(() => isVisitorTypeEnabled = v),
                    input: _buildDropdown(
                      hint: 'Select Visitor Type',
                      value: selectedVisitorTypeId,
                      items: controller.visitorTypes,
                      enabled: isVisitorTypeEnabled,
                      onChanged: (v) => setState(() => selectedVisitorTypeId = v),
                    ),
                  ),
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
                            }
                          }),
                        ),
                        if (isAgendaEnabled && selectedAgendaOption == 'Other') ...[
                          const SizedBox(height: 8),
                          _buildTextField(
                            hint: 'Ketik agenda lainnya...',
                            controller: agendaCtrl,
                            enabled: isAgendaEnabled,
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildFieldRow(
                    label: 'Visit Start',
                    isEnabled: isVisitStartEnabled,
                    onToggle: (v) => setState(() => isVisitStartEnabled = v),
                    input: _buildDateTimePicker(
                      value: visitStart,
                      enabled: isVisitStartEnabled,
                      onTap: () => _pickDateTime(true),
                    ),
                  ),
                  _buildFieldRow(
                    label: 'Visit End',
                    isEnabled: isVisitEndEnabled,
                    onToggle: (v) => setState(() => isVisitEndEnabled = v),
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
                    input: DropdownButtonFormField<int>(
                      initialValue: expiredMinutes,
                      decoration: _inputDecoration(enabled: isExpiredEnabled),
                      hint: const Text('No Expired'),
                      items: expiryOptions.map((opt) {
                        return DropdownMenuItem<int>(
                          value: opt['value'],
                          child: Text(opt['label']),
                        );
                      }).toList(),
                      onChanged: isExpiredEnabled ? (v) => setState(() => expiredMinutes = v) : null,
                    ),
                  ),
                  _buildFieldRow(
                    label: 'Visitor Quota Limit',
                    isEnabled: isQuotaEnabled,
                    onToggle: (v) => setState(() => isQuotaEnabled = v),
                    input: _buildTextField(
                      hint: '0',
                      controller: quotaCtrl,
                      enabled: isQuotaEnabled,
                      keyboardType: TextInputType.number,
                    ),
                  ),

                  Row(
                    children: [
                      Switch(
                        value: isSingleUse,
                        onChanged: (v) => setState(() => isSingleUse = v),
                        activeTrackColor: const Color(0xFF005596).withValues(alpha: 0.5),
                        activeThumbColor: const Color(0xFF005596),
                      ),
                      const Text('Single Use Link', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005596),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _submit(false),
                          child: const Text('Create Link', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF005596)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _submit(true),
                          child: const Text('Create & Send Email', style: TextStyle(color: Color(0xFF005596))),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldRow({required String label, required bool isEnabled, required Function(bool) onToggle, required Widget input}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
      style: const TextStyle(fontSize: 13),
      decoration: _inputDecoration(enabled: enabled).copyWith(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
      ),
      onTap: enabled ? () => _showSelectionBottomSheet(hint, items, value, onChanged) : null,
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                        color: isSelected ? const Color(0xFF005596) : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF005596)) : null,
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

  Widget _buildTextField({required String hint, required TextEditingController controller, required bool enabled, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: _inputDecoration(enabled: enabled).copyWith(hintText: hint),
    );
  }

  Widget _buildDateTimePicker({required DateTime? value, required bool enabled, required VoidCallback onTap}) {
    final displayValue = value != null ? DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id').format(value) : '';
    final controller = TextEditingController(text: displayValue);
    
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      style: const TextStyle(fontSize: 13),
      decoration: _inputDecoration(enabled: enabled).copyWith(
        hintText: 'EEEE, dd MMMM yyyy, HH:mm',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
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
      fillColor: enabled ? Colors.white : Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF005596),
          width: 1.5,
        ),
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
          colorScheme: const ColorScheme.light(primary: Color(0xFF005596)),
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
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> body = {
      if (isHostEnabled) 'host': selectedHostId,
      if (isSiteEnabled) 'site_id': selectedSiteId,
      if (isVisitorTypeEnabled) 'visitor_type_id': selectedVisitorTypeId,
      if (isAgendaEnabled) 'agenda': selectedAgendaOption == 'Other' ? agendaCtrl.text : selectedAgendaOption,
      if (isVisitStartEnabled && visitStart != null) 
        'visitor_period_start': visitStart!.toUtc().toIso8601String().substring(0, 19),
      if (isVisitEndEnabled && visitEnd != null) 
        'visitor_period_end': visitEnd!.toUtc().toIso8601String().substring(0, 19),
      if (isExpiredEnabled) 'expired_number': expiredMinutes,
      if (isQuotaEnabled) 'max_usage': int.tryParse(quotaCtrl.text) ?? 0,
      'is_single_use': isSingleUse,
      'tz': 'Asia/Jakarta',
    };

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    final success = await controller.createShareLinkAction(body, sendEmail: sendEmail);
    
    if (!mounted) return;
    Get.back(); // Close loading

    if (success) {
      Get.snackbar('Success', 'Share link created successfully', backgroundColor: Colors.green, colorText: Colors.white);
      if (mounted) Navigator.pop(context);
    } else {
      Get.snackbar('Error', 'Failed to create share link', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
