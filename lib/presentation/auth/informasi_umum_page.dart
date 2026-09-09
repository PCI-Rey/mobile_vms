// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'controller/informasi_umum_controller.dart';
import 'controller/language_controller.dart';
import '../../data/models/user_model.dart';
import '../../core/helper/responsive_helper.dart';
import '../../../core/core.dart';

String _localTr(String key, String fallbackIndo, String fallbackEn) {
  final val = key.tr;
  if (val == key) {
    final isEn = Get.locale?.languageCode == 'en';
    return isEn ? fallbackEn : fallbackIndo;
  }
  return val;
}

class InformasiUmumPage extends StatefulWidget {
  final UserModel? userModel;
  final String? invitationCode;
  final Map<String, dynamic>? rawData;

  const InformasiUmumPage({
    super.key,
    this.userModel,
    this.invitationCode,
    this.rawData,
  });

  @override
  State<InformasiUmumPage> createState() => _InformasiUmumPageState();
}

class _InformasiUmumPageState extends State<InformasiUmumPage> {
  late InformasiUmumController _ctrl;

  @override
  void initState() {
    super.initState();
    // Use find-or-put to avoid crash when controller hasn't been registered yet
    // (e.g. navigating via named routes without going through VerificationCodeController)
    if (Get.isRegistered<InformasiUmumController>()) {
      _ctrl = Get.find<InformasiUmumController>();
    } else {
      _ctrl = Get.put(InformasiUmumController());
      // If widget.userModel is provided (e.g. direct construction), initialize data
      if (widget.userModel != null) {
        _ctrl.initializeData(
          widget.userModel!,
          widget.invitationCode ?? '',
          widget.rawData,
        );
      }
    }
    // Note: red border indicators on empty fields are already set by initializeData().
    // We do NOT show the snackbar automatically — it only appears when user tries to proceed.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('informasi_umum'.tr),
        centerTitle: true,
        elevation: 0,
        leading: const BackButton(),
        actions: [
          Obx(() {
            final langCtrl = LanguageController.to;
            final isId = langCtrl.selectedLang.value == 'id';
            return Padding(
              padding: EdgeInsets.symmetric(vertical: rh(context, 8), horizontal: rw(context, 8)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: rw(context, 10)),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary500, width: 1.5),
                  borderRadius: BorderRadius.circular(rw(context, 8)),
                  color: AppColors.primary50,
                ),
                child: DropdownButton<String>(
                  value: isId ? 'id' : 'en',
                  underline: const SizedBox.shrink(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: rw(context, 18),
                    color: AppColors.primary500,
                  ),
                  isDense: true,
                  items: [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(
                        '🇬🇧 ENG',
                        style: TextStyle(
                          fontSize: rfs(context, 14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'id',
                      child: Text(
                        '🇮🇩 ID',
                        style: TextStyle(
                          fontSize: rfs(context, 14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) langCtrl.changeLanguage(v);
                  },
                ),
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: rh(context, 16)),
              color: const Color(
                0xFF00529C,
              ), // Senada dengan warna background logo BI/VMS.png
              child: Column(
                children: [
                  Image.asset('assets/images/VMS.png', height: rh(context, 64)),
                  vSpace(context, 6),
                  Text(
                    '${'invitation_code'.tr}: ${widget.invitationCode ?? "-"}',
                    style: TextStyle(
                      fontSize: rfs(context, 14),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            vSpace(context, 8),

            // ── PageView ─────────────────────────────────
            Expanded(
              child: Obx(
                () => PageView(
                  controller: _ctrl.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => _ctrl.currentPage.value = i,
                  children: _ctrl.activeSteps.map((stepType) {
                    switch (stepType) {
                      case InformasiUmumStepType.visitorInfo:
                        return _Step1(ctrl: _ctrl);
                      case InformasiUmumStepType.purposeVisit:
                        return _Step2(ctrl: _ctrl);
                      case InformasiUmumStepType.vehicleInfo:
                        return _Step3(ctrl: _ctrl);
                      case InformasiUmumStepType.selfieImage:
                        return _Step4(ctrl: _ctrl);
                      case InformasiUmumStepType.ktpImage:
                        return _Step5(ctrl: _ctrl);
                    }
                  }).toList(),
                ),
              ),
            ),

            // ── Navigation Bar ────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              padding: EdgeInsets.symmetric(horizontal: rw(context, 20), vertical: rh(context, 12)),
              child: Row(
                children: [
                  // Back button (fixed width)
                  SizedBox(
                    width: rw(context, 80),
                    child: Obx(
                      () => _ctrl.currentPage.value > 0
                          ? OutlinedButton(
                              onPressed: _ctrl.previousPage,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.primary500),
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                'back'.tr,
                                style: TextStyle(
                                  color: AppColors.primary500,
                                  fontSize: rfs(context, 13),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),

                  // Dots indicator (flexible center)
                  Expanded(
                    child: Obx(() {
                      final totalDots = _ctrl.totalActiveSteps;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          totalDots,
                          (i) => Container(
                            margin: EdgeInsets.symmetric(horizontal: rw(context, 4)),
                            width: rw(context, 8),
                            height: rw(context, 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _ctrl.currentPage.value == i
                                  ? AppColors.primary500
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  // Next / Submit button (fixed width)
                  SizedBox(
                    width: rw(context, 110),
                    child: Obx(() {
                      if (_ctrl.isLoading.value) {
                        return Center(
                          child: SizedBox(
                            width: rw(context, 24),
                            height: rw(context, 24),
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      final isLast =
                          _ctrl.currentPage.value == _ctrl.totalActiveSteps - 1;
                      final isValid = _ctrl.isCurrentStepValid.value;
                      return ElevatedButton(
                        onPressed: isValid
                            ? (isLast ? _ctrl.submit : _ctrl.nextPage)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          padding: EdgeInsets.zero,
                          elevation: 0,
                        ),
                        child: Text(
                          isLast ? 'submit'.tr : 'next'.tr,
                          style: TextStyle(fontSize: rfs(context, 13)),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step widgets (extracted to avoid rebuild issues)
// ─────────────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  final InformasiUmumController ctrl;
  const _Step1({required this.ctrl});

  Widget _requiredLabel(BuildContext context, String text, {bool isRequired = true}) => Padding(
    padding: EdgeInsets.only(top: rh(context, 10), bottom: rh(context, 4)),
    child: RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: rfs(context, 14),
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    ),
  );

  Widget _buildField(
    BuildContext context,
    String key,
    String label,
    TextEditingController controller,
    String hint, {
    bool isRequired = false,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel(context, label, isRequired: isRequired),
        CustomTextField(
          controller: controller,
          label: '',
          showLabel: false,
          hintText: hint,
          readOnly: readOnly,
          keyboardType: keyboardType,
          errorText: ctrl.fieldErrors[key],
          onChanged: (v) => ctrl.validateField(key, v, label),
        ),
      ],
    );
  }

  Widget _buildDynamicField(BuildContext context, Map<String, dynamic> f) {
    final remarks = (f['remarks'] ?? '').toString().toLowerCase().trim();

    final label = (f['long_display_text'] ?? f['short_name'] ?? remarks).toString();
    final isMandatory = f['mandatory'] == true;

    if (remarks == 'visitor_role' || remarks == 'role') {
      if (ctrl.visitorRolesList.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _requiredLabel(context, label, isRequired: isMandatory),
          DropdownButton2<String>(
            isExpanded: true,
            value: ctrl.selectedVisitorRole.value,
            items: ctrl.visitorRolesList
                .map(
                  (role) => DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) ctrl.selectedVisitorRole.value = v;
            },
            buttonStyleData: ButtonStyleData(
              height: rh(context, 50),
              padding: EdgeInsets.only(left: 0, right: rw(context, 12)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rw(context, 8)),
                border: Border.all(color: AppColors.grey300, width: 1.5),
              ),
            ),
            menuItemStyleData: EdgeInsets.symmetric(horizontal: rw(context, 12)).toMapMenuItemStyleData(),
            dropdownStyleData: DropdownStyleData(
              maxHeight: rh(context, 250),
              offset: Offset(0, rh(context, -10)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(rw(context, 8)),
              ),
            ),
            underline: const SizedBox.shrink(),
          ),
        ],
      );
    } else if (remarks == 'name') {
      return _buildField(context, 'fullname', label, ctrl.fullNameController, 'nama_lengkap'.tr, isRequired: isMandatory);
    } else if (remarks == 'email') {
      return _buildField(context, 'email', label, ctrl.emailController, 'nama@email.com', isRequired: isMandatory, readOnly: true, keyboardType: TextInputType.emailAddress);
    } else if (remarks == 'phone') {
      return _buildField(context, 'phone', label, ctrl.phoneController, '08xx xxxx xxxx', isRequired: isMandatory, keyboardType: TextInputType.phone);
    } else if (remarks == 'organization' || remarks == 'company') {
      return _buildField(context, 'organization', label, ctrl.organizationController, 'instansi_hint'.tr, isRequired: isMandatory);
    } else if (remarks == 'identity_id' || remarks == 'indentity_id') {
      return _buildField(context, 'identityId', label, ctrl.identityIdController, '32012345...', isRequired: isMandatory, keyboardType: TextInputType.number);
    } else {
      final extraCtrl = ctrl.getExtraController(remarks);
      return _buildField(context, remarks, label, extraCtrl, label, isRequired: isMandatory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fields = ctrl.visitorInfoFormFields;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: rw(context, 20), vertical: rh(context, 8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                ctrl.visitorInfoPage?['name']?.toString() ?? 'visitor_information'.tr,
                style: TextStyle(
                  fontSize: rfs(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            vSpace(context, 16),
            if (fields.isEmpty) ...[
              _buildField(context, 'fullname', 'fullname'.tr, ctrl.fullNameController, 'nama_lengkap'.tr, isRequired: true),
              _buildField(context, 'email', 'email'.tr, ctrl.emailController, 'nama@email.com', isRequired: true, readOnly: true, keyboardType: TextInputType.emailAddress),
              _buildField(context, 'phone', 'phone'.tr, ctrl.phoneController, '08xx xxxx xxxx', isRequired: true, keyboardType: TextInputType.phone),
              _buildField(context, 'organization', 'organization'.tr, ctrl.organizationController, 'instansi_hint'.tr, isRequired: true),
            ] else ...[
              for (final f in fields)
                _buildDynamicField(context, f),
            ],
            vSpace(context, 20),
          ],
        ),
      );
    });
  }
}

class _Step2 extends StatelessWidget {
  final InformasiUmumController ctrl;
  const _Step2({required this.ctrl});

  Widget _label(BuildContext context, String text) => Padding(
    padding: EdgeInsets.only(top: rh(context, 10), bottom: rh(context, 4)),
    child: Text(
      text,
      style: TextStyle(
        fontSize: rfs(context, 14),
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );

  Widget _requiredLabel(BuildContext context, String text, {bool isRequired = true}) => Padding(
    padding: EdgeInsets.only(top: rh(context, 10), bottom: rh(context, 4)),
    child: RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: rfs(context, 14),
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    ),
  );

  Widget _readOnlyField(TextEditingController controller) => CustomTextField(
    controller: controller,
    label: '',
    showLabel: false,
    readOnly: true,
  );

  Widget _buildField(
    BuildContext context,
    Map<String, dynamic> f,
  ) {
    final remarks = (f['remarks'] ?? '').toString().toLowerCase().trim();
    final label = (f['long_display_text'] ?? f['short_name'] ?? remarks).toString();
    final isMandatory = f['mandatory'] == true;

    if (remarks == 'site_place') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _requiredLabel(context, label.isNotEmpty ? label : 'destination'.tr, isRequired: isMandatory),
          _readOnlyField(ctrl.destinationController),
        ],
      );
    } else if (remarks == 'host') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _requiredLabel(context, label.isNotEmpty ? label : 'pic_host'.tr, isRequired: isMandatory),
          _readOnlyField(ctrl.picHostController),
        ],
      );
    } else if (remarks == 'agenda') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _requiredLabel(context, label.isNotEmpty ? label : 'agenda'.tr, isRequired: isMandatory),
          _readOnlyField(ctrl.agendaController),
        ],
      );
    } else if (remarks == 'visitor_period_start') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _requiredLabel(context, label.isNotEmpty ? label : 'visit_start'.tr, isRequired: isMandatory),
          _readOnlyField(ctrl.visitStartController),
        ],
      );
    } else if (remarks == 'visitor_period_end') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _requiredLabel(context, label.isNotEmpty ? label : 'visit_end'.tr, isRequired: isMandatory),
          _readOnlyField(ctrl.visitEndController),
        ],
      );
    } else {
      final extraCtrl = ctrl.getExtraController(remarks);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _requiredLabel(context, label, isRequired: isMandatory),
          CustomTextField(
            controller: extraCtrl,
            label: '',
            showLabel: false,
            hintText: label,
            errorText: ctrl.fieldErrors[remarks],
            onChanged: (v) => ctrl.validateField(remarks, v, label),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fields = ctrl.purposeVisitFormFields;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: rw(context, 20), vertical: rh(context, 8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                ctrl.purposeVisitPage?['name']?.toString() ?? 'purpose_visit'.tr,
                style: TextStyle(fontSize: rfs(context, 18), fontWeight: FontWeight.bold),
              ),
            ),
            vSpace(context, 16),
            if (fields.isEmpty) ...[
              _label(context, 'pic_host'.tr),
              _readOnlyField(ctrl.picHostController),
              _label(context, 'agenda'.tr),
              _readOnlyField(ctrl.agendaController),
              _label(context, 'destination'.tr),
              _readOnlyField(ctrl.destinationController),
              _requiredLabel(context, 'visit_start'.tr),
              _readOnlyField(ctrl.visitStartController),
              _requiredLabel(context, 'visit_end'.tr),
              _readOnlyField(ctrl.visitEndController),
            ] else ...[
              for (final f in fields)
                _buildField(context, f),
            ],
            vSpace(context, 20),
          ],
        ),
      );
    });
  }
}

class _Step3 extends StatelessWidget {
  final InformasiUmumController ctrl;
  const _Step3({required this.ctrl});

  Widget _requiredLabel(BuildContext context, String text) => Padding(
    padding: EdgeInsets.only(top: rh(context, 10), bottom: rh(context, 4)),
    child: RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: rfs(context, 14),
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
  );

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: rw(context, 20), vertical: rh(context, 8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                ctrl.vehiclePage?['name']?.toString() ?? 'vehicle_information'.tr,
                style: TextStyle(
                  fontSize: rfs(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            vSpace(context, 16),
            // Are you driving?
            RichText(
              text: TextSpan(
                text: ctrl.vehicleFormFields.firstWhereOrNull((f) => f['remarks'] == 'is_driving')?['long_display_text']?.toString() ?? 'are_you_driving'.tr,
                style: TextStyle(
                  fontSize: rfs(context, 14),
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
            vSpace(context, 4),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: ctrl.isDriving.value,
                  activeColor: AppColors.primary500,
                  onChanged: (v) {
                    ctrl.isDriving.value = v!;
                    if (ctrl.vehiclePlateController.text.trim().isEmpty) {
                      ctrl.validateField(
                        'vehiclePlate',
                        '',
                        ctrl.vehicleFormFields.firstWhereOrNull((f) => f['remarks'] == 'vehicle_plate')?['long_display_text']?.toString() ?? 'vehicle_plate'.tr,
                      );
                    }
                  },
                ),
                Text('yes'.tr),
                hSpace(context, 16),
                Radio<bool>(
                  value: false,
                  groupValue: ctrl.isDriving.value,
                  activeColor: AppColors.primary500,
                  onChanged: (v) {
                    ctrl.isDriving.value = v!;
                    ctrl.fieldErrors.remove('vehiclePlate');
                  },
                ),
                Text('no'.tr),
              ],
            ),
            // Conditionally show vehicle fields only if driving
            if (ctrl.isDriving.value) ...[
              _requiredLabel(
                context,
                ctrl.vehicleFormFields.firstWhereOrNull((f) => f['remarks'] == 'vehicle_type')?['long_display_text']?.toString() ?? 'vehicle_type'.tr,
              ),
              () {
                final options = ctrl.vehicleTypeOptions;
                final currentVal = ctrl.vehicleType.value;
                final match = options.firstWhereOrNull(
                  (o) =>
                      o['value'] == currentVal ||
                      o['label'] == currentVal ||
                      (o['value'] == 'Car' &&
                          (currentVal == 'vehicle_car' || currentVal == 'Car')) ||
                      (o['value'] == 'Motorcycle' &&
                          (currentVal == 'vehicle_motor' ||
                              currentVal == 'Motor' ||
                              currentVal == 'Motorcycle')) ||
                      (o['value'] == 'Bus' &&
                          (currentVal == 'vehicle_bus' || currentVal == 'Bus')) ||
                      (o['value'] == 'Truck' &&
                          (currentVal == 'vehicle_truck' ||
                              currentVal == 'Truck' ||
                              currentVal == 'Truk')) ||
                      (o['value'] == 'Bicycle' &&
                          (currentVal == 'vehicle_bicycle' ||
                              currentVal == 'Bicycle' ||
                              currentVal == 'Sepeda')),
                );
                final selectedValue =
                    match?['value'] ?? (options.isNotEmpty ? options.first['value'] : 'Car');

                return DropdownButton2<String>(
                  isExpanded: true,
                  value: selectedValue,
                  items: options
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item['value'],
                          child: Text(item['label'] ?? item['value'] ?? ''),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      ctrl.vehicleType.value = v;
                      if (ctrl.isBicycle(v)) {
                        ctrl.vehiclePlateController.clear();
                        ctrl.fieldErrors.remove('vehiclePlate');
                      }
                      ctrl.updateStepValidity();
                    }
                  },
                  buttonStyleData: ButtonStyleData(
                    height: rh(context, 50),
                    padding: EdgeInsets.only(left: 0, right: rw(context, 12)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(rw(context, 8)),
                      border: Border.all(color: AppColors.grey300, width: 1.5),
                    ),
                  ),
                  menuItemStyleData: EdgeInsets.symmetric(
                    horizontal: rw(context, 12),
                  ).toMapMenuItemStyleData(),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: rh(context, 250),
                    offset: Offset(0, rh(context, -10)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(rw(context, 8)),
                    ),
                  ),
                  underline: const SizedBox.shrink(),
                );
              }(),
              if (!ctrl.isBicycle(ctrl.vehicleType.value)) ...[
                _requiredLabel(
                  context,
                  ctrl.vehicleFormFields.firstWhereOrNull((f) => f['remarks'] == 'vehicle_plate')?['long_display_text']?.toString() ?? 'vehicle_plate'.tr,
                ),
                CustomTextField(
                  controller: ctrl.vehiclePlateController,
                  label: '',
                  showLabel: false,
                  hintText: 'B 1234 XX',
                  errorText: ctrl.fieldErrors['vehiclePlate'],
                  onChanged: (v) =>
                      ctrl.validateField(
                        'vehiclePlate',
                        v,
                        ctrl.vehicleFormFields.firstWhereOrNull((f) => f['remarks'] == 'vehicle_plate')?['long_display_text']?.toString() ?? 'vehicle_plate'.tr,
                      ),
                ),
              ],
            ],
            vSpace(context, 20),
          ],
        ),
      ),
    );
  }
}

class _Step4 extends StatelessWidget {
  final InformasiUmumController ctrl;
  const _Step4({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 20),
        vertical: rh(context, 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              ctrl.selfiePage?['name']?.toString() ?? 'face_photo_title'.tr,
              style: TextStyle(
                fontSize: rfs(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          vSpace(context, 16),
          Obx(() {
            if (ctrl.selfieImage.value == null) {
              return _UploadPlaceholderCard(
                isUploading: ctrl.isUploadingSelfie.value,
                icon: Icons.camera_alt,
                onTap: () => _showPickerBottomSheet(
                  context,
                  isSelfie: true,
                  ctrl: ctrl,
                ),
              );
            }
            return _ImagePreviewCard(
              file: ctrl.selfieImage.value!,
              fileName: ctrl.selfieFileName.value,
              fileSize: ctrl.selfieFileSizeFormatted.value,
              isUploading: ctrl.isUploadingSelfie.value,
              uploadedUrl: ctrl.selfieUrl.value,
              onReplace: () => _showPickerBottomSheet(
                context,
                isSelfie: true,
                ctrl: ctrl,
              ),
              onRemove: () => ctrl.removeImage(true),
            );
          }),
          vSpace(context, 20),
        ],
      ),
    );
  }
}

class _Step5 extends StatelessWidget {
  final InformasiUmumController ctrl;
  const _Step5({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: rw(context, 20),
        vertical: rh(context, 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              ctrl.ktpPage?['name']?.toString() ?? 'upload_ktp'.tr,
              style: TextStyle(
                fontSize: rfs(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          vSpace(context, 16),
          Obx(() {
            if (ctrl.identityImage.value == null) {
              return _UploadPlaceholderCard(
                isUploading: ctrl.isUploadingIdentity.value,
                icon: Icons.cloud_upload,
                onTap: () => _showPickerBottomSheet(
                  context,
                  isSelfie: false,
                  ctrl: ctrl,
                ),
              );
            }
            return _ImagePreviewCard(
              file: ctrl.identityImage.value!,
              fileName: ctrl.identityFileName.value,
              fileSize: ctrl.identityFileSizeFormatted.value,
              isUploading: ctrl.isUploadingIdentity.value,
              uploadedUrl: ctrl.identityUrl.value,
              onReplace: () => _showPickerBottomSheet(
                context,
                isSelfie: false,
                ctrl: ctrl,
              ),
              onRemove: () => ctrl.removeImage(false),
            );
          }),
          vSpace(context, 20),
        ],
      ),
    );
  }
}

class _UploadPlaceholderCard extends StatelessWidget {
  final bool isUploading;
  final IconData icon;
  final VoidCallback onTap;

  const _UploadPlaceholderCard({
    required this.isUploading,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Container(
        height: rh(context, 220),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary50,
          border: Border.all(color: AppColors.grey300, width: 1.5),
          borderRadius: BorderRadius.circular(rw(context, 8)),
        ),
        child: isUploading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary500),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: rw(context, 50),
                    color: AppColors.primary500,
                  ),
                  vSpace(context, 10),
                  Text(
                    _localTr(
                      'upload_file',
                      'Unggah File',
                      'Upload File',
                    ),
                    style: const TextStyle(
                      color: AppColors.primary500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  vSpace(context, 4),
                  Text(
                    _localTr(
                      'upload_file_support',
                      'Format: JPG, JPEG, PNG. Maks 5MB\nGunakan Kamera',
                      'Supports: JPG, JPEG, PNG. Up to 5MB\nUse Camera',
                    ).replaceAll('100KB', '5MB').replaceAll('100 KB', '5MB'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: rfs(context, 12),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ImagePreviewCard extends StatelessWidget {
  final File file;
  final String fileName;
  final String fileSize;
  final bool isUploading;
  final String? uploadedUrl;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  const _ImagePreviewCard({
    required this.file,
    required this.fileName,
    required this.fileSize,
    required this.isUploading,
    required this.uploadedUrl,
    required this.onReplace,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toUpperCase()
        : 'JPG';
    final displayName = fileName.isNotEmpty
        ? fileName
        : file.path.split(Platform.pathSeparator).last;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rw(context, 14)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(rw(context, 12)),
        border: Border.all(
          color: uploadedUrl != null
              ? Colors.green
              : AppColors.primary500,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(rw(context, 8)),
            child: SizedBox(
              width: rw(context, 75),
              height: rh(context, 75),
              child: Image.file(
                file,
                fit: BoxFit.cover,
              ),
            ),
          ),
          hSpace(context, 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rfs(context, 13),
                    color: const Color(0xFF0F2B48),
                  ),
                ),
                vSpace(context, 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ext,
                        style: TextStyle(
                          fontSize: rfs(context, 10),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    ),
                    if (fileSize.isNotEmpty) ...[
                      hSpace(context, 8),
                      Text(
                        fileSize,
                        style: TextStyle(
                          fontSize: rfs(context, 11),
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
                vSpace(context, 6),
                if (isUploading)
                  Row(
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary500,
                        ),
                      ),
                      hSpace(context, 6),
                      Text(
                        _localTr(
                          'uploading_status',
                          'Mengunggah...',
                          'Uploading...',
                        ),
                        style: TextStyle(
                          fontSize: rfs(context, 11),
                          color: AppColors.primary500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else if (uploadedUrl != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green,
                      ),
                      hSpace(context, 4),
                      Text(
                        _localTr(
                          'uploaded_status',
                          'Tersimpan',
                          'Uploaded',
                        ),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          hSpace(context, 4),
          IconButton(
            tooltip: _localTr('replace_photo', 'Ganti', 'Replace'),
            onPressed: isUploading ? null : onReplace,
            icon: const Icon(Icons.refresh, color: AppColors.primary500),
          ),
          IconButton(
            tooltip: _localTr('remove_photo', 'Hapus', 'Delete'),
            onPressed: isUploading ? null : onRemove,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

void _showPickerBottomSheet(
  BuildContext context, {
  required bool isSelfie,
  required InformasiUmumController ctrl,
}) {
  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: AppColors.primary500),
            title: Text('source_camera'.tr),
            onTap: () {
              Get.back();
              if (isSelfie) {
                ctrl.pickSelfie(ImageSource.camera);
              } else {
                ctrl.pickIdentity(ImageSource.camera);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo, color: AppColors.primary500),
            title: Text('source_gallery'.tr),
            onTap: () {
              Get.back();
              if (isSelfie) {
                ctrl.pickSelfie(ImageSource.gallery);
              } else {
                ctrl.pickIdentity(ImageSource.gallery);
              }
            },
          ),
        ],
      ),
    ),
  );
}

extension DropdownButton2Responsive on EdgeInsets {
  MenuItemStyleData toMapMenuItemStyleData() {
    return MenuItemStyleData(padding: this);
  }
}
