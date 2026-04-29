import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/core.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedGedung;

  final List<String> gedungList = [
    'Gedung HQ',
    'Gedung A',
    'Gedung B',
    'Gedung C',
    'Gedung D',
    'Gedung E',
    'Tower 1',
    'Tower 2',
    'Main Building',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Padding bottom sesuai dengan keyboard height
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Rentang Tanggal
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        locale: const Locale('id', 'ID'),
                      );
                      if (picked != null) {
                        setState(() => startDate = picked);
                      }
                    },
                    child: FilterDateBox(
                      title: "Dari Tanggal",
                      value: startDate != null
                          ? DateFormat(
                              'dd MMM yyyy',
                              'id_ID',
                            ).format(startDate!)
                          : "Pilih tanggal",
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          locale: const Locale('id', 'ID'),
                        );
                        if (picked != null) {
                          setState(() => endDate = picked);
                        }
                      },
                      child: FilterDateBox(
                        title: "Sampai Tanggal",
                        value: endDate != null
                            ? DateFormat(
                                'dd MMM yyyy',
                                'id_ID',
                              ).format(endDate!)
                            : "Pilih tanggal",
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Searchable Dropdown Gedung
            SearchableDropdown(
              value: selectedGedung,
              items: gedungList,
              hintText: 'Pilih Gedung',
              labelText: 'Gedung',
              onChanged: (value) => setState(() => selectedGedung = value),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'startDate': startDate,
                    'endDate': endDate,
                    'gedung': selectedGedung,
                  });
                },
                child: const Text(
                  'Pasang filter',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    if (mounted) {
      setState(() => isDropdownOpen = false);
    }
  }

  void _updateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    // Hitung tinggi item (misal 48 px per item)
    double itemHeight = 48;
    double listHeight =
        (filteredItems.isEmpty ? 48 : filteredItems.length * itemHeight)
            .clamp(0, 200)
            .toDouble();

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: listHeight),
              child: filteredItems.isEmpty
                  ? Container(
                      alignment: Alignment.center,
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text(
                        'Tidak ada data ditemukan',
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              style: const TextStyle(fontSize: 16),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
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
            borderRadius: BorderRadius.circular(8),
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

class FilterDateBox extends StatelessWidget {
  final String title;
  final String value;

  const FilterDateBox({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyles.subtitle2),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xffF2F8FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: TextStyles.bodySmall400),
        ),
      ],
    );
  }
}
