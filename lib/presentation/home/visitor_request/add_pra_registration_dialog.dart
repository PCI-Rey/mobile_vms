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
  // Always delete the old instance first so onInit re-runs with the current token.
  // Without this, Get.put returns the cached (stale) controller from the previous session.
  Get.delete<PraRegistrationController>(force: true);

  // Create a fresh controller — onInit will re-fetch employees/hosts/sites
  Get.put(PraRegistrationController());

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


  Future<bool> _showExitConfirmation(BuildContext context) async {
    final ctrl = Get.find<PraRegistrationController>();
    if (!ctrl.hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Batal Registrasi?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Data yang sudah kamu isi akan terhapus. Apakah kamu yakin ingin menutup form ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Tidak', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Ya, Tutup',
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
    final ctrl = Get.find<PraRegistrationController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmation(context);
        if (shouldExit && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Dialog(
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
                        onPressed: () async {
                          final shouldExit =
                              await _showExitConfirmation(context);
                          if (shouldExit && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
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
                    Builder(builder: (_) {
                      final title = (step == 1 && ctrl.isGroup.value == true)
                          ? 'Visitor Information (Group)'
                          : const [
                              'User Type',
                              'Visitor Information',
                              'Purpose Visit',
                            ][step];
                      return Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
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
          _SectionHeader(title: 'Visitor Type', isRequired: true),
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
          _SectionHeader(title: 'Select Status Visitor', isRequired: true),
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
                onTap: () {
                  if (controller.isGroup.value != true) {
                    controller.isGroup.value = true;
                    controller.initGroupMode();
                  }
                },
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

          // ── Group List (visible when Group selected) ─────────────
          if (controller.isGroup.value == true) ..._buildGroupList(controller),
        ],
      );
    });
  }

  List<Widget> _buildGroupList(PraRegistrationController controller) {
    return [
      const SizedBox(height: 20),
      _SectionHeader(title: 'Group List', isRequired: true),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Group Name',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey600),
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Code',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey600),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.grey200),
            // Group row
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Group Name input
                  Expanded(
                    flex: 3,
                    child: TextField(
                      onChanged: (v) => controller.groupName.value = v,
                      decoration: InputDecoration(
                        hintText: 'Enter group name',
                        hintStyle: TextStyle(color: AppColors.grey400, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.grey300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.grey300),
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Auto-generated code (read-only) — fixed width, no wrap
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      border: Border.all(color: AppColors.grey300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      controller.groupCode.value,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.primary500,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
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
      // Group mode — show visitor table
      if (controller.isGroup.value == true) {
        return _buildGroupVisitorTable(context);
      }

      // Single mode — existing form
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
          // Visitor cards
          ...List.generate(visitors.length, (i) {
            final v = visitors[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey200),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Card header — visitor number + delete
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 16, color: AppColors.primary500),
                        const SizedBox(width: 6),
                        Text(
                          'Visitor ${i + 1}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey700,
                          ),
                        ),
                        const Spacer(),
                        if (visitors.length > 1)
                          GestureDetector(
                            onTap: () => controller.removeGroupVisitor(i),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Card body — fields in 2-column grid
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        // Row 1: Fullname + Email
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
                            const SizedBox(width: 12),
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
                        const SizedBox(height: 12),

                        // Row 2: Phone + Organization
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
                            const SizedBox(width: 12),
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
                        const SizedBox(height: 12),

                        // Row 3: KTP (full width)
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
              icon: const Icon(Icons.add, size: 18, color: AppColors.primary500),
              label: const Text(
                'Add New Visitor',
                style: TextStyle(
                  color: AppColors.primary500,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.primary200),
                backgroundColor: AppColors.primary50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    });
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
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.grey400),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              borderSide:
                  const BorderSide(color: AppColors.primary500, width: 1.5),
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
        children: section.praForm // FIX: pra_form, not visit_form
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

    // Special case: API-backed dropdowns by remarks
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

    // Employee name dropdown — shown when visitor type is Employee
    // Disabled (greyed out) when user answered 'No' to is_employee
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
                controller.selectedEmployeeId.value = id;
                field.answerText = id;
                controller.name.value = name;
                debugPrint('[EMPLOYEE] Selected → id="$id" (UUID), name="$name"');
                debugPrint('[EMPLOYEE] field.answerText is now: "${field.answerText}"');
                controller.updateForm();
              },
              hint: 'Pilih Employee',
            ),
          ),
        );
      });
    }

    // Static agenda dropdown with 'Other' free-text option
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

      case 5: // Radio
        // For is_employee: add a visual divider below to separate from next fields
        if (field.remarks == 'is_employee') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRadioGroup(),
              const SizedBox(height: 4),
              const Divider(thickness: 1, color: AppColors.grey200),
            ],
          );
        }
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

  /// API dropdown — bottom sheet picker, ALWAYS opens from the bottom.
  Widget _buildApiDropdown({
    required RxList<DropdownItem> items,
    required RxString selectedId,
    required void Function(String id, String name) onSelected,
    required String hint,
  }) {
    return Obx(() {
      final list = items.toList();
      final currentId = selectedId.value;
      final selectedItem =
          list.any((e) => e.id == currentId)
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

  /// Static agenda picker with 'Other' free-text option.
  static const _agendaOptions = [
    'Meeting', 'Presentation', 'Visit', 'Training', 'Report', 'Other',
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.grey300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.grey300)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary500, width: 1.5)),
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
                initialValue:
                    field.answerText == 'Other' ? '' : field.answerText,
                decoration: textDecoration.copyWith(
                  hintText: 'Other',
                  hintStyle:
                      const TextStyle(color: AppColors.grey400, fontSize: 13),
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

  /// Trigger widget that looks like a dropdown field but opens a bottom sheet.
  Widget _buildPickerTrigger({
    required String displayText,
    required String hint,
    required void Function(BuildContext) onTap,
  }) {
    return Builder(
      builder: (ctx) => GestureDetector(
        onTap: () => onTap(ctx),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayText.isEmpty ? hint : displayText,
                  style: TextStyle(
                    fontSize: 14,
                    color: displayText.isEmpty
                        ? AppColors.grey400
                        : Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down,
                  color: AppColors.grey400, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom sheet list picker — always slides up from the bottom.
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
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
                          horizontal: 20, vertical: 14),
                      color: selected
                          ? AppColors.primary500.withValues(alpha: 0.08)
                          : Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(label,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: selected
                                      ? AppColors.primary500
                                      : Colors.black87,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                )),
                          ),
                          if (selected)
                            const Icon(Icons.check,
                                size: 18, color: AppColors.primary500),
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
        // FIX: Also write to dedicated controller observables per remarks
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
      },
    );
  }

  Widget _buildRadioGroup() {
    // FIX: ONE StatefulBuilder wraps ALL options so selecting one rebuilds all.
    // Previously each option had its own StatefulBuilder → two could appear selected.
    return StatefulBuilder(
      builder: (ctx, setState) {
        return RadioGroup<String>(
          groupValue: field.answerText,
          onChanged: (v) {
            if (v != null) {
              field.answerText = v;
              // Also sync isEmployee observable if this is the employee question
              if (field.remarks == 'is_employee') {
                controller.isEmployee.value = (v == 'true' || v == 'Yes' || v == '1');
              }
              setState(() {}); // rebuilds ALL options in this group
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
      
      // Simpan sebagai ISO string. Jika remarks adalah period start/end, simpan sebagai UTC.
      String iso;
      if (isUTC) {
        iso = picked.toUtc().toIso8601String().replaceAll(RegExp(r'\.\d+'), '');
      } else {
        iso = picked.toIso8601String().replaceAll(RegExp(r'\.\d+'), '');
      }

      field.answerDatetime = iso;
      field.answerText = iso;
      ctrl.text = _formatDisplay(iso, false);

      // FIX: Sync to controller observables so isStep3Valid passes
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

    final dtRaw =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final isUTC = field.remarks == "visitor_period_start" ||
        field.remarks == "visitor_period_end";
    
    // Simpan sebagai ISO string. Jika remarks adalah period start/end, simpan sebagai UTC.
    String iso;
    if (isUTC) {
      iso = dtRaw.toUtc().toIso8601String().replaceAll(RegExp(r'\.\d+'), '');
    } else {
      iso = dtRaw.toIso8601String().replaceAll(RegExp(r'\.\d+'), '');
    }

    field.answerDatetime = iso;
    field.answerText = iso;
    ctrl.text = _formatDisplay(iso, true);

    // FIX: Sync to controller observables so isStep3Valid passes
    if (field.remarks == 'visitor_period_start') {
      controller.visitStart.value = dtRaw;
    } else if (field.remarks == 'visitor_period_end') {
      controller.visitEnd.value = dtRaw;
    }

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
      // Pastikan string diparse sebagai UTC jika ada indikasi tersebut
      String normalized = iso;
      if (!normalized.endsWith('Z') &&
          !normalized.contains('+') &&
          (field.remarks == "visitor_period_start" ||
              field.remarks == "visitor_period_end")) {
        normalized = '${normalized}Z';
      }

      final dt = DateTime.parse(normalized).toLocal();
      if (withTime) {
        return DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id').format(dt);
      }
      return DateFormat('EEEE, dd MMMM yyyy', 'id').format(dt);
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
      // Next enabled based on current step + mode
      final bool canProceed;
      if (step == 0) {
        final typeSelected = controller.selectedVisitorTypeId.value.isNotEmpty;
        final statusSelected = controller.isGroup.value != null;
        if (controller.isGroup.value == true) {
          // Group mode: also require group name to be filled
          canProceed = typeSelected &&
              statusSelected &&
              controller.groupName.value.trim().isNotEmpty;
        } else {
          canProceed = typeSelected && statusSelected;
        }
      } else {
        canProceed = controller.validateCurrentStep();
      }
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
