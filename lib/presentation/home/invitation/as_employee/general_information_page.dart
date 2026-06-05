import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../../../presentation/home/invitation/as_employee/invitation_list_page.dart';

enum Gender { male, female }

class VisitorData {
  String email;
  String phoneNumber;
  String organization;
  Gender gender;
  String nikKtp;

  VisitorData({
    this.email = '',
    this.phoneNumber = '',
    this.organization = '',
    this.gender = Gender.male,
    this.nikKtp = '',
  });

  bool get isValid {
    return email.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        organization.isNotEmpty &&
        nikKtp.isNotEmpty;
  }
}

class GeneralInformationPage extends StatefulWidget {
  const GeneralInformationPage({super.key});

  @override
  State<GeneralInformationPage> createState() => _GeneralInformationPageState();
}

class _GeneralInformationPageState extends State<GeneralInformationPage>
    with TickerProviderStateMixin {
  List<VisitorData> visitors = [VisitorData()];
  int selectedVisitorIndex = 0;
  bool isCollapsed = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();
  final TextEditingController nikController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVisitorData();
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    organizationController.dispose();
    nikController.dispose();
    super.dispose();
  }

  void _loadVisitorData() {
    final visitor = visitors[selectedVisitorIndex];
    emailController.text = visitor.email;
    phoneController.text = visitor.phoneNumber;
    organizationController.text = visitor.organization;
    nikController.text = visitor.nikKtp;
    setState(() {});
  }

  void _saveCurrentVisitorData() {
    visitors[selectedVisitorIndex] = VisitorData(
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      organization: organizationController.text.trim(),
      gender: visitors[selectedVisitorIndex].gender,
      nikKtp: nikController.text.trim(),
    );
  }

  void _addVisitor() {
    _saveCurrentVisitorData();
    setState(() {
      visitors.add(VisitorData());
      selectedVisitorIndex = visitors.length - 1;
    });
    _loadVisitorData();
  }

  void _removeVisitor(int index) {
    if (visitors.length > 1) {
      setState(() {
        visitors.removeAt(index);
        if (selectedVisitorIndex >= visitors.length) {
          selectedVisitorIndex = visitors.length - 1;
        } else if (selectedVisitorIndex > index) {
          selectedVisitorIndex--;
        }
      });
      _loadVisitorData();
    }
  }

  void _selectVisitor(int index) {
    _saveCurrentVisitorData();
    setState(() {
      selectedVisitorIndex = index;
    });
    _loadVisitorData();
  }

  bool _isFormValid() {
    return visitors.every((visitor) => visitor.isValid);
  }

  void _showRemoveConfirmation(int index) {
    if (visitors.length <= 1) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rw(context, 16)),
          ),
          title: const Text('Remove Visitor'),
          content: Text(
            'Are you sure you want to remove Visitor #${index + 1}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeVisitor(index);
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _toggleCollapse() {
    setState(() {
      isCollapsed = !isCollapsed;
    });
  }

  double _getStackHeight() {
    if (isCollapsed) {
      return rh(context, 80.0);
    } else {
      final maxHeight = MediaQuery.of(context).size.height * 0.4;
      final calculatedHeight = rh(context, 80) + (visitors.length - 1) * rh(context, 30.0);
      return calculatedHeight > maxHeight ? maxHeight : calculatedHeight;
    }
  }

  List<Widget> _buildVisitorCards() {
    return List.generate(visitors.length, (index) {
      final reverseIndex = visitors.length - 1 - index;
      final isSelected = selectedVisitorIndex == reverseIndex;
      final visitor = visitors[reverseIndex];

      double topOffset;
      double scaleOffset = 1.0;
      double opacityValue = 1.0;

      if (isCollapsed) {
        if (isSelected) {
          topOffset = 0;
        } else {
          topOffset = index * rh(context, 2.0);
          scaleOffset = 1.0 - (index * 0.02);
          opacityValue = index == 0 ? 0.8 : 0.0;
        }
      } else {
        topOffset = index * rh(context, 50.0);
      }

      return AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        left: 0,
        right: 0,
        top: topOffset,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: opacityValue,
          child: Transform.scale(
            scale: scaleOffset,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: rh(context, 80),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary500 : Colors.white,
                border: Border.all(
                  color: isSelected ? AppColors.primary500 : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(rw(context, 12)),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.3),
                      blurRadius: rw(context, 8),
                      offset: Offset(0, rh(context, 4)),
                    )
                  else
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.15),
                      blurRadius: rw(context, 6),
                      offset: Offset(0, rh(context, 3)),
                    ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectVisitor(reverseIndex),
                  borderRadius: BorderRadius.circular(rw(context, 12)),
                  child: Container(
                    padding: EdgeInsets.all(rw(context, 16)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Visitor #${reverseIndex + 1}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: rfs(context, 16),
                                    ),
                                  ),
                                  if (visitor.isValid) ...[
                                    hSpace(context, 8),
                                    Icon(
                                      Icons.check_circle,
                                      size: rw(context, 18),
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.green,
                                    ),
                                  ],
                                ],
                              ),
                              vSpace(context, 4),
                              Text(
                                visitor.email.isNotEmpty
                                    ? visitor.email
                                    : 'No email entered',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : Colors.grey[600],
                                  fontSize: rfs(context, 12),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        if (visitors.length > 1 && isSelected && !isCollapsed)
                          GestureDetector(
                            onTap: () => _showRemoveConfirmation(reverseIndex),
                            child: Container(
                              padding: EdgeInsets.all(rw(context, 6)),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(rw(context, 20)),
                              ),
                              child: Icon(
                                Icons.close,
                                size: rw(context, 16),
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildVisitorStack() {
    final stackHeight = _getStackHeight();
    final fullHeight = rh(context, 80) + (visitors.length - 1) * rh(context, 50.0);
    final needsScroll = fullHeight > stackHeight && !isCollapsed;

    if (!needsScroll) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: stackHeight,
        child: Stack(children: _buildVisitorCards()),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: stackHeight,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: fullHeight,
          child: Stack(children: _buildVisitorCards()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "General Information",
          style: TextStyle(
            color: Colors.black,
            fontSize: rfs(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: rw(context, 20), vertical: rh(context, 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Visitors',
                      style: TextStyle(
                        fontSize: rfs(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (visitors.length > 1)
                      GestureDetector(
                        onTap: _toggleCollapse,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: rw(context, 8),
                            vertical: rh(context, 4),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(rw(context, 12)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${visitors.length} visitors',
                                style: TextStyle(
                                  fontSize: rfs(context, 12),
                                  color: Colors.grey[600],
                                ),
                              ),
                              hSpace(context, 4),
                              Icon(
                                isCollapsed
                                    ? Icons.expand_more
                                    : Icons.expand_less,
                                size: rw(context, 16),
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                vSpace(context, 12),

                _buildVisitorStack(),

                vSpace(context, 16),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary500,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(rw(context, 12)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _addVisitor,
                      borderRadius: BorderRadius.circular(rw(context, 12)),
                      child: Container(
                        padding: EdgeInsets.all(rw(context, 16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              color: AppColors.primary500,
                              size: rw(context, 20),
                            ),
                            hSpace(context, 8),
                            Text(
                              'Add Visitor',
                              style: TextStyle(
                                color: AppColors.primary500,
                                fontWeight: FontWeight.w600,
                                fontSize: rfs(context, 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                if (visitors.length > 1)
                  Padding(
                    padding: EdgeInsets.only(top: rh(context, 8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: rw(context, 16),
                          color: Colors.grey[400],
                        ),
                        hSpace(context, 4),
                        Text(
                          'Klik icon ',
                          style: TextStyle(
                            fontSize: rfs(context, 12),
                            color: Colors.grey[500],
                          ),
                        ),
                        Icon(
                          isCollapsed ? Icons.expand_more : Icons.expand_less,
                          size: rw(context, 14),
                          color: Colors.grey[500],
                        ),
                        Text(
                          isCollapsed ? ' untuk melihat semua' : ' untuk sembunyikan',
                          style: TextStyle(
                            fontSize: rfs(context, 12),
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: rw(context, 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 12),
                      vertical: rh(context, 8),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(rw(context, 8)),
                    ),
                    child: Text(
                      'Editing Visitor #${selectedVisitorIndex + 1}',
                      style: TextStyle(
                        color: AppColors.primary500,
                        fontWeight: FontWeight.w600,
                        fontSize: rfs(context, 14),
                      ),
                    ),
                  ),

                  vSpace(context, 20),

                  CustomTextField(
                    controller: emailController,
                    label: 'Email',
                    hintText: 'user@mail.com',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => _saveCurrentVisitorData(),
                  ),

                  CustomTextField(
                    controller: phoneController,
                    label: 'Nomor HP',
                    hintText: '081234567899',
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => _saveCurrentVisitorData(),
                  ),

                  CustomTextField(
                    controller: organizationController,
                    label: 'Organisasi',
                    hintText: 'organisasi',
                    onChanged: (value) => _saveCurrentVisitorData(),
                  ),

                  vSpace(context, 20),

                  Text(
                    'Jenis Kelamin',
                    style: TextStyle(fontSize: rfs(context, 14), fontWeight: FontWeight.w600),
                  ),
                  vSpace(context, 12),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              visitors[selectedVisitorIndex].gender =
                                  Gender.male;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: rh(context, 12)),
                            decoration: BoxDecoration(
                              color:
                                  visitors[selectedVisitorIndex].gender ==
                                          Gender.male
                                      ? AppColors.primary500
                                      : Colors.white,
                              border: Border.all(
                                color:
                                    visitors[selectedVisitorIndex].gender ==
                                            Gender.male
                                        ? AppColors.primary500
                                        : Colors.grey[300]!,
                              ),
                              borderRadius: BorderRadius.circular(rw(context, 8)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.male,
                                  color:
                                      visitors[selectedVisitorIndex].gender ==
                                              Gender.male
                                          ? Colors.white
                                          : Colors.grey[600],
                                  size: rw(context, 20),
                                ),
                                hSpace(context, 8),
                                Text(
                                  'Laki-laki',
                                  style: TextStyle(
                                    color:
                                        visitors[selectedVisitorIndex].gender ==
                                                Gender.male
                                            ? Colors.white
                                            : Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      hSpace(context, 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              visitors[selectedVisitorIndex].gender =
                                  Gender.female;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: rh(context, 12)),
                            decoration: BoxDecoration(
                              color:
                                  visitors[selectedVisitorIndex].gender ==
                                          Gender.female
                                      ? Colors.pink
                                      : Colors.white,
                              border: Border.all(
                                color:
                                    visitors[selectedVisitorIndex].gender ==
                                            Gender.female
                                        ? Colors.pink
                                        : Colors.grey[300]!,
                              ),
                              borderRadius: BorderRadius.circular(rw(context, 8)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.female,
                                  color:
                                      visitors[selectedVisitorIndex].gender ==
                                              Gender.female
                                          ? Colors.white
                                          : Colors.grey[600],
                                  size: rw(context, 20),
                                ),
                                hSpace(context, 8),
                                Text(
                                  'Perempuan',
                                  style: TextStyle(
                                    color:
                                        visitors[selectedVisitorIndex].gender ==
                                                Gender.female
                                            ? Colors.white
                                            : Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  CustomTextField(
                    controller: nikController,
                    label: 'NIK KTP',
                    hintText: '1568900944059883467',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _saveCurrentVisitorData(),
                  ),

                  vSpace(context, 40),
                ],
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.all(rw(context, 20)),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: rw(context, 3),
                  offset: Offset(0, rh(context, -1)),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Button.outlined(
                    onPressed: () => Navigator.pop(context),
                    label: 'Back',
                    height: rh(context, 50),
                    borderRadius: rw(context, 8),
                  ),
                ),

                hSpace(context, 16),

                Expanded(
                  child: Button.filled(
                    onPressed: () {
                      _saveCurrentVisitorData();
                      if (_isFormValid()) {
                        _showSuccessDialog(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please complete all visitor information',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    label: 'Submit',
                    height: rh(context, 50),
                    borderRadius: rw(context, 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rw(context, 16)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Assets.images.success.image(height: rh(context, 50)),
              vSpace(context, 16),
              Text(
                'Invitation\nSuccessfully Sent!',
                style: TextStyles.headline5,
                textAlign: TextAlign.center,
              ),
              vSpace(context, 8),
              Text(
                'Your guest has been added and will receive a confirmation email with a QR Access Pass for check-in.',
                style: TextStyles.caption,
                textAlign: TextAlign.center,
              ),
              vSpace(context, 24),
              Button.filled(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => InvitationListPage()),
                  );
                },
                label: 'OK',
              ),
            ],
          ),
        );
      },
    );
  }
}