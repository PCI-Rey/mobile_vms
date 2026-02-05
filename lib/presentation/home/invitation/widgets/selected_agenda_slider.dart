import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/core.dart';
import '../../../../data/datasources/agenda_datasource.dart';
import '../../../../data/models/agenda_model.dart';
import 'selected_agenda_card.dart';

class SelectableAgendaSlider extends StatefulWidget {
  final Function(AgendaModel?)? onAgendaSelected;
  final AgendaModel? selectedAgenda;
  
  const SelectableAgendaSlider({
    super.key,
    this.onAgendaSelected,
    this.selectedAgenda,
  });

  @override
  State<StatefulWidget> createState() {
    return _SelectableAgendaSliderState();
  }
}

class _SelectableAgendaSliderState extends State<SelectableAgendaSlider> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Enhanced responsive breakpoints
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isTablet = screenWidth >= 600;
    final isLargeTablet = screenWidth >= 800;

    final List<Widget> imageSliders = dummyAgendas
        .map(
          (agenda) => Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(
              bottom: isSmallScreen ? 4 : isMediumScreen ? 6 : 8,
              right: isSmallScreen ? 6 : isMediumScreen ? 10 : 12,
              left: isSmallScreen ? 2 : 4,
            ),
            child: SelectableAgendaCard(
              title: agenda.destination,
              description: agenda.jenis,
              timeRange:
                  "${formatTime(agenda.visitStart)} - ${formatTime(agenda.visitEnd)}",
              date: formatDate(agenda.visitStart),
              image: Assets.images.avaBuilding.image(
                height: isSmallScreen ? 110 : isMediumScreen ? 130 : 160,
                fit: BoxFit.cover,
              ),
              picName: agenda.picOrHost,
              isSelectable: true,
              isSelected: widget.selectedAgenda?.id == agenda.id,
              onSelectionChanged: () {
                // Toggle selection
                if (widget.selectedAgenda?.id == agenda.id) {
                  // Deselect if already selected
                  widget.onAgendaSelected?.call(null);
                } else {
                  // Select this agenda
                  widget.onAgendaSelected?.call(agenda);
                }
              },
            ),
          ),
        )
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Agenda',
                style: TextStyles.bodyMedium.copyWith(
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              if (widget.selectedAgenda != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Selected',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        CarouselSlider(
          items: imageSliders,
          carouselController: _controller,
          options: CarouselOptions(
            height: _getCarouselHeight(screenHeight, isSmallScreen, isMediumScreen, isTablet),
            autoPlay: false, // Disabled for better UX when selecting
            enlargeCenterPage: !isSmallScreen,
            enlargeFactor: isTablet ? 0.2 : 0.3,
            viewportFraction: _getViewportFraction(isSmallScreen, isMediumScreen, isTablet, isLargeTablet),
            enableInfiniteScroll: dummyAgendas.length > 1,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        
        // Dot indicators with responsive sizing
        if (dummyAgendas.length > 1)
          _buildDotIndicators(isSmallScreen, isMediumScreen, isTablet),
      ],
    );
  }

  double _getCarouselHeight(double screenHeight, bool isSmallScreen, bool isMediumScreen, bool isTablet) {
    if (isSmallScreen) {
      return screenHeight * 0.32;
    } else if (isMediumScreen) {
      return screenHeight * 0.35;
    } else if (isTablet) {
      return screenHeight * 0.42;
    } else {
      return screenHeight * 0.40;
    }
  }

  double _getViewportFraction(bool isSmallScreen, bool isMediumScreen, bool isTablet, bool isLargeTablet) {
    if (isSmallScreen) {
      return 0.92;
    } else if (isMediumScreen) {
      return 0.88;
    } else if (isTablet && !isLargeTablet) {
      return 0.75;
    } else if (isLargeTablet) {
      return 0.65;
    } else {
      return 0.85;
    }
  }

  Widget _buildDotIndicators(bool isSmallScreen, bool isMediumScreen, bool isTablet) {
    final activeWidth = isSmallScreen ? 20.0 : isMediumScreen ? 24.0 : 28.0;
    final inactiveSize = isSmallScreen ? 6.0 : isMediumScreen ? 8.0 : 10.0;
    final indicatorHeight = inactiveSize;
    final horizontalMargin = isSmallScreen ? 2.0 : isMediumScreen ? 3.0 : 4.0;
    final verticalPadding = isSmallScreen ? 6.0 : isMediumScreen ? 8.0 : 10.0;

    return Container(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: dummyAgendas.asMap().entries.map((entry) {
          final isActive = _current == entry.key;
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: isActive ? activeWidth : inactiveSize,
              height: indicatorHeight,
              margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(indicatorHeight / 2),
                color: isActive 
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor.withOpacity(0.3),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}