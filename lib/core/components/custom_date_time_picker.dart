import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Function to show the standardized App Date & Time Picker
/// Based on desktop/tablet VMS design, optimized for Mobile Portrait screens.
Future<DateTime?> showAppDateTimePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? minDateTime,
  DateTime? maxDateTime,
  String? title,
  bool withTime = true,
  bool showNowButton = true,
}) {
  return showDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => AppDateTimePickerDialog(
      initialDate: initialDate,
      minDateTime: minDateTime,
      maxDateTime: maxDateTime,
      title: title ?? (withTime ? 'Select Date & Time' : 'Select Date'),
      withTime: withTime,
      showNowButton: showNowButton,
    ),
  );
}

class AppDateTimePickerDialog extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? minDateTime;
  final DateTime? maxDateTime;
  final String title;
  final bool withTime;
  final bool showNowButton;

  const AppDateTimePickerDialog({
    super.key,
    this.initialDate,
    this.minDateTime,
    this.maxDateTime,
    required this.title,
    this.withTime = true,
    this.showNowButton = true,
  });

  @override
  State<AppDateTimePickerDialog> createState() => _AppDateTimePickerDialogState();
}

class _AppDateTimePickerDialogState extends State<AppDateTimePickerDialog> {
  late DateTime liveTime;
  Timer? tickerTimer;

  late DateTime selectedDate;
  int? selectedHour;
  int? selectedMinute;

  // 0: Date tab, 1: Time tab (used in portrait mobile view)
  int _activeTab = 0;

  final ScrollController hourScrollController = ScrollController();
  final ScrollController minuteScrollController = ScrollController();

  DateTime _getGmt7Now() {
    return DateTime.now().toUtc().add(const Duration(hours: 7));
  }

  @override
  void initState() {
    super.initState();
    final gmt7Now = _getGmt7Now();
    liveTime = gmt7Now;

    selectedDate = widget.initialDate ??
        (widget.minDateTime != null && widget.minDateTime!.isAfter(gmt7Now)
            ? widget.minDateTime!
            : gmt7Now);

    if (widget.withTime) {
      selectedHour = widget.initialDate?.hour ?? (widget.minDateTime != null && isSameDayAsMin(selectedDate) ? widget.minDateTime!.hour : gmt7Now.hour);
      selectedMinute = widget.initialDate?.minute ?? (widget.minDateTime != null && isSameDayAsMin(selectedDate) ? widget.minDateTime!.minute : gmt7Now.minute);

      // Pastikan jam/menit tidak sebelum minDateTime
      _validateHourAndMinute();
    }

    tickerTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          liveTime = _getGmt7Now();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedTime(animated: false);
    });
  }

  @override
  void dispose() {
    tickerTimer?.cancel();
    hourScrollController.dispose();
    minuteScrollController.dispose();
    super.dispose();
  }

  bool isSameDayAsMin(DateTime date) {
    if (widget.minDateTime == null) return false;
    return date.year == widget.minDateTime!.year &&
        date.month == widget.minDateTime!.month &&
        date.day == widget.minDateTime!.day;
  }

  void _validateHourAndMinute() {
    if (!widget.withTime || widget.minDateTime == null) return;
    if (isSameDayAsMin(selectedDate)) {
      if (selectedHour != null && selectedHour! < widget.minDateTime!.hour) {
        selectedHour = widget.minDateTime!.hour;
      }
      if (selectedMinute != null &&
          selectedHour == widget.minDateTime!.hour &&
          selectedMinute! < widget.minDateTime!.minute) {
        selectedMinute = widget.minDateTime!.minute;
      }
    }
  }

  void _scrollToSelectedTime({bool animated = true}) {
    if (!widget.withTime) return;
    final h = selectedHour;
    final m = selectedMinute;

    if (h != null && hourScrollController.hasClients) {
      final targetH = ((h * 38.0) - 92.0).clamp(0.0, hourScrollController.position.maxScrollExtent);
      if (animated) {
        hourScrollController.animateTo(targetH, duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic);
      } else {
        hourScrollController.jumpTo(targetH);
      }
    }

    if (m != null && minuteScrollController.hasClients) {
      final targetM = ((m * 38.0) - 92.0).clamp(0.0, minuteScrollController.position.maxScrollExtent);
      if (animated) {
        minuteScrollController.animateTo(targetM, duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic);
      } else {
        minuteScrollController.jumpTo(targetM);
      }
    }
  }

  DateTime? get _currentResult {
    if (!widget.withTime) {
      return DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    }
    if (selectedHour == null || selectedMinute == null) return null;
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedHour!,
      selectedMinute!,
    );
  }

  bool get _isSelectionValid {
    final res = _currentResult;
    if (res == null) return false;
    if (widget.minDateTime != null) {
      if (widget.withTime) {
        if (res.isBefore(widget.minDateTime!)) return false;
      } else {
        final minDateOnly = DateTime(widget.minDateTime!.year, widget.minDateTime!.month, widget.minDateTime!.day);
        if (res.isBefore(minDateOnly)) return false;
      }
    }
    if (widget.maxDateTime != null) {
      if (res.isAfter(widget.maxDateTime!)) return false;
    }
    return true;
  }

  String _formatLiveClock() {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final dayName = days[liveTime.weekday % 7];
    final monthName = months[liveTime.month - 1];
    final h = liveTime.hour.toString().padLeft(2, '0');
    final m = liveTime.minute.toString().padLeft(2, '0');
    final s = liveTime.second.toString().padLeft(2, '0');
    return '$dayName, ${liveTime.day} $monthName ${liveTime.year}, $h:$m:$s';
  }

  String _formatSelectedDateShort() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${selectedDate.day} ${months[selectedDate.month - 1]} ${selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 620;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        width: isWideScreen ? 670 : 380,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── HEADER ────────────────────────────────────────────────────────
            _buildHeader(isWideScreen),

            // ── TAB SWITCHER (Portrait Mobile only when withTime == true) ──────
            if (!isWideScreen && widget.withTime) _buildTabSwitcher(),

            // ── CONTENT BODY ──────────────────────────────────────────────────
            Flexible(
              child: isWideScreen
                  ? _buildWideContent()
                  : _buildMobileContent(),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

            // ── FOOTER ────────────────────────────────────────────────────────
            _buildFooter(isWideScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isWide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: isWide
          ? Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF004385)),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                ),
                const Spacer(),
                _buildLiveClockBadge(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF004385)),
                        const SizedBox(width: 8),
                        Text(
                          widget.title,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildLiveClockBadge(),
              ],
            ),
    );
  }

  Widget _buildLiveClockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_filled_rounded, size: 13, color: Color(0xFF004385)),
          const SizedBox(width: 5),
          Text(
            _formatLiveClock(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF004385),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    final hasSelectedTime = selectedHour != null && selectedMinute != null;
    final timeDisplay = hasSelectedTime
        ? '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}'
        : '--:--';

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeTab = 0),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _activeTab == 0 ? const Color(0xFF004385) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _activeTab == 0
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 15,
                      color: _activeTab == 0 ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        _formatSelectedDateShort(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: _activeTab == 0 ? FontWeight.w700 : FontWeight.w500,
                          color: _activeTab == 0 ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _activeTab = 1);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToSelectedTime();
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _activeTab == 1 ? const Color(0xFF004385) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _activeTab == 1
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: _activeTab == 1 ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Time: $timeDisplay',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: _activeTab == 1 ? FontWeight.w700 : FontWeight.w500,
                        color: _activeTab == 1 ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 11,
            child: _buildCalendar(),
          ),
          if (widget.withTime) ...[
            Container(
              width: 1,
              height: 290,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: const Color(0xFFE2E8F0),
            ),
            Expanded(
              flex: 10,
              child: _buildTimePickerSection(height: 230),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileContent() {
    if (!widget.withTime || _activeTab == 0) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: _buildCalendar(),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
        child: _buildTimePickerSection(height: 250),
      );
    }
  }

  Widget _buildCalendar() {
    final firstDt = widget.minDateTime != null
        ? DateTime(widget.minDateTime!.year, widget.minDateTime!.month, widget.minDateTime!.day)
        : DateTime(2020);
    final lastDt = widget.maxDateTime != null
        ? DateTime(widget.maxDateTime!.year, widget.maxDateTime!.month, widget.maxDateTime!.day)
        : DateTime(2035);

    DateTime validSelected = selectedDate;
    if (validSelected.isBefore(firstDt)) validSelected = firstDt;
    if (validSelected.isAfter(lastDt)) validSelected = lastDt;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF004385),
          onPrimary: Colors.white,
          onSurface: Color(0xFF1E293B),
        ),
      ),
      child: CalendarDatePicker(
        key: ValueKey('${validSelected.year}-${validSelected.month}-${validSelected.day}'),
        initialDate: validSelected,
        firstDate: firstDt,
        lastDate: lastDt,
        onDateChanged: (newDate) {
          setState(() {
            selectedDate = newDate;
            _validateHourAndMinute();
          });
        },
      ),
    );
  }

  Widget _buildTimePickerSection({required double height}) {
    final isSameDay = isSameDayAsMin(selectedDate);
    final hasSelectedTime = selectedHour != null && selectedMinute != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selected Time: ',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                hasSelectedTime
                    ? '${selectedHour.toString().padLeft(2, '0')} : ${selectedMinute.toString().padLeft(2, '0')}'
                    : '-- : -- (Not selected)',
                style: GoogleFonts.inter(
                  fontSize: hasSelectedTime ? 14.5 : 12.5,
                  fontWeight: hasSelectedTime ? FontWeight.w800 : FontWeight.w600,
                  color: hasSelectedTime ? const Color(0xFF004385) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Hour (24h)',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Minute',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: height,
          child: Row(
            children: [
              // HOUR COLUMN
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: RawScrollbar(
                    controller: hourScrollController,
                    thumbVisibility: true,
                    thickness: 3.5,
                    radius: const Radius.circular(4),
                    thumbColor: const Color(0xFF94A3B8),
                    child: ListView.builder(
                      controller: hourScrollController,
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      itemCount: 24,
                      itemBuilder: (ctx, h) {
                        final isHourDisabled = isSameDay && widget.minDateTime != null && h < widget.minDateTime!.hour;
                        final isSelected = selectedHour == h;

                        return SizedBox(
                          height: 38,
                          child: Center(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: isHourDisabled
                                  ? null
                                  : () {
                                      setState(() {
                                        selectedHour = h;
                                        selectedMinute ??= 0;
                                        if (isSameDay && widget.minDateTime != null && h == widget.minDateTime!.hour) {
                                          if (selectedMinute! < widget.minDateTime!.minute) {
                                            selectedMinute = widget.minDateTime!.minute;
                                          }
                                        }
                                      });
                                      if (hourScrollController.hasClients) {
                                        hourScrollController.animateTo(
                                          ((h * 38.0) - 92.0).clamp(0.0, hourScrollController.position.maxScrollExtent),
                                          duration: const Duration(milliseconds: 250),
                                          curve: Curves.easeOutCubic,
                                        );
                                      }
                                    },
                              child: Container(
                                width: double.infinity,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF004385)
                                      : (isHourDisabled ? const Color(0xFFF1F5F9) : Colors.transparent),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  h.toString().padLeft(2, '0'),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : (isHourDisabled ? FontWeight.w400 : FontWeight.w600),
                                    color: isSelected
                                        ? Colors.white
                                        : (isHourDisabled ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // MINUTE COLUMN
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: RawScrollbar(
                    controller: minuteScrollController,
                    thumbVisibility: true,
                    thickness: 3.5,
                    radius: const Radius.circular(4),
                    thumbColor: const Color(0xFF94A3B8),
                    child: ListView.builder(
                      controller: minuteScrollController,
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      itemCount: 60,
                      itemBuilder: (ctx, m) {
                        final isMinuteDisabled = isSameDay &&
                            widget.minDateTime != null &&
                            selectedHour != null &&
                            selectedHour == widget.minDateTime!.hour &&
                            m < widget.minDateTime!.minute;
                        final isSelected = selectedMinute == m;

                        return SizedBox(
                          height: 38,
                          child: Center(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: isMinuteDisabled
                                  ? null
                                  : () {
                                      setState(() {
                                        selectedMinute = m;
                                        selectedHour ??= isSameDay && widget.minDateTime != null ? widget.minDateTime!.hour : 9;
                                      });
                                      if (minuteScrollController.hasClients) {
                                        minuteScrollController.animateTo(
                                          ((m * 38.0) - 92.0).clamp(0.0, minuteScrollController.position.maxScrollExtent),
                                          duration: const Duration(milliseconds: 250),
                                          curve: Curves.easeOutCubic,
                                        );
                                      }
                                    },
                              child: Container(
                                width: double.infinity,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF004385)
                                      : (isMinuteDisabled ? const Color(0xFFF1F5F9) : Colors.transparent),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  m.toString().padLeft(2, '0'),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : (isMinuteDisabled ? FontWeight.w400 : FontWeight.w600),
                                    color: isSelected
                                        ? Colors.white
                                        : (isMinuteDisabled ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isWide) {
    final isMobileDateTimeStep0 = !isWide && widget.withTime && _activeTab == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (widget.showNowButton)
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFEFF6FF),
                foregroundColor: const Color(0xFF004385),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {
                final nowGmt7 = _getGmt7Now();
                setState(() {
                  selectedDate = DateTime(nowGmt7.year, nowGmt7.month, nowGmt7.day);
                  if (widget.withTime) {
                    selectedHour = nowGmt7.hour;
                    selectedMinute = nowGmt7.minute;
                  }
                });
                _scrollToSelectedTime();
              },
              child: Text(
                'Today',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          const Spacer(),
          if (!isWide && widget.withTime && _activeTab == 1)
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              onPressed: () => setState(() => _activeTab = 0),
              child: Text(
                'Back',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            )
          else
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          const SizedBox(width: 8),
          if (isMobileDateTimeStep0)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004385),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              ),
              onPressed: () {
                setState(() => _activeTab = 1);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToSelectedTime();
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Next',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 14),
                ],
              ),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSelectionValid ? const Color(0xFF004385) : const Color(0xFFE2E8F0),
                foregroundColor: _isSelectionValid ? Colors.white : const Color(0xFF94A3B8),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              ),
              onPressed: _isSelectionValid
                  ? () => Navigator.of(context).pop(_currentResult)
                  : null,
              child: Text(
                'OK',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}
