import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/datasources/hive_service.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../controller/invitation_controller.dart';

import '../../../../data/models/access_pass_model.dart';

class CreateQuickAccessDialog extends StatefulWidget {
  final AccessPassModel? duplicateData;
  final List<Map<String, dynamic>>? subVisitors;
  const CreateQuickAccessDialog({
    super.key,
    this.duplicateData,
    this.subVisitors,
  });

  @override
  State<CreateQuickAccessDialog> createState() =>
      _CreateQuickAccessDialogState();
}

class _CreateQuickAccessDialogState extends State<CreateQuickAccessDialog> {
  final controller = Get.find<InvitationController>();
  final HiveService _hive = HiveService();
  final _formKey = GlobalKey<FormState>();

  // Form Fields
  String? selectedProviderId;
  String? selectedRecipientMode; // 'self' or 'others'
  String? selectedHostId;
  String? selectedSiteId;
  int? selectedDuration;

  final receiverNameCtrl = TextEditingController();
  final receiverEmailCtrl = TextEditingController();
  final receiverPhoneCtrl = TextEditingController();

  final courierNameCtrl = TextEditingController();
  final courierEmailCtrl = TextEditingController();
  final courierPhoneCtrl = TextEditingController();
  final vehiclePlateCtrl = TextEditingController();

  bool isSubmitting = false;
  bool _success = false;
  Map<String, dynamic>? selectedProvider;
  bool showVehiclePlate = false;

  @override
  void initState() {
    super.initState();
    receiverNameCtrl.addListener(_onTextChanged);
    receiverEmailCtrl.addListener(_onTextChanged);
    receiverPhoneCtrl.addListener(_onTextChanged);
    courierNameCtrl.addListener(_onTextChanged);
    courierPhoneCtrl.addListener(_onTextChanged);
    vehiclePlateCtrl.addListener(_onTextChanged);

    if (widget.duplicateData != null) {
      final model = widget.duplicateData!;
      
      // 1. Recipient Mode
      String recName = model.receiverName;
      String recEmail = model.receiverEmail;
      String recPhone = model.receiverPhone;

      if (widget.subVisitors != null && widget.subVisitors!.isNotEmpty) {
        final sub = widget.subVisitors!.first;
        final subName = sub['receiver_name']?.toString() ?? '';
        final subEmail = sub['receiver_email']?.toString() ?? '';
        final subPhone = sub['receiver_phone']?.toString() ?? '';
        if (recName.isEmpty) recName = subName;
        if (recEmail.isEmpty) recEmail = subEmail;
        if (recPhone.isEmpty) recPhone = subPhone;
      }

      final user = _hive.getUser();
      final userEmail = (user?.email ?? '').toLowerCase().trim();
      final userFullname = (user?.fullname ?? '').toLowerCase().trim();
      final recNameLower = recName.toLowerCase().trim();
      final recEmailLower = recEmail.toLowerCase().trim();

      bool isSelf = model.isReceiverSelf;
      if (!isSelf) {
        if (recEmailLower.isNotEmpty && recEmailLower == userEmail) {
          if (recNameLower.isEmpty || recNameLower == userFullname) {
            isSelf = true;
          }
        } else if (recNameLower.isNotEmpty && recNameLower == userFullname) {
          isSelf = true;
        } else if (recNameLower.isEmpty && recEmailLower.isEmpty && recPhone.isEmpty) {
          isSelf = true;
        }
      }

      if (isSelf) {
        selectedRecipientMode = 'self';
      } else {
        selectedRecipientMode = 'others';
        receiverNameCtrl.text = recName;
        receiverEmailCtrl.text = recEmail;
        receiverPhoneCtrl.text = recPhone;
      }

      // 2. Visitor Provider
      final providers = controller.visitorProviders
          .where((p) => p['active'] == true && p['is_quick_access'] == true)
          .toList();

      String? matchedProviderId;
      if (widget.subVisitors != null && widget.subVisitors!.isNotEmpty) {
        final sub = widget.subVisitors!.first;
        matchedProviderId = sub['visitor_provider_id']?.toString();
      }

      Map<String, dynamic>? matchedProvider;
      if (matchedProviderId != null && matchedProviderId.isNotEmpty) {
        for (final p in providers) {
          if (p['id']?.toString() == matchedProviderId) {
            matchedProvider = p;
            break;
          }
        }
      }

      if (matchedProvider == null && model.visitorTypeId.isNotEmpty) {
        for (final p in providers) {
          if (p['id']?.toString() == model.visitorTypeId) {
            matchedProvider = p;
            break;
          }
        }
      }

      if (matchedProvider == null && model.visitorTypeName.isNotEmpty) {
        for (final p in providers) {
          if (p['name']?.toString().toLowerCase() == model.visitorTypeName.toLowerCase()) {
            matchedProvider = p;
            break;
          }
        }
      }

      if (matchedProvider != null) {
        selectedProviderId = matchedProvider['id']?.toString();
        selectedProvider = matchedProvider;
        showVehiclePlate =
            matchedProvider['need_plate_number'] == true ||
            matchedProvider['support_vehicle'] == true;
      }

      // 3. Host ID
      if (model.host.isNotEmpty) {
        selectedHostId = model.host;
      }

      // 4. Site ID (Drop Point) - intentionally ignored for duplicate to let auto-selection code select a valid Drop Point

      // 5. Courier/Visitor info
      if (widget.subVisitors != null && widget.subVisitors!.isNotEmpty) {
        final sub = widget.subVisitors!.first;
        courierNameCtrl.text = sub['visitor_name']?.toString() ?? model.visitorName;
        final emailVal = sub['visitor_email']?.toString() ?? model.visitorEmail;
        if (emailVal.isNotEmpty && emailVal != 'courier-no@required.com') {
          courierEmailCtrl.text = emailVal;
        }
        courierPhoneCtrl.text = sub['visitor_phone']?.toString() ?? model.visitorPhone;
        // Pre-fill vehicle plate from sub-visitor if present
        vehiclePlateCtrl.text = sub['vehicle_plate_number']?.toString() ?? model.vehiclePlateNumber;
      } else {
        courierNameCtrl.text = model.visitorName;
        if (model.visitorEmail.isNotEmpty && model.visitorEmail != 'courier-no@required.com') {
          courierEmailCtrl.text = model.visitorEmail;
        }
        courierPhoneCtrl.text = model.visitorPhone;
        vehiclePlateCtrl.text = model.vehiclePlateNumber;
      }

      // 6. Duration
      final differenceMinutes = model.visitorPeriodEnd.difference(model.visitorPeriodStart).inMinutes;
      final durationOptions = [10, 15, 30, 60, 120];
      if (durationOptions.contains(differenceMinutes)) {
        selectedDuration = differenceMinutes;
      } else if (differenceMinutes > 0) {
        int closest = durationOptions.first;
        int minDiff = (differenceMinutes - closest).abs();
        for (final opt in durationOptions) {
          final diff = (differenceMinutes - opt).abs();
          if (diff < minDiff) {
            minDiff = diff;
            closest = opt;
          }
        }
        selectedDuration = closest;
      } else {
        selectedDuration = 30;
      }
    }
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _updateVehiclePlateVisibility() {
    if (selectedProvider != null) {
      setState(() {
        showVehiclePlate =
            selectedProvider!['need_plate_number'] == true ||
            selectedProvider!['support_vehicle'] == true;
      });
    }
  }

  @override
  void dispose() {
    receiverNameCtrl.removeListener(_onTextChanged);
    receiverEmailCtrl.removeListener(_onTextChanged);
    receiverPhoneCtrl.removeListener(_onTextChanged);
    courierNameCtrl.removeListener(_onTextChanged);
    courierPhoneCtrl.removeListener(_onTextChanged);
    vehiclePlateCtrl.removeListener(_onTextChanged);

    receiverNameCtrl.dispose();
    receiverEmailCtrl.dispose();
    receiverPhoneCtrl.dispose();
    courierNameCtrl.dispose();
    courierEmailCtrl.dispose();
    courierPhoneCtrl.dispose();
    vehiclePlateCtrl.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final user = _hive.getUser();
    final bool isUserEmp = user?.roleAccess?.toLowerCase() == 'employee';

    if (selectedRecipientMode == null) return false;
    if (selectedProviderId == null) return false;

    if (selectedRecipientMode == 'others') {
      if (receiverNameCtrl.text.trim().isEmpty) return false;
      if (receiverEmailCtrl.text.trim().isEmpty) return false;
      if (receiverPhoneCtrl.text.trim().isEmpty) return false;
    }

    if (!isUserEmp) {
      if (selectedHostId == null) return false;
    }

    final validSites = controller.sites
        .where((site) => site['name']?.toString().toLowerCase() == 'drop point')
        .map((site) => site['id']?.toString())
        .toList();
    if (selectedSiteId == null || !validSites.contains(selectedSiteId)) return false;

    if (courierNameCtrl.text.trim().isEmpty) return false;
    if (courierPhoneCtrl.text.trim().isEmpty) return false;

    if (showVehiclePlate) {
      if (vehiclePlateCtrl.text.trim().isEmpty) return false;
    }

    if (selectedDuration == null) return false;

    return true;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedProviderId == null) {
      Get.snackbar(
        'Required',
        'Please select a Visitor Provider',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(rw(context, 12)),
      );
      return;
    }

    if (selectedSiteId == null) {
      Get.snackbar(
        'Required',
        'Please select a Destination',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(rw(context, 12)),
      );
      return;
    }

    if (selectedDuration == null) {
      Get.snackbar(
        'Required',
        'Please select a Duration',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(rw(context, 12)),
      );
      return;
    }

    final user = _hive.getUser();
    if (user == null) return;

    // Determine Host ID
    final bool isUserEmp = user.roleAccess?.toLowerCase() == 'employee';
    String? hostId = isUserEmp ? user.id : selectedHostId;

    if (hostId == null) {
      Get.snackbar(
        'Required',
        'Please select a Host',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(rw(context, 12)),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final bool isSelf = selectedRecipientMode == 'self';
      final Map<String, dynamic> body = {
        "visitor_provider_id": selectedProviderId,
        "tz": "Asia/Jakarta",
        "is_receiver_self": isSelf,
        "duration": selectedDuration,
        "site_id": selectedSiteId,
        "host_id": hostId,
        "visitor_name": courierNameCtrl.text.trim(),
        "visitor_email": courierEmailCtrl.text.trim().isEmpty
            ? "courier-no@required.com"
            : courierEmailCtrl.text.trim(),
        "vehicle_plate_number": showVehiclePlate ? vehiclePlateCtrl.text.trim() : "",
      };

      if (isSelf) {
        body["visitor_phone"] = courierPhoneCtrl.text.trim();
      } else {
        body["receiver_name"] = receiverNameCtrl.text.trim();
        body["receiver_phone"] = receiverPhoneCtrl.text.trim();
        body["receiver_email"] = receiverEmailCtrl.text.trim();
        body["visitor_phone"] = courierPhoneCtrl.text.trim();
      }

      final bool success = await controller.createQuickAccessAction(body);

      if (!mounted) return;

      if (success) {
        setState(() => _success = true);
        if (widget.duplicateData == null) {
          Get.snackbar(
            'Success',
            'Quick Access Visit created successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: EdgeInsets.all(rw(context, 12)),
          );
        }
        Navigator.pop(context, true);
      } else {
        Get.snackbar(
          'Failed',
          'Failed to create visit',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(rw(context, 12)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(rw(context, 12)),
        duration: const Duration(seconds: 4),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  bool _hasChanges() {
    return selectedProviderId != null ||
        selectedRecipientMode != null ||
        selectedHostId != null ||
        selectedSiteId != null ||
        selectedDuration != null ||
        receiverNameCtrl.text.isNotEmpty ||
        receiverEmailCtrl.text.isNotEmpty ||
        receiverPhoneCtrl.text.isNotEmpty ||
        courierNameCtrl.text.isNotEmpty ||
        courierEmailCtrl.text.isNotEmpty ||
        courierPhoneCtrl.text.isNotEmpty ||
        vehiclePlateCtrl.text.isNotEmpty;
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
    final user = _hive.getUser();
    final bool isUserEmp = user?.roleAccess?.toLowerCase() == 'employee';

    // Filter active quick access providers
    final providers = controller.visitorProviders
        .where((p) => p['active'] == true && p['is_quick_access'] == true)
        .toList();

    final providerItems = providers
        .map((p) => {"id": p['id'].toString(), "name": p['name'].toString()})
        .toList();

    final recipientItems = [
      {"id": "self", "name": "Self"},
      {"id": "others", "name": "Others"},
    ];

    final durationItems = [
      {"id": "10", "name": "10 Minutes"},
      {"id": "15", "name": "15 Minutes"},
      {"id": "30", "name": "30 Minutes"},
      {"id": "60", "name": "60 Minutes"},
      {"id": "120", "name": "120 Minutes"},
    ];

    return PopScope(
      canPop: _success,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_success && mounted) {
          Navigator.of(context).pop(true);
          return;
        }
        final navigator = Navigator.of(context);
        final shouldExit = await _showExitConfirmation();
        if (shouldExit && mounted) {
          navigator.pop();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rw(context, 16)),
        ),
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(
          horizontal: rw(context, 16),
          vertical: rh(context, 24),
        ),
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      rw(context, 8),
                      rh(context, 20),
                      rw(context, 8),
                      rh(context, 10),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Centered title
                        Center(
                          child: Text(
                            'Quick Access',
                            style: TextStyle(
                              fontSize: rfs(context, 18),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        // Close button aligned to the right
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () async {
                              final navigator = Navigator.of(context);
                              if (await _showExitConfirmation()) {
                                if (mounted) navigator.pop();
                              }
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey.shade600,
                              size: rw(context, 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                // Content Area
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(rw(context, 20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Recipient
                        _buildRequiredLabel(
                          context,
                          'Recipient',
                          hasInfo: true,
                        ),
                        _buildDropdown(
                          hint: 'Select Recipient',
                          value: selectedRecipientMode,
                          items: recipientItems,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectedRecipientMode = val);
                            }
                          },
                        ),
                        vSpace(context, 16),

                        if (selectedRecipientMode != null) ...[
                          // Visitor Provider
                          _buildRequiredLabel(
                            context,
                            'Visitor Provider',
                            hasInfo: true,
                          ),
                          _buildDropdown(
                            hint: 'Select Visitor Provider',
                            value: selectedProviderId,
                            items: providerItems,
                            onChanged: (val) {
                              setState(() {
                                selectedProviderId = val;
                                selectedProvider = providers.firstWhereOrNull(
                                  (p) => p['id']?.toString() == val,
                                );
                                _updateVehiclePlateVisibility();
                              });
                            },
                          ),
                          vSpace(context, 16),

                          // Receiver Info (Conditional on Others)
                          if (selectedRecipientMode == 'others') ...[
                            _buildRequiredLabel(context, 'Receiver Name'),
                            _buildTextField(
                              controller: receiverNameCtrl,
                              hintText: 'Enter receiver name',
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Receiver name is required';
                                }
                                return null;
                              },
                            ),
                            vSpace(context, 16),
                            _buildRequiredLabel(context, 'Receiver Email'),
                            _buildTextField(
                              controller: receiverEmailCtrl,
                              hintText: 'Enter receiver email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Receiver email is required';
                                }
                                if (!GetUtils.isEmail(val.trim())) {
                                  return 'Invalid email address';
                                }
                                return null;
                              },
                            ),
                            vSpace(context, 16),
                            _buildRequiredLabel(context, 'Receiver Phone'),
                            _buildTextField(
                              controller: receiverPhoneCtrl,
                              hintText: 'Enter receiver phone number',
                              keyboardType: TextInputType.phone,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Receiver phone number is required';
                                }
                                return null;
                              },
                            ),
                            vSpace(context, 16),
                          ],

                          // Host Selection (Conditional on operator role)
                          if (!isUserEmp) ...[
                            _buildRequiredLabel(context, 'Host'),
                            _buildDropdown(
                              hint: 'Select Host',
                              value: selectedHostId,
                              items: controller.hosts
                                  .map(
                                    (h) => {
                                      "id": h['id'].toString(),
                                      "name": h['name'].toString(),
                                    },
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(() => selectedHostId = val);
                              },
                            ),
                            vSpace(context, 16),
                          ],

                          // Drop Point
                          _buildRequiredLabel(context, 'Destination'),
                          vSpace(context, 8),
                          _buildDropPointsGrid(),
                          vSpace(context, 16),

                          // Courier Info heading
                          Text(
                            'Courier Information',
                            style: TextStyle(
                              fontSize: rfs(context, 14),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          vSpace(context, 12),

                          _buildRequiredLabel(context, 'Courier Name'),
                          _buildTextField(
                            controller: courierNameCtrl,
                            hintText: 'Enter courier name',
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Courier name is required';
                              }
                              return null;
                            },
                          ),
                          vSpace(context, 16),

                          _buildLabel(context, 'Courier Email (Optional)'),
                          _buildTextField(
                            controller: courierEmailCtrl,
                            hintText: 'Enter courier email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val != null &&
                                  val.trim().isNotEmpty &&
                                  !GetUtils.isEmail(val.trim())) {
                                return 'Invalid email address';
                              }
                              return null;
                            },
                          ),
                          vSpace(context, 16),

                          _buildRequiredLabel(context, 'Courier Phone'),
                          _buildTextField(
                            controller: courierPhoneCtrl,
                            hintText: 'Enter courier phone',
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Courier phone number is required';
                              }
                              return null;
                            },
                          ),
                          vSpace(context, 16),

                          // Vehicle Plate Number
                          if (showVehiclePlate) ...[
                            _buildRequiredLabel(
                              context,
                              'Vehicle Plate Number',
                            ),
                            _buildTextField(
                              controller: vehiclePlateCtrl,
                              hintText: 'Enter plate number (e.g. AB77281)',
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Vehicle plate number is required';
                                }
                                return null;
                              },
                            ),
                          ] else ...[
                            _buildLabel(context, 'Vehicle Plate Number'),
                            _buildTextField(
                              controller: TextEditingController(
                                text: selectedProviderId == null
                                    ? 'Please Select Visitor Provider First'
                                    : 'Not Supported',
                              ),
                              hintText: '',
                              readOnly: true,
                            ),
                          ],
                          vSpace(context, 16),

                          // Duration
                          _buildRequiredLabel(context, 'Duration'),
                          _buildDropdown(
                            hint: 'Select Duration',
                            value: selectedDuration?.toString(),
                            items: durationItems,
                            onChanged: (val) {
                              if (val != null) {
                                setState(
                                  () => selectedDuration = int.parse(val),
                                );
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Footer / Submit Button
                if (selectedRecipientMode != null) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 20),
                      vertical: rh(context, 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005596),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: rw(context, 24),
                              vertical: rh(context, 12),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                rw(context, 8),
                              ),
                            ),
                            elevation: 0,
                          ),
                          onPressed: (isSubmitting || !_isFormValid) ? null : _submit,
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: rfs(context, 13),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Loading Overlay
          if (isSubmitting)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(rw(context, 16)),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    ),
  );
}

  // --- Sub-widgets builder ---

  Widget _buildRequiredLabel(
    BuildContext context,
    String label, {
    bool hasInfo = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 6.0)),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: rfs(context, 13),
              color: const Color(0xFF334155),
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
          if (hasInfo) ...[
            hSpace(context, 4),
            Icon(
              Icons.info_outline,
              size: rw(context, 14),
              color: Colors.grey.shade400,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: rh(context, 6.0)),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: rfs(context, 13),
          color: const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: TextStyle(
        fontSize: rfs(context, 13),
        color: readOnly ? Colors.grey.shade600 : Colors.black,
      ),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey, fontSize: rfs(context, 13)),
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
          borderSide: const BorderSide(color: Color(0xFF005596), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rw(context, 10)),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rw(context, 10)),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<Map<String, dynamic>> items,
    required Function(String?) onChanged,
  }) {
    String? selectedName;
    if (value != null) {
      Map<String, dynamic>? selectedItem;
      for (var i in items) {
        if (i['id'].toString() == value) {
          selectedItem = i;
          break;
        }
      }
      selectedName = selectedItem?['name'];
    }

    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: selectedName),
      style: TextStyle(fontSize: rfs(context, 13)),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey, fontSize: rfs(context, 13)),
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
          borderSide: const BorderSide(color: Color(0xFF005596), width: 1.5),
        ),
        suffixIcon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.grey,
        ),
      ),
      onTap: () => _showSelectionBottomSheet(hint, items, value, onChanged),
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(rw(context, 20)),
        ),
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
                  color: const Color(0xFF1E293B),
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
            vSpace(context, 16),
          ],
        );
      },
    );
  }

  Widget _buildDropPointsGrid() {
    final sites = controller.sites
        .where((site) => site['name']?.toString().toLowerCase() == 'drop point')
        .toList();

    if (sites.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: rh(context, 8)),
        child: Text(
          'No Destination available',
          style: TextStyle(color: Colors.grey, fontSize: rfs(context, 12)),
        ),
      );
    }

    // Auto-select "Drop Point" if there is exactly one matching site and selectedSiteId is not set
    if (selectedSiteId == null && sites.isNotEmpty) {
      final dropPointId = sites.first['id']?.toString();
      if (dropPointId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && selectedSiteId == null) {
            setState(() {
              selectedSiteId = dropPointId;
            });
          }
        });
      }
    }

    return Wrap(
      spacing: rw(context, 8),
      runSpacing: rh(context, 8),
      children: sites.map((site) {
        final siteId = site['id']?.toString();
        final siteName = site['name']?.toString() ?? '';
        final isSelected = selectedSiteId == siteId;

        return GestureDetector(
          onTap: () {
            setState(() => selectedSiteId = siteId);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: rw(context, 16),
              vertical: rh(context, 10),
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF005596).withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(rw(context, 8)),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF005596)
                    : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              siteName,
              style: TextStyle(
                fontSize: rfs(context, 12),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF005596)
                    : const Color(0xFF475569),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
