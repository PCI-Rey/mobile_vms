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
  Get.delete<PraRegistrationController>(force: true);
  Get.put(PraRegistrationController());

  return showDialog(
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Cancel Registration?',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'The data you have entered will be lost. Are you sure you want to close this form?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
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
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Warning',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to go back? Going back to Visitor Type selection will reset the information you have already entered in this step.',
            style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
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
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Visitor?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete this visitor? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'No',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: _StepContent(step: step, controller: ctrl),
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
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Pra Registration',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onClose,
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

          const SizedBox(height: 14),

          // Step title + icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _stepIcons[currentStep],
                  size: 16,
                  color: AppColors.primary500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
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
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                    if (currentStep > 0 && index == 0) {
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
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary500
                          : const Color(0xFFBDBDBD),
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.primary500.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 12,
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
                      margin: const EdgeInsets.symmetric(horizontal: 8),
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
          const SizedBox(height: 12),

          if (controller.isLoadingTypes.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else
            ...List.generate(controller.visitorTypes.length, (i) {
              final type = controller.visitorTypes[i];
              final isSelected = selectedId == type.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      controller.onSelectVisitorType(type.id, type.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
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
                      borderRadius: BorderRadius.circular(12),
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
                              ? const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            type.name,
                            style: TextStyle(
                              fontSize: 14,
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

          const SizedBox(height: 24),

          // ── Select Status Visitor ────────────────────────────────
          _SectionHeader(title: 'Select Status Visitor', isRequired: true),
          const SizedBox(height: 12),

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
              const SizedBox(width: 10),
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
          if (controller.isGroup.value == true) ..._buildGroupList(controller),
        ],
      );
    });
  }

  List<Widget> _buildGroupList(PraRegistrationController controller) {
    return [
      const SizedBox(height: 24),
      _SectionHeader(title: 'Group List', isRequired: true),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Group Name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Code',
                      style: TextStyle(
                        fontSize: 12,
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
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      onChanged: (v) => controller.groupName.value = v,
                      decoration: InputDecoration(
                        hintText: 'Enter group name',
                        hintStyle: const TextStyle(
                          color: AppColors.grey400,
                          fontSize: 13,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.grey300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.grey300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primary500,
                            width: 1.5,
                          ),
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withValues(alpha: 0.06),
                        border: Border.all(color: AppColors.primary200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.groupCode.value,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                          fontSize: 13,
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary500.withValues(alpha: 0.06)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary500 : const Color(0xFFE0E0E0),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary500 : AppColors.grey500,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary500 : Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
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
                  ? const Icon(Icons.check, size: 11, color: Colors.white)
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
        return const Center(child: CircularProgressIndicator());
      }

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

  Widget _buildGroupVisitorTable(BuildContext context) {
    return Obx(() {
      final visitors = controller.groupVisitors;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(visitors.length, (i) {
            final v = visitors[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(14),
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
                  // Card header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary500,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Visitor ${i + 1}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (visitors.length > 1)
                          GestureDetector(
                            onTap: () async {
                              final shouldDelete =
                                  await _showDeleteVisitorConfirmation(context);
                              if (shouldDelete) {
                                controller.removeGroupVisitor(i);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade100),
                              ),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(14),
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
                              const Text(
                                'Are you Employee?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _InlineRadio(
                                    label: 'Yes',
                                    isSelected: empEnabled,
                                    onTap: () {
                                      v.isEmployee.value = true;
                                      // Clear existing row fields
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
                                  const SizedBox(width: 16),
                                  _InlineRadio(
                                    label: 'No',
                                    isSelected: !empEnabled,
                                    onTap: () {
                                      v.isEmployee.value = false;
                                      // Clear existing row fields
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
                              const SizedBox(height: 12),

                              Opacity(
                                opacity: empEnabled ? 1.0 : 0.4,
                                child: IgnorePointer(
                                  ignoring: !empEnabled,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: const TextSpan(
                                          text: 'Employee Name',
                                          style: TextStyle(
                                            fontSize: 12,
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
                                      const SizedBox(height: 6),
                                      Obx(() {
                                        final list = controller.employees
                                            .toList();
                                        final currentId =
                                            v.selectedEmployeeId.value;
                                        final selectedItem =
                                            list.any((e) => e.id == currentId)
                                            ? list.firstWhere(
                                                (e) => e.id == currentId,
                                              )
                                            : null;
                                        return GestureDetector(
                                          onTap: () async {
                                            final result =
                                                await _showEmployeePicker(
                                                  context,
                                                  controller.employees.toList(),
                                                  currentId,
                                                );
                                            if (result != null) {
                                              controller
                                                  .onGroupEmployeeSelected(
                                                    v,
                                                    result.id,
                                                  );
                                            }
                                          },
                                          child: _DropdownTrigger(
                                            text: selectedItem?.name ?? '',
                                            hint: 'Pilih Employee',
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Divider(
                                height: 1,
                                color: Color(0xFFEEEEEE),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        }),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _GroupTextField(
                                label: 'Full Name',
                                controller: v.fullName,
                                hint: 'Enter full name',
                                onChanged: (_) => controller.updateForm(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _GroupTextField(
                                label: 'Email',
                                controller: v.email,
                                hint: 'Enter email',
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (_) => controller.updateForm(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _GroupTextField(
                                label: 'Phone',
                                controller: v.phone,
                                hint: 'e.g. 08123...',
                                keyboardType: TextInputType.phone,
                                onChanged: (_) => controller.updateForm(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _GroupTextField(
                                label: 'Organization',
                                controller: v.organization,
                                hint: 'Company / Instansi',
                                onChanged: (_) => controller.updateForm(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

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
                ],
              ),
            );
          }),

          // Add New button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.addGroupVisitor,
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
                color: AppColors.primary500,
              ),
              label: const Text(
                'Add New Visitor',
                style: TextStyle(
                  color: AppColors.primary500,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: AppColors.primary200),
                backgroundColor: AppColors.primary50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  static Future<DropdownItem?> _showEmployeePicker(
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
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Pilih Employee',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
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
                                fontSize: 14,
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
                            const Icon(
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
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
                ? const Icon(Icons.check, size: 11, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasValue ? text : hint,
              style: TextStyle(
                fontSize: 14,
                color: hasValue ? Colors.black87 : AppColors.grey400,
              ),
            ),
          ),
          const Icon(
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
  const _GroupTextField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 12,
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
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.grey400),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
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
          const SizedBox(height: 7),
          _buildInputWidget(ctx),
        ],
      ),
    );
  }

  Widget _buildInputWidget(BuildContext ctx) {
    if (field.remarks == 'host') {
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
              const SizedBox(height: 4),
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
      final selectedItem = list.any((e) => e.id == currentId)
          ? list.firstWhere((e) => e.id == currentId)
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
            isSelected: (e) => e.id == currentId,
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
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
              const SizedBox(height: 8),
              TextFormField(
                initialValue: field.answerText == 'Other'
                    ? ''
                    : field.answerText,
                decoration: textDecoration.copyWith(
                  hintText: 'Other',
                  hintStyle: const TextStyle(
                    color: AppColors.grey400,
                    fontSize: 13,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
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
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
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
                                fontSize: 14,
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
                            const Icon(
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextInputType keyboardType}) {
    final dedicatedCtrl = controller.getFieldController(field.remarks);

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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
      ),
    );

    if (dedicatedCtrl != null) {
      if (dedicatedCtrl.text.isEmpty && field.answerText.isNotEmpty) {
        dedicatedCtrl.text = field.answerText;
      }
      return TextFormField(
        controller: dedicatedCtrl,
        keyboardType: keyboardType,
        decoration: decoration,
        onChanged: onChanged,
      );
    }

    return TextFormField(
      initialValue: field.answerText,
      keyboardType: keyboardType,
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
                title: Text(opt.name, style: const TextStyle(fontSize: 14)),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
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
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
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
      final iso = picked.toIso8601String().replaceAll(RegExp(r'\.\d+'), '');
      field.answerDatetime = iso;
      field.answerText = iso;
      ctrl.text = _formatDisplay(picked, false);
      if (field.remarks == 'visitor_period_start') {
        controller.visitStart.value = picked;
      } else if (field.remarks == 'visitor_period_end') {
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
    if (!ctx.mounted) return;

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

    final dtRaw = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final iso = dtRaw.toIso8601String().replaceAll(RegExp(r'\.\d+'), '');
    field.answerDatetime = iso;
    field.answerText = iso;
    ctrl.text = _formatDisplay(dtRaw, true);
    if (field.remarks == 'visitor_period_start') {
      controller.visitStart.value = dtRaw;
    } else if (field.remarks == 'visitor_period_end') {
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
      return DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id').format(dt);
    }
    return DateFormat('EEEE, dd MMMM yyyy', 'id').format(dt);
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
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary500,
                ),
              ),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                _pickAndUpload(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary500,
                ),
              ),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                _pickAndUpload(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
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
            borderRadius: BorderRadius.circular(10),
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
                padding: const EdgeInsets.all(5),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 16,
                ),
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
          borderRadius: BorderRadius.circular(10),
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
                  Container(
                    padding: const EdgeInsets.all(8),
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
                  const SizedBox(height: 6),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                  // Kembali dari Page 2 ke Page 1 -> Muncul Warning
                  final shouldBack = await _showBackConfirmation(ctx);
                  if (shouldBack) {
                    controller.clearStep1Fields();
                    controller.prevStep();
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text(
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
                          Navigator.of(context).pop();
                        }
                      } else {
                        controller.nextStep();
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary500,
                disabledBackgroundColor: const Color(0xFFDDDDDD),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
                style: const TextStyle(fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.only(left: 10),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.primary500, width: 3)),
      ),
      child: RichText(
        text: TextSpan(
          text: title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
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
    );
  }
}
