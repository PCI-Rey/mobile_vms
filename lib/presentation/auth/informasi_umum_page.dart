// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'controller/informasi_umum_controller.dart';
import 'controller/language_controller.dart';
import '../../data/models/user_model.dart';
import '../../../core/core.dart';

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
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary500, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primary50,
                ),
                child: DropdownButton<String>(
                  value: isId ? 'id' : 'en',
                  underline: const SizedBox.shrink(),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: AppColors.primary500,
                  ),
                  isDense: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(
                        '🇬🇧 ENG',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'id',
                      child: Text(
                        '🇮🇩 ID',
                        style: TextStyle(
                          fontSize: 14,
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: const Color(0xFF00529C), // Senada dengan warna background logo BI/VMS.png
              child: Column(
                children: [
                  Image.asset('assets/images/VMS.png', height: 64),
                  const SizedBox(height: 6),
                  Text(
                    '${'invitation_code'.tr}: ${widget.invitationCode ?? "-"}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── PageView ─────────────────────────────────
            Expanded(
              child: PageView(
                controller: _ctrl.pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => _ctrl.currentPage.value = i,
                children: [
                  _Step1(ctrl: _ctrl),
                  _Step2(ctrl: _ctrl),
                  _Step3(ctrl: _ctrl),
                  _Step4(ctrl: _ctrl),
                  _Step5(ctrl: _ctrl),
                ],
              ),
            ),

            // ── Navigation Bar ────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Back button (fixed width)
                  SizedBox(
                    width: 80,
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
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),

                  // Dots indicator (flexible center)
                  Expanded(
                    child: Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _ctrl.currentPage.value == i
                                  ? AppColors.primary500
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Next / Submit button (fixed width)
                  SizedBox(
                    width: 110,
                    child: Obx(() {
                      if (_ctrl.isLoading.value) {
                        return const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      final isLast = _ctrl.currentPage.value == 4;
                      return ElevatedButton(
                        onPressed: isLast ? _ctrl.submit : _ctrl.nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          elevation: 0,
                        ),
                        child: Text(
                          isLast ? 'submit'.tr : 'next'.tr,
                          style: const TextStyle(fontSize: 13),
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

  Widget _requiredLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 4),
    child: RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 14,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'visitor_information'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _requiredLabel('fullname'.tr),
            CustomTextField(
              controller: ctrl.fullNameController,
              label: '',
              showLabel: false,
              hintText: 'nama_lengkap'.tr,
              errorText: ctrl.fieldErrors['fullname'],
              onChanged: (v) =>
                  ctrl.validateField('fullname', v, 'fullname'.tr),
            ),
            _requiredLabel('email'.tr),
            CustomTextField(
              controller: ctrl.emailController,
              label: '',
              showLabel: false,
              hintText: 'nama@email.com',
              keyboardType: TextInputType.emailAddress,
              errorText: ctrl.fieldErrors['email'],
              onChanged: (v) => ctrl.validateField('email', v, 'email'.tr),
            ),
            _requiredLabel('phone'.tr),
            CustomTextField(
              controller: ctrl.phoneController,
              label: '',
              showLabel: false,
              hintText: '08xx xxxx xxxx',
              keyboardType: TextInputType.phone,
              errorText: ctrl.fieldErrors['phone'],
              onChanged: (v) => ctrl.validateField('phone', v, 'phone'.tr),
            ),
            _requiredLabel('organization'.tr),
            CustomTextField(
              controller: ctrl.organizationController,
              label: '',
              showLabel: false,
              hintText: 'instansi_hint'.tr,
              errorText: ctrl.fieldErrors['organization'],
              onChanged: (v) =>
                  ctrl.validateField('organization', v, 'organization'.tr),
            ),
            _requiredLabel('identity_id'.tr),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _Step2 extends StatelessWidget {
  final InformasiUmumController ctrl;
  const _Step2({required this.ctrl});

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'purpose_visit'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          _label('pic_host'.tr),
          _readOnlyField(ctrl.picHostController),
          _label('agenda'.tr),
          _readOnlyField(ctrl.agendaController),
          _label('destination'.tr),
          _readOnlyField(ctrl.destinationController),
          _label('visit_start'.tr),
          _readOnlyField(ctrl.visitStartController),
          _label('visit_end'.tr),
          _readOnlyField(ctrl.visitEndController),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _Step3 extends StatelessWidget {
  final InformasiUmumController ctrl;
  const _Step3({required this.ctrl});

  Widget _requiredLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 4),
    child: RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 14,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'vehicle_information'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Are you driving?
            RichText(
              text: TextSpan(
                text: 'are_you_driving'.tr,
                style: const TextStyle(
                  fontSize: 14,
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
            const SizedBox(height: 4),
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
                const SizedBox(width: 16),
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
              _requiredLabel('vehicle_type'.tr),
              () {
                const labelMap = {
                  'vehicle_car': 'vehicle_car',
                  'vehicle_bus': 'vehicle_bus',
                  'vehicle_motor': 'vehicle_motor',
                  'vehicle_bicycle': 'vehicle_bicycle',
                  'vehicle_truck': 'vehicle_truck',
                  'vehicle_private_car': 'vehicle_private_car',
                  'vehicle_other': 'vehicle_other',
                  // Legacy English keys from old API format
                  'Car': 'vehicle_car',
                  'Bus': 'vehicle_bus',
                  'Motor': 'vehicle_motor',
                  'Bicycle': 'vehicle_bicycle',
                  'Truck': 'vehicle_truck',
                  'Private Car': 'vehicle_private_car',
                  'Other': 'vehicle_other',
                };
                const apiKeys = [
                  'vehicle_car',
                  'vehicle_bus',
                  'vehicle_motor',
                  'vehicle_bicycle',
                  'vehicle_truck',
                  'vehicle_private_car',
                  'vehicle_other',
                ];
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
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.grey300, width: 1.5),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 250,
                    offset: const Offset(0, -10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  underline: const SizedBox.shrink(),
                );
              }(),
              _requiredLabel('vehicle_plate'.tr),
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
            const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'face_photo_title'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
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
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                border: Border.all(color: AppColors.grey300, width: 1.5),
                borderRadius: BorderRadius.circular(8),
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
                    borderRadius: BorderRadius.circular(8),
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
                      size: 50,
                      color: AppColors.primary500,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'upload_file'.tr,
                      style: TextStyle(
                        color: AppColors.primary500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'upload_file_support'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'upload_ktp'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
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
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                border: Border.all(color: AppColors.grey300, width: 1.5),
                borderRadius: BorderRadius.circular(8),
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
                    borderRadius: BorderRadius.circular(8),
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
                      size: 50,
                      color: AppColors.primary500,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'upload_file'.tr,
                      style: TextStyle(
                        color: AppColors.primary500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'upload_file_support'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
