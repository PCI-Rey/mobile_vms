import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/models/visitor_type_detail_model.dart';
import 'controllers/pra_registration_controller.dart';
import '../../../../data/models/access_pass_model.dart';

/// Shows the Add Pra Registration dialog.
Future<bool?> showAddPraRegistrationDialog(
  BuildContext context, {
  AccessPassModel? duplicateData,
  List<Map<String, dynamic>>? subVisitors,
}) async {
  Get.delete<PraRegistrationController>(force: true);
  final ctrl = Get.put(PraRegistrationController());
  
  if (duplicateData != null) {
    await ctrl.autofillFromAccessPass(duplicateData, subVisitors: subVisitors);
  }

  if (!context.mounted) return null;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _AddPraRegistrationDialog(),
  );
}

// ─── Utility: Exit Confirmation ───────────────────────────────────────────

Future<bool> _showExitConfirmation(BuildContext context) async {
  final ctrl = Get.find<PraRegistrationController>();
  // If the controller has an 'hasUnsavedChanges' getter, use it.
  // Otherwise, default to showing the dialog to be safe.
  try {
    if (!(ctrl as dynamic).hasUnsavedChanges) return true;
  } catch (_) {
    // If hasUnsavedChanges doesn't exist, we'll just show the dialog
  }

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rw(context, 16)),
      ),
      title: Text(
        'Cancel Registration?',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        'The data you have entered will be lost. Are you sure you want to close this form?',
        textAlign: TextAlign.justify,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('No', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Yes, Close',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<bool> _showBackConfirmation(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rw(context, 16)),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              hSpace(context, 12),
              Text('Warning', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Are you sure you want to go back? Going back to Visitor Type selection will reset the information you have already entered in this step.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: rfs(context, 14),
              color: Color(0xFF616161),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Yes, Go Back',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ) ??
      false;
}

Future<bool> _showDeleteVisitorConfirmation(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rw(context, 16)),
          ),
          title: Text(
            'Delete Visitor?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this visitor? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Yes, Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ) ??
      false;
}

class _AddPraRegistrationDialog extends StatelessWidget {
  const _AddPraRegistrationDialog();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PraRegistrationController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmation(context);
        if (shouldExit && context.mounted) {
          ctrl.resetFields(); // Ensure data is cleared
          Navigator.of(context).pop();
        }
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rw(context, 20)),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: rw(context, 16),
          vertical: rh(context, 28),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.88,
          child: Obx(() {
            final step = ctrl.currentStep.value;
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // ── Header ────────────────────────────────────────────
                _DialogHeader(
                  step: step,
                  onClose: () async {
                    final shouldExit = await _showExitConfirmation(context);
                    if (shouldExit && context.mounted) {
                      ctrl.resetFields(); // Ensure data is cleared
                      Navigator.of(context).pop();
                    }
                  },
                  controller: ctrl,
                ),

                // ── Content ─────────────────────────────────────────
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(color: Color(0xFFF3F4F6)),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 20),
                        vertical: rh(context, 20),
                      ),
                      child: _StepContent(step: step, controller: ctrl),
                    ),
                  ),
                ),

                // ── Navigation Buttons ───────────────────────────────
                _BottomNav(step: step, controller: ctrl, context: context),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog Header — title + step indicator + close button
// ─────────────────────────────────────────────────────────────────────────────

class _DialogHeader extends StatelessWidget {
  final int step;
  final VoidCallback onClose;
  final PraRegistrationController controller;

  const _DialogHeader({
    required this.step,
    required this.onClose,
    required this.controller,
  });

  static const _stepTitles = [
    'User Type',
    'Visitor Information',
    'Purpose Visit',
  ];

  static const _stepIcons = [
    Icons.person_outline_rounded,
    Icons.badge_outlined,
    Icons.edit_calendar_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentStep = controller.currentStep.value;
      final title = (currentStep == 1 && controller.isGroup.value == true)
          ? 'Visitor Information (Group)'
          : _stepTitles[currentStep];

      return Column(
        children: [
          // Top bar: title + close
          Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Create Pra Registration',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: rfs(context, 17),
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(rw(context, 20)),
                    onTap: onClose,
                    child: Container(
                      padding: EdgeInsets.all(rw(context, 6)),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Step progress bar
          _StepProgressBar(
            controller: controller,
            currentStep: currentStep,
            total: 3,
          ),

          vSpace(context, 14),

          // Step title + icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(rw(context, 6)),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(rw(context, 8)),
                ),
                child: Icon(
                  _stepIcons[currentStep],
                  size: 16,
                  color: AppColors.primary500,
                ),
              ),
              hSpace(context, 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: rfs(context, 15),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          vSpace(context, 14),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step progress bar (segmented)
// ─────────────────────────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final PraRegistrationController controller;
  final int currentStep;
  final int total;

  const _StepProgressBar({
    required this.controller,
    required this.currentStep,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 32),
        vertical: rh(context, 16),
      ),
      child: Row(
        children: List.generate(total, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          final isActive = isCompleted || isCurrent;

          return Expanded(
            flex: index == total - 1 ? 0 : 1,
            child: Row(
              children: [
                // ── Circle Number ──────────────────────────────────
                GestureDetector(
                  onTap: () async {
                    // Jika user mencoba kembali ke Step 0 (Page 1) dari step manapun yang lebih tinggi
                    if (currentStep > 0 && index == 0 && !controller.isDuplicateMode.value) {
                      final shouldBack = await _showBackConfirmation(context);
                      if (shouldBack) {
                        controller
                            .clearStep1Fields(); // Ini akan mereset Step 1 dan Step 2
                        controller.goToStep(index);
                      }
                    } else {
                      controller.goToStep(index);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary500
                          : const Color(0xFFCCCCCC),
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.primary500.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 10,
                                spreadRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: rfs(context, 13),
                              ),
                            ),
                    ),
                  ),
                ),

                // ── Connecting Line ────────────────────────────────
                if (index < total - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: EdgeInsets.symmetric(horizontal: rw(context, 8)),
                      color: (index < currentStep)
                          ? AppColors.primary500
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
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
      final selectedId = controller.selectedVisitorTypeId.value;
      final isLoadingDetail = controller.isLoadingDetail.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Visitor Type section ─────────────────────────────────
          _SectionHeader(title: 'Visitor Type', isRequired: true),
          vSpace(context, 12),

          if (controller.isLoadingTypes.value)
            Center(
              child: Padding(
                padding: EdgeInsets.all(rw(context, 24)),
                child: CircularProgressIndicator(),
              ),
            )
          else
            ...List.generate(controller.visitorTypes.length, (i) {
              final type = controller.visitorTypes[i];
              final isSelected = selectedId == type.id;
              return Padding(
                padding: EdgeInsets.only(bottom: rh(context, 8)),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      controller.onSelectVisitorType(type.id, type.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 14),
                      vertical: rh(context, 14),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary500.withValues(alpha: 0.06)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary500
                            : const Color(0xFFE0E0E0),
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(rw(context, 12)),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primary500
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary500
                                  : const Color(0xFFBDBDBD),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Icon(Icons.check, size: 12, color: Colors.white)
                              : null,
                        ),
                        hSpace(context, 12),
                        Expanded(
                          child: Text(
                            type.name,
                            style: TextStyle(
                              fontSize: rfs(context, 14),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primary500
                                  : Colors.black87,
                            ),
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
              );
            }),

          vSpace(context, 24),

          // ── Select Status Visitor ────────────────────────────────
          _SectionHeader(title: 'Select Status Visitor', isRequired: true),
          vSpace(context, 12),

          Row(
            children: [
              Expanded(
                child: _StatusCard(
                  label: 'Single',
                  icon: Icons.person_outline_rounded,
                  isSelected: controller.isGroup.value == false,
                  onTap: () => controller.isGroup.value = false,
                ),
              ),
              hSpace(context, 10),
              Expanded(
                child: _StatusCard(
                  label: 'Group',
                  icon: Icons.group_outlined,
                  isSelected: controller.isGroup.value == true,
                  onTap: () {
                    if (controller.isGroup.value != true) {
                      controller.isGroup.value = true;
                      controller.initGroupMode();
                    }
                  },
                ),
              ),
            ],
          ),

          // ── Group List (visible when Group selected) ─────────────
          if (controller.isGroup.value == true)
            ..._buildGroupList(context, controller),
        ],
      );
    });
  }

  List<Widget> _buildGroupList(
    BuildContext context,
    PraRegistrationController controller,
  ) {
    return [
      vSpace(context, 24),
      _SectionHeader(title: 'Group List', isRequired: true),
      vSpace(context, 12),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(rw(context, 12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Table header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 14),
                vertical: rh(context, 10),
              ),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Group Name',
                      style: TextStyle(
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                  hSpace(context, 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Code',
                      style: TextStyle(
                        fontSize: rfs(context, 12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Padding(
              padding: EdgeInsets.all(rw(context, 14)),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: controller.groupNameCtrl,
                      onChanged: (v) => controller.groupName.value = v,
                      decoration: InputDecoration(
                        hintText: 'Enter group name',
                        hintStyle: TextStyle(
                          color: AppColors.grey400,
                          fontSize: rfs(context, 13),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: rw(context, 12),
                          vertical: rh(context, 10),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(rw(context, 8)),
                          borderSide: const BorderSide(
                            color: AppColors.grey300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(rw(context, 8)),
                          borderSide: const BorderSide(
                            color: AppColors.grey300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(rw(context, 8)),
                          borderSide: const BorderSide(
                            color: AppColors.primary500,
                            width: 1.5,
                          ),
                        ),
                        isDense: true,
                      ),
                      style: TextStyle(fontSize: rfs(context, 13)),
                    ),
                  ),
                  hSpace(context, 8),
                  Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 10),
                        vertical: rh(context, 10),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withValues(alpha: 0.06),
                        border: Border.all(color: AppColors.primary200),
                        borderRadius: BorderRadius.circular(rw(context, 8)),
                      ),
                      child: Text(
                        controller.groupCode.value,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: rfs(context, 13),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

// ── Status card (Single / Group) ──────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: rh(context, 14),
          horizontal: rw(context, 12),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary500.withValues(alpha: 0.06)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary500 : const Color(0xFFE0E0E0),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(rw(context, 12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary500 : AppColors.grey500,
            ),
            hSpace(context, 8),
            Text(
              label,
              style: TextStyle(
                fontSize: rfs(context, 14),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary500 : Colors.black87,
              ),
            ),
            hSpace(context, 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary500 : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary500 : AppColors.grey400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 11, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
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
      if (controller.isGroup.value == true) {
        return _buildGroupVisitorTable(context);
      }

      final detail = controller.formStructure.value;
      if (detail == null) {
        return Center(child: CircularProgressIndicator());
      }

      final sections = detail.sectionPageVisitorTypes;
      final section =
          sections.firstWhereOrNull(
            (s) => s.name.toLowerCase().contains('visitor'),
          ) ??
          sections.firstOrNull;

      if (section == null) {
        return Text('Tidak ada data form.');
      }

      // Tampilkan search hanya jika Visitor Type yang dipilih BUKAN tipe Employee/Staff.
      // Cara deteksi: form Employee/Staff selalu punya field remarks='is_employee'.
      final isEmployeeType =
          controller.formStructure.value?.sectionPageVisitorTypes.any(
            (s) =>
                s.praForm.any((f) => f.remarks.toLowerCase() == 'is_employee'),
          ) ??
          false;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Existing Visitor — hanya untuk Visitor type (bukan Employee/Staff) ──
          if (!isEmployeeType) ...[
            _SectionHeader(title: 'Search Existing Visitor'),
            vSpace(context, 8),
            _VisitorSearchField(
              controller: controller,
              onSelected: (v) => controller.autofillSingleFromVisitor(v),
              onClear: () => controller.clearVisitorFormInputs(),
            ),
            vSpace(context, 20),
          ],

          // ── Search Existing Employee — hanya untuk Employee/Staff type ──
          if (isEmployeeType) ...[
            _SectionHeader(title: 'Search Existing Employee'),
            vSpace(context, 8),
            _EmployeeSearchField(
              controller: controller,
              initialValue: controller.selectedEmployeeName.value,
              onSelected: (e) {
                final id = e['id']?.toString() ?? '';
                controller.onEmployeeSelected(id);
              },
              onClear: () => controller.clearVisitorFormInputs(),
            ),
            vSpace(context, 20),
          ],

          // ── Form fields from API structure ───────────────────────────
          ...section.praForm
              .where((f) => f.isEnable)
              .map(
                (f) => _FormFieldWidget(
                  field: f,
                  context: context,
                  controller: controller,
                ),
              ),
        ],
      );
    });
  }

  Widget _buildGroupVisitorTable(BuildContext context) {
    return Obx(() {
      final visitors = controller.groupVisitors;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(visitors.length, (i) {
            final v = visitors[i];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Use App's native Section Header style (Left Accent Border)
                _SectionHeader(title: 'Visitor ${i + 1}'),
                vSpace(context, 10),

                // Per-row search — Visitor or Employee
                Builder(
                  builder: (context) {
                    final isEmpType =
                        controller.formStructure.value?.sectionPageVisitorTypes
                            .any(
                              (s) => s.praForm.any(
                                (f) => f.remarks.toLowerCase() == 'is_employee',
                              ),
                            ) ??
                        false;
                    if (isEmpType) {
                      return Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _EmployeeSearchField(
                              controller: controller,
                              initialValue: v.selectedEmployeeName.value,
                              syncWith: v.selectedEmployeeName,
                              onSelected: (emp) {
                                final id = emp['id']?.toString() ?? '';
                                controller.onGroupEmployeeSelected(v, id);
                              },
                              onClear: () {
                                v.selectedEmployeeId.value = '';
                                v.selectedEmployeeName.value = '';
                                v.fullName.clear();
                                v.email.clear();
                                v.phone.clear();
                                v.organization.clear();
                                v.identityId.clear();
                                controller.updateForm();
                              },
                            ),
                            vSpace(context, 12),
                          ],
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _VisitorSearchField(
                          controller: controller,
                          onSelected: (visitor) => controller
                              .autofillGroupVisitorFromVisitor(v, visitor),
                          onClear: () {
                            v.fullName.clear();
                            v.email.clear();
                            v.phone.clear();
                            v.organization.clear();
                            v.identityId.clear();
                            controller.updateForm();
                          },
                        ),
                        vSpace(context, 12),
                      ],
                    );
                  },
                ),

                // Remove button moved to a more elegant position if needed,
                // but keeping it simple for consistency.
                if (visitors.length > 1)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () async {
                        final shouldDelete =
                            await _showDeleteVisitorConfirmation(context);
                        if (shouldDelete) {
                          controller.removeGroupVisitor(i);
                        }
                      },
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: Colors.red.shade400,
                      ),
                      label: Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: rfs(context, 12),
                          color: Colors.red.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: rw(context, 8),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),

                // Form Fields
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rw(context, 4)),
                  child: Column(
                    children: [
                      // Are you Employee? section
                      Obx(() {
                        final isEmployeeType = controller
                            .selectedVisitorTypeName
                            .value
                            .toLowerCase()
                            .contains('employee');
                        if (!isEmployeeType) {
                          if (v.isEmployee.value) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              v.isEmployee.value = false;
                              v.selectedEmployeeId.value = '';
                              v.selectedEmployeeName.value = '';
                              v.fullName.clear();
                              v.email.clear();
                              v.phone.clear();
                              v.organization.clear();
                              v.identityId.clear();
                            });
                          }
                          return const SizedBox.shrink();
                        }
                        final empEnabled = v.isEmployee.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Are you Employee?',
                              style: TextStyle(
                                fontSize: rfs(context, 13),
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            vSpace(context, 8),
                            Row(
                              children: [
                                _InlineRadio(
                                  label: 'Yes',
                                  isSelected: empEnabled,
                                  onTap: () {
                                    v.isEmployee.value = true;
                                    v.selectedEmployeeId.value = '';
                                    v.selectedEmployeeName.value = '';
                                    v.fullName.clear();
                                    v.email.clear();
                                    v.phone.clear();
                                    v.organization.clear();
                                    v.identityId.clear();
                                    controller.updateForm();
                                  },
                                ),
                                hSpace(context, 16),
                                _InlineRadio(
                                  label: 'No',
                                  isSelected: !empEnabled,
                                  onTap: () {
                                    v.isEmployee.value = false;
                                    v.selectedEmployeeId.value = '';
                                    v.selectedEmployeeName.value = '';
                                    v.fullName.clear();
                                    v.email.clear();
                                    v.phone.clear();
                                    v.organization.clear();
                                    v.identityId.clear();
                                    controller.updateForm();
                                  },
                                ),
                              ],
                            ),
                            vSpace(context, 16),
                            // Employee Name dropdown is hidden as per request; employee is selected from search field
                            vSpace(context, 16),
                          ],
                        );
                      }),

                      // Role Dropdown
                      Obx(() {
                        final roles =
                            controller.formStructure.value?.visitorRoles ?? [];
                        final isEmployeeType = controller
                            .selectedVisitorTypeName
                            .value
                            .toLowerCase()
                            .contains('employee');

                        if (isEmployeeType) {
                          final defaultRole = roles.isNotEmpty ? roles.first.role : 'Employee';
                          if (v.selectedVisitorRole.value != defaultRole) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              v.selectedVisitorRole.value = defaultRole;
                              controller.updateForm();
                            });
                          }
                          return const SizedBox.shrink();
                        }

                        if (roles.isEmpty) return const SizedBox.shrink();
                        final selected = v.selectedVisitorRole.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Role',
                                style: TextStyle(
                                  fontSize: rfs(context, 13),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' *',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            vSpace(context, 8),
                            Builder(
                              builder: (ctx) => GestureDetector(
                                onTap: () async {
                                  final result = await _showVisitorRolePicker(
                                    ctx,
                                    roles,
                                    selected,
                                  );
                                  if (result != null) {
                                    v.selectedVisitorRole.value = result.role;
                                    controller.updateForm();
                                  }
                                },
                                child: _DropdownTrigger(
                                  text: selected,
                                  hint: 'Pilih Role',
                                ),
                              ),
                            ),
                            vSpace(context, 16),
                          ],
                        );
                      }),

                      _GroupTextField(
                        label: 'Full Name',
                        controller: v.fullName,
                        hint: 'Enter full name',
                        readOnly: controller.selectedVisitorTypeName.value
                            .toLowerCase()
                            .contains('employee'),
                        onChanged: (_) => controller.updateForm(),
                      ),
                      vSpace(context, 16),
                      _GroupTextField(
                        label: 'Email',
                        controller: v.email,
                        hint: 'Enter email',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => controller.updateForm(),
                      ),
                      vSpace(context, 16),
                      _GroupTextField(
                        label: 'Phone',
                        controller: v.phone,
                        hint: 'e.g. 08123...',
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => controller.updateForm(),
                      ),
                      vSpace(context, 16),
                      _GroupTextField(
                        label: 'Organization',
                        controller: v.organization,
                        hint: 'Company / Instance',
                        onChanged: (_) => controller.updateForm(),
                      ),
                      vSpace(context, 16),
                      _GroupTextField(
                        label: 'Identity ID (KTP)',
                        controller: v.identityId,
                        hint: 'Enter KTP number',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => controller.updateForm(),
                      ),
                    ],
                  ),
                ),

                if (i < visitors.length - 1) ...[
                  vSpace(context, 32),
                  const Divider(height: 1, color: Color(0xFFE0E0E0)),
                  vSpace(context, 32),
                ] else
                  vSpace(context, 24),
              ],
            );
          }),

          vSpace(context, 10),
          Center(
            child: OutlinedButton.icon(
              onPressed: controller.addGroupVisitor,
              icon: Icon(Icons.add_circle_outline_rounded, size: 20),
              label: Text(
                'Add New Visitor',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: rfs(context, 14),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary500,
                backgroundColor: AppColors.primary500.withValues(alpha: 0.05),
                side: BorderSide(
                  color: AppColors.primary500.withValues(alpha: 0.3),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 28),
                  vertical: rh(context, 12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rw(context, 30)),
                ),
              ),
            ),
          ),
          vSpace(context, 20),
        ],
      );
    });
  }
}

// ── Shared visitor role picker ────────────────────────────────────────────────

Future<VisitorRoleItem?> _showVisitorRolePicker(
  BuildContext context,
  List<VisitorRoleItem> items,
  String currentRole,
) {
  return showModalBottomSheet<VisitorRoleItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: rh(context, 10)),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(rw(context, 2)),
            ),
          ),
          Text(
            'Pilih Role',
            style: TextStyle(
              fontSize: rfs(context, 15),
              fontWeight: FontWeight.w700,
            ),
          ),
          vSpace(context, 8),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final selected = item.role == currentRole;
                return InkWell(
                  onTap: () => Navigator.of(sheetCtx).pop(item),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 20),
                      vertical: rh(context, 14),
                    ),
                    color: selected
                        ? AppColors.primary500.withValues(alpha: 0.08)
                        : Colors.transparent,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.role,
                            style: TextStyle(
                              fontSize: rfs(context, 14),
                              color: selected
                                  ? AppColors.primary500
                                  : Colors.black87,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (selected)
                          Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: AppColors.primary500,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          vSpace(context, 8),
        ],
      ),
    ),
  );
}

// ── Shared employee picker ──────────────────────────────────────────────────────

Future<DropdownItem?> _showEmployeePicker(
  BuildContext context,
  List<DropdownItem> items,
  String currentId,
) {
  return showModalBottomSheet<DropdownItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: rh(context, 10)),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(rw(context, 2)),
            ),
          ),
          Text(
            'Pilih Employee',
            style: TextStyle(
              fontSize: rfs(context, 15),
              fontWeight: FontWeight.w700,
            ),
          ),
          vSpace(context, 8),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final selected = item.id == currentId;
                return InkWell(
                  onTap: () => Navigator.of(sheetCtx).pop(item),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 20),
                      vertical: rh(context, 14),
                    ),
                    color: selected
                        ? AppColors.primary500.withValues(alpha: 0.08)
                        : Colors.transparent,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: rfs(context, 14),
                              color: selected
                                  ? AppColors.primary500
                                  : Colors.black87,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (selected)
                          Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: AppColors.primary500,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          vSpace(context, 8),
        ],
      ),
    ),
  );
}

// ── Shared inline radio widget ─────────────────────────────────────────────────

class _InlineRadio extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _InlineRadio({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary500 : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary500
                    : const Color(0xFFBDBDBD),
                width: 2,
              ),
            ),
            child: isSelected
                ? Icon(Icons.check, size: 11, color: Colors.white)
                : null,
          ),
          hSpace(context, 6),
          Text(
            label,
            style: TextStyle(fontSize: rfs(context, 13), color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

// ── Shared dropdown trigger ─────────────────────────────────────────────────────

class _DropdownTrigger extends StatelessWidget {
  final String text;
  final String hint;

  const _DropdownTrigger({required this.text, required this.hint});

  @override
  Widget build(BuildContext context) {
    final hasValue = text.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 12),
        vertical: rh(context, 13),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(rw(context, 10)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasValue ? text : hint,
              style: TextStyle(
                fontSize: rfs(context, 14),
                color: hasValue ? Colors.black87 : AppColors.grey400,
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.grey400,
            size: 22,
          ),
        ],
      ),
    );
  }
}

// ─── Group text field with label ──────────────────────────────────────────────

class _GroupTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  const _GroupTextField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: rfs(context, 13),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        vSpace(context, 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          readOnly: readOnly,
          style: TextStyle(fontSize: rfs(context, 14)),
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: rfs(context, 13),
              color: AppColors.grey400,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: rw(context, 12),
              vertical: rh(context, 12),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rw(context, 10)),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rw(context, 10)),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rw(context, 10)),
              borderSide: readOnly
                  ? const BorderSide(color: Color(0xFFDDDDDD))
                  : const BorderSide(
                      color: AppColors.primary500,
                      width: 1.5,
                    ),
            ),
            isDense: true,
          ),
        ),
      ],
    );
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
      final detail = controller.formStructure.value;
      if (detail == null) {
        return Center(child: CircularProgressIndicator());
      }

      final sections = detail.sectionPageVisitorTypes;
      final section =
          sections.firstWhereOrNull(
            (s) => s.name.toLowerCase().contains('purpose'),
          ) ??
          (sections.length > 1 ? sections[1] : null);

      if (section == null) {
        return Text('Tidak ada data form tujuan.');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: section.praForm
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
    final isEmployeeType = controller.selectedVisitorTypeName.value
        .toLowerCase()
        .contains('employee');

    if (isEmployeeType &&
        (field.remarks == 'employee_name' || field.remarks == 'employee')) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          RichText(
            text: TextSpan(
              text: field.longDisplayText.isEmpty
                  ? field.shortName
                  : field.longDisplayText,
              style: TextStyle(
                fontSize: rfs(context, 13),
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              children: [
                if (field.mandatory || controller.currentStep.value == 2)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          vSpace(context, 7),
          _buildInputWidget(ctx),
        ],
      ),
    );
  }

  Widget _buildInputWidget(BuildContext ctx) {
    if (field.remarks == 'visitor_role') {
      return Obx(() {
        final roles = controller.formStructure.value?.visitorRoles ?? [];
        final selected = controller.selectedVisitorRole.value;
        final selectedRole = roles.isNotEmpty
            ? roles.firstWhereOrNull((r) => r.role == selected)
            : null;

        // If only 1 role is available, auto-select and show as read-only
        if (roles.length == 1) {
          final single = roles.first;
          if (controller.selectedVisitorRole.value != single.role) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.selectedVisitorRole.value = single.role;
              field.answerText = single.role;
              controller.updateForm();
            });
          }
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 12),
              vertical: rh(context, 13),
            ),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDDDDDD)),
              borderRadius: BorderRadius.circular(rw(context, 10)),
              color: Colors.white,
            ),
            child: Text(
              single.role,
              style: TextStyle(
                fontSize: rfs(context, 14),
                color: Colors.black87,
              ),
            ),
          );
        }

        return _buildPickerTrigger(
          displayText: selectedRole?.role ?? '',
          hint: 'Pilih Role',
          onTap: (ctx) async {
            if (roles.isEmpty) return;
            final result = await _showPickerSheet<VisitorRoleItem>(
              ctx,
              title: 'Pilih Role',
              items: roles,
              labelOf: (r) => r.role,
              isSelected: (r) => r.role == selected,
            );
            if (result != null) {
              controller.selectedVisitorRole.value = result.role;
              field.answerText = result.role;
              controller.updateForm();
            }
          },
        );
      });
    }

    if (field.remarks == 'host') {
      return Obx(() {
        final list = controller.hosts.toList();
        // If only 1 host available, auto-select and show as read-only
        if (list.length == 1) {
          final single = list.first;
          // Auto-set if not already set
          if (controller.selectedHostId.value != single.id) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.selectedHostId.value = single.id;
              field.answerText = single.id;
              controller.updateForm();
            });
          }
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 12),
              vertical: rh(context, 13),
            ),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDDDDDD)),
              borderRadius: BorderRadius.circular(rw(context, 10)),
              color: Colors.white,
            ),
            child: Text(
              single.name,
              style: TextStyle(
                fontSize: rfs(context, 14),
                color: Colors.black87,
              ),
            ),
          );
        }
        // Multiple hosts → show dropdown as usual
        return _buildApiDropdown(
          items: controller.hosts,
          selectedId: controller.selectedHostId,
          onSelected: (id, name) {
            controller.selectedHostId.value = id;
            field.answerText = id;
            controller.updateForm();
          },
          hint: 'Pilih PIC Host',
        );
      });
    }

    if (field.remarks == 'site_place') {
      return _buildApiDropdown(
        items: controller.sites,
        selectedId: controller.selectedSiteId,
        onSelected: (id, name) {
          controller.selectedSiteId.value = id;
          field.answerText = id;
          controller.updateForm();
        },
        hint: 'Pilih Destinasi',
      );
    }

    if (field.remarks == 'employee_name' || field.remarks == 'employee') {
      return Obx(() {
        final enabled = controller.isEmployee.value;
        return Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: IgnorePointer(
            ignoring: !enabled,
            child: _buildApiDropdown(
              items: controller.employees,
              selectedId: controller.selectedEmployeeId,
              onSelected: (id, name) {
                controller.onEmployeeSelected(id);
                field.answerText = id;
              },
              hint: 'Pilih Employee',
            ),
          ),
        );
      });
    }

    if (field.remarks == 'agenda') return _buildAgendaDropdown();

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

      case 5:
        if (field.remarks == 'is_employee') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRadioGroup(),
              vSpace(context, 4),
              const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
            ],
          );
        }
        return _buildRadioGroup();

      case 4:
        return _buildDateField(ctx, withTime: false);

      case 9:
        return _buildDateField(ctx, withTime: true);

      case 6:
        return _buildCheckbox();

      case 10:
      case 11:
      case 12:
        return _buildFileUploadField();

      default:
        return _buildTextField(keyboardType: TextInputType.text);
    }
  }

  Widget _buildApiDropdown({
    required RxList<DropdownItem> items,
    required RxString selectedId,
    required void Function(String id, String name) onSelected,
    required String hint,
  }) {
    return Obx(() {
      final list = items.toList();
      final currentId = selectedId.value;
      final selectedItem = list.any((e) => e.id.toLowerCase() == currentId.toLowerCase())
          ? list.firstWhere((e) => e.id.toLowerCase() == currentId.toLowerCase())
          : null;

      return _buildPickerTrigger(
        displayText: selectedItem?.name ?? '',
        hint: hint,
        onTap: (ctx) async {
          final result = await _showPickerSheet<DropdownItem>(
            ctx,
            title: hint,
            items: list,
            labelOf: (e) => e.name,
            isSelected: (e) => e.id.toLowerCase() == currentId.toLowerCase(),
          );
          if (result != null) onSelected(result.id, result.name);
        },
      );
    });
  }

  static const _agendaOptions = [
    'Meeting',
    'Presentation',
    'Visit',
    'Training',
    'Report',
    'Other',
  ];

  Widget _buildAgendaDropdown() {
    return StatefulBuilder(
      builder: (ctx, setState) {
        final predefined = _agendaOptions.sublist(0, 5);
        final selectedLabel = predefined.contains(field.answerText)
            ? field.answerText
            : (field.answerText.isEmpty ? '' : 'Other');
        final showCustomField = selectedLabel == 'Other';

        final textDecoration = InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: rw(context, 12),
            vertical: rh(context, 12),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(context, 10)),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(context, 10)),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(context, 10)),
            borderSide: const BorderSide(
              color: AppColors.primary500,
              width: 1.5,
            ),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPickerTrigger(
              displayText: selectedLabel,
              hint: 'Pilih Agenda',
              onTap: (context) async {
                final result = await _showPickerSheet<String>(
                  context,
                  title: 'Pilih Agenda',
                  items: _agendaOptions,
                  labelOf: (e) => e,
                  isSelected: (e) => e == selectedLabel,
                );
                if (result != null) {
                  if (result == 'Other') {
                    field.answerText = 'Other';
                    controller.agenda.value = '';
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.agendaFocusNode.requestFocus();
                    });
                  } else {
                    field.answerText = result;
                    controller.agenda.value = result;
                  }
                  setState(() {});
                  controller.updateForm();
                }
              },
            ),
            if (showCustomField) ...[
              vSpace(context, 8),
              TextFormField(
                initialValue: field.answerText == 'Other'
                    ? ''
                    : field.answerText,
                focusNode: controller.agendaFocusNode,
                decoration: textDecoration.copyWith(
                  hintText: 'Other',
                  hintStyle: TextStyle(
                    color: AppColors.grey400,
                    fontSize: rfs(context, 13),
                  ),
                ),
                style: TextStyle(fontSize: rfs(context, 14)),
                onChanged: (v) {
                  field.answerText = v;
                  controller.agenda.value = v;
                  controller.updateForm();
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPickerTrigger({
    required String displayText,
    required String hint,
    required void Function(BuildContext) onTap,
  }) {
    return Builder(
      builder: (ctx) => GestureDetector(
        onTap: () => onTap(ctx),
        child: _DropdownTrigger(text: displayText, hint: hint),
      ),
    );
  }

  static Future<T?> _showPickerSheet<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required String Function(T) labelOf,
    required bool Function(T) isSelected,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: rh(context, 10)),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(rw(context, 2)),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: rfs(context, 15),
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            vSpace(context, 8),
            const Divider(height: 1),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  final label = labelOf(item);
                  final selected = isSelected(item);
                  return InkWell(
                    onTap: () => Navigator.of(sheetCtx).pop(item),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 20),
                        vertical: rh(context, 14),
                      ),
                      color: selected
                          ? AppColors.primary500.withValues(alpha: 0.08)
                          : Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: rfs(context, 14),
                                color: selected
                                    ? AppColors.primary500
                                    : Colors.black87,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (selected)
                            Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: AppColors.primary500,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            vSpace(context, 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextInputType keyboardType,
    FocusNode? focusNode,
  }) {
    final dedicatedCtrl = controller.getFieldController(field.remarks);

    final isEmployeeType = controller.selectedVisitorTypeName.value
        .toLowerCase()
        .contains('employee');
    final bool isReadOnly = isEmployeeType && field.remarks == 'name';

    void onChanged(String v) {
      field.answerText = v;
      switch (field.remarks) {
        case 'name':
          controller.name.value = v;
          break;
        case 'email':
          controller.email.value = v;
          break;
        case 'phone':
          controller.phone.value = v;
          break;
        case 'organization':
          controller.organization.value = v;
          break;
        case 'indentity_id':
          controller.identityId.value = v;
          break;
        case 'host':
          controller.selectedHostId.value = v;
          break;
        case 'agenda':
          controller.agenda.value = v;
          break;
        case 'site_place':
          controller.selectedSiteId.value = v;
          break;
      }
      controller.updateForm();
    }

    final decoration = InputDecoration(
      filled: isReadOnly,
      fillColor: isReadOnly ? Colors.grey.shade100 : Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: rw(context, 12),
        vertical: rh(context, 12),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rw(context, 10)),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rw(context, 10)),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(rw(context, 10)),
        borderSide: isReadOnly 
            ? const BorderSide(color: Color(0xFFDDDDDD))
            : const BorderSide(color: AppColors.primary500, width: 1.5),
      ),
    );

    if (dedicatedCtrl != null) {
      if (dedicatedCtrl.text.isEmpty && field.answerText.isNotEmpty) {
        dedicatedCtrl.text = field.answerText;
      }
      return TextFormField(
        controller: dedicatedCtrl,
        keyboardType: keyboardType,
        focusNode: focusNode,
        readOnly: isReadOnly,
        decoration: decoration,
        onChanged: onChanged,
      );
    }

    return TextFormField(
      initialValue: field.answerText,
      keyboardType: keyboardType,
      focusNode: focusNode,
      readOnly: isReadOnly,
      decoration: decoration,
      onChanged: onChanged,
    );
  }

  Widget _buildRadioGroup() {
    return StatefulBuilder(
      builder: (ctx, setState) {
        return RadioGroup<String>(
          groupValue: field.answerText,
          onChanged: (v) {
            if (v != null) {
              field.answerText = v;
              if (field.remarks == 'is_employee') {
                controller.isEmployee.value =
                    (v == 'true' || v == 'Yes' || v == '1');
              }
              setState(() {});
              controller.updateForm();
            }
          },
          child: Column(
            children: field.multipleOptionFields.map((opt) {
              return RadioListTile<String>(
                value: opt.value,
                activeColor: AppColors.primary500,
                title: Text(
                  opt.name,
                  style: TextStyle(fontSize: rfs(context, 14)),
                ),
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCheckbox() {
    return StatefulBuilder(
      builder: (ctx, setState) => CheckboxListTile(
        value: field.answerText == 'true',
        activeColor: AppColors.primary500,
        title: Text(
          field.shortName,
          style: TextStyle(fontSize: rfs(context, 14)),
        ),
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
    DateTime? existingDt;
    if (field.answerDatetime.isNotEmpty) {
      try {
        existingDt = DateTime.parse(field.answerDatetime);
      } catch (_) {}
    }
    final displayCtrl = TextEditingController(
      text: existingDt != null ? _formatDisplay(existingDt, withTime) : '',
    );

    return StatefulBuilder(
      builder: (ctx, setState) => TextFormField(
        controller: displayCtrl,
        readOnly: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: rw(context, 12),
            vertical: rh(context, 12),
          ),
          hintText: withTime
              ? 'EEEE, DD MMMM YYYY, HH:mm'
              : 'EEEE, DD MMMM YYYY',
          hintStyle: TextStyle(
            color: AppColors.grey400,
            fontSize: rfs(context, 13),
          ),
          suffixIcon: displayCtrl.text.isNotEmpty
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    field.answerDatetime = '';
                    field.answerText = '';
                    displayCtrl.clear();
                    bool isStart = field.remarks == 'visitor_period_start';
                    bool isEnd = field.remarks == 'visitor_period_end';
                    if (isStart) {
                      controller.visitStart.value = null;
                    } else if (isEnd) {
                      controller.visitEnd.value = null;
                    }
                    setState(() {});
                    controller.updateForm();
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.grey500,
                    size: 18,
                  ),
                )
              : Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.grey500,
                  size: 18,
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(context, 10)),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(context, 10)),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(context, 10)),
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
    bool isStart = field.remarks == 'visitor_period_start';
    bool isEnd = field.remarks == 'visitor_period_end';

    DateTime initialDate = now;
    DateTime firstDate = DateTime(now.year - 1);
    DateTime lastDate = DateTime(now.year + 5);

    if (isEnd && controller.visitStart.value != null) {
      firstDate = DateTime(
          controller.visitStart.value!.year,
          controller.visitStart.value!.month,
          controller.visitStart.value!.day);
      if (initialDate.isBefore(firstDate)) {
        initialDate = firstDate;
      }
    }

    if (isStart && controller.visitEnd.value != null) {
      lastDate = DateTime(
          controller.visitEnd.value!.year,
          controller.visitEnd.value!.month,
          controller.visitEnd.value!.day);
      if (initialDate.isAfter(lastDate)) {
        initialDate = lastDate;
      }
    }

    final picked = await showDatePicker(
      context: ctx,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary500),
        ),
        child: child!,
      ),
    );
    if (picked != null) {

      final iso = picked.toIso8601String().replaceAll(RegExp(r'\.\d+'), '');
      field.answerDatetime = iso;
      field.answerText = iso;
      ctrl.text = _formatDisplay(picked, false);
      if (isStart) {
        controller.visitStart.value = picked;
      } else if (isEnd) {
        controller.visitEnd.value = picked;
      }
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
    bool isStart = field.remarks == 'visitor_period_start';
    bool isEnd = field.remarks == 'visitor_period_end';

    DateTime initialDate = now;
    DateTime firstDate = DateTime(now.year - 1);
    DateTime lastDate = DateTime(now.year + 5);

    if (isEnd && controller.visitStart.value != null) {
      firstDate = DateTime(
          controller.visitStart.value!.year,
          controller.visitStart.value!.month,
          controller.visitStart.value!.day);
      if (initialDate.isBefore(firstDate)) {
        initialDate = firstDate;
      }
    }

    if (isStart && controller.visitEnd.value != null) {
      lastDate = DateTime(
          controller.visitEnd.value!.year,
          controller.visitEnd.value!.month,
          controller.visitEnd.value!.day);
      if (initialDate.isAfter(lastDate)) {
        initialDate = lastDate;
      }
    }

    final date = await showDatePicker(
      context: ctx,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary500),
        ),
        child: child!,
      ),
    );
    if (date == null) return;
    if (!ctx.mounted) return;

    TimeOfDay initialTime = TimeOfDay.now();
    if (isEnd && controller.visitStart.value != null) {
      if (date.year == controller.visitStart.value!.year &&
          date.month == controller.visitStart.value!.month &&
          date.day == controller.visitStart.value!.day) {
        if (initialTime.hour < controller.visitStart.value!.hour ||
            (initialTime.hour == controller.visitStart.value!.hour &&
                initialTime.minute < controller.visitStart.value!.minute)) {
          initialTime = TimeOfDay(
              hour: controller.visitStart.value!.hour,
              minute: controller.visitStart.value!.minute);
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
    if (isEnd && controller.visitStart.value != null) {
      if (date.year == controller.visitStart.value!.year &&
          date.month == controller.visitStart.value!.month &&
          date.day == controller.visitStart.value!.day) {
        cupertinoMinDate = controller.visitStart.value!;
        if (cupertinoInitialDate.isBefore(cupertinoMinDate)) {
          cupertinoInitialDate = cupertinoMinDate;
        }
      }
    }

    DateTime? cupertinoMaxDate;
    if (isStart && controller.visitEnd.value != null) {
      if (date.year == controller.visitEnd.value!.year &&
          date.month == controller.visitEnd.value!.month &&
          date.day == controller.visitEnd.value!.day) {
        cupertinoMaxDate = controller.visitEnd.value!;
        if (cupertinoInitialDate.isAfter(cupertinoMaxDate)) {
          cupertinoInitialDate = cupertinoMaxDate;
        }
      }
    }

    TimeOfDay? time;
    await showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(rw(ctx, 16))),
      ),
      builder: (BuildContext builder) {
        return SizedBox(
          height: rh(ctx, 300),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rw(ctx, 16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                      onPressed: () => Navigator.of(builder).pop(),
                    ),
                    TextButton(
                      child: const Text('OK', style: TextStyle(color: AppColors.primary500, fontWeight: FontWeight.bold)),
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
                  maximumDate: cupertinoMaxDate,
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
    if (time == null) return;
    if (!ctx.mounted) return;

    final dtRaw = DateTime(
      date.year,
      date.month,
      date.day,
      time!.hour,
      time!.minute,
    );

    // Strict validator check fallback (snackbar) to ensure correctness
    if (isEnd && controller.visitStart.value != null && dtRaw.isBefore(controller.visitStart.value!)) {
      Get.snackbar('Waktu Tidak Valid', 'Visit End tidak boleh lebih awal dari Visit Start', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }
    if (isStart && controller.visitEnd.value != null && dtRaw.isAfter(controller.visitEnd.value!)) {
      Get.snackbar('Waktu Tidak Valid', 'Visit Start tidak boleh lebih lambat dari Visit End', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }

    final iso = dtRaw.toIso8601String().replaceAll(RegExp(r'\.\d+'), '');
    field.answerDatetime = iso;
    field.answerText = iso;
    ctrl.text = _formatDisplay(dtRaw, true);
    if (isStart) {
      controller.visitStart.value = dtRaw;
    } else if (isEnd) {
      controller.visitEnd.value = dtRaw;
    }
    setState(() {});
    controller.updateForm();
  }

  Widget _buildFileUploadField() {
    return _FileUploadState(field: field, cameraOnly: field.fieldType == 10);
  }

  String _formatDisplay(DateTime dt, bool withTime) {
    if (withTime) {
      return DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'en').format(dt);
    }
    return DateFormat('EEEE, dd MMMM yyyy', 'en').format(dt);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// File / Image upload widget
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: rh(context, 10)),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(rw(context, 2)),
              ),
            ),
            Text(
              'Pilih Sumber Foto',
              style: TextStyle(
                fontSize: rfs(context, 15),
                fontWeight: FontWeight.w700,
              ),
            ),
            vSpace(context, 8),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(rw(context, 8)),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(rw(context, 10)),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary500,
                ),
              ),
              title: Text('Kamera'),
              onTap: () {
                Get.back();
                _pickAndUpload(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(rw(context, 8)),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(rw(context, 10)),
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary500,
                ),
              ),
              title: Text('Galeri'),
              onTap: () {
                Get.back();
                _pickAndUpload(ImageSource.gallery);
              },
            ),
            vSpace(context, 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pickedFile != null && !_isUploading) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(rw(context, 10)),
            child: Image.file(
              _pickedFile!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _pickedFile = null;
                  widget.field.answerText = '';
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(rw(context, 5)),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 16),
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
        height: 90,
        decoration: BoxDecoration(
          border: Border.all(
            color: _isUploading
                ? AppColors.primary500
                : const Color(0xFFDDDDDD),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(rw(context, 10)),
          color: AppColors.primary50,
        ),
        child: _isUploading
            ? Center(
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
                    vSpace(context, 6),
                    Text(
                      'Mengupload...',
                      style: TextStyle(
                        color: AppColors.grey500,
                        fontSize: rfs(context, 12),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(rw(context, 8)),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.cameraOnly
                          ? Icons.camera_alt_outlined
                          : Icons.upload_outlined,
                      color: AppColors.primary500,
                      size: 22,
                    ),
                  ),
                  vSpace(context, 6),
                  Text(
                    widget.cameraOnly ? 'Buka Kamera' : 'Pilih File / Foto',
                    style: TextStyle(
                      color: AppColors.primary500,
                      fontSize: rfs(context, 13),
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
      final bool canProceed;
      if (step == 0) {
        final typeSelected = controller.selectedVisitorTypeId.value.isNotEmpty;
        final statusSelected = controller.isGroup.value != null;
        if (controller.isGroup.value == true) {
          canProceed =
              typeSelected &&
              statusSelected &&
              controller.groupName.value.trim().isNotEmpty;
        } else {
          canProceed = typeSelected && statusSelected;
        }
      } else {
        canProceed = controller.validateCurrentStep();
      }
      final isSubmitting = controller.isSubmitting.value;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFEEEEEE))),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: rw(context, 20),
          vertical: rh(context, 14),
        ),
        child: Row(
          children: [
            // Back button
            OutlinedButton.icon(
              onPressed: () async {
                if (step == 0) {
                  final shouldExit = await _showExitConfirmation(ctx);
                  if (shouldExit && ctx.mounted) {
                    controller.resetFields();
                    Navigator.of(ctx).pop();
                  }
                } else if (step == 1) {
                  if (controller.isDuplicateMode.value) {
                    controller.prevStep();
                  } else {
                    // Kembali dari Page 2 ke Page 1 -> Muncul Warning
                    final shouldBack = await _showBackConfirmation(ctx);
                    if (shouldBack) {
                      controller.clearStep1Fields();
                      controller.prevStep();
                    }
                  }
                } else {
                  // Kembali dari Page 3 ke Page 2 -> Langsung Back (Data Aman)
                  controller.prevStep();
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: step == 0
                      ? const Color(0xFFDDDDDD)
                      : AppColors.primary500,
                ),
                foregroundColor: AppColors.primary500,
                disabledForegroundColor: const Color(0xFFBDBDBD),
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 18),
                  vertical: rh(context, 12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rw(context, 10)),
                ),
              ),
              icon: Icon(Icons.arrow_back_rounded, size: 16),
              label: Text(
                'Back',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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
                          Navigator.of(context).pop(true);
                        }
                      } else {
                        controller.nextStep();
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary500,
                disabledBackgroundColor: const Color(0xFFDDDDDD),
                padding: EdgeInsets.symmetric(
                  horizontal: rw(context, 22),
                  vertical: rh(context, 12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rw(context, 10)),
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
                  : Icon(
                      isLast
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      size: 16,
                    ),
              label: Text(
                isLast ? 'Submit' : 'Next',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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
  final bool isRequired;
  const _SectionHeader({required this.title, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: rw(context, 10)),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.primary500, width: 3)),
      ),
      child: RichText(
        text: TextSpan(
          text: title,
          style: TextStyle(
            fontSize: rfs(context, 14),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: [
            if (isRequired)
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Visitor Search Field — autocomplete dropdown that fetches /api/invitation-visitor
// ─────────────────────────────────────────────────────────────────────────────

class _VisitorSearchField extends StatefulWidget {
  final PraRegistrationController controller;
  final void Function(Map<String, dynamic> visitor) onSelected;
  final void Function()? onClear;

  const _VisitorSearchField({
    required this.controller,
    required this.onSelected,
    this.onClear,
  });

  @override
  State<_VisitorSearchField> createState() => _VisitorSearchFieldState();
}

class _VisitorSearchFieldState extends State<_VisitorSearchField> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showDropdown = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  late final VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();
    _focusListener = () {
      if (!mounted) return;
      if (_focusNode.hasFocus) {
        _openDropdown();
      } else {
        _closeDropdown();
      }
    };
    _focusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    // Remove the listener first so it can't fire after disposal
    _focusNode.removeListener(_focusListener);
    // Clean up overlay directly — DO NOT call setState here (element is defunct)
    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openDropdown() {
    if (!mounted) return;
    if (_overlayEntry != null) return;
    setState(() => _showDropdown = true);
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _showDropdown = false);
  }

  void _onVisitorSelected(Map<String, dynamic> v) {
    _searchCtrl.text = v['name']?.toString() ?? '';
    widget.controller.visitorSearchQuery.value = '';
    widget.onSelected(v);
    _closeDropdown();
    _focusNode.unfocus();
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _closeDropdown();
                _focusNode.unfocus();
              },
            ),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 4),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(rw(context, 12)),
                shadowColor: Colors.black26,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 260),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(rw(context, 12)),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Obx(() {
                    final ctrl = widget.controller;
                    if (ctrl.isLoadingVisitors.value) {
                      return Padding(
                        padding: EdgeInsets.all(rw(context, 16)),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    final results = ctrl.filteredVisitors;
                    if (results.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(rw(context, 16)),
                        child: Text(
                          ctrl.visitorSearchQuery.value.isEmpty
                              ? 'Type to search visitors...'
                              : 'No visitor found',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: rfs(context, 13),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: results.length > 50 ? 50 : results.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      itemBuilder: (context, i) {
                        final v = results[i];
                        final name = v['name']?.toString() ?? '';
                        final org = v['organization']?.toString() ?? '';
                        final email = v['email']?.toString() ?? '';
                        return InkWell(
                          borderRadius: i == 0
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                )
                              : BorderRadius.zero,
                          onTap: () => _onVisitorSelected(v),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: rw(context, 14),
                              vertical: rh(context, 10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary500.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: AppColors.primary500,
                                        fontWeight: FontWeight.bold,
                                        fontSize: rfs(context, 15),
                                      ),
                                    ),
                                  ),
                                ),
                                hSpace(context, 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: rfs(context, 13),
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (org.isNotEmpty || email.isNotEmpty)
                                        Text(
                                          [
                                            if (org.isNotEmpty) org,
                                            if (email.isNotEmpty) email,
                                          ].join(' · '),
                                          style: TextStyle(
                                            fontSize: rfs(context, 11),
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _searchCtrl,
        focusNode: _focusNode,
        onChanged: (q) {
          widget.controller.visitorSearchQuery.value = q;
          // Rebuild overlay to reflect filtered results
          _overlayEntry?.markNeedsBuild();
          if (!_showDropdown) _openDropdown();
        },
        style: TextStyle(fontSize: rfs(context, 14)),
        decoration: InputDecoration(
          hintText: 'Search visitor by name...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: rfs(context, 13)),
          prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
          suffixIcon: Obx(
            () => widget.controller.isLoadingVisitors.value
                ? Padding(
                    padding: EdgeInsets.all(rw(context, 12)),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close, size: 18, color: Colors.grey),
                    onPressed: () {
                      _searchCtrl.clear();
                      widget.controller.visitorSearchQuery.value = '';
                      _overlayEntry?.markNeedsBuild();
                      if (widget.onClear != null) widget.onClear!();
                    },
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: rw(context, 14),
            vertical: rh(context, 12),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(context, 10)),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(context, 10)),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(context, 10)),
            borderSide: const BorderSide(
              color: AppColors.primary500,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Employee Search Field — autocomplete dropdown for Employees
// ─────────────────────────────────────────────────────────────────────────────

class _EmployeeSearchField extends StatefulWidget {
  final PraRegistrationController controller;
  final String initialValue;
  final void Function(Map<String, dynamic> employee) onSelected;
  final void Function()? onClear;

  /// Observable yang akan di-sync ke search field.
  /// Jika tidak diberikan, secara default listen ke controller.selectedEmployeeName.
  final RxString? syncWith;

  const _EmployeeSearchField({
    required this.controller,
    required this.onSelected,
    this.initialValue = '',
    this.onClear,
    this.syncWith,
  });

  @override
  State<_EmployeeSearchField> createState() => _EmployeeSearchFieldState();
}

class _EmployeeSearchFieldState extends State<_EmployeeSearchField> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showDropdown = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late final VoidCallback _focusListener;
  Worker? _nameWorker;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = widget.initialValue;
    _focusListener = () {
      if (!mounted) return;
      if (_focusNode.hasFocus) {
        _openDropdown();
      } else {
        _closeDropdown();
      }
    };
    _focusNode.addListener(_focusListener);
    // Listen ke observable yang relevan:
    // - syncWith jika diberikan (contoh: per-row group visitor)
    // - fallback ke controller.selectedEmployeeName (single mode)
    final targetObs = widget.syncWith ?? widget.controller.selectedEmployeeName;
    _nameWorker = ever(targetObs, (String newName) {
      if (!mounted) return;
      if (_searchCtrl.text != newName) {
        _searchCtrl.text = newName;
      }
    });
  }

  @override
  void didUpdateWidget(_EmployeeSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _searchCtrl.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _nameWorker?.dispose();
    _focusNode.removeListener(_focusListener);
    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openDropdown() {
    if (!mounted) return;
    if (_overlayEntry != null) return;
    setState(() => _showDropdown = true);
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _showDropdown = false);
  }

  void _onEmployeeSelected(Map<String, dynamic> e) {
    _searchCtrl.text = e['name']?.toString() ?? '';
    widget.controller.employeeSearchQuery.value = '';
    widget.onSelected(e);
    _closeDropdown();
    _focusNode.unfocus();
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _closeDropdown();
                _focusNode.unfocus();
              },
            ),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 4),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(rw(context, 12)),
                shadowColor: Colors.black26,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 260),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(rw(context, 12)),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Obx(() {
                    final ctrl = widget.controller;
                    if (ctrl.isLoadingEmployees.value) {
                      return Padding(
                        padding: EdgeInsets.all(rw(context, 16)),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    final results = ctrl.filteredEmployees;
                    if (results.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(rw(context, 16)),
                        child: Text(
                          ctrl.employeeSearchQuery.value.isEmpty
                              ? 'Type to search employees...'
                              : 'No employee found',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: rfs(context, 13),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: results.length > 50 ? 50 : results.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      itemBuilder: (context, i) {
                        final e = results[i];
                        final name = e['name']?.toString() ?? '';
                        final org =
                            e['organization']?.toString() ??
                            e['Organization']?['name']?.toString() ??
                            e['company']?.toString() ??
                            '';
                        final email = e['email']?.toString() ?? '';
                        return InkWell(
                          borderRadius: i == 0
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                )
                              : BorderRadius.zero,
                          onTap: () => _onEmployeeSelected(e),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: rw(context, 14),
                              vertical: rh(context, 10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary500.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: AppColors.primary500,
                                        fontWeight: FontWeight.bold,
                                        fontSize: rfs(context, 15),
                                      ),
                                    ),
                                  ),
                                ),
                                hSpace(context, 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: rfs(context, 13),
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (org.isNotEmpty || email.isNotEmpty)
                                        Text(
                                          [
                                            if (org.isNotEmpty) org,
                                            if (email.isNotEmpty) email,
                                          ].join(' · '),
                                          style: TextStyle(
                                            fontSize: rfs(context, 11),
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _searchCtrl,
        focusNode: _focusNode,
        onChanged: (q) {
          widget.controller.employeeSearchQuery.value = q;
          _overlayEntry?.markNeedsBuild();
          if (!_showDropdown) _openDropdown();
        },
        style: TextStyle(fontSize: rfs(context, 14)),
        decoration: InputDecoration(
          hintText: 'Search employee by name...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: rfs(context, 13)),
          prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
          suffixIcon: Obx(
            () => widget.controller.isLoadingEmployees.value
                ? Padding(
                    padding: EdgeInsets.all(rw(context, 12)),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close, size: 18, color: Colors.grey),
                    onPressed: () {
                      _searchCtrl.clear();
                      widget.controller.employeeSearchQuery.value = '';
                      _overlayEntry?.markNeedsBuild();
                      if (widget.onClear != null) widget.onClear!();
                    },
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: rw(context, 14),
            vertical: rh(context, 12),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(context, 10)),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(context, 10)),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(context, 10)),
            borderSide: const BorderSide(
              color: AppColors.primary500,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
