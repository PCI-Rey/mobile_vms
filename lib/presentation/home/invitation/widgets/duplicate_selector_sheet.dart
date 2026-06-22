import 'package:flutter/material.dart';
import '../../../../core/helper/responsive_helper.dart';

class DuplicateSelectorSheet extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final String Function(dynamic item) nameExtractor;
  final bool Function(dynamic item, String query) searchMatcher;
  final ValueChanged<dynamic> onSelected;
  final bool dismissOnSelect;
  final String? badgeUnit;

  const DuplicateSelectorSheet({
    super.key,
    required this.title,
    required this.items,
    required this.nameExtractor,
    required this.searchMatcher,
    required this.onSelected,
    this.dismissOnSelect = true,
    this.badgeUnit,
  });

  static void show({
    required BuildContext context,
    required String title,
    required List<dynamic> items,
    required String Function(dynamic item) nameExtractor,
    required bool Function(dynamic item, String query) searchMatcher,
    required ValueChanged<dynamic> onSelected,
    bool dismissOnSelect = true,
    String? badgeUnit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DuplicateSelectorSheet(
        title: title,
        items: items,
        nameExtractor: nameExtractor,
        searchMatcher: searchMatcher,
        onSelected: onSelected,
        dismissOnSelect: dismissOnSelect,
        badgeUnit: badgeUnit,
      ),
    );
  }

  @override
  State<DuplicateSelectorSheet> createState() => _DuplicateSelectorSheetState();
}

class _DuplicateSelectorSheetState extends State<DuplicateSelectorSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic> _filteredItems = [];
  bool _isLoading = false;

  // Deeper, saturated colors for the initial letter text
  static const List<Color> _presetColors = [
    Color(0xFF1565C0), // blue
    Color(0xFF00796B), // teal
    Color(0xFFC2185B), // pink/rose
    Color(0xFF7B1FA2), // purple
    Color(0xFF546E7A), // blue-grey
    Color(0xFFE64A19), // deep orange
    Color(0xFF388E3C), // green
    Color(0xFF0277BD), // light-blue
  ];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      _filteredItems = query.isEmpty
          ? widget.items
          : widget.items
              .where((item) => widget.searchMatcher(item, query))
              .toList();
    });
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      final first = parts[0];
      final second = parts[1];
      if (first.isNotEmpty && second.isNotEmpty) {
        return (first[0] + second[0]).toUpperCase();
      }
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final double sh = MediaQuery.of(context).size.height * 0.75;
    final paddingBottom = MediaQuery.of(context).viewInsets.bottom;

    return Stack(
      children: [
        Container(
          height: sh + paddingBottom,
          padding: EdgeInsets.only(bottom: paddingBottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header title & Close
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: rfs(context, 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (widget.badgeUnit != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F51B5).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF3F51B5).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          '${_filteredItems.length} ${widget.badgeUnit}',
                          style: TextStyle(
                            color: const Color(0xFF3F51B5),
                            fontSize: rfs(context, 12),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: rw(context, 32),
                        height: rw(context, 32),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: rw(context, 16),
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(color: Colors.grey.shade800),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              // Divider
              Container(height: 1, color: Colors.grey.shade100),

              // Grid List
              Expanded(
                child: _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No matches found',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: rfs(context, 14),
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final name = widget.nameExtractor(item);
                          final initials = _getInitials(name);

                          // Pick a color cycling through the preset palette
                          final baseColor = (name.isEmpty || name == '?')
                              ? Colors.grey
                              : _presetColors[index % _presetColors.length];

                          // Pastel background: very light tint of base color
                          final bgColor = baseColor.withValues(alpha: 0.12);

                          return GestureDetector(
                            onTap: () async {
                              if (_isLoading) return;
                              final navigator = Navigator.of(context);
                              setState(() => _isLoading = true);
                              try {
                                final Function onSel = widget.onSelected;
                                final dynamic res = onSel(item);
                                if (res is Future) {
                                  await res;
                                }
                              } catch (e) {
                                debugPrint('Error onSelected duplicate item: $e');
                              } finally {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                              if (widget.dismissOnSelect && mounted) {
                                navigator.pop();
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: rw(context, 64),
                                  height: rw(context, 64),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      initials,
                                      style: TextStyle(
                                        color: baseColor,
                                        fontSize: rfs(context, 20),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  name.isNotEmpty ? name : 'Visitor',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // Absorb taps
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
