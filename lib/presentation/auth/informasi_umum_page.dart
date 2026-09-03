// ignore_for_file: deprecated_member_use
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
                  children: [
                    _WhoFillStep(ctrl: _ctrl),
                    if (_ctrl.isSelfRegistered.value == false)
                      _StepOther(ctrl: _ctrl),
                    _Step1(ctrl: _ctrl),
                    _Step2(ctrl: _ctrl),
                    _Step3(ctrl: _ctrl),
                    _Step4(ctrl: _ctrl),
                    _Step5(ctrl: _ctrl),
                  ],
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
                      final totalDots = _ctrl.isSelfRegistered.value == false
                          ? 7
                          : 6;
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
                          _ctrl.currentPage.value ==
                          (_ctrl.isSelfRegistered.value == false ? 6 : 5);
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
                'visitor_information'.tr,
                style: TextStyle(
                  fontSize: rfs(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            vSpace(context, 16),
            _requiredLabel(
              context,
              _localTr('visitor_role', 'Peran Pengunjung', 'Visitor Role'),
            ),
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
                  color: AppColors.primary50,
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
            _requiredLabel(context, 'fullname'.tr),
            CustomTextField(
              controller: ctrl.fullNameController,
              label: '',
              showLabel: false,
              hintText: 'nama_lengkap'.tr,
              errorText: ctrl.fieldErrors['fullname'],
              onChanged: (v) =>
                  ctrl.validateField('fullname', v, 'fullname'.tr),
            ),
            _requiredLabel(context, 'email'.tr),
            CustomTextField(
              controller: ctrl.emailController,
              label: '',
              showLabel: false,
              hintText: 'nama@email.com',
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
              errorText: ctrl.fieldErrors['email'],
              onChanged: (v) => ctrl.validateField('email', v, 'email'.tr),
            ),
            _requiredLabel(context, 'phone'.tr),
            CustomTextField(
              controller: ctrl.phoneController,
              label: '',
              showLabel: false,
              hintText: '08xx xxxx xxxx',
              keyboardType: TextInputType.phone,
              errorText: ctrl.fieldErrors['phone'],
              onChanged: (v) => ctrl.validateField('phone', v, 'phone'.tr),
            ),
            _requiredLabel(context, 'organization'.tr),
            CustomTextField(
              controller: ctrl.organizationController,
              label: '',
              showLabel: false,
              hintText: 'instansi_hint'.tr,
              errorText: ctrl.fieldErrors['organization'],
              onChanged: (v) =>
                  ctrl.validateField('organization', v, 'organization'.tr),
            ),
            _requiredLabel(context, 'identity_id'.tr),
            CustomTextField(
              controller: ctrl.identityIdController,
              label: '',
              showLabel: false,
              hintText: '32012345...',
              keyboardType: TextInputType.number,
              errorText: ctrl.fieldErrors['identityId'],
              onChanged: (v) =>
                  ctrl.validateField('identityId', v, 'identity_id'.tr),
            ),
            vSpace(context, 20),
          ],
        ),
      ),
    );
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
  Widget _readOnlyField(TextEditingController controller) => CustomTextField(
    controller: controller,
    label: '',
    showLabel: false,
    readOnly: true,
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: rw(context, 20), vertical: rh(context, 8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'purpose_visit'.tr,
              style: TextStyle(fontSize: rfs(context, 18), fontWeight: FontWeight.bold),
            ),
          ),
          vSpace(context, 16),
          _label(context, 'pic_host'.tr),
          _readOnlyField(ctrl.picHostController),
          _label(context, 'agenda'.tr),
          _readOnlyField(ctrl.agendaController),
          _label(context, 'destination'.tr),
          _readOnlyField(ctrl.destinationController),
          _label(context, 'visit_start'.tr),
          GestureDetector(
            onTap: () => ctrl.pickDateTime(context, isStart: true),
            child: AbsorbPointer(
              child: CustomTextField(
                controller: ctrl.visitStartController,
                label: '',
                showLabel: false,
                readOnly: true,
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.primary500,
                  size: rw(context, 18),
                ),
              ),
            ),
          ),
          _label(context, 'visit_end'.tr),
          GestureDetector(
            onTap: () => ctrl.pickDateTime(context, isStart: false),
            child: AbsorbPointer(
              child: CustomTextField(
                controller: ctrl.visitEndController,
                label: '',
                showLabel: false,
                readOnly: true,
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.primary500,
                  size: rw(context, 18),
                ),
              ),
            ),
          ),
          vSpace(context, 20),
        ],
      ),
    );
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
                'vehicle_information'.tr,
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
                text: 'are_you_driving'.tr,
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
                        'vehicle_plate'.tr,
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
              _requiredLabel(context, 'vehicle_type'.tr),
              () {
                const labelMap = {
                  'vehicle_car': 'vehicle_car',
                  'vehicle_bus': 'vehicle_bus',
                  'vehicle_motor': 'vehicle_motor',
                  // Legacy English keys from old API format
                  'Car': 'vehicle_car',
                  'Bus': 'vehicle_bus',
                  'Motor': 'vehicle_motor',
                };
                const apiKeys = ['vehicle_car', 'vehicle_bus', 'vehicle_motor'];
                final normalizedValue =
                    labelMap.containsKey(ctrl.vehicleType.value)
                    ? (apiKeys.contains(ctrl.vehicleType.value)
                          ? ctrl.vehicleType.value
                          : labelMap[ctrl.vehicleType.value]!)
                    : 'vehicle_car';

                return DropdownButton2<String>(
                  isExpanded: true,
                  value: normalizedValue,
                  items: apiKeys
                      .map(
                        (key) => DropdownMenuItem<String>(
                          value: key,
                          child: Text(key.tr),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) ctrl.vehicleType.value = v;
                  },
                  buttonStyleData: ButtonStyleData(
                    height: rh(context, 50),
                    padding: EdgeInsets.only(left: 0, right: rw(context, 12)),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
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
                );
              }(),
              _requiredLabel(context, 'vehicle_plate'.tr),
              CustomTextField(
                controller: ctrl.vehiclePlateController,
                label: '',
                showLabel: false,
                hintText: 'B 1234 XX',
                errorText: ctrl.fieldErrors['vehiclePlate'],
                onChanged: (v) =>
                    ctrl.validateField('vehiclePlate', v, 'vehicle_plate'.tr),
              ),
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
      padding: EdgeInsets.symmetric(horizontal: rw(context, 20), vertical: rh(context, 8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'face_photo_title'.tr,
              style: TextStyle(fontSize: rfs(context, 18), fontWeight: FontWeight.bold),
            ),
          ),
          vSpace(context, 16),
          GestureDetector(
            onTap: () {
              Get.bottomSheet(
                Container(
                  color: Colors.white,
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: Text('source_camera'.tr),
                        onTap: () {
                          Get.back();
                          ctrl.pickSelfie(ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo),
                        title: Text('source_gallery'.tr),
                        onTap: () {
                          Get.back();
                          ctrl.pickSelfie(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              height: rh(context, 220),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                border: Border.all(color: AppColors.grey300, width: 1.5),
                borderRadius: BorderRadius.circular(rw(context, 8)),
              ),
              child: Obx(() {
                if (ctrl.isUploadingSelfie.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary500,
                    ),
                  );
                }
                if (ctrl.selfieImage.value != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(rw(context, 8)),
                    child: Image.file(
                      ctrl.selfieImage.value!,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: rw(context, 50),
                      color: AppColors.primary500,
                    ),
                    vSpace(context, 10),
                    Text(
                      'upload_file'.tr,
                      style: TextStyle(
                        color: AppColors.primary500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    vSpace(context, 4),
                    Text(
                      'upload_file_support'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: rfs(context, 12), color: Colors.grey),
                    ),
                  ],
                );
              }),
            ),
          ),
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
      padding: EdgeInsets.symmetric(horizontal: rw(context, 20), vertical: rh(context, 8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'upload_ktp'.tr,
              style: TextStyle(fontSize: rfs(context, 18), fontWeight: FontWeight.bold),
            ),
          ),
          vSpace(context, 16),
          GestureDetector(
            onTap: () {
              Get.bottomSheet(
                Container(
                  color: Colors.white,
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: Text('source_camera'.tr),
                        onTap: () {
                          Get.back();
                          ctrl.pickIdentity(ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo),
                        title: Text('source_gallery'.tr),
                        onTap: () {
                          Get.back();
                          ctrl.pickIdentity(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              height: rh(context, 220),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                border: Border.all(color: AppColors.grey300, width: 1.5),
                borderRadius: BorderRadius.circular(rw(context, 8)),
              ),
              child: Obx(() {
                if (ctrl.isUploadingIdentity.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary500,
                    ),
                  );
                }
                if (ctrl.identityImage.value != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(rw(context, 8)),
                    child: Image.file(
                      ctrl.identityImage.value!,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: rw(context, 50),
                      color: AppColors.primary500,
                    ),
                    vSpace(context, 10),
                    Text(
                      'upload_file'.tr,
                      style: TextStyle(
                        color: AppColors.primary500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    vSpace(context, 4),
                    Text(
                      'upload_file_support'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: rfs(context, 12), color: Colors.grey),
                    ),
                  ],
                );
              }),
            ),
          ),
          vSpace(context, 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 0: Who Fills the Form Page
// ─────────────────────────────────────────────────────────────

class _WhoFillStep extends StatelessWidget {
  final InformasiUmumController ctrl;
  const _WhoFillStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(rw(context, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          vSpace(context, 20),
          Center(
            child: Text(
              _localTr(
                'who_fill_title',
                'SIAPA YANG MENGISI FORMULIR INI?',
                'WHO FILL THIS FORM?',
              ),
              style: TextStyle(
                fontSize: rfs(context, 20),
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          vSpace(context, 8),
          Center(
            child: Text(
              _localTr(
                'who_fill_subtitle',
                'Silakan pilih siapa yang mengisi formulir pendaftaran ini.',
                'Please select who is completing this registration form.',
              ),
              style: TextStyle(fontSize: rfs(context, 14), color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
          vSpace(context, 40),
          Obx(() {
            final isSelf = ctrl.isSelfRegistered.value == true;
            final isOther = ctrl.isSelfRegistered.value == false;
            return Column(
              children: [
                // Yourself Option Card
                GestureDetector(
                  onTap: () {
                    ctrl.isSelfRegistered.value = true;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: EdgeInsets.all(rw(context, 20)),
                    decoration: BoxDecoration(
                      color: isSelf
                          ? AppColors.primary50.withOpacity(0.5)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(rw(context, 16)),
                      border: Border.all(
                        color: isSelf
                            ? AppColors.primary500
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelf
                              ? AppColors.primary500.withOpacity(0.08)
                              : Colors.black.withOpacity(0.02),
                          blurRadius: rw(context, 10),
                          offset: Offset(0, rh(context, 4)),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(rw(context, 12)),
                          decoration: BoxDecoration(
                            color: isSelf
                                ? AppColors.primary500
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            color: isSelf ? Colors.white : Colors.grey.shade600,
                            size: rw(context, 28),
                          ),
                        ),
                        hSpace(context, 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _localTr(
                                  'yourself_title',
                                  'DIRI SENDIRI',
                                  'YOURSELF',
                                ),
                                style: TextStyle(
                                  fontSize: rfs(context, 16),
                                  fontWeight: FontWeight.bold,
                                  color: isSelf
                                      ? AppColors.primary500
                                      : AppColors.grey900,
                                ),
                              ),
                              vSpace(context, 4),
                              Text(
                                _localTr(
                                  'yourself_subtitle',
                                  'Saya mendaftar untuk diri saya sendiri.',
                                  'I am registering for myself.',
                                ),
                                style: TextStyle(
                                  fontSize: rfs(context, 13),
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelf)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary500,
                            size: rw(context, 26),
                          ),
                      ],
                    ),
                  ),
                ),
                vSpace(context, 20),
                // Other Option Card
                GestureDetector(
                  onTap: () {
                    ctrl.isSelfRegistered.value = false;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: EdgeInsets.all(rw(context, 20)),
                    decoration: BoxDecoration(
                      color: isOther
                          ? AppColors.primary50.withOpacity(0.5)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(rw(context, 16)),
                      border: Border.all(
                        color: isOther
                            ? AppColors.primary500
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isOther
                              ? AppColors.primary500.withOpacity(0.08)
                              : Colors.black.withOpacity(0.02),
                          blurRadius: rw(context, 10),
                          offset: Offset(0, rh(context, 4)),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(rw(context, 12)),
                          decoration: BoxDecoration(
                            color: isOther
                                ? AppColors.primary500
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.people,
                            color: isOther
                                ? Colors.white
                                : Colors.grey.shade600,
                            size: rw(context, 28),
                          ),
                        ),
                        hSpace(context, 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _localTr('other_title', 'ORANG LAIN', 'OTHER'),
                                style: TextStyle(
                                  fontSize: rfs(context, 16),
                                  fontWeight: FontWeight.bold,
                                  color: isOther
                                      ? AppColors.primary500
                                      : AppColors.grey900,
                                ),
                              ),
                              vSpace(context, 4),
                              Text(
                                _localTr(
                                  'other_subtitle',
                                  'Saya mendaftar atas nama orang lain.',
                                  'I am registering on behalf of someone else.',
                                ),
                                style: TextStyle(
                                  fontSize: rfs(context, 13),
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isOther)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary500,
                            size: rw(context, 26),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 0.5: Other Form Filler Information Page
// ─────────────────────────────────────────────────────────────

class _StepOther extends StatelessWidget {
  final InformasiUmumController ctrl;
  const _StepOther({required this.ctrl});

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
                _localTr(
                  'filler_info_title',
                  'INFORMASI PENGISI FORMULIR',
                  'FORM FILLER INFORMATION',
                ),
                style: TextStyle(
                  fontSize: rfs(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            vSpace(context, 6),
            Center(
              child: Text(
                _localTr(
                  'filler_info_subtitle',
                  'Silakan isi detail data orang yang mengisi formulir pendaftaran ini.',
                  'Please fill in the details of the person completing this registration form.',
                ),
                style: TextStyle(fontSize: rfs(context, 13), color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
            vSpace(context, 16),
            _requiredLabel(context, 'fullname'.tr),
            CustomTextField(
              controller: ctrl.filledByNameController,
              label: '',
              showLabel: false,
              hintText: _localTr(
                'filler_name_hint',
                'Masukkan nama Anda',
                'Enter your name',
              ),
              errorText: ctrl.fieldErrors['filledByName'],
              onChanged: (v) =>
                  ctrl.validateField('filledByName', v, 'fullname'.tr),
            ),
            _requiredLabel(context, 'email'.tr),
            CustomTextField(
              controller: ctrl.filledByEmailController,
              label: '',
              showLabel: false,
              hintText: 'yourname@gmail.com',
              keyboardType: TextInputType.emailAddress,
              errorText: ctrl.fieldErrors['filledByEmail'],
              onChanged: (v) =>
                  ctrl.validateField('filledByEmail', v, 'email'.tr),
            ),
            _requiredLabel(context, 'phone'.tr),
            CustomTextField(
              controller: ctrl.filledByPhoneController,
              label: '',
              showLabel: false,
              hintText: '08xx xxxx xxxx',
              keyboardType: TextInputType.phone,
              errorText: ctrl.fieldErrors['filledByPhone'],
              onChanged: (v) =>
                  ctrl.validateField('filledByPhone', v, 'phone'.tr),
            ),
            _requiredLabel(context, 'relationship'.tr),
            DropdownButton2<String>(
              isExpanded: true,
              value: ctrl.filledByRelationship.value,
              hint: Text(
                _localTr(
                  'select_relationship',
                  'Pilih Hubungan',
                  'Select Relationship',
                ),
                style: TextStyle(color: Colors.grey.shade600, fontSize: rfs(context, 14)),
              ),
              items: ctrl.relationshipOptions
                  .map(
                    (key) =>
                        DropdownMenuItem<String>(value: key, child: Text(key)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  ctrl.filledByRelationship.value = v;
                  if (v != 'Other') {
                    ctrl.filledByRelationshipOtherController.clear();
                    ctrl.fieldErrors.remove('filledByRelationshipOther');
                  }
                }
              },
              buttonStyleData: ButtonStyleData(
                height: rh(context, 50),
                padding: EdgeInsets.only(left: 0, right: rw(context, 12)),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
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
            if (ctrl.filledByRelationship.value == 'Other') ...[
              vSpace(context, 10),
              CustomTextField(
                controller: ctrl.filledByRelationshipOtherController,
                label: _localTr(
                  'relationship_details_title',
                  'Detail Hubungan Lainnya',
                  'Other Relationship Details',
                ),
                hintText: _localTr(
                  'relationship_details_hint',
                  'Masukkan jenis hubungan (misal: Kurir)',
                  'Enter relationship type (e.g. Courier)',
                ),
                errorText: ctrl.fieldErrors['filledByRelationshipOther'],
                onChanged: (v) => ctrl.validateField(
                  'filledByRelationshipOther',
                  v,
                  _localTr(
                    'relationship_details_title',
                    'Detail Hubungan Lainnya',
                    'Other Relationship Details',
                  ),
                ),
              ),
            ],
            vSpace(context, 20),
          ],
        ),
      ),
    );
  }
}

extension DropdownButton2Responsive on EdgeInsets {
  MenuItemStyleData toMapMenuItemStyleData() {
    return MenuItemStyleData(padding: this);
  }
}
