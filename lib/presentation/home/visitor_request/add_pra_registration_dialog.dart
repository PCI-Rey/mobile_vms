// ignore_for_file: unused_import, unused_local_variable, unused_element, use_build_context_synchronously, sized_box_for_whitespace, unnecessary_underscores, unnecessary_import, unnecessary_null_comparison, curly_braces_in_flow_control_structures, unused_element_parameter, deprecated_member_use
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../../../core/components/custom_date_time_picker.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/models/access_pass_model.dart';
import '../../../../data/models/visitor_type_model.dart';
import 'controllers/pra_registration_controller.dart';

/// Entry point to display the Walk-In / Create Invitation dialog
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

class _AddPraRegistrationDialog extends StatelessWidget {
  const _AddPraRegistrationDialog();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PraRegistrationController>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ctrl.resetFields();
        }
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rw(context, 16)),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: rw(context, 14),
          vertical: rh(context, 20),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.90,
          child: Obx(() {
            final step = ctrl.currentStep.value;
            final _ = ctrl.formUpdateTrigger.value;

            return Column(
              children: [
                // ── Header ──────────────────────────────────────────
                _DialogHeader(controller: ctrl),

                // ── Step Content ────────────────────────────────────
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 16),
                        vertical: rh(context, 16),
                      ),
                      child: _buildStepContent(context, ctrl, step),
                    ),
                  ),
                ),

                // ── Footer Navigation ───────────────────────────────
                _BottomNav(controller: ctrl),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    PraRegistrationController ctrl,
    int step,
  ) {
    if (step == 1) return _Step1UserType(controller: ctrl);
    if (step == 2) return _Step2VisitorInfo(controller: ctrl);
    if (step == 3) return _Step3PurposeVisit(controller: ctrl);

    // Dynamic steps based on visitor type configuration
    if (ctrl.hasVehicleStep && step == ctrl.vehicleStepIndex) {
      return _Step4VehicleInfo(controller: ctrl);
    }
    if (ctrl.hasSelfieStep && step == ctrl.selfieStepIndex) {
      return _Step5SelfieImage(controller: ctrl);
    }
    if (ctrl.hasKtpStep && step == ctrl.ktpStepIndex) {
      return _Step6KtpImage(controller: ctrl);
    }

    return const SizedBox.shrink();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG HEADER: Title + Stepper (when step >= 1) + Close Button
// ─────────────────────────────────────────────────────────────────────────────

class _DialogHeader extends StatelessWidget {
  final PraRegistrationController controller;
  const _DialogHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final step = controller.currentStep.value;
    final titles = controller.dynamicStepTitles;
    final currentTitle = step > 0 && step <= titles.length
        ? titles[step - 1]
        : 'Create Invitation';

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
                    'Create Invitation',
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
                    controller.resetFields();
                    Navigator.of(context).pop();
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
                // Stepper Bubbles & Connecting Lines
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(titles.length * 2 - 1, (index) {
                      if (index.isOdd) {
                        final stepBefore = (index ~/ 2) + 1;
                        final isConnectorCompleted =
                            stepBefore < step ||
                            (stepBefore < controller.maxStepReached.value &&
                                controller.isStepValid(stepBefore));
                        return Container(
                          width: rw(context, 28),
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          color: isConnectorCompleted
                              ? AppColors.primary500
                              : const Color(0xFFCBD5E1),
                        );
                      }

                      final stepNum = (index ~/ 2) + 1;
                      final isCurrent = step == stepNum;
                      final isCompleted =
                          stepNum < step ||
                          (stepNum <= controller.maxStepReached.value &&
                              controller.isStepValid(stepNum) &&
                              !isCurrent);
                      final canJump = controller.canJumpToStep(stepNum);

                      return GestureDetector(
                        onTap: canJump ? () => controller.goToStep(stepNum) : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent || isCompleted
                                ? AppColors.primary500
                                : (canJump
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFFCBD5E1)),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : Text(
                                    '$stepNum',
                                    style: TextStyle(
                                      fontSize: rfs(context, 12),
                                      fontWeight: isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
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
                    titles.length > 1
                        ? 'Step $step of ${titles.length}: $currentTitle'
                        : 'Step $step: $currentTitle',
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
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1: USER TYPE
// ─────────────────────────────────────────────────────────────────────────────

class _Step1UserType extends StatelessWidget {
  final PraRegistrationController controller;
  const _Step1UserType({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Visitor Type', isRequired: true),
          vSpace(context, 8),

          if (controller.isLoadingTypes.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          else if (controller.visitorTypes.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: rh(context, 8)),
              child: Row(
                children: [
                  Text(
                    'No visitor types available.',
                    style: TextStyle(
                      fontSize: rfs(context, 12),
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  hSpace(context, 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => controller.fetchVisitorTypes(),
                    icon: const Icon(Icons.refresh, size: 14),
                    label: Text(
                      'Retry',
                      style: TextStyle(fontSize: rfs(context, 12)),
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.visitorTypes.map((type) {
                final isSelected = controller.selectedVisitorTypeId.value == type.id;
                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => controller.onSelectVisitorType(type.id, type.name),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 12),
                      vertical: rh(context, 10),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppColors.primary500 : const Color(0xFFCBD5E1),
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 16,
                          color: isSelected ? AppColors.primary500 : const Color(0xFF94A3B8),
                        ),
                        hSpace(context, 8),
                        Text(
                          type.name,
                          style: TextStyle(
                            fontSize: rfs(context, 12.5),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppColors.primary500 : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

          vSpace(context, 20),

          _buildSectionHeader(context, 'Select Status Visitor', isRequired: true),
          vSpace(context, 4),
          Text(
            'Is this visit for one or more than one visitor?',
            style: TextStyle(
              fontSize: rfs(context, 12),
              color: const Color(0xFF64748B),
            ),
          ),
          vSpace(context, 10),

          // Status Cards: Single vs Group
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  context,
                  title: 'Single',
                  icon: Icons.person_outline_rounded,
                  isSelected: controller.isGroup.value == false,
                  onTap: () {
                    controller.isGroup.value = false;
                    controller.updateForm();
                  },
                ),
              ),
              hSpace(context, 12),
              Expanded(
                child: _buildStatusCard(
                  context,
                  title: 'Group',
                  icon: Icons.groups_outlined,
                  isSelected: controller.isGroup.value == true,
                  onTap: () {
                    controller.isGroup.value = true;
                    controller.updateForm();
                  },
                ),
              ),
            ],
          ),

          // Group mode additional inputs: Group Name & Group Code
          if (controller.isGroup.value == true) ...[
            vSpace(context, 18),
            Container(
              padding: EdgeInsets.all(rw(context, 14)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rw(context, 12)),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel(context, 'Group Name', isRequired: true),
                  vSpace(context, 6),
                  _buildTextInputField(
                    context,
                    controller: controller.groupNameCtrl,
                    hintText: 'Enter group name (e.g. Bank Indonesia Delegation)',
                    onChanged: (val) {
                      controller.groupName.value = val;
                      controller.updateForm();
                    },
                  ),
                  vSpace(context, 12),
                  _buildFieldLabel(context, 'Group Code', isRequired: false),
                  vSpace(context, 6),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 12),
                      vertical: rh(context, 11),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      controller.groupCode.value,
                      style: TextStyle(
                        fontSize: rfs(context, 13),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: rw(context, 14),
          vertical: rh(context, 12),
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary500 : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary500 : const Color(0xFF64748B),
            ),
            hSpace(context, 8),
            Text(
              title,
              style: TextStyle(
                fontSize: rfs(context, 13),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary500 : const Color(0xFF1E293B),
              ),
            ),
            hSpace(context, 6),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: isSelected ? AppColors.primary500 : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2: VISITOR INFORMATION
// ─────────────────────────────────────────────────────────────────────────────

class _Step2VisitorInfo extends StatelessWidget {
  final PraRegistrationController controller;
  const _Step2VisitorInfo({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isGroup.value == true) {
      return _buildGroupVisitorInfo(context);
    }
    return _buildSingleVisitorInfo(context);
  }

  // ── Single Mode ───────────────────────────────────────────────────────────
  Widget _buildSingleVisitorInfo(BuildContext context) {
    final searchList = controller.isEmployee.value == true
        ? controller.filteredEmployees
        : controller.filteredVisitors;
    final roles = controller.getRolesForSelectedType();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quick Search with instant autofill
        _buildSearchBox(
          context,
          hint: controller.isEmployee.value == true ? 'Search Employee' : 'Search Visitor',
          controller: controller.singleSearchCtrl,
          isOpen: controller.singleIsSearchOpen.value,
          items: searchList,
          onToggleOpen: () {
            controller.singleIsSearchOpen.value = !controller.singleIsSearchOpen.value;
          },
          onChanged: (val) {
            controller.singleIsSearchOpen.value = true;
          },
          onSelect: (item) {
            controller.onSingleSelect(item);
          },
          onClear: () {
            controller.clearSingle();
          },
        ),

        vSpace(context, 16),

        // Are you Employee? Radio
        _buildFieldLabel(context, 'Are you Employee?', isRequired: true),
        vSpace(context, 6),
        Row(
          children: [
            _buildRadioOption(
              context,
              label: 'Yes',
              isSelected: controller.isEmployee.value == true,
              onTap: () {
                controller.isEmployee.value = true;
                controller.clearSingle();
              },
            ),
            hSpace(context, 20),
            _buildRadioOption(
              context,
              label: 'No',
              isSelected: controller.isEmployee.value == false,
              onTap: () {
                controller.isEmployee.value = false;
                controller.clearSingle();
              },
            ),
          ],
        ),

        vSpace(context, 14),

        // Visitor Role Selector (if multiple roles exist)
        if (roles.isNotEmpty) ...[
          _buildFieldLabel(context, 'Visitor Role', isRequired: false),
          vSpace(context, 6),
          _buildDropdownField<String>(
            context,
            value: controller.selectedVisitorRole.value.isNotEmpty
                ? controller.selectedVisitorRole.value
                : roles.first,
            items: roles
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                controller.selectedVisitorRole.value = val;
                controller.updateForm();
              }
            },
          ),
          vSpace(context, 14),
        ],

        // Full Name
        _buildFieldLabel(context, 'Full Name', isRequired: true),
        vSpace(context, 6),
        _buildTextInputField(
          context,
          controller: controller.nameCtrl,
          hintText: 'Enter full name',
          onChanged: (_) => controller.updateForm(),
        ),

        vSpace(context, 14),

        // Email
        _buildFieldLabel(context, 'Email', isRequired: true),
        vSpace(context, 6),
        _buildTextInputField(
          context,
          controller: controller.emailCtrl,
          hintText: 'Enter email address',
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => controller.updateForm(),
        ),

        vSpace(context, 14),

        // Phone
        _buildFieldLabel(context, 'Phone', isRequired: true),
        vSpace(context, 6),
        _buildTextInputField(
          context,
          controller: controller.phoneCtrl,
          hintText: 'Enter phone number',
          keyboardType: TextInputType.phone,
          onChanged: (_) => controller.updateForm(),
        ),

        vSpace(context, 14),

        // Department / Organization / Company
        _buildFieldLabel(context, 'Department / Organization / Company', isRequired: true),
        vSpace(context, 6),
        _buildTextInputField(
          context,
          controller: controller.organizationCtrl,
          hintText: 'Enter department / organization / company',
          onChanged: (_) => controller.updateForm(),
        ),

        vSpace(context, 14),

        // Identity (KTP)
        _buildFieldLabel(context, 'Identity (KTP)', isRequired: true),
        vSpace(context, 6),
        _buildTextInputField(
          context,
          controller: controller.identityIdCtrl,
          hintText: 'Enter identity / KTP number',
          keyboardType: TextInputType.number,
          onChanged: (_) => controller.updateForm(),
        ),
      ],
    );
  }

  // ── Group Mode ────────────────────────────────────────────────────────────
  Widget _buildGroupVisitorInfo(BuildContext context) {
    final activeIndex = controller.selectedGroupMemberIndex.value;
    final safeIndex = activeIndex < controller.groupVisitors.length ? activeIndex : 0;
    final v = controller.groupVisitors[safeIndex];
    final roles = controller.getRolesForSelectedType();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Member Tabs + Add Button
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...List.generate(controller.groupVisitors.length, (i) {
                final isSelected = safeIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('Visitor ${i + 1}'),
                    selected: isSelected,
                    selectedColor: AppColors.primary500,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: rfs(context, 12),
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary500 : const Color(0xFFCBD5E1),
                    ),
                    onSelected: (_) {
                      controller.selectedGroupMemberIndex.value = i;
                      controller.updateForm();
                    },
                  ),
                );
              }),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16, color: AppColors.primary500),
                label: const Text('Add Visitor'),
                labelStyle: TextStyle(
                  color: AppColors.primary500,
                  fontWeight: FontWeight.w600,
                  fontSize: rfs(context, 12),
                ),
                backgroundColor: const Color(0xFFEFF6FF),
                side: const BorderSide(color: Color(0xFF93C5FD)),
                onPressed: () => controller.addGroupVisitor(),
              ),
            ],
          ),
        ),

        vSpace(context, 12),

        // Delete button if more than 1 member
        if (controller.groupVisitors.length > 1)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade600),
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Remove this Visitor'),
              onPressed: () => controller.removeGroupVisitor(safeIndex),
            ),
          ),

        vSpace(context, 6),

        // Quick Search for current member
        _buildSearchBox(
          context,
          hint: v.isEmployee.value == true ? 'Search Employee' : 'Search Visitor',
          controller: v.searchCtrl,
          isOpen: v.isSearchOpen.value,
          items: v.isEmployee.value == true
              ? controller.filteredEmployees
              : controller.filteredVisitors,
          onToggleOpen: () {
            v.isSearchOpen.value = !v.isSearchOpen.value;
          },
          onChanged: (_) {
            v.isSearchOpen.value = true;
          },
          onSelect: (item) {
            controller.onGroupSelect(safeIndex, item);
          },
          onClear: () {
            controller.clearGroup(safeIndex);
          },
        ),

        vSpace(context, 14),

        // Are you Employee? Radio
        _buildFieldLabel(context, 'Are you Employee?', isRequired: true),
        vSpace(context, 6),
        Row(
          children: [
            _buildRadioOption(
              context,
              label: 'Yes',
              isSelected: v.isEmployee.value == true,
              onTap: () {
                v.isEmployee.value = true;
                controller.clearGroup(safeIndex);
              },
            ),
            hSpace(context, 20),
            _buildRadioOption(
              context,
              label: 'No',
              isSelected: v.isEmployee.value == false,
              onTap: () {
                v.isEmployee.value = false;
                controller.clearGroup(safeIndex);
              },
            ),
          ],
        ),

        vSpace(context, 14),

        // Visitor Role Selector
        if (roles.isNotEmpty) ...[
          _buildFieldLabel(context, 'Visitor Role', isRequired: false),
          vSpace(context, 6),
          _buildDropdownField<String>(
            context,
            value: v.role.value.isNotEmpty ? v.role.value : roles.first,
            items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (val) {
              if (val != null) {
                v.role.value = val;
                controller.updateForm();
              }
            },
          ),
          vSpace(context, 14),
        ],

        // Member Full Name
        _buildFieldLabel(context, 'Full Name', isRequired: true),
        vSpace(context, 6),
        _buildTextInputField(
          context,
          controller: v.fullNameCtrl,
          hintText: 'Enter full name',
          onChanged: (_) => controller.updateForm(),
        ),

        vSpace(context, 14),

        // Member Email
        _buildFieldLabel(context, 'Email', isRequired: true),
        vSpace(context, 6),
        _buildTextInputField(
          context,
          controller: v.emailCtrl,
          hintText: 'Enter email address',
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => controller.updateForm(),
        ),

        vSpace(context, 14),

        // Member Phone
        _buildFieldLabel(context, 'Phone', isRequired: true),
        vSpace(context, 6),
        _buildTextInputField(
          context,
          controller: v.phoneCtrl,
          hintText: 'Enter phone number',
          keyboardType: TextInputType.phone,
          onChanged: (_) => controller.updateForm(),
        ),

        vSpace(context, 14),

        // Member Organization
        _buildFieldLabel(context, 'Department / Organization / Company', isRequired: true),
        vSpace(context, 6),
        _buildTextInputField(
          context,
          controller: v.orgCtrl,
          hintText: 'Enter department / organization / company',
          onChanged: (_) => controller.updateForm(),
        ),

        vSpace(context, 14),

        // Member Identity
        _buildFieldLabel(context, 'Identity (KTP)', isRequired: true),
        vSpace(context, 6),
        _buildTextInputField(
          context,
          controller: v.identityCtrl,
          hintText: 'Enter identity / KTP number',
          keyboardType: TextInputType.number,
          onChanged: (_) => controller.updateForm(),
        ),
      ],
    );
  }

  Widget _buildSearchBox(
    BuildContext context, {
    required String hint,
    required TextEditingController controller,
    required bool isOpen,
    required List<Map<String, dynamic>> items,
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
            style: TextStyle(fontSize: rfs(context, 13)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: rfs(context, 13),
              ),
              prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                      onPressed: onClear,
                    )
                  : IconButton(
                      icon: Icon(
                        isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        size: 20,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: onToggleOpen,
                    ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: rw(context, 12),
                vertical: rh(context, 10),
              ),
              border: InputBorder.none,
            ),
          ),
        ),

        // Search results dropdown overlay box
        if (isOpen && items.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: items.take(15).length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3: PURPOSE VISIT
// ─────────────────────────────────────────────────────────────────────────────

class _Step3PurposeVisit extends StatelessWidget {
  final PraRegistrationController controller;
  const _Step3PurposeVisit({required this.controller});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd MMM yyyy, HH:mm', 'id');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Select Destination
        _buildFieldLabel(context, 'Destination (Site)', isRequired: true),
        vSpace(context, 6),
        _buildDropdownField<String>(
          context,
          value: controller.selectedSiteId.value.isNotEmpty
              ? controller.selectedSiteId.value
              : (controller.sites.isNotEmpty ? controller.sites.first.id : null),
          items: controller.sites
              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              controller.selectedSiteId.value = val;
              final found = controller.sites.firstWhereOrNull((s) => s.id == val);
              if (found != null) controller.selectedSiteName.value = found.name;
              controller.updateForm();
            }
          },
        ),

        vSpace(context, 14),

        // Select PIC Host
        _buildFieldLabel(context, 'PIC Host', isRequired: true),
        vSpace(context, 6),
        _buildDropdownField<String>(
          context,
          value: controller.selectedHostId.value.isNotEmpty
              ? controller.selectedHostId.value
              : (controller.hosts.isNotEmpty ? controller.hosts.first.id : null),
          items: controller.hosts
              .map((h) => DropdownMenuItem(value: h.id, child: Text(h.name)))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              controller.selectedHostId.value = val;
              final found = controller.hosts.firstWhereOrNull((h) => h.id == val);
              if (found != null) controller.selectedHostName.value = found.name;
              controller.updateForm();
            }
          },
        ),

        vSpace(context, 14),

        // Select Agenda
        _buildFieldLabel(context, 'Agenda', isRequired: true),
        vSpace(context, 6),
        _buildDropdownField<String>(
          context,
          value: controller.selectedAgenda.value,
          items: controller.agendaOptions
              .map((a) => DropdownMenuItem(value: a, child: Text(a)))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              controller.selectedAgenda.value = val;
              controller.updateForm();
            }
          },
        ),

        // If Agenda is 'Others', show custom agenda input
        if (controller.selectedAgenda.value == 'Others') ...[
          vSpace(context, 10),
          _buildTextInputField(
            context,
            controller: controller.otherAgendaCtrl,
            hintText: 'Specify your agenda',
            onChanged: (_) => controller.updateForm(),
          ),
        ],

        vSpace(context, 14),

        // Visit Start
        _buildFieldLabel(context, 'Visit Start', isRequired: true),
        vSpace(context, 6),
        _buildDateTimeTile(
          context,
          value: controller.visitStart.value != null
              ? dateFormat.format(controller.visitStart.value!)
              : 'Select visit start date & time',
          isSelected: controller.visitStart.value != null,
          onTap: () async {
            final picked = await showAppDateTimePicker(
              context,
              initialDate: controller.visitStart.value ?? DateTime.now(),
              minDateTime: DateTime.now(),
              withTime: true,
              title: 'Select Visit Start',
            );
            if (picked != null) {
              controller.visitStart.value = picked;
              // Auto adjust visitEnd if before visitStart
              if (controller.visitEnd.value == null ||
                  controller.visitEnd.value!.isBefore(picked)) {
                controller.visitEnd.value = picked.add(const Duration(hours: 2));
              }
              controller.updateForm();
            }
          },
        ),

        vSpace(context, 14),

        // Visit End
        _buildFieldLabel(context, 'Visit End', isRequired: true),
        vSpace(context, 6),
        _buildDateTimeTile(
          context,
          value: controller.visitEnd.value != null
              ? dateFormat.format(controller.visitEnd.value!)
              : 'Select visit end date & time',
          isSelected: controller.visitEnd.value != null,
          onTap: () async {
            final picked = await showAppDateTimePicker(
              context,
              initialDate: controller.visitEnd.value ??
                  (controller.visitStart.value?.add(const Duration(hours: 2)) ?? DateTime.now()),
              minDateTime: controller.visitStart.value ?? DateTime.now(),
              withTime: true,
              title: 'Select Visit End',
            );
            if (picked != null) {
              controller.visitEnd.value = picked;
              controller.updateForm();
            }
          },
        ),
      ],
    );
  }

  Widget _buildDateTimeTile(
    BuildContext context, {
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: rw(context, 12),
          vertical: rh(context, 11),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: isSelected ? AppColors.primary500 : const Color(0xFF64748B),
            ),
            hSpace(context, 10),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: rfs(context, 12.5),
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4: VEHICLE/PARKING INFORMATION (Dynamic)
// ─────────────────────────────────────────────────────────────────────────────

class _Step4VehicleInfo extends StatelessWidget {
  final PraRegistrationController controller;
  const _Step4VehicleInfo({required this.controller});

  @override
  Widget build(BuildContext context) {
    final vehicleOptions = controller.getVehicleTypeOptions();

    if (controller.isGroup.value == true) {
      final activeIndex = controller.selectedGroupMemberIndex.value;
      final safeIndex = activeIndex < controller.groupVisitors.length ? activeIndex : 0;
      final v = controller.groupVisitors[safeIndex];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Vehicle Information for Visitor ${safeIndex + 1}',
            style: TextStyle(
              fontSize: rfs(context, 14),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F2B48),
            ),
          ),
          vSpace(context, 12),

          // Are you driving a vehicle?
          _buildFieldLabel(context, 'Are you driving a vehicle?', isRequired: true),
          vSpace(context, 6),
          Row(
            children: [
              _buildRadioOption(
                context,
                label: 'Yes',
                isSelected: v.isDriving.value == true,
                onTap: () {
                  v.isDriving.value = true;
                  if (v.vehicleType.value.isEmpty && vehicleOptions.isNotEmpty) {
                    v.vehicleType.value = vehicleOptions.first;
                  }
                  controller.updateForm();
                },
              ),
              hSpace(context, 20),
              _buildRadioOption(
                context,
                label: 'No',
                isSelected: v.isDriving.value == false,
                onTap: () {
                  v.isDriving.value = false;
                  controller.updateForm();
                },
              ),
            ],
          ),

          if (v.isDriving.value) ...[
            vSpace(context, 14),
            _buildFieldLabel(context, 'Vehicle Type', isRequired: true),
            vSpace(context, 6),
            _buildDropdownField<String>(
              context,
              value: v.vehicleType.value.isNotEmpty ? v.vehicleType.value : vehicleOptions.first,
              items: vehicleOptions
                  .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  v.vehicleType.value = val;
                  controller.updateForm();
                }
              },
            ),

            if (!controller.isBicycle(v.vehicleType.value)) ...[
              vSpace(context, 14),
              _buildFieldLabel(context, 'License Plate Number', isRequired: true),
              vSpace(context, 6),
              _buildTextInputField(
                context,
                controller: v.vehiclePlateCtrl,
                hintText: 'e.g. B 1234 ABC',
                onChanged: (_) => controller.updateForm(),
              ),
            ],
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFieldLabel(context, 'Are you driving a vehicle?', isRequired: true),
        vSpace(context, 6),
        Row(
          children: [
            _buildRadioOption(
              context,
              label: 'Yes',
              isSelected: controller.isDriving.value == true,
              onTap: () {
                controller.isDriving.value = true;
                if (controller.vehicleType.value.isEmpty && vehicleOptions.isNotEmpty) {
                  controller.vehicleType.value = vehicleOptions.first;
                }
                controller.updateForm();
              },
            ),
            hSpace(context, 20),
            _buildRadioOption(
              context,
              label: 'No',
              isSelected: controller.isDriving.value == false,
              onTap: () {
                controller.isDriving.value = false;
                controller.updateForm();
              },
            ),
          ],
        ),

        if (controller.isDriving.value) ...[
          vSpace(context, 14),
          _buildFieldLabel(context, 'Vehicle Type', isRequired: true),
          vSpace(context, 6),
          _buildDropdownField<String>(
            context,
            value: controller.vehicleType.value.isNotEmpty
                ? controller.vehicleType.value
                : vehicleOptions.first,
            items: vehicleOptions
                .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                controller.vehicleType.value = val;
                controller.updateForm();
              }
            },
          ),

          if (!controller.isBicycle(controller.vehicleType.value)) ...[
            vSpace(context, 14),
            _buildFieldLabel(context, 'License Plate Number', isRequired: true),
            vSpace(context, 6),
            _buildTextInputField(
              context,
              controller: controller.vehiclePlateCtrl,
              hintText: 'e.g. B 1234 ABC',
              onChanged: (_) => controller.updateForm(),
            ),
          ],
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 5: SELFIE IMAGE (Dynamic)
// ─────────────────────────────────────────────────────────────────────────────

class _Step5SelfieImage extends StatelessWidget {
  final PraRegistrationController controller;
  const _Step5SelfieImage({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isGroup = controller.isGroup.value == true;
    final activeIndex = controller.selectedGroupMemberIndex.value;
    final safeIndex = activeIndex < controller.groupVisitors.length ? activeIndex : 0;
    final currentImage = isGroup
        ? controller.groupVisitors[safeIndex].selfieImage.value
        : controller.selfieImage.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context,
          isGroup ? 'Selfie Image for Visitor ${safeIndex + 1}' : 'Selfie Image',
          isRequired: false,
        ),
        vSpace(context, 4),
        Text(
          'Take a clear selfie photo or select from gallery (max 5 MB).',
          style: TextStyle(
            fontSize: rfs(context, 12),
            color: const Color(0xFF64748B),
          ),
        ),
        vSpace(context, 16),

        if (currentImage != null)
          _buildImagePreview(
            context,
            fileData: currentImage,
            onRemove: () => controller.removeImage(isKtp: false, groupIndex: isGroup ? safeIndex : null),
            onRetake: () => controller.pickImage(isKtp: false, fromCamera: true, groupIndex: isGroup ? safeIndex : null),
          )
        else
          _buildUploadPlaceholder(
            context,
            title: 'Take Selfie or Choose File',
            onCamera: () => controller.pickImage(isKtp: false, fromCamera: true, groupIndex: isGroup ? safeIndex : null),
            onGallery: () => controller.pickImage(isKtp: false, fromCamera: false, groupIndex: isGroup ? safeIndex : null),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 6: UPLOAD IDENTITY / KTP (Dynamic)
// ─────────────────────────────────────────────────────────────────────────────

class _Step6KtpImage extends StatelessWidget {
  final PraRegistrationController controller;
  const _Step6KtpImage({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isGroup = controller.isGroup.value == true;
    final activeIndex = controller.selectedGroupMemberIndex.value;
    final safeIndex = activeIndex < controller.groupVisitors.length ? activeIndex : 0;
    final currentImage = isGroup
        ? controller.groupVisitors[safeIndex].ktpImage.value
        : controller.ktpImage.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context,
          isGroup ? 'Upload Identity (KTP) for Visitor ${safeIndex + 1}' : 'Upload Identity (KTP)',
          isRequired: false,
        ),
        vSpace(context, 4),
        Text(
          'Take a clear photo of your Identity Card (KTP) or select from gallery (max 5 MB).',
          style: TextStyle(
            fontSize: rfs(context, 12),
            color: const Color(0xFF64748B),
          ),
        ),
        vSpace(context, 16),

        if (currentImage != null)
          _buildImagePreview(
            context,
            fileData: currentImage,
            onRemove: () => controller.removeImage(isKtp: true, groupIndex: isGroup ? safeIndex : null),
            onRetake: () => controller.pickImage(isKtp: true, fromCamera: true, groupIndex: isGroup ? safeIndex : null),
          )
        else
          _buildUploadPlaceholder(
            context,
            title: 'Take KTP Photo or Choose File',
            onCamera: () => controller.pickImage(isKtp: true, fromCamera: true, groupIndex: isGroup ? safeIndex : null),
            onGallery: () => controller.pickImage(isKtp: true, fromCamera: false, groupIndex: isGroup ? safeIndex : null),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOOTER NAVIGATION BAR: BACK & NEXT / SUBMIT BUTTONS
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final PraRegistrationController controller;
  const _BottomNav({required this.controller});

  @override
  Widget build(BuildContext context) {
    final step = controller.currentStep.value;
    final isFinalStep = step > 1 && step == controller.maxSteps;
    final isValid = controller.isCurrentStepValid && !controller.isSubmitting.value;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 16),
        vertical: rh(context, 12),
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 16),
                vertical: rh(context, 10),
              ),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: !controller.isSubmitting.value
                ? () {
                    if (step <= 1) {
                      controller.resetFields();
                      Navigator.of(context).pop();
                    } else {
                      controller.prevStep();
                    }
                  }
                : null,
            icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.primary500),
            label: Text(
              'Back',
              style: TextStyle(
                fontSize: rfs(context, 13),
                fontWeight: FontWeight.w600,
                color: AppColors.primary500,
              ),
            ),
          ),

          // Next / Submit Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid ? AppColors.primary500 : const Color(0xFFE2E8F0),
              foregroundColor: isValid ? Colors.white : const Color(0xFF94A3B8),
              elevation: isValid ? 1.5 : 0,
              padding: EdgeInsets.symmetric(
                horizontal: rw(context, 22),
                vertical: rh(context, 10),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: isValid
                ? () async {
                    if (isFinalStep) {
                      final success = await controller.submitForm();
                      if (success && context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    } else {
                      controller.nextStep();
                    }
                  }
                : null,
            child: controller.isSubmitting.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isFinalStep ? 'Submit' : 'Next',
                        style: TextStyle(
                          fontSize: rfs(context, 13),
                          fontWeight: FontWeight.w700,
                          color: isValid ? Colors.white : const Color(0xFF94A3B8),
                        ),
                      ),
                      if (!isFinalStep) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: isValid ? Colors.white : const Color(0xFF94A3B8),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED UI HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildSectionHeader(BuildContext context, String title, {bool isRequired = false}) {
  return Row(
    children: [
      Container(
        width: 3.5,
        height: 16,
        decoration: BoxDecoration(
          color: AppColors.primary500,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      hSpace(context, 8),
      Text(
        title,
        style: TextStyle(
          fontSize: rfs(context, 14),
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F2B48),
        ),
      ),
      if (isRequired) ...[
        hSpace(context, 4),
        const Text(
          '*',
          style: TextStyle(
            color: Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ],
  );
}

Widget _buildFieldLabel(BuildContext context, String label, {bool isRequired = false}) {
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
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ]
          : null,
    ),
  );
}

Widget _buildTextInputField(
  BuildContext context, {
  required TextEditingController controller,
  required String hintText,
  TextInputType keyboardType = TextInputType.text,
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

Widget _buildDropdownField<T>(
  BuildContext context, {
  required T? value,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: rw(context, 12)),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFCBD5E1)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        items: items,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: rfs(context, 13),
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
      ),
    ),
  );
}

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
            color: isSelected ? AppColors.primary500 : const Color(0xFF334155),
          ),
        ),
      ],
    ),
  );
}

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
      border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
    ),
    child: Column(
      children: [
        Icon(Icons.cloud_upload_outlined, size: 36, color: Colors.blue.shade600),
        vSpace(context, 8),
        Text(
          title,
          style: TextStyle(
            fontSize: rfs(context, 13),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

Widget _buildImagePreview(
  BuildContext context, {
  required UploadedFileData fileData,
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
              : (fileData.localPath != null
                  ? Image.file(
                      File(fileData.localPath!),
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
                    fileData.sizeFormatted,
                    style: TextStyle(
                      fontSize: rfs(context, 11),
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary500, size: 20),
              tooltip: 'Retake',
              onPressed: onRetake,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              tooltip: 'Remove',
              onPressed: onRemove,
            ),
          ],
        ),
      ],
    ),
  );
}
