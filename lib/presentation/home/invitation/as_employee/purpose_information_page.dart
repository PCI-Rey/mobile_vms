import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../../../presentation/home/invitation/as_employee/general_information_page.dart';

class PurposeInformationPage extends StatefulWidget {
  final String? selectedPurpose;

  const PurposeInformationPage({super.key, this.selectedPurpose});

  @override
  State<PurposeInformationPage> createState() => _PurposeInformationPageState();
}

class _PurposeInformationPageState extends State<PurposeInformationPage> {
  final TextEditingController picHostController = TextEditingController();
  final TextEditingController visitTimeController = TextEditingController();

  String? selectedDestination;

  // List of destinations for the searchable dropdown
  final List<String> destinations = [
    'Gedung HQ',
    'Gedung Operasional',
    'Gedung IT',
    'Gedung A',
    'Gedung B',
    'Gedung C',
    'Meeting Room A',
    'Meeting Room B',
    'Meeting Room C',
    'Conference Room 1',
    'Conference Room 2',
    'Cafeteria',
    'Reception Area',
    'Training Room',
    'Auditorium',
    'Laboratory',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    picHostController.dispose();
    visitTimeController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return picHostController.text.isNotEmpty &&
        selectedDestination != null &&
        visitTimeController.text.isNotEmpty;
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
          "Purpose Information",
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
          // Form Section
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(rw(context, 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PIC/Host Field
                  CustomTextField(
                    controller: picHostController,
                    label: 'PIC/Host',
                    hintText: 'Enter PIC or Host name',
                    onChanged: (value) => setState(() {}),
                  ),

                  vSpace(context, 20),

                  // Destination Field - Using SearchableDropdown
                  SearchableDropdown(
                    value: selectedDestination,
                    items: destinations,
                    hintText: 'Search and select destination',
                    labelText: 'Destination',
                    onChanged: (value) {
                      setState(() {
                        selectedDestination = value;
                      });
                    },
                  ),

                  vSpace(context, 20),

                  // Visit Time Field
                  CustomTextField(
                    controller: visitTimeController,
                    label: 'Visit Time',
                    hintText: 'date range & time',
                    suffixIconData: Icons.access_time,
                    readOnly: true,
                    onTapSuffixIcon: () => _showDateTimePicker(),
                    onChanged: (value) => setState(() {}),
                  ),

                  vSpace(context, 40),
                ],
              ),
            ),
          ),

          // Bottom Buttons
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
                // Back Button
                Expanded(
                  child: Button.outlined(
                    onPressed: () => Navigator.pop(context),
                    label: 'Back',
                    height: rh(context, 50),
                    borderRadius: rw(context, 8),
                  ),
                ),

                hSpace(context, 16),

                // Next Button
                Expanded(
                  child: Button.filled(
                    onPressed: () {
                      context.push(const GeneralInformationPage());
                    },
                    label: 'Next',
                    height: rh(context, 50),
                    borderRadius: rw(context, 8),
                    disabled: !_isFormValid(),
                    color: _isFormValid()
                        ? AppColors.primary500
                        : Colors.grey[300]!,
                    textColor: _isFormValid()
                        ? Colors.white
                        : Colors.grey[600]!,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDateTimePicker() async {
    final pickedStart = await showAppDateTimePicker(
      context,
      initialDate: DateTime.now(),
      title: 'Select Visit Date & Time',
      withTime: true,
    );

    if (pickedStart != null && mounted) {
      final formattedDate = "${pickedStart.day}/${pickedStart.month}/${pickedStart.year}";
      final startStr = "${pickedStart.hour.toString().padLeft(2, '0')}:${pickedStart.minute.toString().padLeft(2, '0')}";
      final endDt = pickedStart.add(const Duration(hours: 1));
      final endStr = "${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}";

      setState(() {
        visitTimeController.text = "$formattedDate, $startStr - $endStr";
      });
    }
  }
}

// SearchableDropdown Widget - Adopted from FilterBottomSheet
class SearchableDropdown extends StatefulWidget {
  final String? value;
  final List<String> items;
  final String hintText;
  final String labelText;
  final ValueChanged<String?> onChanged;

  const SearchableDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hintText,
    required this.labelText,
    required this.onChanged,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  late TextEditingController _controller;
  List<String> filteredItems = [];
  bool isDropdownOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    filteredItems = widget.items;

    // Listen to focus changes to handle overlay positioning
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !isDropdownOpen) {
        _showOverlay();
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = widget.items;
      } else {
        filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
    _updateOverlay();
  }

  void _toggleDropdown() {
    if (isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => isDropdownOpen = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => isDropdownOpen = false);
  }

  void _updateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    // Calculate item height (48 px per item)
    double itemHeight = rh(context, 48);
    double listHeight =
        (filteredItems.isEmpty ? rh(context, 48) : filteredItems.length * itemHeight)
            .clamp(0, rh(context, 200))
            .toDouble();

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + rh(context, 5.0)),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(rw(context, 8)),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: listHeight),
              child: filteredItems.isEmpty
                  ? Container(
                      alignment: Alignment.center,
                      height: rh(context, 48),
                      padding: EdgeInsets.symmetric(horizontal: rw(context, 16)),
                      child: const Text(
                        'No destination found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return InkWell(
                          onTap: () {
                            _controller.text = item;
                            widget.onChanged(item);
                            _focusNode.unfocus();
                            _removeOverlay();
                          },
                          child: Container(
                            height: itemHeight,
                            padding: EdgeInsets.symmetric(horizontal: rw(context, 16)),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              border: index < filteredItems.length - 1
                                  ? Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 0.5,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Text(
                              item,
                              style: TextStyle(fontSize: rfs(context, 16)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          filled: true,
          fillColor: const Color(0xffF2F8FD),
          contentPadding: EdgeInsets.symmetric(
            horizontal: rw(context, 12),
            vertical: rh(context, 16),
          ),
          suffixIcon: GestureDetector(
            onTap: _toggleDropdown,
            child: Icon(
              isDropdownOpen
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rw(context, 8)),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: _filterItems,
        onTap: () {
          if (!isDropdownOpen) {
            _showOverlay();
          }
        },
      ),
    );
  }
}
