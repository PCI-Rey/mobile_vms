import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/models/visitor_type_detail_model.dart';
import 'controllers/pra_registration_controller.dart';

/// Shows the Add Pra Registration dialog.
Future<void> showAddPraRegistrationDialog(BuildContext context) {
  // Put fresh controller every time dialog opens
  final controller = Get.put(PraRegistrationController());
  controller.resetForm();
  controller.fetchVisitorTypes();

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _AddPraRegistrationDialog(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Root dialog widget
// ─────────────────────────────────────────────────────────────────────────────

class _AddPraRegistrationDialog extends StatelessWidget {
  const _AddPraRegistrationDialog();

  static const _stepTitles = [
    'User Type',
    'Visitor Information',
    'Purpose Visit',
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PraRegistrationController>();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Obx(() {
          final step = ctrl.currentStep.value;
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // ── Header ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Add Pra Registration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ── Step title + dots ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Text(
                      _stepTitles[step],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _StepDots(currentStep: step, total: 3),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ── Content ─────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: _StepContent(step: step, controller: ctrl),
                ),
              ),

              const Divider(height: 1),

              // ── Navigation Buttons ───────────────────────────────
              _BottomNav(step: step, controller: ctrl, context: context),
            ],
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step dots indicator
// ─────────────────────────────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  final int currentStep;
  final int total;
  const _StepDots({required this.currentStep, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary500 : AppColors.grey300,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step content router
// ─────────────────────────────────────────────────────────────────────────────

class _StepContent extends StatelessWidget {
  final int step;
  final PraRegistrationController controller;
  const _StepContent({required this.step, required this.controller});

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return _Step0UserType(controller: controller);
      case 1:
        return _Step1VisitorInfo(controller: controller);
      case 2:
        return _Step2PurposeVisit(controller: controller);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 0 — User Type
// ─────────────────────────────────────────────────────────────────────────────

class _Step0UserType extends StatelessWidget {
  final PraRegistrationController controller;
  const _Step0UserType({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // IMPORTANT: Read reactive values HERE (in Obx builder body)
      // so GetX tracks them. Reads inside itemBuilder are NOT tracked
      // because itemBuilder runs lazily during layout, not during Obx build.
      final selectedId = controller.selectedVisitorTypeId.value;
      final isLoadingDetail = controller.isLoadingDetail.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Visitor Type section ─────────────────────────────────
          _SectionHeader(title: 'Visitor Type'),
          const SizedBox(height: 8),

          if (controller.isLoadingTypes.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.visitorTypes.length,
              separatorBuilder: (_, index) => const SizedBox(height: 4),
              itemBuilder: (_, i) {
                final type = controller.visitorTypes[i];
                final isSelected = selectedId == type.id;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      controller.onSelectVisitorType(type.id, type.name),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColors.primary500
                              : AppColors.grey400,
                          size: 22,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary500
                                  : AppColors.grey300,
                              width: isSelected ? 1.5 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  type.name,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              if (isSelected && isLoadingDetail)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 20),

          // ── Select Status Visitor ────────────────────────────────
          _SectionHeader(title: 'Select Status Visitor'),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () => controller.isGroup.value = false,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        controller.isGroup.value == false
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: controller.isGroup.value == false
                            ? AppColors.primary500
                            : AppColors.grey400,
                        size: 22,
                      ),
                    ),
                    const Icon(
                      Icons.person_outline,
                      size: 18,
                      color: AppColors.grey500,
                    ),
                    const SizedBox(width: 4),
                    const Text('Single', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => controller.isGroup.value = true,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        controller.isGroup.value == true
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: controller.isGroup.value == true
                            ? AppColors.primary500
                            : AppColors.grey400,
                        size: 22,
                      ),
                    ),
                    const Icon(
                      Icons.group_outlined,
                      size: 18,
                      color: AppColors.grey500,
                    ),
                    const SizedBox(width: 4),
                    const Text('Group', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1 — Visitor Information
// ─────────────────────────────────────────────────────────────────────────────

class _Step1VisitorInfo extends StatelessWidget {
  final PraRegistrationController controller;
  const _Step1VisitorInfo({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final detail = controller.selectedTypeDetail.value;
      if (detail == null) {
        return const Center(child: CircularProgressIndicator());
      }

      // Find the first section that contains 'visitor' in name (case-insensitive)
      // or fall back to first section
      final sections = detail.sectionPageVisitorTypes;
      final section =
          sections.firstWhereOrNull(
            (s) => s.name.toLowerCase().contains('visitor'),
          ) ??
          sections.firstOrNull;

      if (section == null) {
        return const Text('Tidak ada data form.');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: section.visitForm
            .where((f) => f.isEnable)
            .map(
              (f) => _FormFieldWidget(
                field: f,
                context: context,
                controller: controller,
              ),
            )
            .toList(),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2 — Purpose Visit
// ─────────────────────────────────────────────────────────────────────────────

class _Step2PurposeVisit extends StatelessWidget {
  final PraRegistrationController controller;
  const _Step2PurposeVisit({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final detail = controller.selectedTypeDetail.value;
      if (detail == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final sections = detail.sectionPageVisitorTypes;
      final section =
          sections.firstWhereOrNull(
            (s) => s.name.toLowerCase().contains('purpose'),
          ) ??
          (sections.length > 1 ? sections[1] : null);

      if (section == null) {
        return const Text('Tidak ada data form tujuan.');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: section.visitForm
            .where((f) => f.isEnable)
            .map(
              (f) => _FormFieldWidget(
                field: f,
                context: context,
                controller: controller,
              ),
            )
            .toList(),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dynamic form field renderer
// ─────────────────────────────────────────────────────────────────────────────

class _FormFieldWidget extends StatelessWidget {
  final VisitFormField field;
  final BuildContext context;
  final PraRegistrationController controller;
  const _FormFieldWidget({
    required this.field,
    required this.context,
    required this.controller,
  });

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          RichText(
            text: TextSpan(
              text: field.longDisplayText.isEmpty
                  ? field.shortName
                  : field.longDisplayText,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              children: [
                if (field.mandatory || controller.currentStep.value == 2)
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
          const SizedBox(height: 6),

          // Field based on type
          _buildInputWidget(ctx),
        ],
      ),
    );
  }

  Widget _buildInputWidget(BuildContext ctx) {
    // 0=Text, 1=Number, 2=Email, 3=Dropdown, 4=DatePicker,
    // 5=Radio, 6=Checkbox, 9=DateTime, 10=Camera, 11=File, 12=Image
    switch (field.fieldType) {
      case 0:
      case 1:
      case 2:
      case 3:
        return _buildTextField(
          keyboardType: field.fieldType == 1
              ? TextInputType.number
              : field.fieldType == 2
              ? TextInputType.emailAddress
              : TextInputType.text,
        );

      case 5: // Radio
        return _buildRadioGroup();

      case 4: // Date picker
        return _buildDateField(ctx, withTime: false);

      case 9: // DateTime picker
        return _buildDateField(ctx, withTime: true);

      case 6: // Checkbox
        return _buildCheckbox();

      case 10:
      case 11:
      case 12:
        return _buildFileUploadField();

      default:
        return _buildTextField(keyboardType: TextInputType.text);
    }
  }

  Widget _buildTextField({required TextInputType keyboardType}) {
    return TextFormField(
      initialValue: field.answerText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
        ),
      ),
      onChanged: (v) {
        field.answerText = v;
        controller.updateForm();
      },
    );
  }

  Widget _buildRadioGroup() {
    return Column(
      children: field.multipleOptionFields.map((opt) {
        return StatefulBuilder(
          builder: (ctx, setState) => RadioListTile<String>(
            value: opt.value,
            groupValue: field.answerText,
            activeColor: AppColors.primary500,
            title: Text(opt.name, style: const TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.zero,
            onChanged: (v) {
              if (v != null) {
                field.answerText = v;
                setState(() {});
                controller.updateForm();
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCheckbox() {
    return StatefulBuilder(
      builder: (ctx, setState) => CheckboxListTile(
        value: field.answerText == 'true',
        activeColor: AppColors.primary500,
        title: Text(field.shortName, style: const TextStyle(fontSize: 14)),
        contentPadding: EdgeInsets.zero,
        onChanged: (v) {
          field.answerText = (v == true).toString();
          setState(() {});
          controller.updateForm();
        },
      ),
    );
  }

  Widget _buildDateField(BuildContext ctx, {required bool withTime}) {
    final displayCtrl = TextEditingController(
      text: _formatDisplay(field.answerDatetime, withTime),
    );

    return StatefulBuilder(
      builder: (ctx, setState) => TextFormField(
        controller: displayCtrl,
        readOnly: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          hintText: withTime
              ? 'EEEE, DD MMMM YYYY, HH:mm'
              : 'EEEE, DD MMMM YYYY',
          hintStyle: const TextStyle(color: AppColors.grey400, fontSize: 13),
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.grey500,
            size: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.primary500,
              width: 1.5,
            ),
          ),
        ),
        onTap: () async {
          if (withTime) {
            await _pickDateTime(ctx, setState, displayCtrl);
          } else {
            await _pickDate(ctx, setState, displayCtrl);
          }
        },
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext ctx,
    StateSetter setState,
    TextEditingController ctrl,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: ctx,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary500),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final isUTC = field.remarks == "visitor_period_start" ||
          field.remarks == "visitor_period_end";
      final dt = isUTC ? picked.toUtc() : picked;
      final iso = dt.toIso8601String().replaceAll(RegExp(r'\.\d+'), '');
      field.answerDatetime = iso;
      field.answerText = iso;
      ctrl.text = _formatDisplay(iso, false);
      setState(() {});
      controller.updateForm();
    }
  }

  Future<void> _pickDateTime(
    BuildContext ctx,
    StateSetter setState,
    TextEditingController ctrl,
  ) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: ctx,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary500),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary500),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    if (!ctx.mounted) return;

    final dtRaw =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final isUTC = field.remarks == "visitor_period_start" ||
        field.remarks == "visitor_period_end";
    final dt = isUTC ? dtRaw.toUtc() : dtRaw;
    final iso = dt.toIso8601String().replaceAll(RegExp(r'\.\d+'), '');
    field.answerDatetime = iso;
    field.answerText = iso;
    ctrl.text = _formatDisplay(iso, true);
    setState(() {});
    controller.updateForm();
  }

  Widget _buildFileUploadField() {
    // field.fieldType: 10 = camera only, 11 = file, 12 = image (camera + gallery)
    return _FileUploadState(field: field, cameraOnly: field.fieldType == 10);
  }

  String _formatDisplay(String iso, bool withTime) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      if (withTime) {
        return DateFormat('EEE, dd MMM yyyy HH:mm').format(dt);
      }
      return DateFormat('EEE, dd MMM yyyy').format(dt);
    } catch (_) {
      return iso;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// File / Image upload widget (handles camera, gallery, upload, preview)
// ─────────────────────────────────────────────────────────────────────────────

class _FileUploadState extends StatefulWidget {
  final VisitFormField field;
  final bool cameraOnly;
  const _FileUploadState({required this.field, required this.cameraOnly});

  @override
  State<_FileUploadState> createState() => _FileUploadStateState();
}

class _FileUploadStateState extends State<_FileUploadState> {
  File? _pickedFile;
  bool _isUploading = false;

  Future<void> _pickAndUpload(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _pickedFile = file;
      _isUploading = true;
    });

    try {
      final api = ApiService();
      final response = await api.uploadFile(file);

      final status = response.data['status']?.toString();
      if (status == 'success') {
        final path = response.data['collection']?.toString() ?? '';
        widget.field.answerText = path;
        debugPrint(
          'Upload berhasil [${widget.field.shortName}]: ${widget.field.answerText}',
        );
        setState(() => _isUploading = false);
        Get.find<PraRegistrationController>().updateForm();
      } else {
        final msg = response.data['msg']?.toString() ?? 'Upload gagal';
        setState(() {
          _isUploading = false;
          _pickedFile = null;
        });
        Get.snackbar(
          'Error',
          msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _pickedFile = null;
      });
      Get.snackbar(
        'Error',
        'Gagal mengupload file: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _showSourceSheet() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primary500,
              ),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                _pickAndUpload(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary500,
              ),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                _pickAndUpload(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show preview if file already uploaded
    if (_pickedFile != null && !_isUploading) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _pickedFile!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _pickedFile = null;
                  widget.field.answerText = '';
                });
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _isUploading
          ? null
          : () {
              if (widget.cameraOnly) {
                _pickAndUpload(ImageSource.camera);
              } else {
                _showSourceSheet();
              }
            },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: _isUploading ? AppColors.primary500 : AppColors.grey300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.primary50,
        ),
        child: _isUploading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary500,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Mengupload...',
                      style: TextStyle(color: AppColors.grey500, fontSize: 12),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.cameraOnly
                        ? Icons.camera_alt_outlined
                        : Icons.upload_outlined,
                    color: AppColors.primary500,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.cameraOnly ? 'Buka Kamera' : 'Pilih File / Foto',
                    style: const TextStyle(
                      color: AppColors.primary500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int step;
  final PraRegistrationController controller;
  final BuildContext context;
  const _BottomNav({
    required this.step,
    required this.controller,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return Obx(() {
      final isLast = step == 2;
      // Next enabled as long as a type is selected and status is selected
      final canProceed = step == 0
          ? controller.selectedVisitorTypeId.value.isNotEmpty &&
                controller.isGroup.value != null
          : controller.validateCurrentStep();
      final isSubmitting = controller.isSubmitting.value;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Back button
            OutlinedButton.icon(
              onPressed: step == 0 ? null : controller.prevStep,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: step == 0 ? AppColors.grey300 : AppColors.primary500,
                ),
                foregroundColor: AppColors.primary500,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
            ),

            const Spacer(),

            // Next / Submit button
            FilledButton.icon(
              onPressed: (!canProceed || isSubmitting)
                  ? null
                  : () async {
                      if (isLast) {
                        final ok = await controller.submitForm();
                        if (ok && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      } else {
                        controller.nextStep();
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary500,
                disabledBackgroundColor: AppColors.grey300,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(isLast ? Icons.check : Icons.arrow_forward, size: 16),
              label: Text(isLast ? 'Submit' : 'Next'),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header with left blue border accent
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.primary500, width: 3)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
