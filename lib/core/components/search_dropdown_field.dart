import 'package:flutter/material.dart';
import 'dart:async';

import '../core.dart';

class SearchableDropdownField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final List<String> items;
  final bool showLabel;
  final Widget? prefixIcon;
  final String? errorText;
  final ValueChanged<String>? onSelected;

  const SearchableDropdownField({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    required this.items,
    this.showLabel = true,
    this.prefixIcon,
    this.errorText,
    this.onSelected,
  });

  @override
  State<SearchableDropdownField> createState() =>
      _SearchableDropdownFieldState();
}

class _SearchableDropdownFieldState extends State<SearchableDropdownField> {
  List<String> filteredItems = [];
  bool isDropdownOpen = false;
  late FocusNode _focusNode;
  OverlayEntry? _overlayEntry;
  Timer? _debounceTimer;
  String _lastSearchTerm = '';

  @override
  void initState() {
    super.initState();
    filteredItems = List.from(widget.items);
    widget.controller.addListener(_onChanged);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        Timer(const Duration(milliseconds: 150), () {
          if (!_focusNode.hasFocus) {
            _closeDropdown();
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant SearchableDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filterItems(widget.controller.text);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _closeDropdown();
    super.dispose();
  }

  void _onChanged() {
    final text = widget.controller.text;
    if (text == _lastSearchTerm) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (text != _lastSearchTerm && mounted) {
        _lastSearchTerm = text;
        _filterItems(text);

        if (text.isNotEmpty && !isDropdownOpen) {
          _openDropdown();
        } else if (text.isEmpty && isDropdownOpen) {
          filteredItems = List.from(widget.items);
          _updateOverlay();
        }
      }
    });
  }

  void _filterItems(String text) {
    final value = text.trim().toLowerCase();

    List<String> newFilteredItems;
    if (value.isEmpty) {
      newFilteredItems = List.from(widget.items);
    } else {
      newFilteredItems = widget.items
          .where((item) => item.toLowerCase().contains(value))
          .toList();
    }

    if (_isDifferentList(filteredItems, newFilteredItems)) {
      filteredItems = newFilteredItems;
      _updateOverlay();
    }
  }

  bool _isDifferentList(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return true;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return true;
    }
    return false;
  }

  void _updateOverlay() {
    if (mounted && isDropdownOpen && _overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _openDropdown() {
    if (isDropdownOpen || _overlayEntry != null) return;

    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildDropdownOverlay(offset, size),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      isDropdownOpen = true;
    });
  }

  Widget _buildDropdownOverlay(Offset offset, Size size) {
    return Positioned(
      left: offset.dx,
      top: offset.dy + size.height,
      width: size.width,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxHeight: 300,
            minHeight: filteredItems.isEmpty ? 60 : 0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildDropdownContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownContent() {
    if (filteredItems.isEmpty) {
      return Container(
        height: 60,
        alignment: Alignment.center,
        child: const Text(
          'Tidak ditemukan',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: filteredItems.length,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildDropdownItem(item);
      },
    );
  }

  Widget _buildDropdownItem(String item) {
    final searchTerm = widget.controller.text.toLowerCase();
    final itemLower = item.toLowerCase();

    return InkWell(
      onTap: () => _selectItem(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: searchTerm.isNotEmpty && itemLower.contains(searchTerm)
                  ? _buildHighlightedText(item, searchTerm)
                  : Text(item, style: const TextStyle(fontSize: 14)),
            ),
            if (item == widget.controller.text)
              const Icon(Icons.check, color: Colors.blue, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String searchTerm) {
    final startIndex = text.toLowerCase().indexOf(searchTerm);
    final matchLength = searchTerm.length;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, startIndex),
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
          TextSpan(
            text: text.substring(startIndex, startIndex + matchLength),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          TextSpan(
            text: text.substring(startIndex + matchLength),
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  void _closeDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    if (mounted && isDropdownOpen) {
      setState(() {
        isDropdownOpen = false;
      });
    }
  }

  void _selectItem(String item) {
    _debounceTimer?.cancel();

    widget.controller.removeListener(_onChanged);
    widget.controller.text = item;
    widget.controller.selection = TextSelection.collapsed(offset: item.length);
    widget.controller.addListener(_onChanged);

    _lastSearchTerm = item;

    _closeDropdown();

    // ✅ Callback untuk aksi tambahan
    widget.onSelected?.call(item);

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  void _toggleDropdown() {
    if (isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        if (widget.showLabel) ...[
          Text(
            widget.label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          onTap: () {
            if (!isDropdownOpen) {
              _openDropdown();
            }
          },
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon,
            hintText: widget.hintText,
            filled: true,
            fillColor: AppColors.primary50,
            contentPadding: const EdgeInsets.all(12.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.grey300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            suffixIcon: GestureDetector(
              onTap: _toggleDropdown,
              child: AnimatedRotation(
                turns: isDropdownOpen ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
            ),
          ),
          style: const TextStyle(fontSize: 16),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
