import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../controller/invitation_controller.dart';

class CreateShareLinkDialog extends StatefulWidget {
  const CreateShareLinkDialog({super.key});

  @override
  State<CreateShareLinkDialog> createState() => _CreateShareLinkDialogState();
}

class _CreateShareLinkDialogState extends State<CreateShareLinkDialog> {
  final InvitationController controller = Get.find<InvitationController>();
  final _formKey = GlobalKey<FormState>();
  bool _success = false;

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

  bool isQuotaEnabled = true;
  final TextEditingController quotaCtrl = TextEditingController(text: '');

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
    // Only count a field as changed if its toggle is enabled (user explicitly turned it on)
    // or if the field is always-visible and has been modified
    return (isHostEnabled && selectedHostId != null) ||
        (isSiteEnabled && selectedSiteId != null) ||
        (isVisitorTypeEnabled && selectedVisitorTypeId != null) ||
        (isAgendaEnabled && (selectedAgendaOption != null || agendaCtrl.text.isNotEmpty)) ||
        (isVisitStartEnabled && visitStart != null) ||
        (isVisitEndEnabled && visitEnd != null) ||
        (isExpiredEnabled && selectedExpiredMinutes != null && selectedExpiredMinutes != '0') ||
        (quotaCtrl.text.isNotEmpty && quotaCtrl.text != '0') ||
        isSingleUse == true;
  }

  Future<bool> _showExitConfirmation() async {
    final hasData = _hasChanges();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rw(context, 16))),
        title: Text(
          hasData ? 'Discard Progress?' : 'Close Form?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          hasData
              ? 'Are you sure you want to close this form? Your progress will be lost.'
              : 'Are you sure you want to close this form?',
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              hasData ? 'Yes, Discard' : 'Yes, Close',
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
                    // Centered title
                    Center(
                      child: Text(
                        'Create Share Link Registration',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: rfs(context, 17),
                        ),
                      ),
                    ),
                    // Close button on the right
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
                        _buildFieldRow(
                          label: 'Agenda',
                          isEnabled: isAgendaEnabled,
                          onToggle: (v) => setState(() => isAgendaEnabled = v),
                          input: Column(
                            children: [
                              _buildDropdown(
                                hint: 'Select Agenda',
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
                                vSpace(context, 8),
                                _buildTextField(
                                  hint: 'Type other agenda...',
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
                                  fontSize: rfs(context, 13),
                                  color: isHostEnabled
                                      ? Colors.black87
                                      : Colors.transparent,
                                ),
                                decoration:
                                    _inputDecoration(
                                      enabled: isHostEnabled,
                                    ).copyWith(
                                      hintText: 'Select Host',
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: rfs(context, 13),
                                      ),
                                    ),
                              );
                            }
                            return _buildDropdown(
                              hint: 'Select Host',
                              value: selectedHostId,
                              items: controller.hosts
                                  .map(
                                    (h) => {
                                      "id": h['id']?.toString() ?? '',
                                      "name": h['name']?.toString() ?? '',
                                    },
                                  )
                                  .toList(),
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
                            hint: 'Select Link Expiry',
                            value: selectedExpiredMinutes,
                            items: expiryOptions,
                            enabled: isExpiredEnabled,
                            onChanged: (v) =>
                                setState(() => selectedExpiredMinutes = v),
                          ),
                        ),
                        _buildRequiredFieldRow(
                          label: 'Visitor Quota Limit',
                          input: _buildTextField(
                            hint: 'Cannot be empty',
                            controller: quotaCtrl,
                            enabled: !isSingleUse,
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
                              activeTrackColor: const Color(
                                0xFF005596,
                              ).withValues(alpha: 0.5),
                              activeThumbColor: const Color(0xFF005596),
                            ),
                            const Text(
                              'Single Use Link',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: rw(context, 12)),
                          child: Text(
                            'Enable this option to allow the link to be used only once.',
                            style: TextStyle(fontSize: rfs(context, 10), color: Colors.grey),
                          ),
                        ),

                        vSpace(context, 24),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF005596),
                                  padding: EdgeInsets.symmetric(
                                    vertical: rh(context, 14),
                                  ),
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
                                  side: const BorderSide(
                                    color: Color(0xFF005596),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: rh(context, 14),
                                  ),
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
                                  'Create & Send Email',
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
                  activeTrackColor: const Color(
                    0xFF005596,
                  ).withValues(alpha: 0.5),
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

  Widget _buildRequiredFieldRow({
    required String label,
    required Widget input,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 16.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: rfs(context, 13),
                ),
              ),
              Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: rfs(context, 13),
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
                  final isSelected = item['id'].toString() == currentValue;
                  return ListTile(
                    title: Text(
                      item['name'] ?? '',
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF005596)
                            : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF005596))
                        : null,
                    onTap: () {
                      onSelected(item['id'].toString());
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
    FocusNode? focusNode,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      focusNode: focusNode,
      style: TextStyle(fontSize: rfs(context, 13)),
      decoration: _inputDecoration(enabled: enabled).copyWith(hintText: hint),
    );
  }

  Widget _buildDateTimePicker({
    required DateTime? value,
    required bool enabled,
    required VoidCallback onTap,
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
        suffixIcon: Icon(
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
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now().subtract(const Duration(days: 365));

    if (!isStart && visitStart != null) {
      firstDate = DateTime(visitStart!.year, visitStart!.month, visitStart!.day);
      if (initialDate.isBefore(firstDate)) {
        initialDate = firstDate;
      }
    }

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF005596)),
        ),
        child: child!,
      ),
    );

    if (date != null && mounted) {
      TimeOfDay initialTime = TimeOfDay.now();
      if (!isStart && visitStart != null) {
        if (date.year == visitStart!.year &&
            date.month == visitStart!.month &&
            date.day == visitStart!.day) {
          if (initialTime.hour < visitStart!.hour ||
              (initialTime.hour == visitStart!.hour &&
                  initialTime.minute < visitStart!.minute)) {
            initialTime = TimeOfDay(
                hour: visitStart!.hour, minute: visitStart!.minute);
          }
        }
      }

      DateTime cupertinoInitialDate = DateTime(
        date.year,
        date.month,
        date.day,
        initialTime.hour,
        initialTime.minute,
      );
      DateTime? cupertinoMinDate;
      if (!isStart && visitStart != null) {
        if (date.year == visitStart!.year &&
            date.month == visitStart!.month &&
            date.day == visitStart!.day) {
          cupertinoMinDate = visitStart!;
        }
      }

      TimeOfDay? time;
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(rw(context, 16))),
        ),
        builder: (BuildContext builder) {
          return SizedBox(
            height: rh(context, 300),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rw(context, 16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                        onPressed: () => Navigator.of(builder).pop(),
                      ),
                      TextButton(
                        child: const Text('OK', style: TextStyle(color: Color(0xFF005596), fontWeight: FontWeight.bold)),
                        onPressed: () {
                          time ??= TimeOfDay.fromDateTime(cupertinoInitialDate);
                          Navigator.of(builder).pop();
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    initialDateTime: cupertinoInitialDate,
                    minimumDate: cupertinoMinDate,
                    onDateTimeChanged: (DateTime newDateTime) {
                      time = TimeOfDay.fromDateTime(newDateTime);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );

      if (time != null && mounted) {
        final dt = DateTime(
          date.year,
          date.month,
          date.day,
          time!.hour,
          time!.minute,
        );

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
  }

  Future<void> _submit(bool sendEmail) async {
    // Validation — Visitor Quota Limit is required
    final quotaValue = int.tryParse(quotaCtrl.text.trim());
    if (!isSingleUse &&
        (quotaCtrl.text.trim().isEmpty ||
            quotaValue == null ||
            quotaValue < 1)) {
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
        margin: EdgeInsets.all(rw(context, 12)),
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
        margin: EdgeInsets.all(rw(context, 12)),
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
      'max_usage': isSingleUse ? 1 : (int.tryParse(quotaCtrl.text.trim()) ?? 1),
      'is_single_use': isSingleUse,
      if (email != null) 'emails': [email],
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
        Get.snackbar(
          'Success',
          'Share link created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              Navigator.of(context).pop(); // Close Create dialog
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
